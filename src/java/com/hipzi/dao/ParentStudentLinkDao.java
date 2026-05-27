package com.hipzi.dao;

import com.hipzi.model.ParentStudentLink;
import com.hipzi.util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
        return links;
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
