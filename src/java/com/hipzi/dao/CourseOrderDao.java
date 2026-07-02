package com.hipzi.dao;

import com.hipzi.model.CourseOrder;
import com.hipzi.model.CourseOrderItem;
import com.hipzi.model.StaffCourseTransaction;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class CourseOrderDao {

    public CourseOrderDao() {
        ensureSchema();
    }

    public CourseOrder createPendingOrder(CourseOrder order) {
        if (order == null || order.getItems() == null || order.getItems().isEmpty()) {
            return null;
        }

        String insertOrder = "INSERT INTO course_orders "
                + "(order_code, student_id, total_amount, currency, status, payment_provider, payment_content, expires_at, discount_code_id, discount_amount, paid_at) "
                + "VALUES (?, ?::uuid, ?, ?, ?, ?, ?, ?, ?::uuid, ?, ?) "
                + "RETURNING id, created_at, updated_at";

        String insertItem = "INSERT INTO course_order_items "
                + "(order_id, course_id, teacher_id, course_title, price_amount, currency) "
                + "VALUES (?::uuid, ?::uuid, ?::uuid, ?, ?, ?) "
                + "RETURNING id, created_at";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertOrder)) {
                    ps.setString(1, order.getOrderCode());
                    ps.setString(2, order.getStudentId());
                    ps.setBigDecimal(3, order.getTotalAmount());
                    ps.setString(4, valueOrDefault(order.getCurrency(), "VND"));
                    ps.setString(5, valueOrDefault(order.getStatus(), "pending"));
                    ps.setString(6, valueOrDefault(order.getPaymentProvider(), "sepay"));
                    ps.setString(7, order.getPaymentContent());
                    ps.setTimestamp(8, order.getExpiresAt());
                    ps.setString(9, order.getDiscountCodeId());
                    ps.setBigDecimal(10, order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO);
                    ps.setTimestamp(11, order.getPaidAt());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return null;
                        }
                        order.setId(rs.getString("id"));
                        order.setCreatedAt(rs.getTimestamp("created_at"));
                        order.setUpdatedAt(rs.getTimestamp("updated_at"));
                    }
                }

                for (CourseOrderItem item : order.getItems()) {
                    try (PreparedStatement ps = conn.prepareStatement(insertItem)) {
                        ps.setString(1, order.getId());
                        ps.setString(2, item.getCourseId());
                        if (item.getTeacherId() == null || item.getTeacherId().trim().isEmpty()) {
                            ps.setNull(3, Types.OTHER);
                        } else {
                            ps.setString(3, item.getTeacherId());
                        }
                        ps.setString(4, item.getCourseTitle());
                        ps.setBigDecimal(5, item.getPriceAmount());
                        ps.setString(6, valueOrDefault(item.getCurrency(), "VND"));

                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                item.setId(rs.getString("id"));
                                item.setOrderId(order.getId());
                                item.setCreatedAt(rs.getTimestamp("created_at"));
                            }
                        }
                    }
                }

                conn.commit();
                return order;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error in CourseOrderDao.createPendingOrder transaction: " + e.getMessage());
                return null;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.createPendingOrder: " + e.getMessage());
        }
        return null;
    }

    public CourseOrder findById(String orderId, String studentId) {
        String sql = baseOrderSelect() + "WHERE o.id = ?::uuid AND o.student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CourseOrder order = mapOrder(rs);
                    order.setItems(listItems(conn, order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.findById: " + e.getMessage());
        }
        return null;
    }

    public CourseOrder findByCode(String orderCode) {
        String sql = baseOrderSelect() + "WHERE o.order_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CourseOrder order = mapOrder(rs);
                    order.setItems(listItems(conn, order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.findByCode: " + e.getMessage());
        }
        return null;
    }

    public List<CourseOrder> listPaidByStudentId(String studentId, int limit) {
        List<CourseOrder> orders = new ArrayList<>();
        if (studentId == null || studentId.trim().isEmpty()) {
            return orders;
        }

        String sql = baseOrderSelect()
                + "WHERE o.student_id = ?::uuid AND o.status = 'paid' "
                + "ORDER BY COALESCE(o.paid_at, o.created_at) DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourseOrder order = mapOrder(rs);
                    order.setItems(listItems(conn, order.getId()));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.listPaidByStudentId: " + e.getMessage());
        }
        return orders;
    }

    public List<StaffCourseTransaction> listForStaffTransactions(String status, String search, int limit) {
        List<StaffCourseTransaction> transactions = new ArrayList<>();
        String normalizedStatus = emptyToNull(status);
        String normalizedSearch = emptyToNull(search);
        StringBuilder sql = new StringBuilder()
                .append("SELECT tx.* FROM (")
                .append("SELECT o.order_code, COALESCE(o.paid_at,o.created_at) AS transaction_at, o.status, ")
                .append("oi.course_title, oi.price_amount, oi.currency, student.display_name AS student_name, ")
                .append("student.email AS student_email, teacher.display_name AS teacher_name, teacher.email AS teacher_email ")
                .append("FROM course_order_items oi JOIN course_orders o ON o.id=oi.order_id ")
                .append("JOIN users student ON student.id=o.student_id LEFT JOIN users teacher ON teacher.id=oi.teacher_id ")
                .append("UNION ALL ")
                .append("SELECT ti.invoice_code AS order_code, COALESCE(ti.paid_at,ti.created_at) AS transaction_at, ti.status, ")
                .append("'Học phí lớp: ' || ti.classroom_title AS course_title, ti.amount AS price_amount, ti.currency, ")
                .append("student.display_name AS student_name, student.email AS student_email, ")
                .append("teacher.display_name AS teacher_name, teacher.email AS teacher_email ")
                .append("FROM classroom_tuition_invoices ti JOIN users student ON student.id=ti.student_id ")
                .append("JOIN users teacher ON teacher.id=ti.teacher_id")
                .append(") tx WHERE 1=1 ");
        if (normalizedStatus != null && !"all".equalsIgnoreCase(normalizedStatus)) sql.append("AND tx.status=? ");
        if (normalizedSearch != null) {
            sql.append("AND (LOWER(tx.order_code) LIKE ? OR LOWER(tx.course_title) LIKE ? ")
                    .append("OR LOWER(tx.student_name) LIKE ? OR LOWER(tx.student_email) LIKE ? ")
                    .append("OR LOWER(COALESCE(tx.teacher_name,'')) LIKE ? OR LOWER(COALESCE(tx.teacher_email,'')) LIKE ?) ");
        }
        sql.append("ORDER BY tx.transaction_at DESC LIMIT ?");
        try (Connection conn=DBContext.getConnection(); PreparedStatement ps=conn.prepareStatement(sql.toString())) {
            int idx=1;
            if (normalizedStatus != null && !"all".equalsIgnoreCase(normalizedStatus)) ps.setString(idx++,normalizedStatus);
            if (normalizedSearch != null) {
                String like="%"+normalizedSearch.toLowerCase(Locale.ROOT)+"%";
                for (int i=0;i<6;i++) ps.setString(idx++,like);
            }
            ps.setInt(idx,Math.max(1,limit));
            try (ResultSet rs=ps.executeQuery()) { while(rs.next()) transactions.add(mapStaffTransaction(rs)); }
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.listForStaffTransactions: "+e.getMessage());
        }
        return transactions;
    }
    private List<CourseOrderItem> listItems(Connection conn, String orderId) throws SQLException {
        String sql = "SELECT id, order_id, course_id, teacher_id, course_title, price_amount, currency, created_at "
                + "FROM course_order_items WHERE order_id = ?::uuid ORDER BY created_at ASC";
        List<CourseOrderItem> items = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapItem(rs));
                }
            }
        }
        return items;
    }

    private String baseOrderSelect() {
        return "SELECT o.id, o.order_code, o.student_id, o.total_amount, o.currency, o.status, "
                + "o.payment_provider, o.payment_reference, o.payment_content, o.paid_at, "
                + "o.expires_at, o.created_at, o.updated_at, o.discount_code_id, o.discount_amount "
                + "FROM course_orders o ";
    }

    private CourseOrder mapOrder(ResultSet rs) throws SQLException {
        CourseOrder order = new CourseOrder();
        order.setId(rs.getString("id"));
        order.setOrderCode(rs.getString("order_code"));
        order.setStudentId(rs.getString("student_id"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setCurrency(rs.getString("currency"));
        order.setStatus(rs.getString("status"));
        order.setPaymentProvider(rs.getString("payment_provider"));
        order.setPaymentReference(rs.getString("payment_reference"));
        order.setPaymentContent(rs.getString("payment_content"));
        order.setPaidAt(rs.getTimestamp("paid_at"));
        order.setExpiresAt(rs.getTimestamp("expires_at"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
        order.setDiscountCodeId(rs.getString("discount_code_id"));
        order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        return order;
    }

    private CourseOrderItem mapItem(ResultSet rs) throws SQLException {
        CourseOrderItem item = new CourseOrderItem();
        item.setId(rs.getString("id"));
        item.setOrderId(rs.getString("order_id"));
        item.setCourseId(rs.getString("course_id"));
        item.setTeacherId(rs.getString("teacher_id"));
        item.setCourseTitle(rs.getString("course_title"));
        item.setPriceAmount(rs.getBigDecimal("price_amount"));
        item.setCurrency(rs.getString("currency"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }

    private StaffCourseTransaction mapStaffTransaction(ResultSet rs) throws SQLException {
        StaffCourseTransaction transaction = new StaffCourseTransaction();
        transaction.setOrderCode(rs.getString("order_code"));
        transaction.setTransactionAt(rs.getTimestamp("transaction_at"));
        transaction.setStatus(rs.getString("status"));
        transaction.setCourseTitle(rs.getString("course_title"));
        BigDecimal amount = rs.getBigDecimal("price_amount");
        transaction.setAmount(amount == null ? BigDecimal.ZERO : amount);
        transaction.setCurrency(rs.getString("currency"));
        transaction.setStudentName(rs.getString("student_name"));
        transaction.setStudentEmail(rs.getString("student_email"));
        transaction.setTeacherName(rs.getString("teacher_name"));
        transaction.setTeacherEmail(rs.getString("teacher_email"));
        return transaction;
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS course_orders ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), "
                    + "order_code VARCHAR(32) UNIQUE NOT NULL, "
                    + "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                    + "total_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0), "
                    + "currency VARCHAR(10) NOT NULL DEFAULT 'VND', "
                    + "status VARCHAR(24) NOT NULL DEFAULT 'pending', "
                    + "payment_provider VARCHAR(40) NOT NULL DEFAULT 'sepay', "
                    + "payment_reference TEXT, payment_content TEXT NOT NULL, paid_at TIMESTAMPTZ, expires_at TIMESTAMPTZ, "
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_orders_student ON course_orders(student_id, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_orders_status ON course_orders(status, created_at DESC)");
            st.execute("CREATE TABLE IF NOT EXISTS course_order_items ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), "
                    + "order_id UUID NOT NULL REFERENCES course_orders(id) ON DELETE CASCADE, "
                    + "course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT, "
                    + "teacher_id UUID REFERENCES users(id) ON DELETE SET NULL, "
                    + "course_title TEXT NOT NULL, price_amount NUMERIC(12,2) NOT NULL CHECK (price_amount >= 0), "
                    + "currency VARCHAR(10) NOT NULL DEFAULT 'VND', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), "
                    + "UNIQUE(order_id, course_id))");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_order_items_order ON course_order_items(order_id)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_order_items_course ON course_order_items(course_id)");
            st.execute("CREATE TABLE IF NOT EXISTS payment_events ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), provider VARCHAR(40) NOT NULL DEFAULT 'sepay', "
                    + "provider_event_id TEXT, order_id UUID REFERENCES course_orders(id) ON DELETE SET NULL, order_code VARCHAR(32), "
                    + "amount NUMERIC(12,2), currency VARCHAR(10) NOT NULL DEFAULT 'VND', payment_reference TEXT, payment_content TEXT, "
                    + "raw_payload JSONB NOT NULL DEFAULT '{}'::jsonb, status VARCHAR(24) NOT NULL DEFAULT 'received', "
                    + "last_error TEXT, received_at TIMESTAMPTZ NOT NULL DEFAULT now(), processed_at TIMESTAMPTZ)");
            st.execute("CREATE UNIQUE INDEX IF NOT EXISTS uq_payment_events_provider_event ON payment_events(provider, provider_event_id) WHERE provider_event_id IS NOT NULL");
            st.execute("CREATE INDEX IF NOT EXISTS idx_payment_events_order ON payment_events(order_id, received_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_payment_events_order_code ON payment_events(order_code, received_at DESC)");
        } catch (SQLException e) {
            System.err.println("Error in CourseOrderDao.ensureSchema: " + e.getMessage());
        }
    }
}
