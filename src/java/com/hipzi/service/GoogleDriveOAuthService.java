package com.hipzi.service;

import com.hipzi.dao.TeacherGoogleAccountDao;
import com.hipzi.model.TeacherGoogleAccount;
import com.hipzi.util.SimpleJson;
import com.hipzi.util.TokenCrypto;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;

public class GoogleDriveOAuthService {
    public static final String DRIVE_SCOPE = "openid email profile https://www.googleapis.com/auth/drive.file";

    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";
    private static final String DRIVE_FILE_URL = "https://www.googleapis.com/drive/v3/files/";

    private final TeacherGoogleAccountDao accountDao = new TeacherGoogleAccountDao();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(12))
            .build();

    public TeacherGoogleAccount connectTeacher(
            String teacherId,
            String code,
            String redirectUri,
            String clientId,
            String clientSecret,
            String encryptionKey
    ) throws IOException, InterruptedException {
        Map<String, Object> tokenJson = exchangeCodeForToken(code, redirectUri, clientId, clientSecret);
        String accessToken = SimpleJson.asString(tokenJson, "access_token");
        String refreshToken = SimpleJson.asString(tokenJson, "refresh_token");
        String scope = SimpleJson.asString(tokenJson, "scope");
        long expiresIn = asLong(tokenJson.get("expires_in"), 3600L);

        if (isBlank(accessToken)) {
            throw new IllegalStateException("Google khong tra ve access token.");
        }
        if (isBlank(refreshToken) && accountDao.findActiveByTeacherId(teacherId) == null) {
            throw new IllegalStateException("Google chua tra ve refresh token. Hay thu ket noi lai va chap nhan quyen truy cap offline.");
        }

        Map<String, Object> profileJson = fetchProfile(accessToken);
        String googleUserId = SimpleJson.asString(profileJson, "sub");
        String googleEmail = SimpleJson.asString(profileJson, "email");
        if (isBlank(googleUserId) || isBlank(googleEmail)) {
            throw new IllegalStateException("Khong doc duoc thong tin tai khoan Google Drive.");
        }

        TeacherGoogleAccount account = new TeacherGoogleAccount();
        account.setTeacherId(teacherId);
        account.setGoogleUserId(googleUserId);
        account.setGoogleEmail(googleEmail);
        account.setScope(isBlank(scope) ? DRIVE_SCOPE : scope);
        account.setAccessTokenEncrypted(TokenCrypto.encrypt(accessToken, encryptionKey));
        account.setRefreshTokenEncrypted(TokenCrypto.encrypt(refreshToken, encryptionKey));
        account.setTokenExpiresAt(Timestamp.from(Instant.now().plusSeconds(Math.max(60, expiresIn - 60))));

        if (!accountDao.upsert(account)) {
            throw new IllegalStateException("Khong luu duoc ket noi Google Drive.");
        }
        return accountDao.findActiveByTeacherId(teacherId);
    }

    public String accessTokenForTeacher(String teacherId, String clientId, String clientSecret, String encryptionKey)
            throws IOException, InterruptedException {
        TeacherGoogleAccount account = accountDao.findActiveByTeacherId(teacherId);
        if (account == null || !account.isConnected()) {
            throw new IllegalStateException("Giang vien chua ket noi Google Drive.");
        }
        if (account.getTokenExpiresAt() != null && account.getTokenExpiresAt().toInstant().isAfter(Instant.now().plusSeconds(90))) {
            return TokenCrypto.decrypt(account.getAccessTokenEncrypted(), encryptionKey);
        }

        String refreshToken = TokenCrypto.decrypt(account.getRefreshTokenEncrypted(), encryptionKey);
        Map<String, Object> tokenJson = refreshAccessToken(refreshToken, clientId, clientSecret);
        String accessToken = SimpleJson.asString(tokenJson, "access_token");
        long expiresIn = asLong(tokenJson.get("expires_in"), 3600L);
        if (isBlank(accessToken)) {
            throw new IllegalStateException("Khong refresh duoc access token Google Drive.");
        }

        Timestamp expiresAt = Timestamp.from(Instant.now().plusSeconds(Math.max(60, expiresIn - 60)));
        accountDao.updateAccessToken(teacherId, TokenCrypto.encrypt(accessToken, encryptionKey), expiresAt);
        return accessToken;
    }

    public void verifyShareableResource(String accessToken, String driveId) throws IOException, InterruptedException {
        if (isBlank(driveId)) {
            return;
        }
        String url = DRIVE_FILE_URL + encodePath(driveId) + "?fields=id,name,mimeType,capabilities/canShare";
        HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                .timeout(Duration.ofSeconds(20))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("Không tìm thấy file/folder Google Drive. HTTP " + response.statusCode() + " - Chi tiết: " + response.body());
        }
        Map<String, Object> json = SimpleJson.asObject(SimpleJson.parse(response.body()));
        Map<String, Object> capabilities = SimpleJson.asObject(json.get("capabilities"));
        Object canShare = capabilities.get("canShare");
        if (!(canShare instanceof Boolean) || !((Boolean) canShare)) {
            throw new IllegalStateException("Tai khoan Google Drive da ket noi chua co quyen chia se file/folder nay.");
        }
    }

    public String createReaderPermission(String accessToken, String driveId, String emailAddress)
            throws IOException, InterruptedException {
        if (isBlank(accessToken) || isBlank(driveId) || isBlank(emailAddress)) {
            throw new IllegalArgumentException("Thieu thong tin cap quyen Google Drive.");
        }

        String url = DRIVE_FILE_URL + encodePath(driveId)
                + "/permissions?sendNotificationEmail=true&fields=id";
        String body = "{"
                + "\"type\":\"user\","
                + "\"role\":\"reader\","
                + "\"emailAddress\":" + jsonString(emailAddress)
                + "}";

        HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                .timeout(Duration.ofSeconds(25))
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("Khong cap duoc quyen Google Drive. HTTP "
                    + response.statusCode() + " - " + response.body());
        }

        Map<String, Object> json = SimpleJson.asObject(SimpleJson.parse(response.body()));
        String permissionId = SimpleJson.asString(json, "id");
        if (isBlank(permissionId)) {
            throw new IllegalStateException("Google Drive khong tra ve permission id.");
        }
        return permissionId;
    }

    public boolean revokeTeacher(String teacherId) {
        return accountDao.revoke(teacherId);
    }

    private Map<String, Object> exchangeCodeForToken(String code, String redirectUri, String clientId, String clientSecret)
            throws IOException, InterruptedException {
        String form = "code=" + encode(code)
                + "&client_id=" + encode(clientId)
                + "&client_secret=" + encode(clientSecret)
                + "&redirect_uri=" + encode(redirectUri)
                + "&grant_type=authorization_code";
        return postFormForJson(GOOGLE_TOKEN_URL, form, "Khong the xac thuc Google Drive. Kiem tra redirect URI.");
    }

    private Map<String, Object> refreshAccessToken(String refreshToken, String clientId, String clientSecret)
            throws IOException, InterruptedException {
        String form = "refresh_token=" + encode(refreshToken)
                + "&client_id=" + encode(clientId)
                + "&client_secret=" + encode(clientSecret)
                + "&grant_type=refresh_token";
        return postFormForJson(GOOGLE_TOKEN_URL, form, "Khong the refresh Google Drive token.");
    }

    private Map<String, Object> postFormForJson(String url, String form, String errorMessage)
            throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder(URI.create(url))
                .timeout(Duration.ofSeconds(20))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form))
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException(errorMessage);
        }
        return SimpleJson.asObject(SimpleJson.parse(response.body()));
    }

    private Map<String, Object> fetchProfile(String accessToken) throws IOException, InterruptedException {
        HttpRequest request = HttpRequest.newBuilder(URI.create(GOOGLE_USERINFO_URL))
                .timeout(Duration.ofSeconds(20))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("Khong lay duoc thong tin Google profile.");
        }
        return SimpleJson.asObject(SimpleJson.parse(response.body()));
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private String encodePath(String value) {
        return encode(value).replace("+", "%20");
    }

    private String jsonString(String value) {
        if (value == null) {
            return "null";
        }
        return "\"" + value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t")
                + "\"";
    }

    private long asLong(Object value, long fallback) {
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (Exception e) {
            return fallback;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
