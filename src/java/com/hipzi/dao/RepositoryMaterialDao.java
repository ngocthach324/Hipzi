package com.hipzi.dao;

import com.hipzi.model.Material;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RepositoryMaterialDao {
    private static volatile boolean schemaReady = false;

    public boolean create(Material material) {
        ensureSchema();
        String sql = "INSERT INTO repository_materials "
                + "(title, description, subject, grade, material_type, file_path, original_file_name, "
                + "file_type, file_size, uploaded_by, status, visibility) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, material.getTitle());
            ps.setString(2, material.getDescription());
            ps.setString(3, material.getSubject());
            ps.setString(4, material.getGrade());
            ps.setString(5, normalizeType(material.getType()));
            ps.setString(6, material.getFilePath());
            ps.setString(7, material.getOriginalFileName());
            ps.setString(8, material.getFileType());
            ps.setLong(9, material.getFileSize());
            ps.setString(10, material.getUploadedBy());
            ps.setString(11, normalizeStatus(material.getStatus()));
            ps.setString(12, normalizeVisibility(material.getVisibility()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in RepositoryMaterialDao.create: " + e.getMessage());
        }
        return false;
    }

    public Material findById(String id) {
        ensureSchema();
        String sql = "SELECT rm.*, u.display_name AS teacher_name "
                + "FROM repository_materials rm "
                + "LEFT JOIN users u ON u.id::text = rm.uploaded_by "
                + "WHERE rm.id = ?::uuid AND rm.visibility = 'VISIBLE' "
                + "LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RepositoryMaterialDao.findById: " + e.getMessage());
        }
        return null;
    }

    public List<Material> search(String subject, String grade, String type, String searchQuery, String sort, int page, int pageSize) {
        long startedAt = System.nanoTime();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT rm.id, rm.title, rm.description, rm.subject, rm.grade, rm.material_type, ")
                .append("rm.file_path, rm.original_file_name, rm.file_type, rm.file_size, rm.uploaded_by, ")
                .append("rm.view_count, rm.rating_average, rm.rating_count, rm.status, rm.visibility, rm.created_at, ")
                .append("u.display_name AS teacher_name ")
                .append("FROM repository_materials rm ")
                .append("LEFT JOIN users u ON u.id::text = rm.uploaded_by ")
                .append("WHERE rm.visibility = 'VISIBLE' AND rm.status = 'APPROVED' ");

        if (!isAll(subject)) {
            sql.append("AND rm.subject = ? ");
            params.add(subject);
        }
        if (!isAll(grade)) {
            sql.append("AND rm.grade = ? ");
            params.add(grade);
        }
        if (!isAll(type)) {
            sql.append("AND rm.material_type = ? ");
            params.add(type);
        }
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (rm.title ILIKE ? "
                    + "OR COALESCE(u.display_name, '') ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if ("views".equalsIgnoreCase(sort) || "Xem nhiều nhất".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY rm.view_count DESC, rm.created_at DESC ");
        } else if ("rating".equalsIgnoreCase(sort) || "Đánh giá cao".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY rm.rating_average DESC, rm.rating_count DESC, rm.created_at DESC ");
        } else {
            sql.append("ORDER BY rm.created_at DESC ");
        }

        sql.append("LIMIT ? OFFSET ?");

        List<Material> materials = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            int offset = (page - 1) * pageSize;
            ps.setInt(params.size() + 1, pageSize);
            ps.setInt(params.size() + 2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    materials.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RepositoryMaterialDao.search: " + e.getMessage());
        }
        logPerf("RepositoryMaterialDao.search rows=" + materials.size() + " params=" + params.size(), startedAt);
        return materials;
    }

    public int countSearch(String subject, String grade, String type, String searchQuery) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT count(*) ")
           .append("FROM repository_materials rm ")
           .append("LEFT JOIN users u ON u.id::text = rm.uploaded_by ")
           .append("WHERE rm.visibility = 'VISIBLE' AND rm.status = 'APPROVED' ");

        if (!isAll(subject)) {
            sql.append("AND rm.subject = ? ");
            params.add(subject);
        }
        if (!isAll(grade)) {
            sql.append("AND rm.grade = ? ");
            params.add(grade);
        }
        if (!isAll(type)) {
            sql.append("AND rm.material_type = ? ");
            params.add(type);
        }
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (rm.title ILIKE ? "
                    + "OR COALESCE(u.display_name, '') ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RepositoryMaterialDao.countSearch: " + e.getMessage());
        }
        return 0;
    }

    public void incrementViewCount(String id) {
        ensureSchema();
        String sql = "UPDATE repository_materials SET view_count = view_count + 1, updated_at = now() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in RepositoryMaterialDao.incrementViewCount: " + e.getMessage());
        }
    }

    private Material mapRow(ResultSet rs) throws SQLException {
        Material material = new Material();
        material.setId(rs.getString("id"));
        material.setTitle(rs.getString("title"));
        material.setDescription(rs.getString("description"));
        material.setSubject(rs.getString("subject"));
        material.setGrade(rs.getString("grade"));
        material.setType(rs.getString("material_type"));
        material.setFilePath(rs.getString("file_path"));
        material.setOriginalFileName(rs.getString("original_file_name"));
        material.setFileType(rs.getString("file_type"));
        material.setFileSize(rs.getLong("file_size"));
        material.setUploadedBy(rs.getString("uploaded_by"));
        material.setTeacherName(readOptionalString(rs, "teacher_name"));
        material.setViewCount(rs.getInt("view_count"));
        material.setRatingAverage(rs.getDouble("rating_average"));
        material.setRatingCount(rs.getInt("rating_count"));
        material.setStatus(rs.getString("status"));
        material.setVisibility(rs.getString("visibility"));
        material.setCreatedAt(rs.getTimestamp("created_at"));
        return material;
    }

    private void ensureSchema() {
        if (schemaReady) return;
        synchronized (RepositoryMaterialDao.class) {
            if (schemaReady) return;
            String sql = "CREATE TABLE IF NOT EXISTS repository_materials ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "title TEXT NOT NULL,"
                    + "description TEXT,"
                    + "subject TEXT NOT NULL,"
                    + "grade TEXT NOT NULL,"
                    + "material_type TEXT NOT NULL,"
                    + "file_path TEXT NOT NULL,"
                    + "original_file_name TEXT NOT NULL,"
                    + "file_type TEXT,"
                    + "file_size BIGINT NOT NULL DEFAULT 0,"
                    + "uploaded_by TEXT,"
                    + "view_count INTEGER NOT NULL DEFAULT 0 CHECK (view_count >= 0),"
                    + "rating_average NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (rating_average >= 0 AND rating_average <= 5),"
                    + "rating_count INTEGER NOT NULL DEFAULT 0 CHECK (rating_count >= 0),"
                    + "status VARCHAR(20) NOT NULL DEFAULT 'APPROVED' CHECK (status IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED')),"
                    + "visibility VARCHAR(20) NOT NULL DEFAULT 'VISIBLE' CHECK (visibility IN ('VISIBLE', 'HIDDEN')),"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")";
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {
                st.execute(sql);
                st.execute("CREATE INDEX IF NOT EXISTS idx_repository_materials_filters ON repository_materials(subject, grade, material_type, created_at DESC)");
                st.execute("CREATE INDEX IF NOT EXISTS idx_repository_materials_uploaded_by ON repository_materials(uploaded_by, created_at DESC)");
                st.execute("CREATE INDEX IF NOT EXISTS idx_repository_materials_status_visible ON repository_materials(status, visibility, created_at DESC)");
                schemaReady = true;
            } catch (SQLException e) {
                System.err.println("Error ensuring repository_materials schema: " + e.getMessage());
            }
        }
    }

    private boolean isAll(String value) {
        return value == null || value.trim().isEmpty() || "Tất cả".equalsIgnoreCase(value.trim());
    }

    private String normalizeType(String type) {
        return type == null || type.trim().isEmpty() ? "Lý thuyết" : type.trim();
    }

    private String normalizeStatus(String status) {
        if ("DRAFT".equals(status) || "PENDING".equals(status) || "REJECTED".equals(status)) {
            return status;
        }
        return "APPROVED";
    }

    private String normalizeVisibility(String visibility) {
        return "HIDDEN".equals(visibility) ? "HIDDEN" : "VISIBLE";
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }

    private void logPerf(String label, long startedAt) {
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;
        System.err.println("[PERF] " + label + " " + elapsedMs + "ms");
    }
}
