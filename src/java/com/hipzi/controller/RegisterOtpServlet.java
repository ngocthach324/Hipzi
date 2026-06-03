package com.hipzi.controller;

import com.hipzi.dao.UserDao;
import com.hipzi.model.User;
import com.hipzi.service.OtpService;
import com.hipzi.service.OtpService.OtpValidationResult;
import com.hipzi.dao.UserRoleDao;
import com.hipzi.dao.RoleDao;
import com.hipzi.model.Role;
import com.hipzi.util.OtpUtil;
import com.hipzi.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet xử lý bước gửi OTP khi đăng ký.
 *
 * Luồng:
 *   1. RegisterServlet tạo thông tin user tạm trong session (pending_register_*)
 *   2. Redirect sang /send-register-otp → Servlet này gửi OTP đến email
 *   3. Redirect sang /verify-otp?purpose=register
 *
 * Route: POST /send-register-otp
 */
@WebServlet("/send-register-otp")
public class RegisterOtpServlet extends HttpServlet {

    private final OtpService otpService = new OtpService();
    private final UserDao    userDao    = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // --- Kiểm tra dữ liệu đăng ký tạm trong session ---
        if (session == null
                || session.getAttribute("pending_register_email") == null
                || session.getAttribute("pending_register_name") == null
                || session.getAttribute("pending_register_hash") == null
                || session.getAttribute("pending_register_role") == null) {
            resp.sendRedirect(req.getContextPath() + "/register?error=session_expired");
            return;
        }

        String email       = (String) session.getAttribute("pending_register_email");
        String displayName = (String) session.getAttribute("pending_register_name");

        // --- Kiểm tra email chưa tồn tại ---
        if (userDao.findByEmail(email) != null) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/register?error=email_exists");
            return;
        }

        try {
            // Gửi OTP (user_id = null vì chưa tạo user)
            otpService.generateAndSend(email, null, displayName, "register");
            resp.sendRedirect(req.getContextPath() + "/verify-otp?purpose=register");
        } catch (IllegalStateException e) {
            // Rate limit
            req.getSession().setAttribute("otp_error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/verify-otp?purpose=register&rateLimited=true");
        } catch (Exception e) {
            System.err.println("[RegisterOtpServlet] Lỗi gửi OTP: " + e.getMessage());
            req.getSession().setAttribute("otp_error", "Không thể gửi mã OTP. Vui lòng thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/register?error=otp_failed");
        }
    }
}