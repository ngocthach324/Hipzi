package com.hipzi.dao;

import com.hipzi.model.SupportMessage;
import com.hipzi.model.SupportTicket;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SupportTicketDao {

    public SupportTicket createTicketWithMessage(String userId, String title, String message, String sourceRole) {
        String insertTicketSql = "INSERT INTO support_tickets (user_id, title, status, source_role) "
                + "VALUES (?::uuid, ?, 'waiting_staff', ?) RETURNING *";
        String insertMessageSql = "INSERT INTO support_messages (ticket_id, sender_id, sender_role, message) "
                + "VALUES (?::uuid, ?::uuid, ?, ?)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                SupportTicket ticket = null;
                try (PreparedStatement ps = conn.prepareStatement(insertTicketSql)) {
                    ps.setString(1, userId);
                    ps.setString(2, title);
                    ps.setString(3, normalizeRole(sourceRole));
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            ticket = mapTicket(rs);
                        }
                    }
                }

                if (ticket == null) {
                    conn.rollback();
                    return null;
                }

                try (PreparedStatement ps = conn.prepareStatement(insertMessageSql)) {
                    ps.setString(1, ticket.getId());
                    ps.setString(2, userId);
                    ps.setString(3, normalizeRole(sourceRole));
                    ps.setString(4, message);
                    ps.executeUpdate();
                }

                conn.commit();
                return findById(ticket.getId());
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.createTicketWithMessage: " + e.getMessage());
        }
        return null;
    }

    public boolean addMessage(String ticketId, String senderId, String senderRole, String message, String nextStatus) {
        String insertMessageSql = "INSERT INTO support_messages (ticket_id, sender_id, sender_role, message) "
                + "VALUES (?::uuid, ?::uuid, ?, ?)";
        String updateTicketSql = "UPDATE support_tickets "
                + "SET status = ?, assigned_staff_id = CASE WHEN ? = 'staff' OR ? = 'admin' THEN ?::uuid ELSE assigned_staff_id END, "
                + "updated_at = NOW(), resolved_at = CASE WHEN ? = 'resolved' THEN NOW() ELSE resolved_at END "
                + "WHERE id = ?::uuid";

        String normalizedRole = normalizeRole(senderRole);
        String normalizedStatus = normalizeStatus(nextStatus);

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertMessageSql)) {
                    ps.setString(1, ticketId);
                    ps.setString(2, senderId);
                    ps.setString(3, normalizedRole);
                    ps.setString(4, message);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(updateTicketSql)) {
                    ps.setString(1, normalizedStatus);
                    ps.setString(2, normalizedRole);
                    ps.setString(3, normalizedRole);
                    ps.setString(4, senderId);
                    ps.setString(5, normalizedStatus);
                    ps.setString(6, ticketId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.addMessage: " + e.getMessage());
        }
        return false;
    }

    public SupportTicket findById(String ticketId) {
        String sql = baseTicketSelect()
                + "WHERE t.id = ?::uuid "
                + "LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTicketWithSummary(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.findById: " + e.getMessage());
        }
        return null;
    }

    public List<SupportTicket> listByUserId(String userId, int limit) {
        String sql = baseTicketSelect()
                + "WHERE t.user_id = ?::uuid "
                + "ORDER BY t.updated_at DESC "
                + "LIMIT ?";
        return listTickets(sql, userId, limit);
    }

    public List<SupportTicket> listForStaff(int limit) {
        String sql = baseTicketSelect()
                + "ORDER BY CASE t.status "
                + "WHEN 'waiting_staff' THEN 1 "
                + "WHEN 'open' THEN 2 "
                + "WHEN 'waiting_user' THEN 3 "
                + "WHEN 'resolved' THEN 4 "
                + "ELSE 5 END, t.updated_at DESC "
                + "LIMIT ?";
        List<SupportTicket> tickets = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapTicketWithSummary(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.listForStaff: " + e.getMessage());
        }
        return tickets;
    }

    public List<SupportMessage> listMessages(String ticketId) {
        List<SupportMessage> messages = new ArrayList<>();
        String sql = "SELECT m.*, u.display_name AS sender_name, u.email AS sender_email "
                + "FROM support_messages m "
                + "JOIN users u ON u.id = m.sender_id "
                + "WHERE m.ticket_id = ?::uuid "
                + "ORDER BY m.created_at ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    messages.add(mapMessage(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.listMessages: " + e.getMessage());
        }
        return messages;
    }

    public boolean userCanAccessTicket(String ticketId, String userId) {
        String sql = "SELECT 1 FROM support_tickets WHERE id = ?::uuid AND user_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ticketId);
            ps.setString(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.userCanAccessTicket: " + e.getMessage());
        }
        return false;
    }

    public boolean tableExists() {
        String sql = "SELECT to_regclass('public.support_tickets') IS NOT NULL";
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() && rs.getBoolean(1);
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.tableExists: " + e.getMessage());
        }
        return false;
    }

    private List<SupportTicket> listTickets(String sql, String id, int limit) {
        List<SupportTicket> tickets = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapTicketWithSummary(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in SupportTicketDao.listTickets: " + e.getMessage());
        }
        return tickets;
    }

    private String baseTicketSelect() {
        return "SELECT t.*, u.display_name AS user_name, u.email AS user_email, "
                + "(SELECT m.message FROM support_messages m WHERE m.ticket_id = t.id ORDER BY m.created_at DESC LIMIT 1) AS latest_message, "
                + "(SELECT m.sender_role FROM support_messages m WHERE m.ticket_id = t.id ORDER BY m.created_at DESC LIMIT 1) AS latest_sender_role, "
                + "(SELECT m.created_at FROM support_messages m WHERE m.ticket_id = t.id ORDER BY m.created_at DESC LIMIT 1) AS latest_message_at, "
                + "(SELECT COUNT(*) FROM support_messages m WHERE m.ticket_id = t.id) AS message_count "
                + "FROM support_tickets t "
                + "JOIN users u ON u.id = t.user_id ";
    }

    private SupportTicket mapTicket(ResultSet rs) throws SQLException {
        SupportTicket ticket = new SupportTicket();
        ticket.setId(rs.getString("id"));
        ticket.setUserId(rs.getString("user_id"));
        ticket.setAssignedStaffId(rs.getString("assigned_staff_id"));
        ticket.setTitle(rs.getString("title"));
        ticket.setStatus(rs.getString("status"));
        ticket.setPriority(rs.getString("priority"));
        ticket.setSourceRole(rs.getString("source_role"));
        ticket.setCreatedAt(rs.getTimestamp("created_at"));
        ticket.setUpdatedAt(rs.getTimestamp("updated_at"));
        ticket.setResolvedAt(rs.getTimestamp("resolved_at"));
        ticket.setClosedAt(rs.getTimestamp("closed_at"));
        return ticket;
    }

    private SupportTicket mapTicketWithSummary(ResultSet rs) throws SQLException {
        SupportTicket ticket = mapTicket(rs);
        ticket.setUserName(rs.getString("user_name"));
        ticket.setUserEmail(rs.getString("user_email"));
        ticket.setLatestMessage(rs.getString("latest_message"));
        ticket.setLatestSenderRole(rs.getString("latest_sender_role"));
        ticket.setLatestMessageAt(rs.getTimestamp("latest_message_at"));
        ticket.setMessageCount(rs.getInt("message_count"));
        return ticket;
    }

    private SupportMessage mapMessage(ResultSet rs) throws SQLException {
        SupportMessage message = new SupportMessage();
        message.setId(rs.getString("id"));
        message.setTicketId(rs.getString("ticket_id"));
        message.setSenderId(rs.getString("sender_id"));
        message.setSenderRole(rs.getString("sender_role"));
        message.setMessage(rs.getString("message"));
        message.setCreatedAt(rs.getTimestamp("created_at"));
        message.setReadAt(rs.getTimestamp("read_at"));
        message.setSenderName(rs.getString("sender_name"));
        message.setSenderEmail(rs.getString("sender_email"));
        return message;
    }

    private String normalizeRole(String role) {
        if ("teacher".equals(role) || "parent".equals(role) || "staff".equals(role) || "admin".equals(role)) {
            return role;
        }
        return "student";
    }

    private String normalizeStatus(String status) {
        if ("open".equals(status) || "waiting_staff".equals(status) || "waiting_user".equals(status)
                || "resolved".equals(status) || "closed".equals(status)) {
            return status;
        }
        return "open";
    }
}
