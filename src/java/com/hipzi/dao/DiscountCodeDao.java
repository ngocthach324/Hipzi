package com.hipzi.dao;

import com.hipzi.model.DiscountCode;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DiscountCodeDao {

    public DiscountCode findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT id, code, discount_amount, max_uses, current_uses, is_active, created_at "
                + "FROM discount_codes "
                + "WHERE code = ?";
                
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DiscountCode dc = new DiscountCode();
                    dc.setId(rs.getString("id"));
                    dc.setCode(rs.getString("code"));
                    dc.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    dc.setMaxUses(rs.getInt("max_uses"));
                    dc.setCurrentUses(rs.getInt("current_uses"));
                    dc.setActive(rs.getBoolean("is_active"));
                    dc.setCreatedAt(rs.getTimestamp("created_at"));
                    return dc;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in DiscountCodeDao.findByCode: " + e.getMessage());
        }
        return null;
    }

    public boolean incrementUses(String id) {
        if (id == null) {
            return false;
        }
        String sql = "UPDATE discount_codes SET current_uses = current_uses + 1 WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in DiscountCodeDao.incrementUses: " + e.getMessage());
        }
        return false;
    }
}
