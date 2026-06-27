package com.hipzi.controller;

import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.AuthService;
import com.hipzi.util.OAuthUriHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.Base64;
import java.util.List;

@WebServlet(name = "GoogleOAuthServlet", urlPatterns = {"/auth/google", "/auth/google/callback"})
public class GoogleOAuthServlet extends HttpServlet {

    private static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    private static final String GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    private final AuthService authService = new AuthService();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(12))
            .build();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/auth/google/callback".equals(path)) {
            handleCallback(request, response);
        } else {
            startLogin(request, response);
        }
    }

    private void startLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String clientId = config("GOOGLE_CLIENT_ID");
        String clientSecret = config("GOOGLE_CLIENT_SECRET");
        if (isBlank(clientId) || isBlank(clientSecret)) {
            redirectWithOAuthError(request, response,
                    "Google OAuth chưa được cấu hình. Vui lòng thiết lập GOOGLE_CLIENT_ID và GOOGLE_CLIENT_SECRET.");
            return;
        }

        HttpSession session = request.getSession(true);
        String state = generateState();
        session.setAttribute("google_oauth_state", state);

        String redirectUri = callbackUri(request);
        String authUrl = GOOGLE_AUTH_URL
                + "?client_id=" + encode(clientId)
                + "&redirect_uri=" + encode(redirectUri)
                + "&response_type=code"
                + "&scope=" + encode("openid email profile")
                + "&state=" + encode(state)
                + "&prompt=select_account";

        response.sendRedirect(authUrl);
    }

    private void handleCallback(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String error = request.getParameter("error");
        if (!isBlank(error)) {
            redirectWithOAuthError(request, response, "Google đã hủy hoặc từ chối đăng nhập.");
            return;
        }

        String expectedState = (String) session.getAttribute("google_oauth_state");
        session.removeAttribute("google_oauth_state");
        String actualState = request.getParameter("state");
        if (isBlank(expectedState) || !expectedState.equals(actualState)) {
            redirectWithOAuthError(request, response, "Phiên đăng nhập Google không hợp lệ. Vui lòng thử lại.");
            return;
        }

        String code = request.getParameter("code");
        if (isBlank(code)) {
            redirectWithOAuthError(request, response, "Google chưa trả về mã xác thực. Vui lòng thử lại.");
            return;
        }

        try {
            String tokenJson = exchangeCodeForToken(request, code);
            String accessToken = extractJsonString(tokenJson, "access_token");
            if (isBlank(accessToken)) {
                throw new IllegalStateException("Không nhận được access token từ Google.");
            }

            String profileJson = fetchGoogleProfile(accessToken);
            String sub = extractJsonString(profileJson, "sub");
            String email = extractJsonString(profileJson, "email");
            String name = extractJsonString(profileJson, "name");
            String picture = extractJsonString(profileJson, "picture");
            boolean emailVerified = extractJsonBoolean(profileJson, "email_verified");

            if (isBlank(sub) || isBlank(email)) {
                throw new IllegalStateException("Google không trả về đủ thông tin tài khoản.");
            }
            if (!emailVerified) {
                throw new IllegalStateException("Email Google của bạn chưa được xác minh.");
            }
            if (isBlank(name)) {
                name = email;
            }

            User user = authService.loginOrRegisterWithOAuth("google", sub, email, name, picture);
            session.setAttribute("loggedUser", user);

            if (!user.isOnboardingCompleted()) {
                response.sendRedirect(request.getContextPath() + "/onboarding");
                return;
            }

            String redirectUrl = (String) session.getAttribute("redirectUrl");
            if (redirectUrl != null) {
                session.removeAttribute("redirectUrl");
                response.sendRedirect(redirectUrl);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/index");
        } catch (Exception ex) {
            redirectWithOAuthError(request, response, ex.getMessage());
        }
    }

    private String exchangeCodeForToken(HttpServletRequest request, String code) throws IOException, InterruptedException {
        String form = "code=" + encode(code)
                + "&client_id=" + encode(config("GOOGLE_CLIENT_ID"))
                + "&client_secret=" + encode(config("GOOGLE_CLIENT_SECRET"))
                + "&redirect_uri=" + encode(callbackUri(request))
                + "&grant_type=authorization_code";

        HttpRequest tokenRequest = HttpRequest.newBuilder(URI.create(GOOGLE_TOKEN_URL))
                .timeout(Duration.ofSeconds(20))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(form))
                .build();

        HttpResponse<String> tokenResponse = httpClient.send(tokenRequest, HttpResponse.BodyHandlers.ofString());
        if (tokenResponse.statusCode() < 200 || tokenResponse.statusCode() >= 300) {
            throw new IllegalStateException("Không thể xác thực với Google. Vui lòng kiểm tra OAuth redirect URI.");
        }
        return tokenResponse.body();
    }

    private String fetchGoogleProfile(String accessToken) throws IOException, InterruptedException {
        HttpRequest profileRequest = HttpRequest.newBuilder(URI.create(GOOGLE_USERINFO_URL))
                .timeout(Duration.ofSeconds(20))
                .header("Authorization", "Bearer " + accessToken)
                .GET()
                .build();

        HttpResponse<String> profileResponse = httpClient.send(profileRequest, HttpResponse.BodyHandlers.ofString());
        if (profileResponse.statusCode() < 200 || profileResponse.statusCode() >= 300) {
            throw new IllegalStateException("Không thể lấy thông tin tài khoản Google.");
        }
        return profileResponse.body();
    }

    private void redirectWithOAuthError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        request.getSession(true).setAttribute("oauth_error", message);
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private String callbackUri(HttpServletRequest request) {
        return OAuthUriHelper.callbackUri(request, config("GOOGLE_REDIRECT_URI"), "/auth/google/callback");
    }

    private String config(String name) {
        String value = getServletContext().getInitParameter(name);
        if (isBlank(value)) {
            value = getServletContext().getInitParameter(name.toLowerCase().replace('_', '.'));
        }
        if (isBlank(value)) {
            value = System.getenv(name);
        }
        return value;
    }

    private String generateState() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String firstNonBlank(String first, String second) {
        return isBlank(first) ? second : first;
    }

    private String profilePathFromRoles(List<Role> roles) {
        if (roles != null) {
            boolean hasParent = false;
            boolean hasTeacher = false;
            boolean hasStaff = false;
            boolean hasAdmin = false;
            for (Role role : roles) {
                if (role == null || role.getName() == null) continue;
                String roleName = role.getName().toLowerCase();
                if ("parent".equals(roleName)) hasParent = true;
                if ("teacher".equals(roleName)) hasTeacher = true;
                if ("staff".equals(roleName)) hasStaff = true;
                if ("admin".equals(roleName)) hasAdmin = true;
            }
            if (hasAdmin) return "/admin-profile";
            if (hasStaff) return "/staff-profile";
            if (hasTeacher) return "/teacher-profile";
            if (hasParent) return "/parent-profile";
        }
        return "/student-profile";
    }

    private String extractJsonString(String json, String key) {
        if (json == null || key == null) return null;
        String quotedKey = "\"" + key + "\"";
        int keyIndex = json.indexOf(quotedKey);
        if (keyIndex < 0) return null;
        int colonIndex = json.indexOf(':', keyIndex + quotedKey.length());
        if (colonIndex < 0) return null;
        int index = colonIndex + 1;
        while (index < json.length() && Character.isWhitespace(json.charAt(index))) index++;
        if (index >= json.length() || json.charAt(index) != '"') return null;
        index++;

        StringBuilder value = new StringBuilder();
        while (index < json.length()) {
            char current = json.charAt(index++);
            if (current == '"') {
                return value.toString();
            }
            if (current == '\\' && index < json.length()) {
                char escaped = json.charAt(index++);
                switch (escaped) {
                    case '"': value.append('"'); break;
                    case '\\': value.append('\\'); break;
                    case '/': value.append('/'); break;
                    case 'b': value.append('\b'); break;
                    case 'f': value.append('\f'); break;
                    case 'n': value.append('\n'); break;
                    case 'r': value.append('\r'); break;
                    case 't': value.append('\t'); break;
                    case 'u':
                        if (index + 4 <= json.length()) {
                            String hex = json.substring(index, index + 4);
                            value.append((char) Integer.parseInt(hex, 16));
                            index += 4;
                        }
                        break;
                    default:
                        value.append(escaped);
                        break;
                }
            } else {
                value.append(current);
            }
        }
        return null;
    }

    private boolean extractJsonBoolean(String json, String key) {
        if (json == null || key == null) return false;
        String quotedKey = "\"" + key + "\"";
        int keyIndex = json.indexOf(quotedKey);
        if (keyIndex < 0) return false;
        int colonIndex = json.indexOf(':', keyIndex + quotedKey.length());
        if (colonIndex < 0) return false;
        int index = colonIndex + 1;
        while (index < json.length() && Character.isWhitespace(json.charAt(index))) index++;
        return json.startsWith("true", index);
    }
}
