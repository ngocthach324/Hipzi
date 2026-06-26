package com.hipzi.service;

import com.hipzi.dao.CourseReviewDao;
import com.hipzi.model.CourseReview;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.SQLException;

public class CourseReviewService {
    
    private final CourseReviewDao reviewDao = new CourseReviewDao();

    public boolean submitReview(String courseId, String studentId, int rating, String reviewText) {
        if (rating < 1 || rating > 5) {
            return false;
        }
        
        CourseReview existing = reviewDao.findByCourseAndStudent(courseId, studentId);
        
        CourseReview review = new CourseReview();
        review.setCourseId(courseId);
        review.setStudentId(studentId);
        review.setRating(rating);
        review.setReviewText(reviewText);

        boolean isSuccess = false;
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Start transaction

            if (existing != null) {
                isSuccess = reviewDao.updateReview(conn, review);
            } else {
                isSuccess = reviewDao.insertReview(conn, review);
            }

            if (isSuccess) {
                // Synchronize stats back to courses table
                reviewDao.updateCourseRatingStats(conn, courseId);
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            isSuccess = false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return isSuccess;
    }
}
