package com.hipzi.dao;

import com.hipzi.model.TeacherTransaction;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TeacherTransactionDao {

    public List<TeacherTransaction> findByTeacherId(String teacherId) {
        List<TeacherTransaction> transactions = new ArrayList<>();
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return transactions;
        }

        String sql = "SELECT co.order_code, COALESCE(co.paid_at, co.created_at) AS transaction_at, "
                + "coi.course_title, coi.price_amount, coi.currency, co.status "
                + "FROM course_order_items coi "
                + "JOIN course_orders co ON co.id = coi.order_id "
                + "WHERE coi.teacher_id = ?::uuid "
                + "AND co.status <> 'pending' "
                + "ORDER BY COALESCE(co.paid_at, co.created_at) DESC "
                + "LIMIT 80";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeacherTransaction tx = new TeacherTransaction();
                    tx.setTransactionCode(rs.getString("order_code"));
                    tx.setTransactionAt(rs.getTimestamp("transaction_at"));
                    tx.setDescription("Học viên mua khóa học: " + rs.getString("course_title"));
                    tx.setAmount(rs.getBigDecimal("price_amount"));
                    tx.setCurrency(rs.getString("currency"));
                    tx.setStatus(rs.getString("status"));
                    tx.setCredit(true);
                    transactions.add(tx);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherTransactionDao.findByTeacherId: " + e.getMessage());
        }

        return transactions;
    }
}
