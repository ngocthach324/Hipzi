package com.hipzi.dao;

import com.hipzi.model.Role;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserRoleDao {

    public boolean assignRole(String userId, String roleId) {
        // Kiểm tra trước khi INSERT vì partial unique index không hỗ trợ ON CONFLICT đơn giản
        String checkSql = "SELECT id FROM user_roles WHERE user_id = ?::uuid AND role_id = ?::uuid AND is_active = true";
        String insertSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?::uuid, ?::uuid)";
        try (Connection conn = DBContext.getConnection()) {
            // Bước 1: Kiểm tra role đã tồn tại và active chưa
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, userId);
                checkPs.setString(2, roleId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) return true; // Đã có, bỏ qua
                }
            }
            // Bước 2: Chưa có → INSERT mới
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, userId);
                insertPs.setString(2, roleId);
                return insertPs.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error in UserRoleDao.assignRole: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Role> getRolesByUserId(String userId) {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT r.* FROM roles r " +
                     "JOIN user_roles ur ON r.id = ur.role_id " +
                     "WHERE ur.user_id = ?::uuid AND ur.is_active = true";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Role role = new Role();
                    role.setId(rs.getString("id"));
                    role.setName(rs.getString("name"));
                    role.setDescription(rs.getString("description"));
                    role.setCreatedAt(rs.getTimestamp("created_at"));
                    roles.add(role);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in UserRoleDao.getRolesByUserId: " + e.getMessage());
            e.printStackTrace();
        }
        return roles;
    }

    public boolean replaceActivePublicRole(String userId, String roleId) {
        String deactivateSql = "UPDATE user_roles ur "
                + "SET is_active = false, revoked_at = NOW() "
                + "FROM roles r "
                + "WHERE ur.role_id = r.id "
                + "AND ur.user_id = ?::uuid "
                + "AND ur.is_active = true "
                + "AND r.name IN ('student', 'parent', 'teacher') "
                + "AND ur.role_id <> ?::uuid";
        String checkSql = "SELECT id FROM user_roles "
                + "WHERE user_id = ?::uuid AND role_id = ?::uuid AND is_active = true";
        String insertSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?::uuid, ?::uuid)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deactivateSql)) {
                    ps.setString(1, userId);
                    ps.setString(2, roleId);
                    ps.executeUpdate();
                }

                boolean alreadyAssigned = false;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setString(1, userId);
                    ps.setString(2, roleId);
                    try (ResultSet rs = ps.executeQuery()) {
                        alreadyAssigned = rs.next();
                    }
                }

                if (!alreadyAssigned) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setString(1, userId);
                        ps.setString(2, roleId);
                        ps.executeUpdate();
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
            System.err.println("Error in UserRoleDao.replaceActivePublicRole: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
