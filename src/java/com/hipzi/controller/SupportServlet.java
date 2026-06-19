package com.hipzi.controller;

import com.hipzi.dao.SupportTicketDao;
import com.hipzi.model.Role;
import com.hipzi.model.SupportTicket;
import com.hipzi.model.User;
import com.hipzi.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "SupportServlet", urlPatterns = {"/support"})
public class SupportServlet extends HttpServlet {

    private final SupportTicketDao supportTicketDao = new SupportTicketDao();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Ban can dang nhap de gui yeu cau ho tro.");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (!supportTicketDao.tableExists()) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Chua co bang support_tickets. Vui long chay migration database/17-support-tickets.sql.");
            return;
        }

        String action = cleanParam(request.getParameter("action"));
        if ("reply".equals(action)) {
            handleReply(request, response, session, user);
            return;
        }

        handleCreateTicket(request, response, user);
    }

    private void handleCreateTicket(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String title = cleanParam(request.getParameter("title"));
        String content = cleanParam(request.getParameter("content"));

        if (title.isEmpty() || content.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tieu de va noi dung khong duoc de trong.");
            return;
        }

        try {
            SupportTicket ticket = supportTicketDao.createTicketWithMessage(
                    user.getId(),
                    title,
                    content,
                    primaryRole(user)
            );

            if (ticket == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Khong the tao ticket ho tro luc nay.");
                return;
            }

            response.setContentType("text/plain;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Yeu cau ho tro cua ban da duoc ghi nhan trong he thong!");
        } catch (Exception e) {
            System.err.println("[SupportServlet] Create ticket error: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Khong the gui yeu cau ho tro luc nay. Vui long thu lai sau.");
        }
    }

    private void handleReply(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException {
        if (!hasRole(user, "staff") && !hasRole(user, "admin")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Ban khong co quyen phan hoi ticket ho tro.");
            return;
        }

        String ticketId = cleanParam(request.getParameter("ticketId"));
        String replyContent = cleanParam(request.getParameter("replyContent"));
        String nextStatus = "resolved".equals(cleanParam(request.getParameter("nextStatus"))) ? "resolved" : "waiting_user";

        if (ticketId.isEmpty() || replyContent.isEmpty()) {
            session.setAttribute("toastMsg", "Vui long chon ticket va nhap noi dung phan hoi.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/staff-profile?tab=support");
            return;
        }

        SupportTicket ticket = supportTicketDao.findById(ticketId);
        if (ticket == null) {
            session.setAttribute("toastMsg", "Khong tim thay ticket ho tro.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/staff-profile?tab=support");
            return;
        }

        boolean saved = supportTicketDao.addMessage(ticketId, user.getId(), primaryRole(user), replyContent, nextStatus);
        if (saved) {
            notificationService.sendToUser(
                    ticket.getUserId(),
                    "Ban co phan hoi ho tro moi",
                    "Nhan vien HIPZI da phan hoi yeu cau: " + ticket.getTitle(),
                    "support"
            );
            session.setAttribute("toastMsg", "Da gui phan hoi ho tro cho nguoi dung.");
            session.setAttribute("toastType", "success");
        } else {
            session.setAttribute("toastMsg", "Khong the gui phan hoi. Vui long thu lai.");
            session.setAttribute("toastType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/staff-profile?tab=support&supportTicketId=" + ticketId);
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) {
            return false;
        }
        for (Role role : user.getRoles()) {
            if (roleName.equals(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private String primaryRole(User user) {
        if (hasRole(user, "admin")) {
            return "admin";
        }
        if (hasRole(user, "staff")) {
            return "staff";
        }
        if (hasRole(user, "teacher")) {
            return "teacher";
        }
        if (hasRole(user, "parent")) {
            return "parent";
        }
        return "student";
    }
}
