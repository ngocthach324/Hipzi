package com.hipzi.dao;

import com.hipzi.model.CourseOrder;
import com.hipzi.model.CourseOrderItem;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class CourseOrderDao {

    public CourseOrderDao() {
        ensureSchema();
    }

    public CourseOrder createPendingOrder(CourseOrder order) {
        if (order == null || order.getItems() == null || order.getItems().isEmpty()) {
            return null;
        }

        String insertOrder = "INSERT INTO course_orders "
                + "(order_code, student_id, total_amount, currency, status, payment_provider, payment_content, expires_at) "
                + "VALUES (?, ?::uuid, ?, ?, 'pending', ?, ?, ?) "
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
                    ps.setString(5, valueOrDefault(order.getPaymentProvider(), "sepay"));
                    ps.setString(6, order.getPaymentContent());
                    ps.setTimestamp(7, order.getExpiresAt());

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
                + "o.expires_at, o.created_at, o.updated_at "
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

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
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
