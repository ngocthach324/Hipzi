package com.hipzi.dao;

import com.hipzi.model.ClassroomExam;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ClassroomExamDao {

    public ClassroomExamDao() {
        ensureSchema();
    }

    public List<ClassroomExam> listByClassroom(String classroomId, boolean openOnly) {
        String sql = "SELECT * FROM classroom_exams "
                + "WHERE classroom_id = ?::uuid "
                + (openOnly ? "AND status = 'open' " : "")
                + "ORDER BY created_at DESC";
        List<ClassroomExam> exams = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    exams.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomExamDao.listByClassroom: " + e.getMessage());
        }
        return exams;
    }

    public ClassroomExam findByCode(String examCode) {
        String sql = "SELECT * FROM classroom_exams WHERE UPPER(exam_code) = UPPER(?) LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomExamDao.findByCode: " + e.getMessage());
        }
        return null;
    }

    public boolean create(ClassroomExam exam) {
        String sql = "INSERT INTO classroom_exams "
                + "(classroom_id, title, description, exam_code, source_material_id, status, duration_minutes, created_by) "
                + "VALUES (?::uuid, ?, ?, ?, NULLIF(?, '')::uuid, ?, ?, ?::uuid)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, exam.getClassroomId());
            ps.setString(2, exam.getTitle());
            ps.setString(3, exam.getDescription());
            ps.setString(4, exam.getExamCode());
            ps.setString(5, exam.getSourceMaterialId());
            ps.setString(6, normalizeStatus(exam.getStatus()));
            ps.setInt(7, exam.getDurationMinutes() > 0 ? exam.getDurationMinutes() : 45);
            ps.setString(8, exam.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomExamDao.create: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteForClassroom(String examId, String classroomId) {
        String sql = "DELETE FROM classroom_exams WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            ps.setString(2, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomExamDao.deleteForClassroom: " + e.getMessage());
        }
        return false;
    }

    private ClassroomExam mapRow(ResultSet rs) throws SQLException {
        ClassroomExam exam = new ClassroomExam();
        exam.setId(rs.getString("id"));
        exam.setClassroomId(rs.getString("classroom_id"));
        exam.setTitle(rs.getString("title"));
        exam.setDescription(rs.getString("description"));
        exam.setExamCode(rs.getString("exam_code"));
        exam.setSourceMaterialId(rs.getString("source_material_id"));
        exam.setStatus(rs.getString("status"));
        exam.setDurationMinutes(rs.getInt("duration_minutes"));
        exam.setStartAt(rs.getTimestamp("start_at"));
        exam.setEndAt(rs.getTimestamp("end_at"));
        exam.setCreatedBy(rs.getString("created_by"));
        exam.setCreatedAt(rs.getTimestamp("created_at"));
        exam.setUpdatedAt(rs.getTimestamp("updated_at"));
        return exam;
    }

    private String normalizeStatus(String status) {
        if ("draft".equals(status) || "closed".equals(status)) {
            return status;
        }
        return "open";
    }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS classroom_exams ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,"
                    + "title TEXT NOT NULL,"
                    + "description TEXT,"
                    + "exam_code TEXT NOT NULL UNIQUE,"
                    + "source_material_id UUID REFERENCES classroom_materials(id) ON DELETE SET NULL,"
                    + "status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('draft', 'open', 'closed')),"
                    + "duration_minutes INTEGER NOT NULL DEFAULT 45 CHECK (duration_minutes > 0),"
                    + "start_at TIMESTAMPTZ,"
                    + "end_at TIMESTAMPTZ,"
                    + "created_by UUID REFERENCES users(id) ON DELETE SET NULL,"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_exams_classroom ON classroom_exams(classroom_id, status, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_exams_code ON classroom_exams(exam_code)");
        } catch (SQLException e) {
            System.err.println("Error ensuring classroom_exams schema: " + e.getMessage());
        }
    }
}
