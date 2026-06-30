package com.hipzi.dao;

import com.hipzi.util.DBContext;
import com.hipzi.model.AdminUserSummary;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminUserDao {
    private static final String MANAGED_ROLE_FILTER = "('student', 'teacher', 'parent', 'staff')";

    public List<AdminUserSummary> listManagedUsers(int page, int pageSize) {
        return listManagedUsers(null, null, null, page, pageSize);
    }
    
    public List<AdminUserSummary> listManagedUsers(String searchQuery, String roleFilter, String statusFilter, int page, int pageSize) {
        List<AdminUserSummary> users = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, pageSize);
        int offset = (safePage - 1) * safePageSize;

        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.display_name, u.email, u.account_status, " +
                "STRING_AGG(DISTINCT r.name, ', ' ORDER BY r.name) AS roles " +
                "FROM users u " +
                "JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true " +
                "JOIN roles r ON r.id = ur.role_id " +
                "WHERE u.deleted_at IS NULL AND LOWER(r.name) IN " + MANAGED_ROLE_FILTER + " "
        );

        List<Object> params = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (u.display_name ILIKE ? OR u.email ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter.trim())) {
            sql.append("AND u.id IN (SELECT ur2.user_id FROM user_roles ur2 JOIN roles r2 ON r2.id = ur2.role_id WHERE ur2.is_active = true AND LOWER(r2.name) = ?) ");
            params.add(roleFilter.trim().toLowerCase());
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND LOWER(u.account_status) = ? ");
            params.add(statusFilter.trim().toLowerCase());
        }

        sql.append("GROUP BY u.id, u.display_name, u.email, u.account_status, u.created_at ")
           .append("ORDER BY u.created_at DESC NULLS LAST, u.display_name ASC ")
           .append("LIMIT ? OFFSET ?");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ps.setInt(params.size() + 1, safePageSize);
            ps.setInt(params.size() + 2, offset);
            
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

    public List<AdminUserSummary> listStaffManagedLearnersAndTeachers(String searchQuery, String roleFilter, String statusFilter) {
        List<AdminUserSummary> users = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.display_name, u.email, u.account_status, "
                + "STRING_AGG(DISTINCT r.name, ', ' ORDER BY r.name) AS roles "
                + "FROM users u "
                + "JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true "
                + "JOIN roles r ON r.id = ur.role_id "
                + "WHERE u.deleted_at IS NULL "
                + "AND LOWER(r.name) IN ('student', 'teacher') ");

        List<Object> params = new ArrayList<>();
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (u.display_name ILIKE ? OR u.email ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter.trim())) {
            sql.append("AND LOWER(r.name) = ? ");
            params.add(roleFilter.trim().toLowerCase());
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND LOWER(u.account_status) = ? ");
            params.add(statusFilter.trim().toLowerCase());
        }

        sql.append("GROUP BY u.id, u.display_name, u.email, u.account_status, u.created_at ")
           .append("ORDER BY u.created_at DESC NULLS LAST, u.display_name ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in AdminUserDao.listStaffManagedLearnersAndTeachers: " + e.getMessage());
        }
        return users;
    }

    public int countManagedUsers() {
        return countManagedUsers(null, null, null);
    }
    
    public int countManagedUsers(String searchQuery, String roleFilter, String statusFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT u.id) AS total " +
                "FROM users u " +
                "JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true " +
                "JOIN roles r ON r.id = ur.role_id " +
                "WHERE u.deleted_at IS NULL AND LOWER(r.name) IN " + MANAGED_ROLE_FILTER + " "
        );

        List<Object> params = new ArrayList<>();
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (u.display_name ILIKE ? OR u.email ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter.trim())) {
            sql.append("AND u.id IN (SELECT ur2.user_id FROM user_roles ur2 JOIN roles r2 ON r2.id = ur2.role_id WHERE ur2.is_active = true AND LOWER(r2.name) = ?) ");
            params.add(roleFilter.trim().toLowerCase());
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND LOWER(u.account_status) = ? ");
            params.add(statusFilter.trim().toLowerCase());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total") : 0;
            }
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

    public boolean unbanUser(String userId, String adminId) {
        if (userId == null || userId.trim().isEmpty() || userId.equals(adminId)) {
            return false;
        }

        String sql = "UPDATE users u SET account_status = 'active', updated_at = NOW() " +
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
            System.err.println("Error in AdminUserDao.unbanUser: " + e.getMessage());
        }
        return false;
    }

    public boolean changeUserRole(String targetUserId, String newRoleName, String adminId) {
        String deactivateSql = "UPDATE user_roles SET is_active = false, revoked_at = NOW() WHERE user_id = ?::uuid AND is_active = true";
        String getRoleSql = "SELECT id FROM roles WHERE LOWER(name) = LOWER(?)";
        String insertSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?::uuid, ?::uuid)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(deactivateSql)) {
                    ps.setString(1, targetUserId);
                    ps.executeUpdate();
                }

                String roleId = null;
                try (PreparedStatement ps = conn.prepareStatement(getRoleSql)) {
                    ps.setString(1, newRoleName);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            roleId = rs.getString("id");
                        }
                    }
                }

                if (roleId != null) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setString(1, targetUserId);
                        ps.setString(2, roleId);
                        ps.executeUpdate();
                    }
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in AdminUserDao.changeUserRole: " + e.getMessage());
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
