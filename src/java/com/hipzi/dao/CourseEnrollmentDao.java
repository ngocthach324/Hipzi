package com.hipzi.dao;

import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class CourseEnrollmentDao {
    
    public boolean enrollFreeCourse(String studentId, String courseId) {
        String sqlEnroll = "INSERT INTO course_enrollments (course_id, student_id, status, price_paid) "
                         + "VALUES (?::uuid, ?::uuid, 'pending_access', 0) "
                         + "ON CONFLICT (course_id, student_id) DO NOTHING";
                         
        String sqlGrant = "INSERT INTO course_access_grants (enrollment_id, course_id, student_id, student_email) "
                        + "SELECT e.id, e.course_id, e.student_id, u.email "
                        + "FROM course_enrollments e "
                        + "JOIN users u ON u.id = e.student_id "
                        + "WHERE e.course_id = ?::uuid AND e.student_id = ?::uuid";
                        
        String sqlUpdateCount = "UPDATE courses SET students_count = students_count + 1 WHERE id = ?::uuid";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlEnroll)) {
                    ps.setString(1, courseId);
                    ps.setString(2, studentId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }
                
                try (PreparedStatement ps = conn.prepareStatement(sqlGrant)) {
                    ps.setString(1, courseId);
                    ps.setString(2, studentId);
                    ps.executeUpdate();
                }
                
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateCount)) {
                    ps.setString(1, courseId);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                System.err.println("Transaction error in enrollFreeCourse: " + ex.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("DB connection error: " + e.getMessage());
        }
        return false;
    }
}
