package com.hipzi.dao;

import com.hipzi.model.ClassroomModule;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassroomModuleDao {

    public List<ClassroomModule> findByClassroomId(String classroomId, String moduleType) {
        String sql = "SELECT * FROM classroom_modules "
                + "WHERE classroom_id = ?::uuid AND module_type = ? "
                + "ORDER BY sort_order ASC, created_at ASC";
        List<ClassroomModule> modules = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classroomId);
            ps.setString(2, normalizeModuleType(moduleType));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    modules.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomModuleDao.findByClassroomId: " + e.getMessage());
        }
        return modules;
    }

    public boolean create(ClassroomModule module) {
        String sql = "INSERT INTO classroom_modules (classroom_id, module_type, title, description, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, module.getClassroomId());
            ps.setString(2, normalizeModuleType(module.getModuleType()));
            ps.setString(3, module.getTitle());
            ps.setString(4, module.getDescription());
            ps.setInt(5, Math.max(1, module.getSortOrder()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomModuleDao.create: " + e.getMessage());
        }
        return false;
    }

    public boolean updateForClassroom(ClassroomModule module) {
        String sql = "UPDATE classroom_modules "
                + "SET title = ?, description = ?, sort_order = ?, updated_at = NOW() "
                + "WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, module.getTitle());
            ps.setString(2, module.getDescription());
            ps.setInt(3, Math.max(1, module.getSortOrder()));
            ps.setString(4, module.getId());
            ps.setString(5, module.getClassroomId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomModuleDao.updateForClassroom: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteForClassroom(String moduleId, String classroomId) {
        String sql = "DELETE FROM classroom_modules WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, moduleId);
            ps.setString(2, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomModuleDao.deleteForClassroom: " + e.getMessage());
        }
        return false;
    }

    private String normalizeModuleType(String moduleType) {
        if ("entry_requirement".equals(moduleType)) {
            return "entry_requirement";
        }
        return "learning_content";
    }

    private ClassroomModule mapRow(ResultSet rs) throws SQLException {
        ClassroomModule module = new ClassroomModule();
        module.setId(rs.getString("id"));
        module.setClassroomId(rs.getString("classroom_id"));
        module.setModuleType(rs.getString("module_type"));
        module.setTitle(rs.getString("title"));
        module.setDescription(rs.getString("description"));
        module.setSortOrder(rs.getInt("sort_order"));
        module.setCreatedAt(rs.getTimestamp("created_at"));
        module.setUpdatedAt(rs.getTimestamp("updated_at"));
        return module;
    }
}
