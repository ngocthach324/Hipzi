package com.hipzi.dao;

import com.hipzi.model.Notification;
import com.hipzi.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDao {

    public boolean insert(Notification n) {
        String sql = "INSERT INTO notifications (user_id, title, message, type) VALUES (?::uuid, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, n.getUserId());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            ps.setString(4, n.getType());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.insert: " + e.getMessage());
        }
        return false;
    }

    public List<Notification> listByUserId(String userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ?::uuid ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.listByUserId: " + e.getMessage());
        }
        return list;
    }

    public int countUnread(String userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ?::uuid AND is_read = false";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.countUnread: " + e.getMessage());
        }
        return 0;
    }

    public boolean markAsRead(String id) {
        String sql = "UPDATE notifications SET is_read = true WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.markAsRead: " + e.getMessage());
        }
        return false;
    }

    public boolean markAllAsRead(String userId) {
        String sql = "UPDATE notifications SET is_read = true WHERE user_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.markAllAsRead: " + e.getMessage());
        }
        return false;
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getString("id"));
        n.setUserId(rs.getString("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
