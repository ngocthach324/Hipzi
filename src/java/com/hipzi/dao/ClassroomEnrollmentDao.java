package com.hipzi.dao;

import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassroomEnrollmentDao {

    public ClassroomEnrollment findByClassroomAndStudent(String classroomId, String studentId) {
        String sql = "SELECT ce.*, u.display_name AS student_name, u.email AS student_email "
                + "FROM classroom_enrollments ce "
                + "JOIN users u ON u.id = ce.student_id "
                + "WHERE ce.classroom_id = ?::uuid AND ce.student_id = ?::uuid "
                + "LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomEnrollmentDao.findByClassroomAndStudent: " + e.getMessage());
        }
        return null;
    }

    public boolean requestJoin(String classroomId, String studentId) {
        String sql = "INSERT INTO classroom_enrollments (classroom_id, student_id, status) "
                + "VALUES (?::uuid, ?::uuid, 'pending') "
                + "ON CONFLICT (classroom_id, student_id) DO UPDATE SET "
                + "status = CASE "
                + "WHEN classroom_enrollments.status = 'accepted' THEN classroom_enrollments.status "
                + "ELSE 'pending' END, "
                + "requested_at = CASE "
                + "WHEN classroom_enrollments.status = 'accepted' THEN classroom_enrollments.requested_at "
                + "ELSE now() END, "
                + "reviewed_by = CASE "
                + "WHEN classroom_enrollments.status = 'accepted' THEN classroom_enrollments.reviewed_by "
                + "ELSE NULL END, "
                + "reviewed_at = CASE "
                + "WHEN classroom_enrollments.status = 'accepted' THEN classroom_enrollments.reviewed_at "
                + "ELSE NULL END, "
                + "updated_at = now()";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomEnrollmentDao.requestJoin: " + e.getMessage());
        }
        return false;
    }

    public List<ClassroomEnrollment> listByClassroomAndStatus(String classroomId, String status) {
        String sql = "SELECT ce.*, u.display_name AS student_name, u.email AS student_email "
                + "FROM classroom_enrollments ce "
                + "JOIN users u ON u.id = ce.student_id "
                + "WHERE ce.classroom_id = ?::uuid AND ce.status = ? "
                + "ORDER BY ce.requested_at DESC";

        List<ClassroomEnrollment> enrollments = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    enrollments.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomEnrollmentDao.listByClassroomAndStatus: " + e.getMessage());
        }
        return enrollments;
    }

    public boolean updateStatus(String classroomId, String enrollmentId, String status, String reviewerId) {
        String normalizedStatus = "accepted".equals(status) ? "accepted" : "rejected";
        String sql = "UPDATE classroom_enrollments SET "
                + "status = ?, reviewed_by = ?::uuid, reviewed_at = now(), updated_at = now() "
                + "WHERE id = ?::uuid AND classroom_id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedStatus);
            ps.setString(2, reviewerId);
            ps.setString(3, enrollmentId);
            ps.setString(4, classroomId);
            int changed = ps.executeUpdate();
            if (changed > 0) {
                refreshStudentCount(conn, classroomId);
            }
            return changed > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomEnrollmentDao.updateStatus: " + e.getMessage());
        }
        return false;
    }

    private void refreshStudentCount(Connection conn, String classroomId) throws SQLException {
        String sql = "UPDATE classrooms SET student_count = ("
                + "SELECT COUNT(*) FROM classroom_enrollments "
                + "WHERE classroom_id = ?::uuid AND status = 'accepted'"
                + "), updated_at = now() WHERE id = ?::uuid";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, classroomId);
            ps.executeUpdate();
        }
    }

    private ClassroomEnrollment mapRow(ResultSet rs) throws SQLException {
        ClassroomEnrollment enrollment = new ClassroomEnrollment();
        enrollment.setId(rs.getString("id"));
        enrollment.setClassroomId(rs.getString("classroom_id"));
        enrollment.setStudentId(rs.getString("student_id"));
        enrollment.setStatus(rs.getString("status"));
        enrollment.setRequestedAt(rs.getTimestamp("requested_at"));
        enrollment.setReviewedAt(rs.getTimestamp("reviewed_at"));
        enrollment.setUpdatedAt(rs.getTimestamp("updated_at"));
        enrollment.setStudentName(readOptionalString(rs, "student_name"));
        enrollment.setStudentEmail(readOptionalString(rs, "student_email"));
        return enrollment;
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }
}
