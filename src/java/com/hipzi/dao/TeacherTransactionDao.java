package com.hipzi.dao;

import com.hipzi.model.TeacherTransaction;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Comparator;
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

        String tuitionSql = "SELECT invoice_code, COALESCE(paid_at, created_at) AS transaction_at, classroom_title, amount, currency, status "
                + "FROM classroom_tuition_invoices WHERE teacher_id = ?::uuid AND status = 'paid' "
                + "ORDER BY COALESCE(paid_at, created_at) DESC LIMIT 80";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(tuitionSql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeacherTransaction tx = new TeacherTransaction();
                    tx.setTransactionCode(rs.getString("invoice_code"));
                    tx.setTransactionAt(rs.getTimestamp("transaction_at"));
                    tx.setDescription("Nhận học phí lớp: " + rs.getString("classroom_title"));
                    tx.setAmount(rs.getBigDecimal("amount"));
                    tx.setCurrency(rs.getString("currency"));
                    tx.setStatus(rs.getString("status"));
                    tx.setCredit(true);
                    transactions.add(tx);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherTransactionDao.findTuitionByTeacherId: " + e.getMessage());
        }
        String withdrawalSql = "SELECT request_code, COALESCE(paid_at, rejected_at, failed_at, requested_at) AS transaction_at, "
                + "amount, currency, status, momo_phone "
                + "FROM teacher_withdrawal_requests "
                + "WHERE teacher_id = ?::uuid "
                + "ORDER BY COALESCE(paid_at, rejected_at, failed_at, requested_at) DESC "
                + "LIMIT 80";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(withdrawalSql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeacherTransaction tx = new TeacherTransaction();
                    tx.setTransactionCode(rs.getString("request_code"));
                    tx.setTransactionAt(rs.getTimestamp("transaction_at"));
                    tx.setDescription("Rút tiền về MoMo: " + rs.getString("momo_phone"));
                    tx.setAmount(rs.getBigDecimal("amount"));
                    tx.setCurrency(rs.getString("currency"));
                    tx.setStatus(normalizeWithdrawalStatus(rs.getString("status")));
                    tx.setCredit(false);
                    transactions.add(tx);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherTransactionDao.findWithdrawalsByTeacherId: " + e.getMessage());
        }

        transactions.sort(Comparator.comparing(
                TeacherTransaction::getTransactionAt,
                Comparator.nullsLast(Comparator.reverseOrder())
        ));
        if (transactions.size() > 80) {
            return new ArrayList<>(transactions.subList(0, 80));
        }

        return transactions;
    }

    private String normalizeWithdrawalStatus(String status) {
        if ("failed".equalsIgnoreCase(status)) {
            return "rejected";
        }
        return status;
    }
}
