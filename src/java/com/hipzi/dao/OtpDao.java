package com.hipzi.dao;

import com.hipzi.model.OtpCode;
import com.hipzi.util.DBContext;

import java.sql.*;

/**
 * DAO truy cập bảng otp_codes.
 *
 * Quy tắc:
 *   - Chỉ chứa SQL, không chứa business rules.
 *   - Luôn dùng PreparedStatement.
 *   - Đóng Connection, Statement, ResultSet trong try-with-resources.
 */
public class OtpDao {

    // -------------------------------------------------------------------------
    // Helper: ánh xạ ResultSet → OtpCode
    // -------------------------------------------------------------------------
    private OtpCode mapRow(ResultSet rs) throws SQLException {
        OtpCode otp = new OtpCode();
        otp.setId(rs.getString("id"));
        otp.setUserId(rs.getString("user_id"));
        otp.setEmail(rs.getString("email"));
        otp.setCodeHash(rs.getString("code_hash"));
        otp.setPurpose(rs.getString("purpose"));
        otp.setExpiresAt(rs.getTimestamp("expires_at"));
        otp.setUsedAt(rs.getTimestamp("used_at"));
        otp.setAttemptCount(rs.getInt("attempt_count"));
        otp.setCreatedAt(rs.getTimestamp("created_at"));
        return otp;
    }

    // -------------------------------------------------------------------------
    // Tạo bản ghi OTP mới
    // Trả về true nếu insert thành công
    // -------------------------------------------------------------------------
    public boolean insert(OtpCode otp) {
        String sql = "INSERT INTO otp_codes (user_id, email, code_hash, purpose, expires_at) "
                   + "VALUES (?::uuid, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (otp.getUserId() != null) {
                ps.setString(1, otp.getUserId());
            } else {
                ps.setNull(1, Types.OTHER);
            }
            ps.setString(2, otp.getEmail());
            ps.setString(3, otp.getCodeHash());
            ps.setString(4, otp.getPurpose());
            ps.setTimestamp(5, otp.getExpiresAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.insert: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Tìm OTP mới nhất còn hiệu lực theo email + purpose
    // (chưa dùng, chưa hết hạn, attempt_count < 5)
    // -------------------------------------------------------------------------
    public OtpCode findActiveByEmailAndPurpose(String email, String purpose) {
        String sql = "SELECT * FROM otp_codes "
                   + "WHERE email = ? AND purpose = ? AND used_at IS NULL "
                   + "  AND expires_at > NOW() AND attempt_count < 5 "
                   + "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, purpose);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.findActiveByEmailAndPurpose: " + e.getMessage());
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // Đánh dấu OTP đã dùng (vô hiệu hóa)
    // -------------------------------------------------------------------------
    public boolean markUsed(String otpId) {
        String sql = "UPDATE otp_codes SET used_at = NOW() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.markUsed: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Tăng attempt_count khi người dùng nhập sai OTP
    // -------------------------------------------------------------------------
    public boolean incrementAttempt(String otpId) {
        String sql = "UPDATE otp_codes SET attempt_count = attempt_count + 1 WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otpId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.incrementAttempt: " + e.getMessage());
        }
        return false;
    }

    // -------------------------------------------------------------------------
    // Vô hiệu hóa tất cả OTP cũ của email + purpose (trước khi tạo OTP mới)
    // Ngăn người dùng dùng OTP cũ sau khi đã yêu cầu gửi lại
    // -------------------------------------------------------------------------
    public void invalidateOldOtps(String email, String purpose) {
        String sql = "UPDATE otp_codes SET used_at = NOW() "
                   + "WHERE email = ? AND purpose = ? AND used_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, purpose);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.invalidateOldOtps: " + e.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // Kiểm tra rate limit: email có gửi OTP trong vòng 60 giây gần nhất không?
    // Ngăn spam gửi OTP liên tục.
    // -------------------------------------------------------------------------
    public boolean hasRecentOtp(String email, String purpose) {
        String sql = "SELECT 1 FROM otp_codes "
                   + "WHERE email = ? AND purpose = ? AND created_at > NOW() - INTERVAL '60 seconds' "
                   + "LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, purpose);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error in OtpDao.hasRecentOtp: " + e.getMessage());
        }
        return false;
    }
}
