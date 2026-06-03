package com.hipzi.service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class B2StorageService {
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final String keyId;
    private final String applicationKey;
    private final String bucketId;
    private final String bucketName;

    private String apiUrl;
    private String authorizationToken;
    private String downloadUrl;
    private long tokenFetchTime = 0;

    public B2StorageService() {
        this.keyId = firstConfigured("B2_KEY_ID", "b2.keyId", "005d1da2364bf810000000001");
        this.applicationKey = firstConfigured("B2_APP_KEY", "b2.appKey", "K005DNR13tK8CoNzUkdj5Dc7M5hIxbo");
        this.bucketId = firstConfigured("B2_BUCKET_ID", "b2.bucketId", "ed110d3ab2a386c49bef0811");
        this.bucketName = firstConfigured("B2_BUCKET_NAME", "b2.bucketName", "hipzi-edu-storage");
    }

    public boolean isConfigured() {
        return !keyId.equals("REPLACE_ME") && !applicationKey.equals("REPLACE_ME") && !bucketId.equals("REPLACE_ME");
    }

    public String getBucketName() {
        return bucketName;
    }

    private synchronized void authorize() throws IOException, InterruptedException {
        // Cache token for 12 hours
        if (authorizationToken != null && (System.currentTimeMillis() - tokenFetchTime) < 12 * 3600 * 1000L) {
            return;
        }

        String authString = keyId + ":" + applicationKey;
        String basicAuth = Base64.getEncoder().encodeToString(authString.getBytes(StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.backblazeb2.com/b2api/v3/b2_authorize_account"))
                .header("Authorization", "Basic " + basicAuth)
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() != 200) {
            throw new IOException("B2 auth failed: HTTP " + response.statusCode() + " - " + response.body());
        }

        this.apiUrl = extractJsonString(response.body(), "apiUrl");
        this.authorizationToken = extractJsonString(response.body(), "authorizationToken");
        this.downloadUrl = extractJsonString(response.body(), "downloadUrl");
        this.tokenFetchTime = System.currentTimeMillis();
    }

    public void uploadObject(String objectPath, byte[] bytes, String contentType) throws IOException, InterruptedException {
        if (!isConfigured()) return;
        authorize();

        int maxRetries = 3;
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                // 1. Get upload URL
                String getUploadUrlBody = "{\"bucketId\":\"" + bucketId + "\"}";
                HttpRequest uploadUrlRequest = HttpRequest.newBuilder()
                        .uri(URI.create(apiUrl + "/b2api/v3/b2_get_upload_url"))
                        .header("Authorization", authorizationToken)
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(getUploadUrlBody, StandardCharsets.UTF_8))
                        .build();

                HttpResponse<String> uploadUrlResp = httpClient.send(uploadUrlRequest, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (uploadUrlResp.statusCode() != 200) {
                    throw new IOException("B2 get_upload_url failed: HTTP " + uploadUrlResp.statusCode());
                }

                String uploadUrl = extractJsonString(uploadUrlResp.body(), "uploadUrl");
                String uploadAuthToken = extractJsonString(uploadUrlResp.body(), "authorizationToken");

                // 2. Upload the file
                String normalizedContentType = contentType == null || contentType.isBlank() ? "b2/x-auto" : contentType;
                
                HttpRequest uploadRequest = HttpRequest.newBuilder()
                        .uri(URI.create(uploadUrl))
                        .header("Authorization", uploadAuthToken)
                        .header("X-Bz-File-Name", encodePath(objectPath))
                        .header("Content-Type", normalizedContentType)
                        .header("X-Bz-Content-Sha1", "do_not_verify")
                        .POST(HttpRequest.BodyPublishers.ofByteArray(bytes))
                        .build();

                HttpResponse<String> uploadResp = httpClient.send(uploadRequest, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (uploadResp.statusCode() != 200) {
                    if ((uploadResp.statusCode() == 503 || uploadResp.statusCode() == 429) && attempt < maxRetries) {
                        Thread.sleep(1000L * attempt);
                        continue;
                    }
                    throw new IOException("B2 upload failed: HTTP " + uploadResp.statusCode() + " - " + uploadResp.body());
                }
                break; // success
            } catch (IOException e) {
                if (attempt == maxRetries) throw e;
                Thread.sleep(1000L * attempt);
            }
        }
    }

    public void deleteObject(String objectPath) throws IOException, InterruptedException {
        if (!isConfigured()) return;
        // Simplified delete: normally B2 needs fileId. To get fileId we need to list file names.
        // For simple integration, if we just want to hide it, we can use b2_hide_file, or we can use Supabase since deleting on B2 without fileId is a 2-step process.
        // Let's implement b2_hide_file which only requires bucketId and fileName
        authorize();
        String hideBody = "{\"bucketId\":\"" + bucketId + "\", \"fileName\":\"" + objectPath + "\"}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(apiUrl + "/b2api/v3/b2_hide_file"))
                .header("Authorization", authorizationToken)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(hideBody, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() >= 400 && response.statusCode() != 404 && response.statusCode() != 400) {
            throw new IOException("B2 hide_file failed: HTTP " + response.statusCode());
        }
    }

    public String createSignedUrl(String objectPath, int expiresInSeconds) throws IOException, InterruptedException {
        if (!isConfigured()) return "";
        authorize();
        int expiresIn = Math.max(60, Math.min(expiresInSeconds, 604800));

        String body = "{\"bucketId\":\"" + bucketId + "\", \"fileNamePrefix\":\"" + objectPath + "\", \"validDurationInSeconds\":" + expiresIn + "}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(apiUrl + "/b2api/v3/b2_get_download_authorization"))
                .header("Authorization", authorizationToken)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() != 200) {
            throw new IOException("B2 get_download_authorization failed: " + response.body());
        }

        String downloadAuthToken = extractJsonString(response.body(), "authorizationToken");
        return downloadUrl + "/file/" + bucketName + "/" + encodePath(objectPath) + "?Authorization=" + downloadAuthToken;
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

    private String firstConfigured(String envName, String propertyName, String fallback) {
        String value = System.getenv(envName);
        if (value == null || value.isBlank()) {
            value = System.getProperty(propertyName);
        }
        return value == null || value.isBlank() ? fallback : value.trim();
    }
}
