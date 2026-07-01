package com.hipzi.dao;

import com.hipzi.model.PaymentProcessResult;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class CoursePaymentDao {

    public PaymentProcessResult processSePayPayment(
            String orderCode,
            BigDecimal amount,
            String paymentReference,
            String paymentContent,
            String providerEventId,
            String rawPayload) {

        if (orderCode == null || orderCode.trim().isEmpty()) {
            return PaymentProcessResult.failure("Không tìm thấy mã đơn trong nội dung thanh toán.", "", "failed");
        }
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return PaymentProcessResult.failure("Số tiền webhook không hợp lệ.", orderCode, "failed");
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (providerEventId != null && !providerEventId.trim().isEmpty() && paymentEventExists(conn, providerEventId)) {
                    conn.rollback();
                    return PaymentProcessResult.duplicate("Webhook đã được ghi nhận trước đó.", orderCode, "duplicate");
                }

                LockedOrder order = lockOrder(conn, orderCode);
                String eventId = insertPaymentEvent(conn, order, orderCode, amount, paymentReference, paymentContent, providerEventId, rawPayload);

                if (order == null) {
                    updatePaymentEventStatus(conn, eventId, "failed", "Không tìm thấy đơn thanh toán.");
                    conn.commit();
                    return PaymentProcessResult.failure("Không tìm thấy đơn thanh toán.", orderCode, "failed");
                }

                if ("paid".equalsIgnoreCase(order.status)) {
                    updatePaymentEventStatus(conn, eventId, "ignored", "Đơn hàng đã được thanh toán trước đó.");
                    conn.commit();
                    return PaymentProcessResult.duplicate("Đơn hàng đã được thanh toán trước đó.", orderCode, "paid");
                }

                if (!"pending".equalsIgnoreCase(order.status)) {
                    updatePaymentEventStatus(conn, eventId, "ignored", "Đơn hàng không ở trạng thái chờ thanh toán.");
                    conn.commit();
                    return PaymentProcessResult.failure("Đơn hàng không ở trạng thái chờ thanh toán.", orderCode, order.status);
                }

                if (amount.compareTo(order.totalAmount) != 0) {
                    updatePaymentEventStatus(conn, eventId, "failed", "Số tiền thanh toán không khớp đơn hàng.");
                    conn.commit();
                    return PaymentProcessResult.failure("Số tiền thanh toán không khớp đơn hàng.", orderCode, "amount_mismatch");
                }

                String walletTransactionId = insertWalletTransaction(conn, order);
                int enrolledCount = createEnrollments(conn, order, walletTransactionId);
                creditTeacherWallets(conn, order);
                updateOrderPaid(conn, order.id, paymentReference);
                updatePaymentEventStatus(conn, eventId, "processed", null);
                clearPaidCartItems(conn, order);

                conn.commit();
                return PaymentProcessResult.success("Đã ghi nhận thanh toán cho " + enrolledCount + " khóa học.", orderCode, "paid");
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in CoursePaymentDao.processSePayPayment transaction: " + e.getMessage());
                return PaymentProcessResult.failure("Lỗi xử lý thanh toán: " + e.getMessage(), orderCode, "failed");
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in CoursePaymentDao.processSePayPayment: " + e.getMessage());
            return PaymentProcessResult.failure("Không thể kết nối database để xử lý thanh toán.", orderCode, "failed");
        }
    }

    public void processFreeOrder(String orderCode) {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                LockedOrder order = lockOrder(conn, orderCode);
                if (order != null && "paid".equalsIgnoreCase(order.status)) {
                    String walletTransactionId = insertWalletTransaction(conn, order);
                    createEnrollments(conn, order, walletTransactionId);
                    creditTeacherWallets(conn, order);
                    clearPaidCartItems(conn, order);
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in CoursePaymentDao.processFreeOrder transaction: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in CoursePaymentDao.processFreeOrder: " + e.getMessage());
        }
    }

    private boolean paymentEventExists(Connection conn, String providerEventId) throws SQLException {
        String sql = "SELECT 1 FROM payment_events WHERE provider = 'sepay' AND provider_event_id = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, providerEventId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private LockedOrder lockOrder(Connection conn, String orderCode) throws SQLException {
        String sql = "SELECT id, order_code, student_id, total_amount, currency, status "
                + "FROM course_orders WHERE order_code = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                LockedOrder order = new LockedOrder();
                order.id = rs.getString("id");
                order.orderCode = rs.getString("order_code");
                order.studentId = rs.getString("student_id");
                order.totalAmount = rs.getBigDecimal("total_amount");
                order.currency = rs.getString("currency");
                order.status = rs.getString("status");
                return order;
            }
        }
    }

    private String insertPaymentEvent(
            Connection conn,
            LockedOrder order,
            String orderCode,
            BigDecimal amount,
            String paymentReference,
            String paymentContent,
            String providerEventId,
            String rawPayload) throws SQLException {

        String sql = "INSERT INTO payment_events "
                + "(provider, provider_event_id, order_id, order_code, amount, currency, payment_reference, payment_content, raw_payload, status) "
                + "VALUES ('sepay', ?, ?::uuid, ?, ?, 'VND', ?, ?, COALESCE(NULLIF(?, ''), '{}')::jsonb, 'received') "
                + "RETURNING id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(providerEventId));
            if (order == null) {
                ps.setNull(2, Types.OTHER);
            } else {
                ps.setString(2, order.id);
            }
            ps.setString(3, orderCode);
            ps.setBigDecimal(4, amount);
            ps.setString(5, emptyToNull(paymentReference));
            ps.setString(6, emptyToNull(paymentContent));
            ps.setString(7, rawPayload == null || rawPayload.trim().isEmpty() ? "{}" : rawPayload);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("id") : null;
            }
        }
    }

    private void updatePaymentEventStatus(Connection conn, String eventId, String status, String lastError) throws SQLException {
        if (eventId == null) {
            return;
        }
        String sql = "UPDATE payment_events SET status = ?, last_error = ?, processed_at = now() WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, lastError);
            ps.setString(3, eventId);
            ps.executeUpdate();
        }
    }

    private String insertWalletTransaction(Connection conn, LockedOrder order) throws SQLException {
        String sql = "INSERT INTO wallet_transactions "
                + "(user_id, amount, transaction_type, reference_id, description) "
                + "VALUES (?::uuid, ?, 'withdraw', ?::uuid, ?) RETURNING id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, order.studentId);
            ps.setBigDecimal(2, order.totalAmount.negate());
            ps.setString(3, order.id);
            ps.setString(4, "Thanh toán khóa học qua SePay - " + order.orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("id") : null;
            }
        }
    }

    private int createEnrollments(Connection conn, LockedOrder order, String walletTransactionId) throws SQLException {
        String itemSql = "SELECT course_id, price_amount, currency FROM course_order_items WHERE order_id = ?::uuid";
        int enrolledCount = 0;
        try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
            ps.setString(1, order.id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String courseId = rs.getString("course_id");
                    BigDecimal priceAmount = rs.getBigDecimal("price_amount");
                    String currency = rs.getString("currency");
                    if (insertEnrollment(conn, order, courseId, priceAmount, currency, walletTransactionId)) {
                        insertAccessGrant(conn, courseId, order.studentId);
                        incrementStudentsCount(conn, courseId);
                        enrolledCount++;
                    }
                }
            }
        }
        return enrolledCount;
    }

    private boolean insertEnrollment(
            Connection conn,
            LockedOrder order,
            String courseId,
            BigDecimal priceAmount,
            String currency,
            String walletTransactionId) throws SQLException {
        String sql = "INSERT INTO course_enrollments "
                + "(course_id, student_id, status, price_paid, currency, purchase_transaction_id, purchased_at) "
                + "VALUES (?::uuid, ?::uuid, 'pending_access', ?, ?, ?::uuid, now()) "
                + "ON CONFLICT (course_id, student_id) DO NOTHING";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            ps.setString(2, order.studentId);
            ps.setBigDecimal(3, priceAmount);
            ps.setString(4, currency == null || currency.trim().isEmpty() ? "VND" : currency);
            if (walletTransactionId == null) {
                ps.setNull(5, Types.OTHER);
            } else {
                ps.setString(5, walletTransactionId);
            }
            return ps.executeUpdate() > 0;
        }
    }

    private void insertAccessGrant(Connection conn, String courseId, String studentId) throws SQLException {
        String sql = "INSERT INTO course_access_grants (enrollment_id, course_id, student_id, student_email) "
                + "SELECT e.id, e.course_id, e.student_id, u.email "
                + "FROM course_enrollments e "
                + "JOIN users u ON u.id = e.student_id "
                + "WHERE e.course_id = ?::uuid AND e.student_id = ?::uuid "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM course_access_grants g "
                + "WHERE g.enrollment_id = e.id AND g.status IN ('pending', 'granted'))";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }
    }

    private void incrementStudentsCount(Connection conn, String courseId) throws SQLException {
        String sql = "UPDATE courses SET students_count = students_count + 1 WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            ps.executeUpdate();
        }
    }

    private void updateOrderPaid(Connection conn, String orderId, String paymentReference) throws SQLException {
        String sql = "UPDATE course_orders "
                + "SET status = 'paid', payment_reference = ?, paid_at = now(), updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, emptyToNull(paymentReference));
            ps.setString(2, orderId);
            ps.executeUpdate();
        }
    }

    private void clearPaidCartItems(Connection conn, LockedOrder order) throws SQLException {
        String sql = "DELETE FROM cart_items ci "
                + "USING course_order_items oi "
                + "WHERE oi.order_id = ?::uuid "
                + "AND ci.student_id = ?::uuid "
                + "AND ci.course_id = oi.course_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, order.id);
            ps.setString(2, order.studentId);
            ps.executeUpdate();
        }
    }

    private void creditTeacherWallets(Connection conn, LockedOrder order) throws SQLException {
        String itemSql = "SELECT teacher_id, price_amount, course_id FROM course_order_items "
                + "WHERE order_id = ?::uuid AND teacher_id IS NOT NULL";
        try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
            ps.setString(1, order.id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String teacherId = rs.getString("teacher_id");
                    BigDecimal priceAmount = rs.getBigDecimal("price_amount");
                    String courseId = rs.getString("course_id");
                    if (teacherId != null && priceAmount != null && priceAmount.compareTo(BigDecimal.ZERO) > 0) {
                        addToTeacherWalletBalance(conn, teacherId, priceAmount);
                        insertTeacherWalletTransaction(conn, teacherId, priceAmount, order.id, courseId);
                    }
                }
            }
        }
    }

    private void addToTeacherWalletBalance(Connection conn, String teacherId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users SET wallet_balance = wallet_balance + ?, updated_at = now() WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setString(2, teacherId);
            ps.executeUpdate();
        }
    }

    private void insertTeacherWalletTransaction(Connection conn, String teacherId, BigDecimal amount,
            String orderId, String courseId) throws SQLException {
        String sql = "INSERT INTO wallet_transactions "
                + "(user_id, amount, transaction_type, reference_id, description) "
                + "VALUES (?::uuid, ?, 'deposit', ?::uuid, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            ps.setBigDecimal(2, amount);
            ps.setString(3, orderId);
            String orderRef = orderId != null && orderId.length() >= 8 ? orderId.substring(0, 8).toUpperCase() : "";
            ps.setString(4, "Doanh thu từ bán khóa học - Đơn " + orderRef);
            ps.executeUpdate();
        }
    }

    private String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private static class LockedOrder {
        String id;
        String orderCode;
        String studentId;
        BigDecimal totalAmount;
        String currency;
        String status;
    }
}
