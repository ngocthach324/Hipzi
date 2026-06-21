package com.hipzi.dao;

import com.hipzi.model.CartItem;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CartDao {

    public CartDao() {
        ensureSchema();
    }

    public boolean addItem(String studentId, String courseId) {
        String sql = "INSERT INTO cart_items (student_id, course_id) VALUES (?::uuid, ?::uuid) " +
                     "ON CONFLICT (student_id, course_id) DO NOTHING";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CartDao.addItem: " + e.getMessage());
        }
        return false;
    }

    public boolean removeItem(String studentId, String courseId) {
        String sql = "DELETE FROM cart_items WHERE student_id = ?::uuid AND course_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CartDao.removeItem: " + e.getMessage());
        }
        return false;
    }

    public boolean clearCart(String studentId) {
        String sql = "DELETE FROM cart_items WHERE student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CartDao.clearCart: " + e.getMessage());
        }
        return false;
    }

    public List<CartItem> findByStudent(String studentId) {
        String sql = "SELECT ci.id, ci.student_id, ci.course_id, ci.added_at, " +
                     "c.title, c.subject_name, c.thumbnail_gradient, c.thumbnail_url, c.price_amount, c.currency, " +
                     "u.display_name AS teacher_name " +
                     "FROM cart_items ci " +
                     "JOIN courses c ON c.id = ci.course_id " +
                     "JOIN users u ON u.id = c.teacher_id " +
                     "WHERE ci.student_id = ?::uuid " +
                     "ORDER BY ci.added_at DESC";
        List<CartItem> items = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getString("id"));
                    item.setStudentId(rs.getString("student_id"));
                    item.setCourseId(rs.getString("course_id"));
                    item.setAddedAt(rs.getTimestamp("added_at"));
                    item.setCourseTitle(rs.getString("title"));
                    item.setCourseSubjectName(rs.getString("subject_name"));
                    item.setThumbnailGradient(rs.getString("thumbnail_gradient"));
                    item.setThumbnailUrl(rs.getString("thumbnail_url"));
                    item.setPriceAmount(rs.getBigDecimal("price_amount"));
                    item.setCurrency(rs.getString("currency"));
                    item.setTeacherName(rs.getString("teacher_name"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CartDao.findByStudent: " + e.getMessage());
        }
        return items;
    }

    public int countByStudent(String studentId) {
        String sql = "SELECT COUNT(*) FROM cart_items WHERE student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CartDao.countByStudent: " + e.getMessage());
        }
        return 0;
    }

    public boolean isInCart(String studentId, String courseId) {
        String sql = "SELECT 1 FROM cart_items WHERE student_id = ?::uuid AND course_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error in CartDao.isInCart: " + e.getMessage());
        }
        return false;
    }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS cart_items (" +
                       "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), " +
                       "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, " +
                       "course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, " +
                       "added_at TIMESTAMPTZ NOT NULL DEFAULT now(), " +
                       "UNIQUE(student_id, course_id))");
            st.execute("CREATE INDEX IF NOT EXISTS idx_cart_items_student ON cart_items(student_id, added_at DESC)");
        } catch (SQLException e) {
            System.err.println("Error in CartDao.ensureSchema: " + e.getMessage());
        }
    }
}
