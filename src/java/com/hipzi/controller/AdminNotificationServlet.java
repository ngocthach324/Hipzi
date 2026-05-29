package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.NotificationService;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/notification")
public class AdminNotificationServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("loggedUser");

        // Kiểm tra quyền Admin (Cơ bản)
        if (admin == null || !"active".equals(admin.getAccountStatus())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("broadcast".equals(action)) {
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String type = request.getParameter("type");

            if (title == null || title.isEmpty() || message == null || message.isEmpty()) {
                session.setAttribute("toastMsg", "Vui lòng nhập đầy đủ tiêu đề và nội dung!");
                session.setAttribute("toastType", "error");
            } else {
                int count = notificationService.broadcastToAll(title, message, type);
                session.setAttribute("toastMsg", "Đã gửi thông báo đến " + count + " người dùng thành công!");
                session.setAttribute("toastType", "success");
            }
        } else if ("sendToUser".equals(action)) {
            String targetUserId = request.getParameter("userId");
            String title = request.getParameter("title");
            String message = request.getParameter("message");
            String type = request.getParameter("type");

            if (targetUserId == null || targetUserId.isEmpty() || title == null || title.isEmpty() || message == null || message.isEmpty()) {
                session.setAttribute("toastMsg", "Vui lòng nhập đầy đủ thông tin!");
                session.setAttribute("toastType", "error");
            } else {
                boolean success = notificationService.sendToUser(targetUserId, title, message, type);
                if (success) {
                    session.setAttribute("toastMsg", "Đã gửi thông báo thành công!");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Gửi thông báo thất bại. Vui lòng kiểm tra lại ID người dùng.");
                    session.setAttribute("toastType", "error");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin-profile?tab=notifications");
    }
}
