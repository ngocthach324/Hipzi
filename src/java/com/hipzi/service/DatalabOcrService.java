package com.hipzi.service;

import com.hipzi.util.SimpleJson;
import java.io.ByteArrayOutputStream;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

public class DatalabOcrService implements OcrProvider {
    private static final String DEFAULT_CONVERT_URL = "https://www.datalab.to/api/v1/convert";
    private static final int DEFAULT_MAX_WAIT_SECONDS = 90;
    private static final int POLL_INTERVAL_MILLIS = 2500;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(20))
            .build();

    @Override
    public OcrResult extract(byte[] fileBytes, String contentType, String fileName) throws Exception {
        String apiKey = env("DATALAB_API_KEY", "");
        if (apiKey.isEmpty()) {
            throw new IllegalStateException("DATALAB_API_KEY is not configured.");
        }
        if (fileBytes == null || fileBytes.length == 0) {
            throw new IllegalArgumentException("OCR source file is empty.");
        }

        String convertUrl = env("DATALAB_CONVERT_URL", env("HIPZI_DATALAB_CONVERT_URL", DEFAULT_CONVERT_URL));
        Map<String, Object> submitResponse = submitConvertRequest(convertUrl, apiKey, fileBytes,
                normalizeContentType(contentType), safeFileName(fileName));

        OcrResult immediateResult = toOcrResult(submitResponse);
        if (immediateResult.hasText()) {
            return immediateResult;
        }

        String requestId = firstString(submitResponse, "request_id", "requestId", "id");
        if (requestId.isEmpty()) {
            String error = firstString(submitResponse, "error", "message", "detail");
            throw new IllegalStateException(error.isEmpty()
                    ? "Datalab OCR response did not include output or request_id."
                    : "Datalab OCR error: " + error);
        }

        String requestCheckUrl = firstString(submitResponse, "request_check_url", "requestCheckUrl");
        if (requestCheckUrl.isEmpty()) {
            requestCheckUrl = deriveCheckUrl(convertUrl, requestId);
        }
        OcrResult polledResult = pollResult(requestCheckUrl, apiKey, requestId);
        polledResult.setRequestId(requestId);
        return polledResult;
    }

    private Map<String, Object> submitConvertRequest(
            String url, String apiKey, byte[] fileBytes, String contentType, String fileName) throws Exception {
        String boundary = "----HipziDatalabBoundary" + UUID.randomUUID().toString().replace("-", "");
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(60))
                .header("X-Api-Key", apiKey)
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(buildMultipartBody(boundary, fileBytes, contentType, fileName))
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        return parseDatalabResponse(response);
    }

    private HttpRequest.BodyPublisher buildMultipartBody(
            String boundary, byte[] fileBytes, String contentType, String fileName) throws Exception {
        List<byte[]> parts = new ArrayList<>();
        addTextPart(parts, boundary, "mode", env("HIPZI_DATALAB_MODE", "balanced"));
        addTextPart(parts, boundary, "output_format", env("HIPZI_DATALAB_OUTPUT_FORMAT", "markdown,json"));
        addTextPart(parts, boundary, "paginate", env("HIPZI_DATALAB_PAGINATE", "false"));
        addTextPart(parts, boundary, "include_markdown_in_chunks", env("HIPZI_DATALAB_INCLUDE_MARKDOWN_IN_CHUNKS", "true"));
        addTextPart(parts, boundary, "disable_image_extraction", env("HIPZI_DATALAB_DISABLE_IMAGE_EXTRACTION", "true"));
        addFilePart(parts, boundary, "file", fileName, contentType, fileBytes);
        parts.add(("--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
        return HttpRequest.BodyPublishers.ofByteArrays(parts);
    }

    private void addTextPart(List<byte[]> parts, String boundary, String name, String value) {
        String part = "--" + boundary + "\r\n"
                + "Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n"
                + (value == null ? "" : value) + "\r\n";
        parts.add(part.getBytes(StandardCharsets.UTF_8));
    }

    private void addFilePart(
            List<byte[]> parts, String boundary, String name, String fileName,
            String contentType, byte[] fileBytes) throws Exception {
        ByteArrayOutputStream header = new ByteArrayOutputStream();
        header.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        header.write(("Content-Disposition: form-data; name=\"" + name + "\"; filename=\""
                + escapeFileName(fileName) + "\"\r\n").getBytes(StandardCharsets.UTF_8));
        header.write(("Content-Type: " + contentType + "\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        parts.add(header.toByteArray());
        parts.add(fileBytes);
        parts.add("\r\n".getBytes(StandardCharsets.UTF_8));
    }

    private OcrResult pollResult(String checkUrl, String apiKey, String requestId) throws Exception {
        long deadline = System.currentTimeMillis() + maxWaitSeconds() * 1000L;
        while (System.currentTimeMillis() < deadline) {
            Map<String, Object> response = checkRequestByGet(checkUrl, apiKey);
            String error = firstString(response, "error", "message", "detail");
            if (!error.isEmpty() && isFailureStatus(response)) {
                throw new IllegalStateException("Datalab OCR error: " + error);
            }
            OcrResult result = toOcrResult(response);
            if (result.hasText()) {
                return result;
            }
            if (isFailureStatus(response)) {
                throw new IllegalStateException(error.isEmpty()
                        ? "Datalab OCR failed for request " + requestId + "."
                        : "Datalab OCR error: " + error);
            }
            Thread.sleep(POLL_INTERVAL_MILLIS);
        }
        throw new IllegalStateException("Datalab OCR timeout while waiting for request " + requestId + ".");
    }

    private Map<String, Object> checkRequestByGet(String checkUrl, String apiKey) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(checkUrl))
                .timeout(Duration.ofSeconds(30))
                .header("X-Api-Key", apiKey)
                .GET()
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        return parseDatalabResponse(response);
    }

    private Map<String, Object> parseDatalabResponse(HttpResponse<String> response) {
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("Datalab API error " + response.statusCode() + ": " + response.body());
        }
        Object parsed = SimpleJson.parse(response.body());
        Map<String, Object> root = SimpleJson.asObject(parsed);
        if (root.isEmpty() && parsed instanceof String) {
            root.put("text", parsed);
        }
        return root;
    }

    private OcrResult toOcrResult(Map<String, Object> response) {
        OcrResult result = new OcrResult();
        result.setProvider("datalab");
        result.setRequestId(firstString(response, "request_id", "requestId", "id"));

        String markdown = firstScalarString(response, "markdown", "md", "output");
        String plainText = firstScalarString(response, "text", "plain_text", "plainText", "ocr_text", "full_text");
        if (markdown.isEmpty()) {
            markdown = markdownFromNested(response);
        }
        if (plainText.isEmpty()) {
            plainText = textFromNested(response);
        }
        if (plainText.isEmpty() && !markdown.isEmpty()) {
            plainText = stripMarkdown(markdown);
        }
        if (markdown.isEmpty() && !plainText.isEmpty()) {
            markdown = plainText;
        }

        result.setMarkdown(markdown);
        result.setPlainText(plainText);
        result.setLayoutJson(layoutFromResponse(response));
        return result;
    }

    private String markdownFromNested(Object value) {
        StringBuilder sb = new StringBuilder();
        collectNestedStrings(value, sb, Arrays.asList("markdown", "md", "output"));
        return sb.toString().trim();
    }

    private String textFromNested(Object value) {
        StringBuilder sb = new StringBuilder();
        collectNestedStrings(value, sb, Arrays.asList("text", "plain_text", "plainText", "ocr_text", "full_text"));
        return sb.toString().trim();
    }

    @SuppressWarnings("unchecked")
    private void collectNestedStrings(Object value, StringBuilder sb, List<String> keys) {
        if (value instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) value;
            for (String key : keys) {
                Object item = map.get(key);
                if (item instanceof String && !((String) item).trim().isEmpty()) {
                    appendBlock(sb, (String) item);
                }
            }
            for (Object item : map.values()) {
                if (!(item instanceof String)) {
                    collectNestedStrings(item, sb, keys);
                }
            }
        } else if (value instanceof Iterable) {
            for (Object item : (Iterable<?>) value) {
                collectNestedStrings(item, sb, keys);
            }
        }
    }

    private String layoutFromResponse(Map<String, Object> response) {
        for (String key : Arrays.asList("layout", "pages", "blocks", "chunks", "metadata")) {
            Object value = response.get(key);
            if (value != null) {
                return SimpleJson.stringify(value);
            }
        }
        return "";
    }

    private boolean isFailureStatus(Map<String, Object> response) {
        String status = firstString(response, "status", "state").toLowerCase(Locale.ROOT);
        Object success = response.get("success");
        if (success instanceof Boolean && !((Boolean) success)) {
            return true;
        }
        return status.equals("failed") || status.equals("failure") || status.equals("error");
    }

    private String firstString(Map<String, Object> map, String... keys) {
        if (map == null) {
            return "";
        }
        for (String key : keys) {
            Object value = map.get(key);
            if (value != null) {
                String stringValue = String.valueOf(value).trim();
                if (!stringValue.isEmpty() && !"null".equalsIgnoreCase(stringValue)) {
                    return stringValue;
                }
            }
        }
        return "";
    }

    private String firstScalarString(Map<String, Object> map, String... keys) {
        if (map == null) {
            return "";
        }
        for (String key : keys) {
            Object value = map.get(key);
            if (value instanceof String || value instanceof Number || value instanceof Boolean) {
                String stringValue = String.valueOf(value).trim();
                if (!stringValue.isEmpty() && !"null".equalsIgnoreCase(stringValue)) {
                    return stringValue;
                }
            }
        }
        return "";
    }

    private String stripMarkdown(String value) {
        return value == null ? "" : value
                .replaceAll("(?m)^#{1,6}\\s*", "")
                .replaceAll("(?m)^\\s*[-*+]\\s+", "- ")
                .replaceAll("[*_`]+", "")
                .trim();
    }

    private void appendBlock(StringBuilder sb, String value) {
        String cleaned = value == null ? "" : value.trim();
        if (cleaned.isEmpty()) {
            return;
        }
        if (sb.length() > 0) {
            sb.append("\n\n");
        }
        sb.append(cleaned);
    }

    private String deriveCheckUrl(String submitUrl, String requestId) {
        String cleanedUrl = submitUrl == null || submitUrl.trim().isEmpty()
                ? DEFAULT_CONVERT_URL
                : submitUrl.trim();
        String separator = cleanedUrl.endsWith("/") ? "" : "/";
        return cleanedUrl + separator + URLEncoder.encode(requestId, StandardCharsets.UTF_8);
    }

    private String safeFileName(String fileName) {
        String cleaned = fileName == null ? "" : fileName.trim();
        if (cleaned.isEmpty()) {
            return "hipzi-ocr-source.pdf";
        }
        return cleaned.replaceAll("[\\\\/\\r\\n\"]", "_");
    }

    private String escapeFileName(String fileName) {
        return safeFileName(fileName).replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String normalizeContentType(String contentType) {
        String cleaned = contentType == null ? "" : contentType.trim();
        return cleaned.isEmpty() ? "application/octet-stream" : cleaned;
    }

    private int maxWaitSeconds() {
        try {
            int parsed = Integer.parseInt(env("HIPZI_DATALAB_MAX_WAIT_SECONDS", String.valueOf(DEFAULT_MAX_WAIT_SECONDS)));
            return parsed > 0 ? parsed : DEFAULT_MAX_WAIT_SECONDS;
        } catch (NumberFormatException e) {
            return DEFAULT_MAX_WAIT_SECONDS;
        }
    }

    private String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }
}
