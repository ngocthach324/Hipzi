package com.hipzi.dao;

import com.hipzi.model.ClassroomHomeworkSubmission;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassroomHomeworkSubmissionDao {

    public boolean create(ClassroomHomeworkSubmission submission) {
        String sql = "INSERT INTO classroom_homework_submissions "
                + "(classroom_id, student_id, title, note, file_path, original_file_name, file_type, file_size) "
                + "VALUES (?::uuid, ?::uuid, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, submission.getClassroomId());
            ps.setString(2, submission.getStudentId());
            ps.setString(3, submission.getTitle());
            ps.setString(4, submission.getNote());
            ps.setString(5, submission.getFilePath());
            ps.setString(6, submission.getOriginalFileName());
            ps.setString(7, submission.getFileType());
            ps.setLong(8, submission.getFileSize());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomHomeworkSubmissionDao.create: " + e.getMessage());
        }
        return false;
    }

    public ClassroomHomeworkSubmission findById(String id) {
        String sql = baseSelect()
                + "WHERE chs.id = ?::uuid LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomHomeworkSubmissionDao.findById: " + e.getMessage());
        }
        return null;
    }

    public List<ClassroomHomeworkSubmission> listByClassroom(String classroomId) {
        String sql = baseSelect()
                + "WHERE chs.classroom_id = ?::uuid "
                + "ORDER BY chs.submitted_at DESC";

        List<ClassroomHomeworkSubmission> submissions = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    submissions.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomHomeworkSubmissionDao.listByClassroom: " + e.getMessage());
        }
        return submissions;
    }

    public List<ClassroomHomeworkSubmission> listByClassroomAndStudent(String classroomId, String studentId) {
        String sql = baseSelect()
                + "WHERE chs.classroom_id = ?::uuid AND chs.student_id = ?::uuid "
                + "ORDER BY chs.submitted_at DESC";

        List<ClassroomHomeworkSubmission> submissions = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    submissions.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomHomeworkSubmissionDao.listByClassroomAndStudent: " + e.getMessage());
        }
        return submissions;
    }

    private String baseSelect() {
        return "SELECT chs.*, u.display_name AS student_name, u.email AS student_email "
                + "FROM classroom_homework_submissions chs "
                + "LEFT JOIN users u ON u.id = chs.student_id ";
    }

    private ClassroomHomeworkSubmission mapRow(ResultSet rs) throws SQLException {
        ClassroomHomeworkSubmission submission = new ClassroomHomeworkSubmission();
        submission.setId(rs.getString("id"));
        submission.setClassroomId(rs.getString("classroom_id"));
        submission.setStudentId(rs.getString("student_id"));
        submission.setStudentName(readOptionalString(rs, "student_name"));
        submission.setStudentEmail(readOptionalString(rs, "student_email"));
        submission.setTitle(rs.getString("title"));
        submission.setNote(readOptionalString(rs, "note"));
        submission.setFilePath(rs.getString("file_path"));
        submission.setOriginalFileName(rs.getString("original_file_name"));
        submission.setFileType(readOptionalString(rs, "file_type"));
        submission.setFileSize(rs.getLong("file_size"));
        submission.setSubmittedAt(rs.getTimestamp("submitted_at"));
        return submission;
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }
}
