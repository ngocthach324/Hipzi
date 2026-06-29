package com.hipzi.dao;

import com.hipzi.model.PaymentProcessResult;
import com.hipzi.model.TuitionInvoice;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class TuitionInvoiceDao {
    private static final SecureRandom RANDOM = new SecureRandom();

    public TuitionInvoiceDao() {
        ensureSchema();
    }

    public List<TuitionInvoice> listVisibleByStudent(String studentId) {
        List<TuitionInvoice> invoices = new ArrayList<>();
        if (studentId == null || studentId.trim().isEmpty()) return invoices;
        synchronizeStudentInvoices(studentId);
        String sql = baseSelect()
                + "WHERE ti.student_id = ?::uuid "
                + "AND (ti.status = 'paid' OR (ti.status = 'pending' AND ti.due_date <= CURRENT_DATE + 5)) "
                + "ORDER BY CASE WHEN ti.status = 'pending' THEN 0 ELSE 1 END, ti.due_date ASC, ti.paid_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) invoices.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in TuitionInvoiceDao.listVisibleByStudent: " + e.getMessage());
        }
        return invoices;
    }

    public TuitionInvoice findByIdForStudent(String invoiceId, String studentId) {
        if (invoiceId == null || studentId == null) return null;
        String sql = baseSelect() + "WHERE ti.id = ?::uuid AND ti.student_id = ?::uuid LIMIT 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, invoiceId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapRow(rs) : null; }
        } catch (SQLException e) {
            System.err.println("Error in TuitionInvoiceDao.findByIdForStudent: " + e.getMessage());
            return null;
        }
    }

    public PaymentProcessResult processSePayPayment(String invoiceCode, BigDecimal amount,
            String paymentReference, String paymentContent, String providerEventId, String rawPayload) {
        if (invoiceCode == null || invoiceCode.trim().isEmpty()) {
            return PaymentProcessResult.failure("Không tìm thấy mã học phí trong nội dung thanh toán.", "", "failed");
        }
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return PaymentProcessResult.failure("Số tiền webhook không hợp lệ.", invoiceCode, "failed");
        }
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (hasProviderEvent(conn, providerEventId)) {
                    conn.rollback();
                    return PaymentProcessResult.duplicate("Webhook đã được ghi nhận trước đó.", invoiceCode, "duplicate");
                }
                LockedInvoice invoice = lockByCode(conn, invoiceCode);
                String eventId = insertPaymentEvent(conn, invoice, invoiceCode, amount, paymentReference,
                        paymentContent, providerEventId, rawPayload);
                if (invoice == null) {
                    finishEvent(conn, eventId, "failed", "Không tìm thấy hóa đơn học phí.");
                    conn.commit();
                    return PaymentProcessResult.failure("Không tìm thấy hóa đơn học phí.", invoiceCode, "failed");
                }
                if ("paid".equals(invoice.status)) {
                    finishEvent(conn, eventId, "ignored", "Hóa đơn đã được thanh toán.");
                    conn.commit();
                    return PaymentProcessResult.duplicate("Hóa đơn đã được thanh toán trước đó.", invoiceCode, "paid");
                }
                if (!"pending".equals(invoice.status)) {
                    finishEvent(conn, eventId, "ignored", "Hóa đơn không còn chờ thanh toán.");
                    conn.commit();
                    return PaymentProcessResult.failure("Hóa đơn không còn chờ thanh toán.", invoiceCode, invoice.status);
                }
                if (amount.compareTo(invoice.amount) != 0) {
                    finishEvent(conn, eventId, "failed", "Số tiền không khớp học phí.");
                    conn.commit();
                    return PaymentProcessResult.failure("Số tiền chuyển khoản không khớp học phí.", invoiceCode, "amount_mismatch");
                }

                markPaid(conn, invoice.id, paymentReference);
                insertWalletTransaction(conn, invoice.studentId, invoice.amount.negate(), "withdraw", invoice.id,
                        "Thanh toán học phí lớp " + invoice.classroomTitle + " - " + invoice.invoiceCode);
                creditTeacher(conn, invoice.teacherId, invoice.amount);
                insertWalletTransaction(conn, invoice.teacherId, invoice.amount, "deposit", invoice.id,
                        "Nhận học phí lớp " + invoice.classroomTitle + " - " + invoice.invoiceCode);
                finishEvent(conn, eventId, "processed", null);
                conn.commit();
                return PaymentProcessResult.success("Đã ghi nhận thanh toán học phí.", invoiceCode, "paid");
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in TuitionInvoiceDao.processSePayPayment transaction: " + e.getMessage());
                return PaymentProcessResult.failure("Lỗi xử lý thanh toán học phí.", invoiceCode, "failed");
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in TuitionInvoiceDao.processSePayPayment: " + e.getMessage());
            return PaymentProcessResult.failure("Không thể kết nối database.", invoiceCode, "failed");
        }
    }

    private void synchronizeStudentInvoices(String studentId) {
        String sql = "SELECT c.id, c.teacher_id, c.title, c.tuition_fee, c.tuition_due_date "
                + "FROM classroom_enrollments ce JOIN classrooms c ON c.id = ce.classroom_id "
                + "WHERE ce.student_id = ?::uuid AND ce.status = 'accepted' "
                + "AND c.tuition_fee > 0 AND c.tuition_due_date IS NOT NULL";
        String upsert = "INSERT INTO classroom_tuition_invoices "
                + "(invoice_code, classroom_id, student_id, teacher_id, classroom_title, amount, due_date, payment_content) "
                + "VALUES (?, ?::uuid, ?::uuid, ?::uuid, ?, ?, ?::date, ?) "
                + "ON CONFLICT (classroom_id, student_id) DO UPDATE SET "
                + "teacher_id = CASE WHEN classroom_tuition_invoices.status <> 'paid' THEN EXCLUDED.teacher_id ELSE classroom_tuition_invoices.teacher_id END, "
                + "classroom_title = CASE WHEN classroom_tuition_invoices.status <> 'paid' THEN EXCLUDED.classroom_title ELSE classroom_tuition_invoices.classroom_title END, "
                + "amount = CASE WHEN classroom_tuition_invoices.status <> 'paid' THEN EXCLUDED.amount ELSE classroom_tuition_invoices.amount END, "
                + "due_date = CASE WHEN classroom_tuition_invoices.status <> 'paid' THEN EXCLUDED.due_date ELSE classroom_tuition_invoices.due_date END, "
                + "status = CASE WHEN classroom_tuition_invoices.status = 'cancelled' THEN 'pending' ELSE classroom_tuition_invoices.status END, "
                + "updated_at = now()";        try (Connection conn = DBContext.getConnection(); PreparedStatement select = conn.prepareStatement(sql);
                PreparedStatement insert = conn.prepareStatement(upsert)) {
            select.setString(1, studentId);
            try (ResultSet rs = select.executeQuery()) {
                while (rs.next()) {
                    String code = generateInvoiceCode();
                    insert.setString(1, code);
                    insert.setString(2, rs.getString("id"));
                    insert.setString(3, studentId);
                    insert.setString(4, rs.getString("teacher_id"));
                    insert.setString(5, rs.getString("title"));
                    insert.setBigDecimal(6, rs.getBigDecimal("tuition_fee"));
                    insert.setDate(7, rs.getDate("tuition_due_date"));
                    insert.setString(8, code);
                    insert.addBatch();
                }
                insert.executeBatch();
            }
        } catch (SQLException e) {
            System.err.println("Error in TuitionInvoiceDao.synchronizeStudentInvoices: " + e.getMessage());
        }
    }

    private void cancelInvoicesWithoutEnrollment(String studentId) {
        String sql = "UPDATE classroom_tuition_invoices ti SET status='cancelled', updated_at=now() "
                + "WHERE ti.student_id=?::uuid AND ti.status='pending' AND NOT EXISTS ("
                + "SELECT 1 FROM classroom_enrollments ce WHERE ce.classroom_id=ti.classroom_id "
                + "AND ce.student_id=ti.student_id AND ce.status='accepted')";
        try (Connection conn=DBContext.getConnection(); PreparedStatement ps=conn.prepareStatement(sql)) {
            ps.setString(1,studentId); ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in TuitionInvoiceDao.cancelInvoicesWithoutEnrollment: " + e.getMessage());
        }
    }
    private String baseSelect() {
        return "SELECT ti.*, u.display_name AS teacher_name FROM classroom_tuition_invoices ti "
                + "JOIN users u ON u.id = ti.teacher_id ";
    }

    private TuitionInvoice mapRow(ResultSet rs) throws SQLException {
        TuitionInvoice i = new TuitionInvoice();
        i.setId(rs.getString("id"));
        i.setInvoiceCode(rs.getString("invoice_code"));
        i.setClassroomId(rs.getString("classroom_id"));
        i.setStudentId(rs.getString("student_id"));
        i.setTeacherId(rs.getString("teacher_id"));
        i.setClassroomTitle(rs.getString("classroom_title"));
        i.setTeacherName(rs.getString("teacher_name"));
        i.setAmount(rs.getBigDecimal("amount"));
        i.setCurrency(rs.getString("currency"));
        i.setDueDate(rs.getDate("due_date").toLocalDate());
        i.setStatus(rs.getString("status"));
        i.setPaymentContent(rs.getString("payment_content"));
        i.setPaymentReference(rs.getString("payment_reference"));
        i.setPaidAt(rs.getTimestamp("paid_at"));
        i.setCreatedAt(rs.getTimestamp("created_at"));
        return i;
    }

    private boolean hasProviderEvent(Connection conn, String id) throws SQLException {
        if (id == null || id.trim().isEmpty()) return false;
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM payment_events WHERE provider = 'sepay' AND provider_event_id = ? LIMIT 1")) {
            ps.setString(1, id); try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private LockedInvoice lockByCode(Connection conn, String code) throws SQLException {
        String sql = "SELECT id, invoice_code, student_id, teacher_id, classroom_title, amount, status "
                + "FROM classroom_tuition_invoices WHERE UPPER(invoice_code) = UPPER(?) FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                LockedInvoice i = new LockedInvoice();
                i.id=rs.getString("id"); i.invoiceCode=rs.getString("invoice_code");
                i.studentId=rs.getString("student_id"); i.teacherId=rs.getString("teacher_id");
                i.classroomTitle=rs.getString("classroom_title"); i.amount=rs.getBigDecimal("amount"); i.status=rs.getString("status");
                return i;
            }
        }
    }

    private String insertPaymentEvent(Connection conn, LockedInvoice invoice, String code, BigDecimal amount,
            String reference, String content, String providerId, String payload) throws SQLException {
        String sql = "INSERT INTO payment_events (provider, provider_event_id, tuition_invoice_id, order_code, amount, currency, "
                + "payment_reference, payment_content, raw_payload, status) VALUES ('sepay', ?, ?::uuid, ?, ?, 'VND', ?, ?, "
                + "COALESCE(NULLIF(?, ''), '{}')::jsonb, 'received') RETURNING id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, empty(providerId)); ps.setString(2, invoice == null ? null : invoice.id); ps.setString(3, code);
            ps.setBigDecimal(4, amount); ps.setString(5, empty(reference)); ps.setString(6, empty(content)); ps.setString(7, payload);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getString(1) : null; }
        }
    }

    private void finishEvent(Connection conn, String id, String status, String error) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE payment_events SET status=?, last_error=?, processed_at=now() WHERE id=?::uuid")) {
            ps.setString(1,status); ps.setString(2,error); ps.setString(3,id); ps.executeUpdate();
        }
    }
    private void markPaid(Connection conn, String id, String reference) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE classroom_tuition_invoices SET status='paid', payment_reference=?, paid_at=now(), updated_at=now() WHERE id=?::uuid")) {
            ps.setString(1,empty(reference)); ps.setString(2,id); ps.executeUpdate();
        }
    }
    private void creditTeacher(Connection conn, String teacherId, BigDecimal amount) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE users SET wallet_balance=wallet_balance+?, updated_at=now() WHERE id=?::uuid")) {
            ps.setBigDecimal(1,amount); ps.setString(2,teacherId); ps.executeUpdate();
        }
    }
    private void insertWalletTransaction(Connection conn, String userId, BigDecimal amount, String type, String referenceId, String description) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("INSERT INTO wallet_transactions (user_id,amount,transaction_type,reference_id,description) VALUES (?::uuid,?,?,?::uuid,?)")) {
            ps.setString(1,userId); ps.setBigDecimal(2,amount); ps.setString(3,type); ps.setString(4,referenceId); ps.setString(5,description); ps.executeUpdate();
        }
    }
    private String generateInvoiceCode() {
        return "HT" + System.currentTimeMillis() + String.format("%03d", RANDOM.nextInt(1000));
    }
    private String empty(String value) { return value == null || value.trim().isEmpty() ? null : value.trim(); }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection(); Statement st = conn.createStatement()) {
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS tuition_fee NUMERIC(12,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS tuition_due_date DATE");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_tuition_invoices (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), invoice_code VARCHAR(32) UNIQUE NOT NULL, classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE, student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT, classroom_title TEXT NOT NULL, amount NUMERIC(12,2) NOT NULL CHECK(amount>0), currency VARCHAR(10) NOT NULL DEFAULT 'VND', due_date DATE NOT NULL, status VARCHAR(24) NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','paid','cancelled')), payment_content TEXT NOT NULL, payment_reference TEXT, paid_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(classroom_id,student_id))");
            st.execute("CREATE INDEX IF NOT EXISTS idx_tuition_invoices_student ON classroom_tuition_invoices(student_id,status,due_date DESC)");
            st.execute("ALTER TABLE payment_events ADD COLUMN IF NOT EXISTS tuition_invoice_id UUID REFERENCES classroom_tuition_invoices(id) ON DELETE SET NULL");
        } catch (SQLException e) { System.err.println("Error in TuitionInvoiceDao.ensureSchema: " + e.getMessage()); }
    }

    private static class LockedInvoice {
        String id, invoiceCode, studentId, teacherId, classroomTitle, status;
        BigDecimal amount;
    }
}