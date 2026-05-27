package com.hipzi.dao;

import com.hipzi.model.ClassroomMaterial;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClassroomMaterialDao {

    public boolean create(ClassroomMaterial material) {
        String sql = "INSERT INTO classroom_materials "
                + "(classroom_id, title, description, material_url, file_path, original_file_name, "
                + "file_type, file_size, category, uploaded_by) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?::uuid)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, material.getClassroomId());
            ps.setString(2, material.getTitle());
            ps.setString(3, material.getDescription());
            ps.setString(4, material.getMaterialUrl());
            ps.setString(5, material.getFilePath());
            ps.setString(6, material.getOriginalFileName());
            ps.setString(7, material.getFileType());
            ps.setLong(8, material.getFileSize());
            ps.setString(9, normalizeCategory(material.getCategory()));
            ps.setString(10, material.getUploadedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomMaterialDao.create: " + e.getMessage());
        }
        return false;
    }

    public ClassroomMaterial findById(String id) {
        String sql = "SELECT cm.*, u.display_name AS uploaded_by_name "
                + "FROM classroom_materials cm "
                + "LEFT JOIN users u ON u.id = cm.uploaded_by "
                + "WHERE cm.id = ?::uuid LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomMaterialDao.findById: " + e.getMessage());
        }
        return null;
    }

    public List<ClassroomMaterial> listByClassroom(String classroomId) {
        String sql = "SELECT cm.*, u.display_name AS uploaded_by_name "
                + "FROM classroom_materials cm "
                + "LEFT JOIN users u ON u.id = cm.uploaded_by "
                + "WHERE cm.classroom_id = ?::uuid "
                + "ORDER BY cm.created_at DESC";

        List<ClassroomMaterial> materials = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    materials.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomMaterialDao.listByClassroom: " + e.getMessage());
        }
        return materials;
    }

    public boolean deleteForClassroom(String materialId, String classroomId) {
        String sql = "DELETE FROM classroom_materials WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, materialId);
            ps.setString(2, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomMaterialDao.deleteForClassroom: " + e.getMessage());
        }
        return false;
    }

    private ClassroomMaterial mapRow(ResultSet rs) throws SQLException {
        ClassroomMaterial material = new ClassroomMaterial();
        material.setId(rs.getString("id"));
        material.setClassroomId(rs.getString("classroom_id"));
        material.setTitle(rs.getString("title"));
        material.setDescription(rs.getString("description"));
        material.setMaterialUrl(readOptionalString(rs, "material_url"));
        material.setFilePath(readOptionalString(rs, "file_path"));
        material.setOriginalFileName(readOptionalString(rs, "original_file_name"));
        material.setFileType(readOptionalString(rs, "file_type"));
        material.setFileSize(readOptionalLong(rs, "file_size"));
        material.setCategory(readOptionalString(rs, "category"));
        material.setUploadedBy(readOptionalString(rs, "uploaded_by"));
        material.setUploadedByName(readOptionalString(rs, "uploaded_by_name"));
        material.setCreatedAt(rs.getTimestamp("created_at"));
        material.setUpdatedAt(readOptionalTimestamp(rs, "updated_at"));
        return material;
    }

    private String normalizeCategory(String category) {
        if ("homework".equals(category) || "exam".equals(category)
                || "theory".equals(category) || "teaching".equals(category)) {
            return category;
        }
        return "document";
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }

    private long readOptionalLong(ResultSet rs, String columnName) {
        try {
            return rs.getLong(columnName);
        } catch (SQLException ignored) {
            return 0L;
        }
    }

    private java.sql.Timestamp readOptionalTimestamp(ResultSet rs, String columnName) {
        try {
            return rs.getTimestamp(columnName);
        } catch (SQLException ignored) {
            return null;
        }
    }
}
