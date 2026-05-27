package com.hipzi.controller;

import com.hipzi.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xử lý form liên hệ từ trang chủ (không yêu cầu đăng nhập).
 * Gửi email liên hệ trực tiếp đến email hỗ trợ.
 */
@WebServlet(name = "ContactServlet", urlPatterns = {"/contact"})
public class ContactServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String message = request.getParameter("message");

        // Validate đầu vào dữ liệu (Backend Validation)
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            message == null || message.trim().isEmpty()) {
            
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Vui lòng nhập đầy đủ các trường thông tin!\"}");
            return;
        }

        try {
            // Gửi email liên hệ đến hòm thư hỗ trợ (moviezonevn@gmail.com)
            EmailService.sendContactMessage(name.trim(), email.trim(), phone.trim(), message.trim());
            
            // Trả về JSON thành công
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"message\": \"Lời nhắn của bạn đã được gửi đến đội ngũ hỗ trợ thành công!\"}");
            
        } catch (Exception e) {
            System.err.println("[ContactServlet] Lỗi: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Không thể gửi yêu cầu hỗ trợ lúc này. Vui lòng thử lại sau!\"}");
        }
    }
}
