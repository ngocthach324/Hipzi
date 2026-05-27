package com.hipzi.controller;

import com.hipzi.dao.RememberMeTokenDao;
import com.hipzi.dao.UserDao;
import com.hipzi.model.User;
import com.hipzi.util.EmailService;
import com.hipzi.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private static final String RESET_SUCCESS_MESSAGE =
            "Nếu email tồn tại trong hệ thống, HIPZI đã gửi mật khẩu mới đến email đó.";
    private static final String PASSWORD_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789@#$%";

    private final UserDao userDao = new UserDao();
    private final RememberMeTokenDao rememberMeTokenDao = new RememberMeTokenDao();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Vui lòng nhập email cần khôi phục mật khẩu.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        String normalizedEmail = email.trim().toLowerCase();
        try {
            User user = userDao.findByEmail(normalizedEmail);
            if (user != null && "active".equalsIgnoreCase(user.getAccountStatus())) {
                String newPassword = generatePassword(12);
                if (!userDao.updatePassword(user.getId(), PasswordUtil.hashPassword(newPassword))) {
                    throw new IllegalStateException("Không thể cập nhật mật khẩu mới.");
                }
                rememberMeTokenDao.revokeByUserId(user.getId());
                EmailService.sendPasswordReset(user.getEmail(), user.getDisplayName(), newPassword);
            }

            request.setAttribute("successMsg", RESET_SUCCESS_MESSAGE);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ForgotPasswordServlet error: " + e.getMessage());
            request.setAttribute("errorMsg", "Chưa thể gửi mật khẩu mới lúc này. Vui lòng thử lại sau.");
            request.setAttribute("email", normalizedEmail);
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
        }
    }

    private String generatePassword(int length) {
        StringBuilder password = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            password.append(PASSWORD_CHARS.charAt(secureRandom.nextInt(PASSWORD_CHARS.length())));
        }
        return password.toString();
    }
}
