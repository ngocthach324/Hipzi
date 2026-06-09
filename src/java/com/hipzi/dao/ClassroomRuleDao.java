package com.hipzi.dao;

import com.hipzi.model.ClassroomRule;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassroomRuleDao {

    public List<ClassroomRule> findByClassroomId(String classroomId) {
        String sql = "SELECT * FROM classroom_rules "
                + "WHERE classroom_id = ?::uuid "
                + "ORDER BY sort_order ASC, created_at ASC";
        List<ClassroomRule> rules = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classroomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rules.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomRuleDao.findByClassroomId: " + e.getMessage());
        }
        return rules;
    }

    public boolean create(ClassroomRule rule) {
        String sql = "INSERT INTO classroom_rules (classroom_id, title, rule_text, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, rule.getClassroomId());
            ps.setString(2, rule.getTitle());
            ps.setString(3, rule.getRuleText());
            ps.setInt(4, Math.max(1, rule.getSortOrder()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomRuleDao.create: " + e.getMessage());
        }
        return false;
    }

    public boolean updateForClassroom(ClassroomRule rule) {
        String sql = "UPDATE classroom_rules "
                + "SET title = ?, rule_text = ?, sort_order = ?, updated_at = NOW() "
                + "WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, rule.getTitle());
            ps.setString(2, rule.getRuleText());
            ps.setInt(3, Math.max(1, rule.getSortOrder()));
            ps.setString(4, rule.getId());
            ps.setString(5, rule.getClassroomId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomRuleDao.updateForClassroom: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteForClassroom(String ruleId, String classroomId) {
        String sql = "DELETE FROM classroom_rules WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, ruleId);
            ps.setString(2, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomRuleDao.deleteForClassroom: " + e.getMessage());
        }
        return false;
    }

    private ClassroomRule mapRow(ResultSet rs) throws SQLException {
        ClassroomRule rule = new ClassroomRule();
        rule.setId(rs.getString("id"));
        rule.setClassroomId(rs.getString("classroom_id"));
        rule.setTitle(rs.getString("title"));
        rule.setRuleText(rs.getString("rule_text"));
        rule.setSortOrder(rs.getInt("sort_order"));
        rule.setUpdatedBy(rs.getString("updated_by"));
        rule.setCreatedAt(rs.getTimestamp("created_at"));
        rule.setUpdatedAt(rs.getTimestamp("updated_at"));
        return rule;
    }
}
