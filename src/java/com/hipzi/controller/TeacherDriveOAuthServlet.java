package com.hipzi.controller;

import com.hipzi.model.Role;
import com.hipzi.model.TeacherGoogleAccount;
import com.hipzi.model.User;
import com.hipzi.service.GoogleDriveOAuthService;
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
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet(name = "TeacherDriveOAuthServlet", urlPatterns = {
        "/teacher-drive/connect",
        "/teacher-drive/callback",
        "/teacher-drive/disconnect"
})
public class TeacherDriveOAuthServlet extends HttpServlet {
    private static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth";

    private final GoogleDriveOAuthService driveOAuthService = new GoogleDriveOAuthService();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireTeacher(request, response);
        if (user == null) {
            return;
        }

        String path = request.getServletPath();
        if ("/teacher-drive/callback".equals(path)) {
            handleCallback(request, response, user);
        } else {
            startConnect(request, response, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requireTeacher(request, response);
        if (user == null) {
            return;
        }
        if ("/teacher-drive/disconnect".equals(request.getServletPath())) {
            if (driveOAuthService.revokeTeacher(user.getId())) {
                setToast(request, "Da ngat ket noi Google Drive.", "success");
            } else {
                setToast(request, "Khong tim thay ket noi Google Drive de ngat.", "error");
            }
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
            return;
        }
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void startConnect(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String clientId = config(request, "GOOGLE_CLIENT_ID");
        String clientSecret = config(request, "GOOGLE_CLIENT_SECRET");
        if (isBlank(clientId) || isBlank(clientSecret)) {
            setToast(request, "Google OAuth chua duoc cau hinh.", "error");
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
            return;
        }

        HttpSession session = request.getSession(true);
        String state = generateState();
        session.setAttribute("teacher_drive_oauth_state", state);

        String authUrl = GOOGLE_AUTH_URL
                + "?client_id=" + encode(clientId)
                + "&redirect_uri=" + encode(callbackUri(request))
                + "&response_type=code"
                + "&scope=" + encode(GoogleDriveOAuthService.DRIVE_SCOPE)
                + "&state=" + encode(state)
                + "&access_type=offline"
                + "&include_granted_scopes=true"
                + "&prompt=" + encode("consent select_account");

        response.sendRedirect(authUrl);
    }

    private void handleCallback(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String error = request.getParameter("error");
        if (!isBlank(error)) {
            setToast(request, "Google da huy hoac tu choi ket noi Drive.", "error");
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
            return;
        }

        String expectedState = (String) session.getAttribute("teacher_drive_oauth_state");
        session.removeAttribute("teacher_drive_oauth_state");
        String actualState = request.getParameter("state");
        if (isBlank(expectedState) || !expectedState.equals(actualState)) {
            setToast(request, "Phien ket noi Google Drive khong hop le. Hay thu lai.", "error");
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
            return;
        }

        String code = request.getParameter("code");
        if (isBlank(code)) {
            setToast(request, "Google chua tra ve ma xac thuc Drive.", "error");
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
            return;
        }

        try {
            TeacherGoogleAccount account = driveOAuthService.connectTeacher(
                    user.getId(),
                    code,
                    callbackUri(request),
                    config(request, "GOOGLE_CLIENT_ID"),
                    config(request, "GOOGLE_CLIENT_SECRET"),
                    tokenEncryptionKey(request)
            );
            setToast(request, "Da ket noi Google Drive: " + account.getGoogleEmail(), "success");
        } catch (Exception e) {
            setToast(request, e.getMessage() != null ? e.getMessage() : "Khong ket noi duoc Google Drive.", "error");
        }
        response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=course-registration");
    }

    private User requireTeacher(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("loggedUser");
        if (!hasRole(user, "teacher") && !hasRole(user, "admin")) {
            setToast(request, "Chi giang vien moi co the ket noi Google Drive cho khoa hoc.", "error");
            response.sendRedirect(request.getContextPath() + "/profile");
            return null;
        }
        return user;
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

    private void setToast(HttpServletRequest request, String message, String type) {
        HttpSession session = request.getSession(true);
        session.setAttribute("toastMsg", message);
        session.setAttribute("toastType", type);
    }

    private String callbackUri(HttpServletRequest request) {
        return OAuthUriHelper.callbackUri(request, config(request, "GOOGLE_DRIVE_REDIRECT_URI"), "/teacher-drive/callback");
    }

    private String tokenEncryptionKey(HttpServletRequest request) {
        String value = config(request, "HIPZI_TOKEN_ENCRYPTION_KEY");
        if (isBlank(value)) {
            value = config(request, "TOKEN_ENCRYPTION_KEY");
        }
        return value;
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
}
