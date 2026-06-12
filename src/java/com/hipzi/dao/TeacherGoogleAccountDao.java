package com.hipzi.dao;

import com.hipzi.model.TeacherGoogleAccount;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

public class TeacherGoogleAccountDao {
    private static volatile boolean schemaReady = false;

    public TeacherGoogleAccount findActiveByTeacherId(String teacherId) {
        ensureSchema();
        String sql = "SELECT * FROM teacher_google_accounts "
                + "WHERE teacher_id = ?::uuid AND revoked_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherGoogleAccountDao.findActiveByTeacherId: " + e.getMessage());
        }
        return null;
    }

    public boolean upsert(TeacherGoogleAccount account) {
        ensureSchema();
        String sql = "INSERT INTO teacher_google_accounts ("
                + "teacher_id, google_user_id, google_email, scope, access_token_encrypted, "
                + "refresh_token_encrypted, token_expires_at, connected_at, revoked_at, updated_at"
                + ") VALUES (?::uuid, ?, ?, ?, ?, ?, ?, NOW(), NULL, NOW()) "
                + "ON CONFLICT (teacher_id) DO UPDATE SET "
                + "google_user_id = EXCLUDED.google_user_id, "
                + "google_email = EXCLUDED.google_email, "
                + "scope = EXCLUDED.scope, "
                + "access_token_encrypted = EXCLUDED.access_token_encrypted, "
                + "refresh_token_encrypted = COALESCE(NULLIF(EXCLUDED.refresh_token_encrypted, ''), teacher_google_accounts.refresh_token_encrypted), "
                + "token_expires_at = EXCLUDED.token_expires_at, "
                + "connected_at = NOW(), "
                + "revoked_at = NULL, "
                + "updated_at = NOW()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, account.getTeacherId());
            ps.setString(2, account.getGoogleUserId());
            ps.setString(3, account.getGoogleEmail());
            ps.setString(4, account.getScope());
            ps.setString(5, account.getAccessTokenEncrypted());
            ps.setString(6, account.getRefreshTokenEncrypted());
            ps.setTimestamp(7, account.getTokenExpiresAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeacherGoogleAccountDao.upsert: " + e.getMessage());
        }
        return false;
    }

    public boolean updateAccessToken(String teacherId, String accessTokenEncrypted, Timestamp tokenExpiresAt) {
        ensureSchema();
        String sql = "UPDATE teacher_google_accounts SET "
                + "access_token_encrypted = ?, token_expires_at = ?, last_refreshed_at = NOW(), updated_at = NOW() "
                + "WHERE teacher_id = ?::uuid AND revoked_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, accessTokenEncrypted);
            ps.setTimestamp(2, tokenExpiresAt);
            ps.setString(3, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeacherGoogleAccountDao.updateAccessToken: " + e.getMessage());
        }
        return false;
    }

    public boolean revoke(String teacherId) {
        ensureSchema();
        String sql = "UPDATE teacher_google_accounts SET revoked_at = NOW(), updated_at = NOW() "
                + "WHERE teacher_id = ?::uuid AND revoked_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeacherGoogleAccountDao.revoke: " + e.getMessage());
        }
        return false;
    }

    private TeacherGoogleAccount map(ResultSet rs) throws SQLException {
        TeacherGoogleAccount account = new TeacherGoogleAccount();
        account.setId(rs.getString("id"));
        account.setTeacherId(rs.getString("teacher_id"));
        account.setGoogleUserId(rs.getString("google_user_id"));
        account.setGoogleEmail(rs.getString("google_email"));
        account.setScope(rs.getString("scope"));
        account.setAccessTokenEncrypted(rs.getString("access_token_encrypted"));
        account.setRefreshTokenEncrypted(rs.getString("refresh_token_encrypted"));
        account.setTokenExpiresAt(rs.getTimestamp("token_expires_at"));
        account.setConnectedAt(rs.getTimestamp("connected_at"));
        account.setLastRefreshedAt(rs.getTimestamp("last_refreshed_at"));
        account.setRevokedAt(rs.getTimestamp("revoked_at"));
        account.setCreatedAt(rs.getTimestamp("created_at"));
        account.setUpdatedAt(rs.getTimestamp("updated_at"));
        return account;
    }

    private void ensureSchema() {
        if (schemaReady) return;
        synchronized (TeacherGoogleAccountDao.class) {
            if (schemaReady) return;
            String sql = "CREATE TABLE IF NOT EXISTS teacher_google_accounts ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,"
                    + "google_user_id TEXT NOT NULL,"
                    + "google_email TEXT NOT NULL,"
                    + "scope TEXT NOT NULL,"
                    + "access_token_encrypted TEXT,"
                    + "refresh_token_encrypted TEXT,"
                    + "token_expires_at TIMESTAMPTZ,"
                    + "connected_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "last_refreshed_at TIMESTAMPTZ,"
                    + "revoked_at TIMESTAMPTZ,"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "UNIQUE(teacher_id)"
                    + ");"
                    + "CREATE INDEX IF NOT EXISTS idx_teacher_google_accounts_teacher_active "
                    + "ON teacher_google_accounts(teacher_id) WHERE revoked_at IS NULL;"
                    + "CREATE INDEX IF NOT EXISTS idx_teacher_google_accounts_google_user "
                    + "ON teacher_google_accounts(google_user_id);";
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {
                st.execute(sql);
                schemaReady = true;
            } catch (SQLException e) {
                System.err.println("Error in TeacherGoogleAccountDao.ensureSchema: " + e.getMessage());
            }
        }
    }
}
