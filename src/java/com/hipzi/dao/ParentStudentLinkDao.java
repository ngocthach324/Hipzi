package com.hipzi.dao;

import com.hipzi.model.ParentStudentLink;
import com.hipzi.model.ParentClassSummary;
import com.hipzi.model.ParentExamScore;
import com.hipzi.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class ParentStudentLinkDao {

    public boolean createLink(String parentId, String studentId) {
        String updateSql = "UPDATE parent_student_links " +
                           "SET status = 'linked', updated_at = CURRENT_TIMESTAMP " +
                           "WHERE parent_id = ?::uuid AND student_id = ?::uuid";
        String insertSql = "INSERT INTO parent_student_links (parent_id, student_id, status) " +
                           "VALUES (?::uuid, ?::uuid, 'linked')";
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, parentId);
                updatePs.setString(2, studentId);
                if (updatePs.executeUpdate() > 0) {
                    return true;
                }
            }

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, parentId);
                insertPs.setString(2, studentId);
                return insertPs.executeUpdate() > 0;
            } catch (SQLException duplicateOrRace) {
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setString(1, parentId);
                    updatePs.setString(2, studentId);
                    return updatePs.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ParentStudentLinkDao.createLink: " + e.getMessage());
        }
        return false;
    }

    public List<ParentStudentLink> findLinksByParentId(String parentId) {
        List<ParentStudentLink> links = new ArrayList<>();
        String sql = "SELECT l.*, u.display_name as student_name, u.avatar_url as student_avatar, " +
                     "u.student_code, u.email as student_email, sp.grade_level, " +
                     "COALESCE(sp.current_level, 1) as current_level, " +
                     "COALESCE(sp.current_streak, 0) as current_streak, " +
                     "COALESCE(sp.completed_quizzes_count, 0) as completed_quizzes_count " +
                     "FROM parent_student_links l " +
                     "JOIN users u ON l.student_id = u.id " +
                     "LEFT JOIN student_profiles sp ON sp.user_id = u.id " +
                     "WHERE l.parent_id = ?::uuid AND l.status = 'linked' AND u.deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, parentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ParentStudentLink link = new ParentStudentLink();
                    link.setId(rs.getString("id"));
                    link.setParentId(rs.getString("parent_id"));
                    link.setStudentId(rs.getString("student_id"));
                    link.setStatus(rs.getString("status"));
                    link.setCreatedAt(rs.getTimestamp("created_at"));
                    link.setUpdatedAt(rs.getTimestamp("updated_at"));
                    link.setStudentName(rs.getString("student_name"));
                    link.setStudentAvatar(rs.getString("student_avatar"));
                    link.setStudentCode(rs.getString("student_code"));
                    link.setStudentEmail(rs.getString("student_email"));
                    link.setGradeLevel(rs.getString("grade_level"));
                    link.setCurrentLevel(rs.getInt("current_level"));
                    link.setCurrentStreak(rs.getInt("current_streak"));
                    link.setCompletedQuizzesCount(rs.getInt("completed_quizzes_count"));
                    links.add(link);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ParentStudentLinkDao.findLinksByParentId: " + e.getMessage());
        }
        loadStudentLearningData(parentId, links);
        return links;
    }

    private void loadStudentLearningData(String parentId, List<ParentStudentLink> links) {
        if (links == null || links.isEmpty()) return;
        Map<String, ParentStudentLink> byStudent = new HashMap<>();
        for (ParentStudentLink link : links) byStudent.put(link.getStudentId(), link);

        String classSql = "SELECT ce.student_id, c.id AS classroom_id, c.title, c.schedule_days, c.start_time, c.end_time, "
                + "c.tuition_fee, c.tuition_due_date FROM parent_student_links psl "
                + "JOIN classroom_enrollments ce ON ce.student_id=psl.student_id AND ce.status='accepted' "
                + "JOIN classrooms c ON c.id=ce.classroom_id "
                + "WHERE psl.parent_id=?::uuid AND psl.status='linked' ORDER BY c.title";
        String scoreSql = "SELECT ce.student_id, e.id AS exam_id, e.title AS exam_title, MAX(a.score) AS best_score "
                + "FROM parent_student_links psl "
                + "JOIN classroom_enrollments ce ON ce.student_id=psl.student_id AND ce.status='accepted' "
                + "JOIN classroom_exams e ON e.classroom_id=ce.classroom_id "
                + "JOIN classroom_exam_attempts a ON a.exam_id=e.id AND a.student_id=ce.student_id "
                + "WHERE psl.parent_id=?::uuid AND psl.status='linked' AND a.status='completed' AND a.score IS NOT NULL "
                + "GROUP BY ce.student_id,e.id,e.title,e.created_at ORDER BY e.created_at DESC";
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(classSql)) {
                ps.setString(1, parentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ParentStudentLink link = byStudent.get(rs.getString("student_id"));
                        if (link == null) continue;
                        ParentClassSummary item = new ParentClassSummary();
                        item.setClassroomId(rs.getString("classroom_id"));
                        item.setTitle(rs.getString("title"));
                        item.setScheduleDays(rs.getString("schedule_days"));
                        item.setStartTime(rs.getTime("start_time"));
                        item.setEndTime(rs.getTime("end_time"));
                        item.setTuitionFee(rs.getBigDecimal("tuition_fee"));
                        Date dueDate = rs.getDate("tuition_due_date");
                        item.setTuitionDueDate(dueDate != null ? dueDate.toLocalDate() : null);
                        link.getAcceptedClasses().add(item);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(scoreSql)) {
                ps.setString(1, parentId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ParentStudentLink link = byStudent.get(rs.getString("student_id"));
                        if (link == null) continue;
                        ParentExamScore item = new ParentExamScore();
                        item.setExamId(rs.getString("exam_id"));
                        item.setExamTitle(rs.getString("exam_title"));
                        item.setScore(rs.getBigDecimal("best_score"));
                        link.getExamScores().add(item);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ParentStudentLinkDao.loadStudentLearningData: " + e.getMessage());
        }
    }
    public boolean deleteLink(String parentId, String studentId) {
        String sql = "DELETE FROM parent_student_links WHERE parent_id = ?::uuid AND student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, parentId);
            ps.setString(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ParentStudentLinkDao.deleteLink: " + e.getMessage());
        }
        return false;
    }

    public String findStudentIdByCode(String code) {
        String sql = "SELECT u.id " +
                     "FROM users u " +
                     "LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.is_active = true " +
                     "LEFT JOIN roles r ON r.id = ur.role_id " +
                     "LEFT JOIN student_profiles sp ON sp.user_id = u.id " +
                     "WHERE UPPER(u.student_code) = ? " +
                     "AND u.deleted_at IS NULL " +
                     "AND u.account_status = 'active' " +
                     "AND (LOWER(r.name) = 'student' OR sp.user_id IS NOT NULL) " +
                     "LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code == null ? null : code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("id");
            }
        } catch (SQLException e) {
            System.err.println("Error in ParentStudentLinkDao.findStudentIdByCode: " + e.getMessage());
        }
        return null;
    }
}
