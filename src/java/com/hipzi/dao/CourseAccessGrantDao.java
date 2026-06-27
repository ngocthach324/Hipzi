package com.hipzi.dao;

import com.hipzi.model.CourseAccessGrantJob;
import com.hipzi.model.CourseAccessSummary;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CourseAccessGrantDao {

    public List<CourseAccessGrantJob> listGrantableByOrderCode(String orderCode) {
        List<CourseAccessGrantJob> jobs = new ArrayList<>();
        if (orderCode == null || orderCode.trim().isEmpty()) {
            return jobs;
        }

        String sql = "SELECT g.id AS grant_id, g.enrollment_id, g.course_id, g.student_id, g.student_email, "
                + "c.title AS course_title, c.teacher_id, c.google_drive_file_id, c.google_drive_folder_id, c.require_drive_grant, "
                + "tga.scope AS teacher_google_scope "
                + "FROM course_access_grants g "
                + "JOIN course_order_items oi ON oi.course_id = g.course_id "
                + "JOIN course_orders o ON o.id = oi.order_id AND o.student_id = g.student_id "
                + "JOIN courses c ON c.id = g.course_id "
                + "LEFT JOIN teacher_google_accounts tga ON tga.teacher_id = c.teacher_id AND tga.revoked_at IS NULL "
                + "WHERE o.order_code = ? "
                + "AND o.status = 'paid' "
                + "AND g.status IN ('pending', 'failed') "
                + "ORDER BY g.created_at ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourseAccessGrantJob job = new CourseAccessGrantJob();
                    job.setGrantId(rs.getString("grant_id"));
                    job.setEnrollmentId(rs.getString("enrollment_id"));
                    job.setCourseId(rs.getString("course_id"));
                    job.setStudentId(rs.getString("student_id"));
                    job.setStudentEmail(rs.getString("student_email"));
                    job.setCourseTitle(rs.getString("course_title"));
                    job.setTeacherId(rs.getString("teacher_id"));
                    job.setGoogleDriveFileId(rs.getString("google_drive_file_id"));
                    job.setGoogleDriveFolderId(rs.getString("google_drive_folder_id"));
                    job.setTeacherGoogleScope(rs.getString("teacher_google_scope"));
                    job.setRequireDriveGrant(rs.getBoolean("require_drive_grant"));
                    jobs.add(job);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseAccessGrantDao.listGrantableByOrderCode: " + e.getMessage());
        }
        return jobs;
    }

    public CourseAccessSummary summarizeByOrderId(String orderId) {
        CourseAccessSummary summary = new CourseAccessSummary();
        if (orderId == null || orderId.trim().isEmpty()) {
            return summary;
        }

        String sql = "SELECT COUNT(*) AS total, "
                + "COUNT(*) FILTER (WHERE g.status = 'granted') AS granted, "
                + "COUNT(*) FILTER (WHERE g.status = 'failed' OR g.status = 'revoked') AS failed, "
                + "COUNT(*) FILTER (WHERE g.status = 'pending') AS pending, "
                + "MIN(g.student_email) AS student_email, "
                + "MAX(g.last_error) FILTER (WHERE g.last_error IS NOT NULL) AS last_error "
                + "FROM course_access_grants g "
                + "JOIN course_order_items oi ON oi.course_id = g.course_id "
                + "JOIN course_orders o ON o.id = oi.order_id AND o.student_id = g.student_id "
                + "WHERE o.id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.setTotal(rs.getInt("total"));
                    summary.setGranted(rs.getInt("granted"));
                    summary.setFailed(rs.getInt("failed"));
                    summary.setPending(rs.getInt("pending"));
                    summary.setStudentEmail(rs.getString("student_email"));
                    summary.setLastError(rs.getString("last_error"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseAccessGrantDao.summarizeByOrderId: " + e.getMessage());
        }
        return summary;
    }

    public void markGranted(CourseAccessGrantJob job, String permissionId) {
        String sqlGrant = "UPDATE course_access_grants "
                + "SET status = 'granted', drive_permission_id = ?, granted_at = now(), email_sent_at = now(), "
                + "last_error = NULL, updated_at = now() "
                + "WHERE id = ?::uuid";
        String sqlEnrollment = "UPDATE course_enrollments "
                + "SET status = 'active', access_email = ?, drive_permission_id = ?, access_granted_at = now(), "
                + "last_access_email_sent_at = now(), updated_at = now() "
                + "WHERE id = ?::uuid";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sqlGrant)) {
                ps.setString(1, permissionId);
                ps.setString(2, job.getGrantId());
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlEnrollment)) {
                ps.setString(1, job.getStudentEmail());
                ps.setString(2, permissionId);
                ps.setString(3, job.getEnrollmentId());
                ps.executeUpdate();
            }
            conn.commit();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            System.err.println("Error in CourseAccessGrantDao.markGranted: " + e.getMessage());
        }
    }

    public void markFailed(CourseAccessGrantJob job, String error) {
        String sql = "UPDATE course_access_grants "
                + "SET status = 'failed', last_error = ?, updated_at = now() "
                + "WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, truncate(error, 900));
            ps.setString(2, job.getGrantId());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in CourseAccessGrantDao.markFailed: " + e.getMessage());
        }
    }

    private String truncate(String value, int max) {
        if (value == null) {
            return "";
        }
        return value.length() <= max ? value : value.substring(0, max);
    }
}
