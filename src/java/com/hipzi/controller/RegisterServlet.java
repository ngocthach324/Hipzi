package com.hipzi.controller;

import com.hipzi.dao.UserDao;
import com.hipzi.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String email           = normalizeEmail(request.getParameter("email"));
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String displayName     = request.getParameter("displayName");
        String role            = request.getParameter("role");

        // --- Validation cơ bản ---
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            forwardError(request, response, email, displayName, "Email và mật khẩu không được để trống.");
            return;
        }
        if (displayName == null || displayName.trim().isEmpty()) {
            forwardError(request, response, email, displayName, "Họ và tên không được để trống.");
            return;
        }
        if (password.length() < 6) {
            forwardError(request, response, email, displayName, "Mật khẩu phải có ít nhất 6 ký tự.");
            return;
        }
        if (!password.equals(confirmPassword)) {
            forwardError(request, response, email, displayName, "Mật khẩu xác nhận không khớp.");
            return;
        }

        // --- Kiểm tra email tồn tại ---
        if (userDao.findByEmail(email.trim()) != null) {
            forwardError(request, response, email, displayName, "Email này đã được sử dụng.");
            return;
        }

        // --- Lưu thông tin vào session tạm ---
        HttpSession session = request.getSession(true);
        session.setAttribute("pending_register_email", email.trim());
        session.setAttribute("pending_register_name",  displayName.trim());
        session.setAttribute("pending_register_hash",  PasswordUtil.hashPassword(password));
        session.setAttribute("pending_register_role",  role != null ? role.trim().toLowerCase() : "student");

        // Chuyển tiếp sang Servlet gửi OTP
        request.getRequestDispatcher("/send-register-otp").forward(request, response);
    }

    private void forwardError(HttpServletRequest request, HttpServletResponse response,
                              String email, String displayName, String errorMsg)
            throws ServletException, IOException {
        request.setAttribute("errorMsg", errorMsg);
        request.setAttribute("email", email);
        request.setAttribute("displayName", displayName);
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    private String normalizeEmail(String email) {
        if (email == null) {
            return null;
        }
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        return normalized.isEmpty() ? null : normalized;
    }
}
