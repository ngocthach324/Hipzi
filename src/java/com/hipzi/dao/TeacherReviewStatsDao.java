package com.hipzi.dao;

import com.hipzi.model.TeacherReviewStats;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TeacherReviewStatsDao {

    public TeacherReviewStats getStats(String teacherId) {
        TeacherReviewStats stats = new TeacherReviewStats();
        if (teacherId == null || teacherId.trim().isEmpty()) {
            return stats;
        }

        String sql = "SELECT COUNT(*) AS total_reviews, "
                + "COALESCE(AVG(r.rating), 0) AS average_rating, "
                + "COALESCE(SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END), 0) AS satisfied_count, "
                + "COALESCE(SUM(CASE WHEN r.rating IN (3, 4) THEN 1 ELSE 0 END), 0) AS okay_count, "
                + "COALESCE(SUM(CASE WHEN r.rating IN (1, 2) THEN 1 ELSE 0 END), 0) AS needs_improvement_count "
                + "FROM course_reviews r "
                + "JOIN courses c ON c.id = r.course_id "
                + "WHERE c.teacher_id = ?::uuid AND c.deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalReviews(rs.getInt("total_reviews"));
                    stats.setAverageRating(valueOrZero(rs.getBigDecimal("average_rating")));
                    stats.setSatisfiedCount(rs.getInt("satisfied_count"));
                    stats.setOkayCount(rs.getInt("okay_count"));
                    stats.setNeedsImprovementCount(rs.getInt("needs_improvement_count"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherReviewStatsDao.getStats: " + e.getMessage());
        }
        return stats;
    }

    private BigDecimal valueOrZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
