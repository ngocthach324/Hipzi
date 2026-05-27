package com.hipzi.service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

public class SupabaseStorageService {
    private static final String DEFAULT_PROJECT_REF = "aryzajaqbxbqpsjxjtmz";
    private static final String DEFAULT_BUCKET = "classroom-private-files";

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final String supabaseUrl;
    private final String apiKey;
    private final String bucketName;

    public SupabaseStorageService() {
        this.supabaseUrl = trimTrailingSlash(firstConfigured(
                "SUPABASE_URL",
                "supabase.url",
                "https://" + DEFAULT_PROJECT_REF + ".supabase.co"
        ));
        this.apiKey = firstConfigured("SUPABASE_SERVICE_ROLE_KEY", "supabase.serviceRoleKey", null);
        this.bucketName = firstConfigured("SUPABASE_STORAGE_BUCKET", "supabase.storage.bucket", DEFAULT_BUCKET);
    }

    public boolean isConfigured() {
        return supabaseUrl != null && !supabaseUrl.isBlank()
                && apiKey != null && !apiKey.isBlank()
                && bucketName != null && !bucketName.isBlank();
    }

    public String getBucketName() {
        return bucketName;
    }

    public void uploadObject(String objectPath, byte[] bytes, String contentType)
            throws IOException, InterruptedException {
        requireConfigured();
        String normalizedContentType = contentType == null || contentType.isBlank()
                ? "application/octet-stream"
                : contentType;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(supabaseUrl + "/storage/v1/object/" + encodePath(bucketName) + "/" + encodePath(objectPath)))
                .header("apikey", apiKey)
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", normalizedContentType)
                .header("cache-control", "3600")
                .header("x-upsert", "false")
                .POST(HttpRequest.BodyPublishers.ofByteArray(bytes))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IOException("Supabase Storage upload failed: HTTP " + response.statusCode() + " - " + response.body());
        }
    }

    public void deleteObject(String objectPath) throws IOException, InterruptedException {
        requireConfigured();
        String body = "{\"prefixes\":[\"" + jsonEscape(objectPath) + "\"]}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(supabaseUrl + "/storage/v1/object/" + encodePath(bucketName)))
                .header("apikey", apiKey)
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .method("DELETE", HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IOException("Supabase Storage delete failed: HTTP " + response.statusCode() + " - " + response.body());
        }
    }

    public String createSignedUrl(String objectPath, int expiresInSeconds)
            throws IOException, InterruptedException {
        requireConfigured();
        int expiresIn = Math.max(60, Math.min(expiresInSeconds, 604800));
        String body = "{\"expiresIn\":" + expiresIn + "}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(supabaseUrl + "/storage/v1/object/sign/" + encodePath(bucketName) + "/" + encodePath(objectPath)))
                .header("apikey", apiKey)
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IOException("Supabase Storage signed URL failed: HTTP " + response.statusCode() + " - " + response.body());
        }
        String signedUrl = extractJsonString(response.body(), "signedURL");
        if (signedUrl == null || signedUrl.isBlank()) {
            signedUrl = extractJsonString(response.body(), "signedUrl");
        }
        if (signedUrl == null || signedUrl.isBlank()) {
            throw new IOException("Supabase Storage signed URL response missing signedURL: " + response.body());
        }
        if (signedUrl.startsWith("/")) {
            return supabaseUrl + "/storage/v1" + signedUrl;
        }
        return signedUrl;
    }

    private void requireConfigured() {
        if (!isConfigured()) {
            throw new IllegalStateException("Missing Supabase Storage config. Set SUPABASE_SERVICE_ROLE_KEY and optionally SUPABASE_URL/SUPABASE_STORAGE_BUCKET.");
        }
    }

    private String encodePath(String path) {
        String[] parts = path.split("/");
        StringBuilder encoded = new StringBuilder();
        for (int i = 0; i < parts.length; i++) {
            if (i > 0) encoded.append('/');
            encoded.append(URLEncoder.encode(parts[i], StandardCharsets.UTF_8).replace("+", "%20"));
        }
        return encoded.toString();
    }

    private String extractJsonString(String json, String key) {
        String marker = "\"" + key + "\"";
        int keyIndex = json.indexOf(marker);
        if (keyIndex < 0) return null;
        int colonIndex = json.indexOf(':', keyIndex + marker.length());
        if (colonIndex < 0) return null;
        int startQuote = json.indexOf('"', colonIndex + 1);
        if (startQuote < 0) return null;
        StringBuilder value = new StringBuilder();
        boolean escaped = false;
        for (int i = startQuote + 1; i < json.length(); i++) {
            char ch = json.charAt(i);
            if (escaped) {
                value.append(ch);
                escaped = false;
            } else if (ch == '\\') {
                escaped = true;
            } else if (ch == '"') {
                return value.toString();
            } else {
                value.append(ch);
            }
        }
        return null;
    }

    private String jsonEscape(String value) {
        return value == null ? "" : value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String firstConfigured(String envName, String propertyName, String fallback) {
        String value = System.getenv(envName);
        if (value == null || value.isBlank()) {
            value = System.getProperty(propertyName);
        }
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private String trimTrailingSlash(String value) {
        if (value == null) return null;
        while (value.endsWith("/")) {
            value = value.substring(0, value.length() - 1);
        }
        return value.toLowerCase(Locale.ROOT).startsWith("http") ? value : "https://" + value;
    }
}
