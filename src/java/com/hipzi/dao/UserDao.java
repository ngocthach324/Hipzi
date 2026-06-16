package com.hipzi.dao;

import com.hipzi.model.User;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;

public class UserDao {

    // -------------------------------------------------------------------------
    // Helper: map ResultSet row → User object (tránh lặp code)
    // -------------------------------------------------------------------------
    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getString("id"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setDisplayName(rs.getString("display_name"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setAccountStatus(rs.getString("account_status"));
        user.setOauthProvider(rs.getString("oauth_provider"));
        user.setOauthSub(rs.getString("oauth_sub"));
        user.setOnboardingCompleted(rs.getBoolean("onboarding_completed"));
        user.setEmailVerified(rs.getBoolean("email_verified"));
        user.setTwoFactorEnabled(rs.getBoolean("two_factor_enabled"));
        user.setStudentCode(rs.getString("student_code"));
        user.setWalletBalance(rs.getDouble("wallet_balance"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    // -------------------------------------------------------------------------
    // Tìm user theo email (dùng cho login email/password)
    // -------------------------------------------------------------------------
    public User findByEmail(String email) {
        String normalizedEmail = normalizeEmail(email);
        if (normalizedEmail == null) {
            return null;
        }

        String sql = "SELECT * FROM users WHERE LOWER(TRIM(email)) = ? AND deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.findByEmail: " + e.getMessage());
            throw new IllegalStateException("Could not query user by email", e);
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // Tìm user theo OAuth provider + sub (dùng cho Google OAuth callback)
    // -------------------------------------------------------------------------
    public User findByOAuth(String provider, String sub) {
        String sql = "SELECT * FROM users WHERE oauth_provider = ? AND oauth_sub = ? AND deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, provider);
            ps.setString(2, sub);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.findByOAuth: " + e.getMessage());
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // Tạo user mới qua email/password
    // onboarding_completed = TRUE vì user đã chọn role trên form đăng ký
    // -------------------------------------------------------------------------
    public boolean createUser(User user) {
        String normalizedEmail = normalizeEmail(user != null ? user.getEmail() : null);
        if (user == null || normalizedEmail == null) {
            return false;
        }

        String studentCode = generateStudentCode();
        String sql = "INSERT INTO users (email, password_hash, display_name, student_code, account_status, onboarding_completed) " +
                     "VALUES (?, ?, ?, ?, 'active', true) RETURNING id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getDisplayName());
            ps.setString(4, studentCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user.setId(rs.getString("id"));
                    user.setEmail(normalizedEmail);
                    user.setStudentCode(studentCode);
                    user.setOnboardingCompleted(true);
                    return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.createUser: " + e.getMessage());
        }
        return false;
    }

    private String generateStudentCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder("HZ-");
        java.util.Random rnd = new java.util.Random();
        while (sb.length() < 8) { // 3 (HZ-) + 5 random = 8
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    // -------------------------------------------------------------------------
    // Tạo user mới qua Google OAuth (Onboarding Flow - Giải pháp 2)
    // onboarding_completed = FALSE → sẽ redirect sang /onboarding.jsp
    // -------------------------------------------------------------------------
    public boolean createUserFromOAuth(User user) {
        String normalizedEmail = normalizeEmail(user != null ? user.getEmail() : null);
        if (user == null || normalizedEmail == null) {
            return false;
        }

        String studentCode = generateStudentCode();
        String sql = "INSERT INTO users (email, display_name, avatar_url, oauth_provider, oauth_sub, " +
                     "student_code, account_status, onboarding_completed, email_verified) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'active', false, true) RETURNING id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            ps.setString(2, user.getDisplayName());
            ps.setString(3, user.getAvatarUrl());
            ps.setString(4, user.getOauthProvider());
            ps.setString(5, user.getOauthSub());
            ps.setString(6, studentCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user.setId(rs.getString("id"));
                    user.setEmail(normalizedEmail);
                    user.setStudentCode(studentCode);
                    user.setOnboardingCompleted(false);
                    return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.createUserFromOAuth: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Đánh dấu onboarding hoàn thành sau khi user chọn role tại /onboarding.jsp
    // -------------------------------------------------------------------------
    public boolean completeOnboarding(String userId) {
        String sql = "UPDATE users SET onboarding_completed = true, updated_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDao.completeOnboarding: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Cập nhật thông tin user (Họ tên, ảnh đại diện)
    // -------------------------------------------------------------------------
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET display_name = ?, avatar_url = ?, updated_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getDisplayName());
            ps.setString(2, user.getAvatarUrl());
            ps.setString(3, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDao.updateUser: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Tìm user theo ID (dùng khi xác thực 2FA sau đăng nhập)
    // -------------------------------------------------------------------------
    public User findById(String userId) {
        String sql = "SELECT * FROM users WHERE id = ?::uuid AND deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.findById: " + e.getMessage());
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // Bật hoặc tắt 2FA cho user
    // -------------------------------------------------------------------------
    public boolean setTwoFactorEnabled(String userId, boolean enabled) {
        String sql = "UPDATE users SET two_factor_enabled = ?, updated_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, enabled);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDao.setTwoFactorEnabled: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Đánh dấu email đã xác minh thành công
    // -------------------------------------------------------------------------
    public boolean setEmailVerified(String userId) {
        String sql = "UPDATE users SET email_verified = true, updated_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in UserDao.setEmailVerified: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Cập nhật mật khẩu mới cho user
    // -------------------------------------------------------------------------
    public boolean updatePassword(String userId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ?, updated_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection()) {
            // Tắt autoCommit để quản lý giao dịch tường minh qua Supabase pooler
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newPasswordHash);
                ps.setString(2, userId);
                boolean updated = ps.executeUpdate() > 0;
                conn.commit();
                System.out.println("UserDao.updatePassword executed explicit commit for userId: " + userId + ", success: " + updated);
                return updated;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.updatePassword: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Lấy danh sách tất cả ID người dùng (dùng cho broadcast thông báo)
    // -------------------------------------------------------------------------
    // Lấy danh sách tất cả ID người dùng (dùng cho broadcast thông báo)
    // -------------------------------------------------------------------------
    public java.util.List<String> listAllIds() {
        java.util.List<String> ids = new java.util.ArrayList<>();
        String sql = "SELECT id FROM users WHERE deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ids.add(rs.getString("id"));
            }
        } catch (SQLException e) {
            System.err.println("Error in UserDao.listAllIds: " + e.getMessage());
        }
        return ids;
    }

    private String normalizeEmail(String email) {
        if (email == null) {
            return null;
        }
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        return normalized.isEmpty() ? null : normalized;
    }
}
