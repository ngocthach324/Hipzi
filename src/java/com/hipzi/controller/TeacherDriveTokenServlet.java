package com.hipzi.controller;

import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.GoogleDriveOAuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Trả về access token Google Drive (đã refresh nếu cần) dưới dạng JSON
 * để JavaScript frontend có thể khởi tạo Google Picker.
 *
 * GET /teacher-drive/token
 * Response: {"accessToken":"...","clientId":"..."}
 */
@WebServlet(name = "TeacherDriveTokenServlet", urlPatterns = {"/teacher-drive/token"})
public class TeacherDriveTokenServlet extends HttpServlet {

    private final GoogleDriveOAuthService driveOAuthService = new GoogleDriveOAuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Chua dang nhap.\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (!hasRole(user, "teacher") && !hasRole(user, "admin")) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Chi giang vien moi co the su dung Google Picker.\"}");
            return;
        }

        String clientId = config(request, "GOOGLE_CLIENT_ID");
        String clientSecret = config(request, "GOOGLE_CLIENT_SECRET");
        String encryptionKey = tokenEncryptionKey(request);

        if (isBlank(clientId) || isBlank(clientSecret)) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"error\":\"Google OAuth chua duoc cau hinh tren server.\"}");
            return;
        }

        try {
            String accessToken = driveOAuthService.accessTokenForTeacher(
                    user.getId(), clientId, clientSecret, encryptionKey);

            String json = "{\"accessToken\":" + jsonString(accessToken)
                    + ",\"clientId\":" + jsonString(clientId) + "}";
            response.getWriter().write(json);

        } catch (IllegalStateException e) {
            // Giang vien chua ket noi Drive hoac token bi revoke
            response.setStatus(HttpServletResponse.SC_PRECONDITION_FAILED);
            response.getWriter().write("{\"error\":" + jsonString(
                    e.getMessage() != null ? e.getMessage() : "Chua ket noi Google Drive.") + "}");
        } catch (Exception e) {
            System.err.println("TeacherDriveTokenServlet error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Khong lay duoc token Google Drive. Vui long thu lai.\"}");
        }
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) {
            return false;
        }
        for (Role role : user.getRoles()) {
            if (role != null && role.getName() != null && roleName.equalsIgnoreCase(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private String config(HttpServletRequest request, String name) {
        String value = getServletContext().getInitParameter(name);
        if (isBlank(value)) {
            value = getServletContext().getInitParameter(name.toLowerCase().replace('_', '.'));
        }
        if (isBlank(value)) {
            value = System.getenv(name);
        }
        return value;
    }

    private String tokenEncryptionKey(HttpServletRequest request) {
        String value = config(request, "HIPZI_TOKEN_ENCRYPTION_KEY");
        return isBlank(value) ? config(request, "TOKEN_ENCRYPTION_KEY") : value;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Tạo chuỗi JSON string an toàn, escape các ký tự đặc biệt.
     */
    private String jsonString(String value) {
        if (value == null) {
            return "null";
        }
        return "\"" + value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t") + "\"";
    }
}
