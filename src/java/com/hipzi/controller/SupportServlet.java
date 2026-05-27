package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet xử lý yêu cầu hỗ trợ từ học viên.
 * Gửi email nội dung hỗ trợ đến email quản trị.
 */
@WebServlet(name = "SupportServlet", urlPatterns = {"/support"})
public class SupportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        
        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Bạn cần đăng nhập để gửi yêu cầu hỗ trợ.");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        String title = request.getParameter("title");
        String content = request.getParameter("content");

        // Validate đầu vào
        if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tiêu đề và nội dung không được để trống.");
            return;
        }

        try {
            // Gửi email đến Admin
            EmailService.sendSupportRequest(user.getEmail(), user.getDisplayName(), title, content);
            
            // Trả về thành công (dùng cho AJAX fetch)
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Yêu cầu hỗ trợ của bạn đã được gửi thành công!");
            
        } catch (Exception e) {
            System.err.println("[SupportServlet] Lỗi: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể gửi yêu cầu hỗ trợ lúc này. Vui lòng thử lại sau.");
        }
    }
}
