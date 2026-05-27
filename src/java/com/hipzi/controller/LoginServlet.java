package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.AuthService;
import com.hipzi.service.OtpService;
import com.hipzi.service.RememberMeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final OtpService  otpService  = new OtpService();
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
            java.util.List<com.hipzi.model.Role> roles = user.getRoles();
            if (roles == null || roles.isEmpty()) {
                roles = new com.hipzi.dao.UserRoleDao().getRolesByUserId(user.getId());
                user.setRoles(roles);
                session.setAttribute("loggedUser", user);
            }
            String targetUrl = "student-profile";
            if (roles != null) {
                boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
                for (com.hipzi.model.Role r : roles) {
                    String rn = r.getName().toLowerCase();
                    if ("parent".equals(rn)) hasParent = true;
                    if ("teacher".equals(rn)) hasTeacher = true;
                    if ("staff".equals(rn)) hasStaff = true;
                    if ("admin".equals(rn)) hasAdmin = true;
                }
                if (hasAdmin) targetUrl = "admin-profile";
                else if (hasStaff) targetUrl = "staff-profile";
                else if (hasTeacher) targetUrl = "teacher-profile";
                else if (hasParent) targetUrl = "parent-profile";
            }
            response.sendRedirect(request.getContextPath() + "/" + targetUrl);
            return;
        }

        if (session != null && session.getAttribute("oauth_error") != null) {
            request.setAttribute("errorMsg", session.getAttribute("oauth_error"));
            session.removeAttribute("oauth_error");
        }
        
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        boolean rememberMe = "true".equals(request.getParameter("rememberMe"));
        
        try {
            User user = authService.login(email, password);
            
            HttpSession session = request.getSession(true);

            // --- Kiểm tra bảo mật 2 lớp (2FA) ---
            if (user.isTwoFactorEnabled()) {
                // Gửi OTP đăng nhập
                otpService.generateAndSend(user.getEmail(), user.getId(), user.getDisplayName(), "login");
                // Lưu ID tạm thời để chờ xác thực bước 2
                session.setAttribute("pending_2fa_user_id", user.getId());
                session.setAttribute("pending_remember_me", rememberMe);
                response.sendRedirect(request.getContextPath() + "/verify-otp?purpose=login");
                return;
            }

            // --- 2FA tắt: Đăng nhập thành công ngay ---
            java.util.List<com.hipzi.model.Role> roles = user.getRoles();
            if (roles == null || roles.isEmpty()) {
                roles = new com.hipzi.dao.UserRoleDao().getRolesByUserId(user.getId());
                user.setRoles(roles);
            }
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
            String targetUrl = "student-profile";
            if (roles != null) {
                boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
                for (com.hipzi.model.Role r : roles) {
                    String rn = r.getName().toLowerCase();
                    if ("parent".equals(rn)) hasParent = true;
                    if ("teacher".equals(rn)) hasTeacher = true;
                    if ("staff".equals(rn)) hasStaff = true;
                    if ("admin".equals(rn)) hasAdmin = true;
                }
                if (hasAdmin) targetUrl = "admin-profile";
                else if (hasStaff) targetUrl = "staff-profile";
                else if (hasTeacher) targetUrl = "teacher-profile";
                else if (hasParent) targetUrl = "parent-profile";
            }
            response.sendRedirect(request.getContextPath() + "/" + targetUrl);
            
        } catch (IllegalStateException e) {
            // Rate limit khi gửi OTP
            request.getSession().setAttribute("otp_error", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/verify-otp?purpose=login&rateLimited=true");
        } catch (Exception e) {
            // Login thất bại
            request.setAttribute("errorMsg", e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
