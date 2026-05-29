package com.hipzi.controller;

import com.hipzi.model.Notification;
import com.hipzi.model.NotificationBellData;
import com.hipzi.model.User;
import com.hipzi.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/notification/*")
public class NotificationServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String pathInfo = request.getPathInfo();
        if (!"/bell".equals(pathInfo)) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        long startedAt = System.nanoTime();
        NotificationBellData bellData = notificationService.getBellData(user.getId(), 5);
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;

        response.setContentType("application/json;charset=UTF-8");
        response.addHeader("Server-Timing", "notification-data;dur=" + elapsedMs);
        response.addHeader("X-Hipzi-Perf-Notification", "data=" + elapsedMs + "ms");
        response.getWriter().write(toBellJson(bellData));
    }

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

    private String toBellJson(NotificationBellData bellData) {
        StringBuilder json = new StringBuilder();
        List<Notification> notifications = bellData.getNotifications();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        json.append("{\"unreadCount\":").append(bellData.getUnreadCount()).append(",\"notifications\":[");
        for (int i = 0; i < notifications.size(); i++) {
            Notification n = notifications.get(i);
            if (i > 0) json.append(',');
            json.append('{')
                    .append("\"id\":\"").append(escapeJson(n.getId())).append("\",")
                    .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                    .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                    .append("\"type\":\"").append(escapeJson(n.getType())).append("\",")
                    .append("\"read\":").append(n.isRead()).append(',')
                    .append("\"createdAt\":\"").append(n.getCreatedAt() != null ? escapeJson(sdf.format(n.getCreatedAt())) : "").append("\"")
                    .append('}');
        }
        json.append("]}");
        return json.toString();
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        StringBuilder escaped = new StringBuilder(value.length() + 16);
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\b':
                    escaped.append("\\b");
                    break;
                case '\f':
                    escaped.append("\\f");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    if (ch < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) ch));
                    } else {
                        escaped.append(ch);
                    }
            }
        }
        return escaped.toString();
    }
}
