package com.hipzi.dao;

import com.hipzi.model.Notification;
import com.hipzi.model.NotificationBellData;
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
        long startedAt = System.nanoTime();
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
        logPerf("NotificationDao.listByUserId rows=" + list.size(), startedAt);
        return list;
    }

    public int countUnread(String userId) {
        long startedAt = System.nanoTime();
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ?::uuid AND is_read = false";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    logPerf("NotificationDao.countUnread count=" + count, startedAt);
                    return count;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.countUnread: " + e.getMessage());
        }
        logPerf("NotificationDao.countUnread count=0", startedAt);
        return 0;
    }

    public NotificationBellData getBellData(String userId, int limit) {
        long startedAt = System.nanoTime();
        List<Notification> list = new ArrayList<>();
        int unreadCount = 0;
        String recentSql = "SELECT id, user_id, title, message, type, is_read, created_at "
                + "FROM notifications WHERE user_id = ?::uuid ORDER BY created_at DESC LIMIT ?";
        String unreadSql = "SELECT COUNT(*) FROM notifications WHERE user_id = ?::uuid AND is_read = false";

        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(recentSql)) {
                ps.setString(1, userId);
                ps.setInt(2, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(unreadSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        unreadCount = rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in NotificationDao.getBellData: " + e.getMessage());
        }
        logPerf("NotificationDao.getBellData rows=" + list.size() + " unread=" + unreadCount, startedAt);
        return new NotificationBellData(list, unreadCount);
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

    private void logPerf(String label, long startedAt) {
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;
        System.err.println("[PERF] " + label + " " + elapsedMs + "ms");
    }
}
