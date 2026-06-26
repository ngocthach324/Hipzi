package com.hipzi.dao;

import com.hipzi.model.CourseReview;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CourseReviewDao {

    public List<CourseReview> findByCourseId(String courseId) {
        List<CourseReview> list = new ArrayList<>();
        String sql = "SELECT r.*, u.display_name AS student_name, u.avatar_url AS student_avatar "
                   + "FROM course_reviews r "
                   + "JOIN users u ON r.student_id = u.id "
                   + "WHERE r.course_id = ?::uuid "
                   + "ORDER BY r.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public CourseReview findByCourseAndStudent(String courseId, String studentId) {
        String sql = "SELECT r.*, u.display_name AS student_name, u.avatar_url AS student_avatar "
                   + "FROM course_reviews r "
                   + "JOIN users u ON r.student_id = u.id "
                   + "WHERE r.course_id = ?::uuid AND r.student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertReview(Connection conn, CourseReview review) throws SQLException {
        String sql = "INSERT INTO course_reviews (course_id, student_id, rating, review_text) "
                   + "VALUES (?::uuid, ?::uuid, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, review.getCourseId());
            ps.setString(2, review.getStudentId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getReviewText());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateReview(Connection conn, CourseReview review) throws SQLException {
        String sql = "UPDATE course_reviews SET rating = ?, review_text = ?, updated_at = now() "
                   + "WHERE course_id = ?::uuid AND student_id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getRating());
            ps.setString(2, review.getReviewText());
            ps.setString(3, review.getCourseId());
            ps.setString(4, review.getStudentId());
            return ps.executeUpdate() > 0;
        }
    }

    public void updateCourseRatingStats(Connection conn, String courseId) throws SQLException {
        String sql = "UPDATE courses SET "
                   + "rating_average = COALESCE((SELECT ROUND(AVG(rating)::numeric, 2) FROM course_reviews WHERE course_id = ?::uuid), 0), "
                   + "rating_count = (SELECT COUNT(*) FROM course_reviews WHERE course_id = ?::uuid) "
                   + "WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            ps.setString(2, courseId);
            ps.setString(3, courseId);
            ps.executeUpdate();
        }
    }

    private CourseReview mapRow(ResultSet rs) throws SQLException {
        CourseReview r = new CourseReview();
        r.setId(rs.getString("id"));
        r.setCourseId(rs.getString("course_id"));
        r.setStudentId(rs.getString("student_id"));
        r.setRating(rs.getInt("rating"));
        r.setReviewText(rs.getString("review_text"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        r.setStudentName(rs.getString("student_name"));
        r.setStudentAvatar(rs.getString("student_avatar"));
        return r;
    }
}
