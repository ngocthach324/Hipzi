package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.AuthService;
import com.hipzi.exception.UnauthorizedException;
import com.hipzi.service.OtpService;
import com.hipzi.service.RememberMeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final OtpService otpService = new OtpService();
    private final RememberMeService rememberMeService = new RememberMeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loggedUser") != null) {
            User user = (User) session.getAttribute("loggedUser");
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
            return;
        }

        if (session != null && session.getAttribute("oauth_error") != null) {
            request.setAttribute("errorMsg", session.getAttribute("oauth_error"));
            session.removeAttribute("oauth_error");
        }

        if (session != null) {
            session.removeAttribute("pending_2fa_user_id");
            session.removeAttribute("pending_remember_me");
            session.removeAttribute("otp_error");
        }

        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = normalizeEmail(request.getParameter("email"));
        String password = request.getParameter("password");
        boolean rememberMe = "true".equals(request.getParameter("rememberMe"));

        try {
            User user = authService.login(email, password);
            HttpSession session = request.getSession(true);

            if (user.isTwoFactorEnabled()) {
                session.setAttribute("pending_2fa_user_id", user.getId());
                session.setAttribute("pending_remember_me", rememberMe);
                try {
                    otpService.generateAndSend(user.getEmail(), user.getId(), user.getDisplayName(), "login");
                } catch (IllegalStateException e) {
                    session.setAttribute("otp_error", e.getMessage());
                    response.sendRedirect(request.getContextPath() + "/verify-otp?purpose=login&rateLimited=true");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/verify-otp?purpose=login");
                return;
            }

            session.removeAttribute("pending_2fa_user_id");
            session.removeAttribute("pending_remember_me");
            session.removeAttribute("otp_error");
            session.setAttribute("loggedUser", user);

            if (rememberMe) {
                rememberMeService.issueRememberCookie(user, request, response);
            } else {
                rememberMeService.clearRememberCookie(request, response);
            }

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
        } catch (UnauthorizedException e) {
            request.setAttribute("errorMsg", e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Lỗi kết nối cơ sở dữ liệu hoặc lỗi hệ thống. Vui lòng thử khởi động lại server.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }

    private String normalizeEmail(String email) {
        if (email == null) {
            return null;
        }
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        return normalized.isEmpty() ? null : normalized;
    }

    private String resolveProfileUrl(List<com.hipzi.model.Role> roles) {
        String targetUrl = "student-profile";
        if (roles == null) {
            return targetUrl;
        }

        boolean hasParent = false;
        boolean hasTeacher = false;
        boolean hasStaff = false;
        boolean hasAdmin = false;
        for (com.hipzi.model.Role role : roles) {
            String roleName = role.getName().toLowerCase();
            if ("parent".equals(roleName)) {
                hasParent = true;
            }
            if ("teacher".equals(roleName)) {
                hasTeacher = true;
            }
            if ("staff".equals(roleName)) {
                hasStaff = true;
            }
            if ("admin".equals(roleName)) {
                hasAdmin = true;
            }
        }

        if (hasAdmin) {
            targetUrl = "admin-profile";
        } else if (hasStaff) {
            targetUrl = "staff-profile";
        } else if (hasTeacher) {
            targetUrl = "teacher-profile";
        } else if (hasParent) {
            targetUrl = "parent-profile";
        }
        return targetUrl;
    }
}
