package com.hipzi.dao;

import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.Instant;

public class RememberMeTokenDao {

    private static volatile boolean schemaReady = false;

    public boolean createToken(String userId, String selector, String validatorHash, Instant expiresAt) {
        ensureSchema();
        String sql = "INSERT INTO remember_me_tokens (user_id, selector, validator_hash, expires_at) "
                + "VALUES (?::uuid, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, selector);
            ps.setString(3, validatorHash);
            ps.setTimestamp(4, Timestamp.from(expiresAt));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in RememberMeTokenDao.createToken: " + e.getMessage());
        }
        return false;
    }

    public String findValidUserId(String selector, String validatorHash) {
        ensureSchema();
        String sql = "SELECT user_id FROM remember_me_tokens "
                + "WHERE selector = ? "
                + "AND validator_hash = ? "
                + "AND revoked_at IS NULL "
                + "AND expires_at > NOW()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, selector);
            ps.setString(2, validatorHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    touch(selector);
                    return rs.getString("user_id");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RememberMeTokenDao.findValidUserId: " + e.getMessage());
        }
        return null;
    }

    public void revokeBySelector(String selector) {
        ensureSchema();
        String sql = "UPDATE remember_me_tokens SET revoked_at = NOW() "
                + "WHERE selector = ? AND revoked_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, selector);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in RememberMeTokenDao.revokeBySelector: " + e.getMessage());
        }
    }

    public void revokeByUserId(String userId) {
        ensureSchema();
        String sql = "UPDATE remember_me_tokens SET revoked_at = NOW() "
                + "WHERE user_id = ?::uuid AND revoked_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in RememberMeTokenDao.revokeByUserId: " + e.getMessage());
        }
    }

    private void touch(String selector) {
        ensureSchema();
        String sql = "UPDATE remember_me_tokens SET last_used_at = NOW() WHERE selector = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, selector);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in RememberMeTokenDao.touch: " + e.getMessage());
        }
    }

    private void ensureSchema() {
        if (schemaReady) return;
        synchronized (RememberMeTokenDao.class) {
            if (schemaReady) return;
            String sql = "CREATE TABLE IF NOT EXISTS remember_me_tokens ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,"
                    + "selector VARCHAR(64) UNIQUE NOT NULL,"
                    + "validator_hash VARCHAR(128) NOT NULL,"
                    + "expires_at TIMESTAMP WITH TIME ZONE NOT NULL,"
                    + "created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,"
                    + "last_used_at TIMESTAMP WITH TIME ZONE,"
                    + "revoked_at TIMESTAMP WITH TIME ZONE"
                    + ");"
                    + "CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_selector "
                    + "ON remember_me_tokens(selector) WHERE revoked_at IS NULL;"
                    + "CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_user_id "
                    + "ON remember_me_tokens(user_id);";
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {
                st.execute(sql);
                schemaReady = true;
            } catch (SQLException e) {
                System.err.println("Error in RememberMeTokenDao.ensureSchema: " + e.getMessage());
            }
        }
    }
}
