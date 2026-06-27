package com.hipzi.dao;

import com.hipzi.model.WithdrawalRequest;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class WithdrawalRequestDao {

    public WithdrawalRequestDao() {
        ensureSchema();
    }

    public WithdrawalRequest createMomoRequest(
            String teacherId,
            BigDecimal amount,
            String momoPhone,
            String receiverName,
            String teacherNote) {
        if (isBlank(teacherId) || amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return null;
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                BigDecimal available = lockAvailableBalance(conn, teacherId);
                if (available == null || available.compareTo(amount) < 0) {
                    conn.rollback();
                    return null;
                }

                String requestCode = nextRequestCode();
                String requestId = insertRequest(conn, requestCode, teacherId, amount, momoPhone, receiverName, teacherNote);
                if (requestId == null) {
                    conn.rollback();
                    return null;
                }
                holdTeacherBalance(conn, teacherId, amount);
                insertWalletTransaction(conn, teacherId, amount.negate(), "withdraw", requestId,
                        "Giữ tiền yêu cầu rút MoMo - " + requestCode);
                conn.commit();
                return findById(requestId);
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in WithdrawalRequestDao.createMomoRequest transaction: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.createMomoRequest: " + e.getMessage());
        }
        return null;
    }

    public boolean markProcessing(String requestId, String staffId, String staffNote) {
        String sql = "UPDATE teacher_withdrawal_requests "
                + "SET status = 'processing', staff_id = ?::uuid, staff_note = ?, processing_at = COALESCE(processing_at, now()), updated_at = now() "
                + "WHERE id = ?::uuid AND status = 'pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, staffId);
            ps.setString(2, emptyToNull(staffNote));
            ps.setString(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.markProcessing: " + e.getMessage());
        }
        return false;
    }

    public boolean markPaid(String requestId, String staffId, String payoutReference, String staffNote) {
        if (isBlank(payoutReference)) {
            return false;
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                WithdrawalRequest request = lockRequest(conn, requestId);
                if (request == null || !request.isOpenStatus()) {
                    conn.rollback();
                    return false;
                }

                BigDecimal amount = valueOrZero(request.getAmount());
                releasePendingAsPaid(conn, request.getTeacherId(), amount);
                updatePaid(conn, requestId, staffId, payoutReference, staffNote);
                insertWalletTransaction(conn, request.getTeacherId(), BigDecimal.ZERO, "withdraw", requestId,
                        "Đã thanh toán yêu cầu rút MoMo - " + request.getRequestCode());
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in WithdrawalRequestDao.markPaid transaction: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.markPaid: " + e.getMessage());
        }
        return false;
    }

    public boolean rejectOrFail(String requestId, String staffId, String status, String staffNote) {
        if (!"rejected".equals(status) && !"failed".equals(status)) {
            return false;
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                WithdrawalRequest request = lockRequest(conn, requestId);
                if (request == null || !request.isOpenStatus()) {
                    conn.rollback();
                    return false;
                }

                BigDecimal amount = valueOrZero(request.getAmount());
                releasePendingToAvailable(conn, request.getTeacherId(), amount);
                updateRejectedOrFailed(conn, requestId, staffId, status, staffNote);
                insertWalletTransaction(conn, request.getTeacherId(), amount, "deposit", requestId,
                        ("failed".equals(status) ? "Hoàn tiền yêu cầu rút MoMo thất bại - " : "Hoàn tiền yêu cầu rút MoMo bị từ chối - ")
                                + request.getRequestCode());
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in WithdrawalRequestDao.rejectOrFail transaction: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.rejectOrFail: " + e.getMessage());
        }
        return false;
    }

    public List<WithdrawalRequest> listByTeacherId(String teacherId, int limit) {
        List<WithdrawalRequest> requests = new ArrayList<>();
        if (isBlank(teacherId)) {
            return requests;
        }
        String sql = baseSelect()
                + "WHERE wr.teacher_id = ?::uuid "
                + "ORDER BY wr.requested_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.listByTeacherId: " + e.getMessage());
        }
        return requests;
    }

    public List<WithdrawalRequest> listForStaff(String status, String search, int limit) {
        List<WithdrawalRequest> requests = new ArrayList<>();
        String normalizedStatus = emptyToNull(status);
        String normalizedSearch = emptyToNull(search);
        StringBuilder sql = new StringBuilder(baseSelect()).append("WHERE 1=1 ");
        if (normalizedStatus != null && !"all".equalsIgnoreCase(normalizedStatus)) {
            sql.append("AND wr.status = ? ");
        }
        if (normalizedSearch != null) {
            sql.append("AND (LOWER(wr.request_code) LIKE ? OR LOWER(u.display_name) LIKE ? OR LOWER(u.email) LIKE ? OR wr.momo_phone LIKE ?) ");
        }
        sql.append("ORDER BY wr.requested_at DESC LIMIT ?");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (normalizedStatus != null && !"all".equalsIgnoreCase(normalizedStatus)) {
                ps.setString(idx++, normalizedStatus);
            }
            if (normalizedSearch != null) {
                String like = "%" + normalizedSearch.toLowerCase(Locale.ROOT) + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, "%" + normalizedSearch + "%");
            }
            ps.setInt(idx, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.listForStaff: " + e.getMessage());
        }
        return requests;
    }

    public WithdrawalRequest findById(String requestId) {
        if (isBlank(requestId)) {
            return null;
        }
        String sql = baseSelect() + "WHERE wr.id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.findById: " + e.getMessage());
        }
        return null;
    }

    private BigDecimal lockAvailableBalance(Connection conn, String teacherId) throws SQLException {
        String sql = "SELECT wallet_balance FROM users WHERE id = ?::uuid FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? valueOrZero(rs.getBigDecimal("wallet_balance")) : null;
            }
        }
    }

    private WithdrawalRequest lockRequest(Connection conn, String requestId) throws SQLException {
        String sql = "SELECT wr.*, u.display_name AS teacher_name, u.email AS teacher_email "
                + "FROM teacher_withdrawal_requests wr "
                + "JOIN users u ON u.id = wr.teacher_id "
                + "WHERE wr.id = ?::uuid FOR UPDATE OF wr";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    private String insertRequest(Connection conn, String requestCode, String teacherId, BigDecimal amount,
            String momoPhone, String receiverName, String teacherNote) throws SQLException {
        String sql = "INSERT INTO teacher_withdrawal_requests "
                + "(request_code, teacher_id, amount, currency, payout_method, momo_phone, receiver_name, teacher_note) "
                + "VALUES (?, ?::uuid, ?, 'VND', 'momo', ?, ?, ?) RETURNING id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, requestCode);
            ps.setString(2, teacherId);
            ps.setBigDecimal(3, amount);
            ps.setString(4, momoPhone);
            ps.setString(5, receiverName);
            ps.setString(6, emptyToNull(teacherNote));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("id") : null;
            }
        }
    }

    private void holdTeacherBalance(Connection conn, String teacherId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users "
                + "SET wallet_balance = wallet_balance - ?, pending_withdrawal_balance = pending_withdrawal_balance + ?, updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setBigDecimal(2, amount);
            ps.setString(3, teacherId);
            ps.executeUpdate();
        }
    }

    private void releasePendingAsPaid(Connection conn, String teacherId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users "
                + "SET pending_withdrawal_balance = GREATEST(pending_withdrawal_balance - ?, 0), "
                + "total_withdrawn = total_withdrawn + ?, updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setBigDecimal(2, amount);
            ps.setString(3, teacherId);
            ps.executeUpdate();
        }
    }

    private void releasePendingToAvailable(Connection conn, String teacherId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users "
                + "SET wallet_balance = wallet_balance + ?, pending_withdrawal_balance = GREATEST(pending_withdrawal_balance - ?, 0), updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, amount);
            ps.setBigDecimal(2, amount);
            ps.setString(3, teacherId);
            ps.executeUpdate();
        }
    }

    private void updatePaid(Connection conn, String requestId, String staffId, String payoutReference, String staffNote) throws SQLException {
        String sql = "UPDATE teacher_withdrawal_requests "
                + "SET status = 'paid', staff_id = ?::uuid, payout_reference = ?, staff_note = ?, paid_at = now(), updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, staffId);
            ps.setString(2, payoutReference);
            ps.setString(3, emptyToNull(staffNote));
            ps.setString(4, requestId);
            ps.executeUpdate();
        }
    }

    private void updateRejectedOrFailed(Connection conn, String requestId, String staffId, String status, String staffNote) throws SQLException {
        String timeColumn = "failed".equals(status) ? "failed_at" : "rejected_at";
        String sql = "UPDATE teacher_withdrawal_requests "
                + "SET status = ?, staff_id = ?::uuid, staff_note = ?, " + timeColumn + " = now(), updated_at = now() "
                + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, staffId);
            ps.setString(3, emptyToNull(staffNote));
            ps.setString(4, requestId);
            ps.executeUpdate();
        }
    }

    private void insertWalletTransaction(Connection conn, String userId, BigDecimal amount, String type,
            String referenceId, String description) throws SQLException {
        String sql = "INSERT INTO wallet_transactions "
                + "(user_id, amount, transaction_type, reference_id, description) "
                + "VALUES (?::uuid, ?, ?, ?::uuid, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setBigDecimal(2, amount);
            ps.setString(3, type);
            ps.setString(4, referenceId);
            ps.setString(5, description);
            ps.executeUpdate();
        }
    }

    private String baseSelect() {
        return "SELECT wr.*, u.display_name AS teacher_name, u.email AS teacher_email, u.wallet_balance AS teacher_wallet_balance "
                + "FROM teacher_withdrawal_requests wr "
                + "JOIN users u ON u.id = wr.teacher_id ";
    }

    private WithdrawalRequest mapRow(ResultSet rs) throws SQLException {
        WithdrawalRequest request = new WithdrawalRequest();
        request.setId(rs.getString("id"));
        request.setRequestCode(rs.getString("request_code"));
        request.setTeacherId(rs.getString("teacher_id"));
        request.setTeacherName(readOptionalString(rs, "teacher_name"));
        request.setTeacherEmail(readOptionalString(rs, "teacher_email"));
        request.setTeacherWalletBalance(readOptionalBigDecimal(rs, "teacher_wallet_balance"));
        request.setAmount(rs.getBigDecimal("amount"));
        request.setCurrency(rs.getString("currency"));
        request.setPayoutMethod(rs.getString("payout_method"));
        request.setMomoPhone(rs.getString("momo_phone"));
        request.setReceiverName(rs.getString("receiver_name"));
        request.setTeacherNote(rs.getString("teacher_note"));
        request.setStatus(rs.getString("status"));
        request.setStaffId(rs.getString("staff_id"));
        request.setStaffNote(rs.getString("staff_note"));
        request.setPayoutReference(rs.getString("payout_reference"));
        request.setRequestedAt(rs.getTimestamp("requested_at"));
        request.setProcessingAt(rs.getTimestamp("processing_at"));
        request.setPaidAt(rs.getTimestamp("paid_at"));
        request.setRejectedAt(rs.getTimestamp("rejected_at"));
        request.setFailedAt(rs.getTimestamp("failed_at"));
        request.setCancelledAt(rs.getTimestamp("cancelled_at"));
        request.setUpdatedAt(rs.getTimestamp("updated_at"));
        return request;
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private BigDecimal readOptionalBigDecimal(ResultSet rs, String columnName) {
        try {
            return rs.getBigDecimal(columnName);
        } catch (SQLException ignored) {
            return null;
        }
    }

    private BigDecimal valueOrZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private String nextRequestCode() {
        return "WD-MOMO-" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase(Locale.ROOT);
    }

    private String emptyToNull(String value) {
        return isBlank(value) ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS pending_withdrawal_balance NUMERIC(12,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS total_withdrawn NUMERIC(12,2) NOT NULL DEFAULT 0");
            st.execute("CREATE TABLE IF NOT EXISTS teacher_withdrawal_requests ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), request_code VARCHAR(32) UNIQUE NOT NULL, "
                    + "teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                    + "amount NUMERIC(12,2) NOT NULL CHECK (amount > 0), currency VARCHAR(10) NOT NULL DEFAULT 'VND', "
                    + "payout_method VARCHAR(20) NOT NULL DEFAULT 'momo', momo_phone VARCHAR(20) NOT NULL, receiver_name TEXT NOT NULL, teacher_note TEXT, "
                    + "status VARCHAR(24) NOT NULL DEFAULT 'pending', staff_id UUID REFERENCES users(id) ON DELETE SET NULL, "
                    + "staff_note TEXT, payout_reference TEXT, requested_at TIMESTAMPTZ NOT NULL DEFAULT now(), processing_at TIMESTAMPTZ, "
                    + "paid_at TIMESTAMPTZ, rejected_at TIMESTAMPTZ, failed_at TIMESTAMPTZ, cancelled_at TIMESTAMPTZ, "
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_teacher_withdrawals_teacher ON teacher_withdrawal_requests(teacher_id, requested_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_teacher_withdrawals_status ON teacher_withdrawal_requests(status, requested_at DESC)");
            st.execute("CREATE TABLE IF NOT EXISTS wallet_transactions ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                    + "amount NUMERIC(12,2) NOT NULL, transaction_type VARCHAR(40) NOT NULL, reference_id UUID, description TEXT, "
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user ON wallet_transactions(user_id, created_at DESC)");
        } catch (SQLException e) {
            System.err.println("Error in WithdrawalRequestDao.ensureSchema: " + e.getMessage());
        }
    }
}
