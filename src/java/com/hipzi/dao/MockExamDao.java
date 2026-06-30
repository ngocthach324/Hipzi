package com.hipzi.dao;

import com.hipzi.model.MockExam;
import com.hipzi.model.MockExamEssay;
import com.hipzi.model.MockExamQuestion;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MockExamDao {
    private static volatile boolean schemaReady = false;

    public MockExamDao() {
        ensureSchema();
    }

    public boolean createMultipleChoice(MockExam exam, List<MockExamQuestion> questions) {
        ensureSchema();
        if (exam == null || questions == null || questions.isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            String examId = insertExam(conn, exam, "multiple_choice");
            insertQuestions(conn, examId, questions);

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("Error in MockExamDao.createMultipleChoice: " + e.getMessage());
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public boolean createEssay(MockExam exam, List<MockExamEssay> essays) {
        ensureSchema();
        if (exam == null || essays == null || essays.isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            String examId = insertExam(conn, exam, "essay");
            insertEssays(conn, examId, essays);

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("Error in MockExamDao.createEssay: " + e.getMessage());
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public List<MockExam> listForStaff(int limit) {
        ensureSchema();
        String sql = "SELECT me.*, u.display_name AS creator_name, "
                + "CASE "
                + "WHEN me.exam_type = 'multiple_choice' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_questions q WHERE q.mock_exam_id = me.id), 0) "
                + "WHEN me.exam_type = 'essay' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_essays e WHERE e.mock_exam_id = me.id), 0) "
                + "ELSE 0 END AS item_count "
                + "FROM mock_exams me "
                + "LEFT JOIN users u ON u.id::text = me.created_by::text "
                + "WHERE me.exam_type IN ('multiple_choice', 'essay') "
                + "ORDER BY me.created_at DESC "
                + "LIMIT ?";
        return list(sql, limit);
    }

    public List<MockExam> listPublishedByType(String type, int limit) {
        ensureSchema();
        String normalizedType = normalizeType(type);
        if (!"multiple_choice".equals(normalizedType) && !"essay".equals(normalizedType)) {
            return new ArrayList<>();
        }

        String sql = "SELECT me.*, u.display_name AS creator_name, "
                + "CASE "
                + "WHEN me.exam_type = 'multiple_choice' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_questions q WHERE q.mock_exam_id = me.id), 0) "
                + "WHEN me.exam_type = 'essay' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_essays e WHERE e.mock_exam_id = me.id), 0) "
                + "ELSE 0 END AS item_count "
                + "FROM mock_exams me "
                + "LEFT JOIN users u ON u.id::text = me.created_by::text "
                + "WHERE me.status = 'published' AND me.exam_type = ? "
                + "ORDER BY me.created_at DESC "
                + "LIMIT ?";

        List<MockExam> exams = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalizedType);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    exams.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in MockExamDao.listPublishedByType: " + e.getMessage());
        }
        return exams;
    }

    private List<MockExam> list(String sql, int limit) {
        List<MockExam> exams = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    exams.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in MockExamDao.list: " + e.getMessage());
        }
        return exams;
    }

    public MockExam findByIdAndStatus(String id, String status) {
        ensureSchema();
        String sql = "SELECT me.*, u.display_name AS creator_name, "
                + "CASE "
                + "WHEN me.exam_type = 'multiple_choice' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_questions q WHERE q.mock_exam_id = me.id), 0) "
                + "WHEN me.exam_type = 'essay' THEN COALESCE((SELECT COUNT(*) FROM mock_exam_essays e WHERE e.mock_exam_id = me.id), 0) "
                + "ELSE 0 END AS item_count "
                + "FROM mock_exams me "
                + "LEFT JOIN users u ON u.id::text = me.created_by::text "
                + "WHERE me.id = ?::uuid AND me.status = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in MockExamDao.findByIdAndStatus: " + e.getMessage());
        }
        return null;
    }

    public List<MockExamQuestion> listQuestionsByExamId(String examId) {
        ensureSchema();
        List<MockExamQuestion> list = new ArrayList<>();
        String sql = "SELECT * FROM mock_exam_questions WHERE mock_exam_id = ?::uuid ORDER BY sort_order ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MockExamQuestion q = new MockExamQuestion();
                    q.setId(rs.getString("id"));
                    q.setMockExamId(rs.getString("mock_exam_id"));
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionA(rs.getString("option_a"));
                    q.setOptionB(rs.getString("option_b"));
                    q.setOptionC(rs.getString("option_c"));
                    q.setOptionD(rs.getString("option_d"));
                    q.setCorrectOption(rs.getString("correct_option"));
                    q.setExplanation(rs.getString("explanation"));
                    q.setSortOrder(rs.getInt("sort_order"));
                    q.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in MockExamDao.listQuestionsByExamId: " + e.getMessage());
        }
        return list;
    }

    public List<MockExamEssay> listEssaysByExamId(String examId) {
        ensureSchema();
        List<MockExamEssay> list = new ArrayList<>();
        String sql = "SELECT * FROM mock_exam_essays WHERE mock_exam_id = ?::uuid ORDER BY sort_order ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MockExamEssay e = new MockExamEssay();
                    e.setId(rs.getString("id"));
                    e.setMockExamId(rs.getString("mock_exam_id"));
                    e.setPromptText(rs.getString("prompt_text"));
                    e.setReferenceAnswer(rs.getString("reference_answer"));
                    e.setSortOrder(rs.getInt("sort_order"));
                    e.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(e);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in MockExamDao.listEssaysByExamId: " + e.getMessage());
        }
        return list;
    }

    private String insertExam(Connection conn, MockExam exam, String type) throws SQLException {
        String sql = "INSERT INTO mock_exams "
                + "(title, description, exam_type, subject, grade_level, duration_minutes, status, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?::uuid) RETURNING id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, exam.getTitle());
            ps.setString(2, exam.getDescription());
            ps.setString(3, type);
            ps.setString(4, exam.getSubject());
            ps.setString(5, exam.getGradeLevel());
            if (exam.getDurationMinutes() == null) {
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(6, exam.getDurationMinutes());
            }
            ps.setString(7, normalizeStatus(exam.getStatus()));
            ps.setString(8, exam.getCreatedBy());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("id");
                }
            }
        }
        throw new SQLException("Cannot create mock exam.");
    }

    private void insertQuestions(Connection conn, String examId, List<MockExamQuestion> questions) throws SQLException {
        String sql = "INSERT INTO mock_exam_questions "
                + "(mock_exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int sort = 1;
            for (MockExamQuestion question : questions) {
                ps.setString(1, examId);
                ps.setString(2, question.getQuestionText());
                ps.setString(3, question.getOptionA());
                ps.setString(4, question.getOptionB());
                ps.setString(5, question.getOptionC());
                ps.setString(6, question.getOptionD());
                ps.setString(7, normalizeCorrectOption(question.getCorrectOption()));
                ps.setString(8, question.getExplanation());
                ps.setInt(9, sort++);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertEssays(Connection conn, String examId, List<MockExamEssay> essays) throws SQLException {
        String sql = "INSERT INTO mock_exam_essays "
                + "(mock_exam_id, prompt_text, reference_answer, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int sort = 1;
            for (MockExamEssay essay : essays) {
                ps.setString(1, examId);
                ps.setString(2, essay.getPromptText());
                ps.setString(3, essay.getReferenceAnswer());
                ps.setInt(4, sort++);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private MockExam mapRow(ResultSet rs) throws SQLException {
        MockExam exam = new MockExam();
        exam.setId(rs.getString("id"));
        exam.setTitle(rs.getString("title"));
        exam.setDescription(rs.getString("description"));
        exam.setExamType(rs.getString("exam_type"));
        exam.setSubject(rs.getString("subject"));
        exam.setGradeLevel(rs.getString("grade_level"));
        int duration = rs.getInt("duration_minutes");
        exam.setDurationMinutes(rs.wasNull() ? null : duration);
        exam.setStatus(rs.getString("status"));
        exam.setCreatedBy(rs.getString("created_by"));
        exam.setCreatorName(rs.getString("creator_name"));
        exam.setItemCount(rs.getInt("item_count"));
        exam.setCreatedAt(rs.getTimestamp("created_at"));
        exam.setUpdatedAt(rs.getTimestamp("updated_at"));
        return exam;
    }

    private String normalizeType(String type) {
        String value = type == null ? "" : type.trim().toLowerCase(Locale.ROOT);
        return "essay".equals(value) ? "essay" : "multiple_choice";
    }

    private String normalizeStatus(String status) {
        String value = status == null ? "" : status.trim().toLowerCase(Locale.ROOT);
        return "published".equals(value) ? "published" : "draft";
    }

    private String normalizeCorrectOption(String value) {
        if (value == null) return "A";
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return normalized.matches("[ABCD]") ? normalized : "A";
    }

    private void ensureSchema() {
        if (schemaReady) return;
        synchronized (MockExamDao.class) {
            if (schemaReady) return;
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {
                st.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto");
                st.execute("CREATE TABLE IF NOT EXISTS mock_exams ("
                        + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                        + "title TEXT NOT NULL,"
                        + "description TEXT,"
                        + "exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice' CHECK (exam_type IN ('multiple_choice','flashcard','essay')),"
                        + "subject TEXT NOT NULL,"
                        + "grade_level TEXT NOT NULL,"
                        + "duration_minutes INTEGER,"
                        + "status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),"
                        + "created_by UUID REFERENCES users(id) ON DELETE SET NULL,"
                        + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                        + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
                st.execute("CREATE INDEX IF NOT EXISTS idx_mock_exams_filters ON mock_exams(exam_type, subject, grade_level, status, created_at DESC)");
                st.execute("CREATE TABLE IF NOT EXISTS mock_exam_questions ("
                        + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                        + "mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,"
                        + "question_text TEXT NOT NULL,"
                        + "option_a TEXT,"
                        + "option_b TEXT,"
                        + "option_c TEXT,"
                        + "option_d TEXT,"
                        + "correct_option CHAR(1) CHECK (correct_option IN ('A','B','C','D')),"
                        + "explanation TEXT,"
                        + "sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),"
                        + "created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
                st.execute("CREATE INDEX IF NOT EXISTS idx_mock_exam_questions_exam_id ON mock_exam_questions(mock_exam_id, sort_order)");
                st.execute("CREATE TABLE IF NOT EXISTS mock_exam_essays ("
                        + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                        + "mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,"
                        + "prompt_text TEXT NOT NULL,"
                        + "reference_answer TEXT,"
                        + "sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),"
                        + "created_at TIMESTAMPTZ NOT NULL DEFAULT now())");
                st.execute("CREATE INDEX IF NOT EXISTS idx_mock_exam_essays_exam_id ON mock_exam_essays(mock_exam_id, sort_order)");
                schemaReady = true;
            } catch (SQLException e) {
                System.err.println("Error ensuring mock exam schema: " + e.getMessage());
            }
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ignored) {}
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ignored) {}
        }
    }
}

