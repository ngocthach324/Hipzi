package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/notification/*")
public class NotificationServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String pathInfo = request.getPathInfo();
        if ("/markAllRead".equals(pathInfo)) {
            boolean success = notificationService.markAllAsRead(user.getId());
            response.getWriter().write(String.valueOf(success));
        } else if ("/markRead".equals(pathInfo)) {
            String id = request.getParameter("id");
            if (id != null) {
                boolean success = notificationService.markAsRead(id);
                response.getWriter().write(String.valueOf(success));
            }
        }
    }
}
