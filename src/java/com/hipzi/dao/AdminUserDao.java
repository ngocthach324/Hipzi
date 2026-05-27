package com.hipzi.dao;

import com.hipzi.model.AdminUserSummary;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminUserDao {
    private static final String MANAGED_ROLE_FILTER = "('student', 'teacher', 'parent', 'staff')";

    public List<AdminUserSummary> listManagedUsers(int page, int pageSize) {
        List<AdminUserSummary> users = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, pageSize);
        int offset = (safePage - 1) * safePageSize;

        String sql = "SELECT u.id, u.display_name, u.email, u.account_status, " +
                     "STRING_AGG(DISTINCT r.name, ', ' ORDER BY r.name) AS roles " +
                     "FROM users u " +
                     "JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true " +
                     "JOIN roles r ON r.id = ur.role_id " +
                     "WHERE u.deleted_at IS NULL AND LOWER(r.name) IN " + MANAGED_ROLE_FILTER + " " +
                     "GROUP BY u.id, u.display_name, u.email, u.account_status, u.created_at " +
                     "ORDER BY u.created_at DESC NULLS LAST, u.display_name ASC " +
                     "LIMIT ? OFFSET ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safePageSize);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in AdminUserDao.listManagedUsers: " + e.getMessage());
        }
        return users;
    }

    public int countManagedUsers() {
        String sql = "SELECT COUNT(DISTINCT u.id) AS total " +
                     "FROM users u " +
                     "JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true " +
                     "JOIN roles r ON r.id = ur.role_id " +
                     "WHERE u.deleted_at IS NULL AND LOWER(r.name) IN " + MANAGED_ROLE_FILTER;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt("total") : 0;
        } catch (SQLException e) {
            System.err.println("Error in AdminUserDao.countManagedUsers: " + e.getMessage());
        }
        return 0;
    }

    public boolean banUser(String userId, String adminId) {
        if (userId == null || userId.trim().isEmpty() || userId.equals(adminId)) {
            return false;
        }

        String sql = "UPDATE users u SET account_status = 'disabled', updated_at = NOW() " +
                     "WHERE u.id = ?::uuid AND u.deleted_at IS NULL " +
                     "AND EXISTS (" +
                     "    SELECT 1 FROM user_roles ur " +
                     "    JOIN roles r ON r.id = ur.role_id " +
                     "    WHERE ur.user_id = u.id AND ur.is_active = true AND LOWER(r.name) IN " + MANAGED_ROLE_FILTER +
                     ") " +
                     "AND NOT EXISTS (" +
                     "    SELECT 1 FROM user_roles ur " +
                     "    JOIN roles r ON r.id = ur.role_id " +
                     "    WHERE ur.user_id = u.id AND ur.is_active = true AND LOWER(r.name) = 'admin'" +
                     ")";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in AdminUserDao.banUser: " + e.getMessage());
        }
        return false;
    }

    private AdminUserSummary mapRow(ResultSet rs) throws SQLException {
        AdminUserSummary user = new AdminUserSummary();
        user.setId(rs.getString("id"));
        user.setDisplayName(rs.getString("display_name"));
        user.setEmail(rs.getString("email"));
        user.setRoles(rs.getString("roles"));
        user.setAccountStatus(rs.getString("account_status"));
        return user;
    }
}
