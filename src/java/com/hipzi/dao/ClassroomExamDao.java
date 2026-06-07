package com.hipzi.dao;

import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import com.hipzi.dto.ClassroomExamAttemptDto;
import com.hipzi.model.ClassroomExamAttempt;
import com.hipzi.model.ClassroomExamAnswer;

public class ClassroomExamDao {

    private final ThreadLocal<String> lastError = new ThreadLocal<>();

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
            attachQuestions(conn, exams);
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
                    ClassroomExam exam = mapRow(rs);
                    exam.setQuestions(listQuestions(conn, exam.getId()));
                    return exam;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomExamDao.findByCode: " + e.getMessage());
        }
        return null;
    }

    public boolean create(ClassroomExam exam) {
        return createWithQuestions(exam, exam != null ? exam.getQuestions() : null);
    }

    public boolean createWithQuestions(ClassroomExam exam, List<ClassroomExamQuestion> questions) {
        lastError.remove();
        String sql = "INSERT INTO classroom_exams "
                + "(classroom_id, title, description, exam_code, exam_type, creation_mode, raw_source_text, "
                + "source_material_id, status, max_score, duration_minutes, start_at, end_at, created_by) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, NULLIF(?, '')::uuid, ?, ?, ?, ?, ?, ?::uuid) RETURNING id";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, exam.getClassroomId());
                ps.setString(2, exam.getTitle());
                ps.setString(3, exam.getDescription());
                ps.setString(4, exam.getExamCode());
                ps.setString(5, normalizeExamType(exam.getExamType()));
                ps.setString(6, normalizeCreationMode(exam.getCreationMode()));
                ps.setString(7, exam.getRawSourceText());
                ps.setString(8, exam.getSourceMaterialId());
                ps.setString(9, normalizeStatus(exam.getStatus()));
                ps.setDouble(10, exam.getMaxScore() != null && exam.getMaxScore() > 0 ? exam.getMaxScore() : 10.0);
                ps.setInt(11, exam.getDurationMinutes() > 0 ? exam.getDurationMinutes() : 45);
                ps.setTimestamp(12, exam.getStartAt());
                ps.setTimestamp(13, exam.getEndAt());
                ps.setString(14, exam.getCreatedBy());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exam.setId(rs.getString("id"));
                    }
                }
            }
            insertQuestions(conn, exam.getId(), questions);
            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            lastError.set(e.getMessage());
            System.err.println("Error in ClassroomExamDao.createWithQuestions: " + e.getMessage());
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public boolean updateMetadata(ClassroomExam exam) {
        lastError.remove();
        String sql = "UPDATE classroom_exams SET title = ?, description = ?, exam_code = ?, max_score = ?, duration_minutes = ?, start_at = ?, end_at = ?, updated_at = now() WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, exam.getTitle());
            ps.setString(2, exam.getDescription());
            ps.setString(3, exam.getExamCode());
            ps.setDouble(4, exam.getMaxScore() != null && exam.getMaxScore() > 0 ? exam.getMaxScore() : 10.0);
            ps.setInt(5, exam.getDurationMinutes() > 0 ? exam.getDurationMinutes() : 45);
            ps.setTimestamp(6, exam.getStartAt());
            ps.setTimestamp(7, exam.getEndAt());
            ps.setString(8, exam.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            lastError.set(e.getMessage());
            System.err.println("Error in ClassroomExamDao.updateMetadata: " + e.getMessage());
        }
        return false;
    }

    public String getLastError() {
        return lastError.get();
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
        exam.setExamType(rs.getString("exam_type"));
        exam.setCreationMode(rs.getString("creation_mode"));
        exam.setRawSourceText(rs.getString("raw_source_text"));
        exam.setSourceMaterialId(rs.getString("source_material_id"));
        exam.setStatus(rs.getString("status"));
        exam.setMaxScore(rs.getDouble("max_score"));
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

    private String normalizeExamType(String examType) {
        if ("essay".equals(examType) || "flashcard".equals(examType)) {
            return examType;
        }
        return "multiple_choice";
    }

    private String normalizeCreationMode(String creationMode) {
        return "ai".equals(creationMode) ? "ai" : "manual";
    }

    private void attachQuestions(Connection conn, List<ClassroomExam> exams) throws SQLException {
        if (exams == null) {
            return;
        }
        for (ClassroomExam exam : exams) {
            exam.setQuestions(listQuestions(conn, exam.getId()));
        }
    }

    private List<ClassroomExamQuestion> listQuestions(Connection conn, String examId) throws SQLException {
        String sql = "SELECT * FROM classroom_exam_questions WHERE exam_id = ?::uuid ORDER BY sort_order ASC";
        List<ClassroomExamQuestion> questions = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ClassroomExamQuestion question = new ClassroomExamQuestion();
                    question.setId(rs.getString("id"));
                    question.setExamId(rs.getString("exam_id"));
                    question.setQuestionText(rs.getString("question_text"));
                    question.setOptionA(rs.getString("option_a"));
                    question.setOptionB(rs.getString("option_b"));
                    question.setOptionC(rs.getString("option_c"));
                    question.setOptionD(rs.getString("option_d"));
                    question.setCorrectOption(rs.getString("correct_option"));
                    question.setReferenceAnswer(rs.getString("reference_answer"));
                    question.setPoints(rs.getDouble("points"));
                    question.setSortOrder(rs.getInt("sort_order"));
                    question.setCreatedAt(rs.getTimestamp("created_at"));
                    questions.add(question);
                }
            }
        }
        return questions;
    }

    private void insertQuestions(Connection conn, String examId, List<ClassroomExamQuestion> questions) throws SQLException {
        if (questions == null || questions.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO classroom_exam_questions "
                + "(exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, reference_answer, points, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int order = 1;
            for (ClassroomExamQuestion question : questions) {
                if (isBlank(question.getQuestionText())) {
                    continue;
                }
                ps.setString(1, examId);
                ps.setString(2, question.getQuestionText());
                ps.setString(3, question.getOptionA());
                ps.setString(4, question.getOptionB());
                ps.setString(5, question.getOptionC());
                ps.setString(6, question.getOptionD());
                String correct = normalizeOption(question.getCorrectOption());
                ps.setString(7, correct.isEmpty() ? null : correct);
                ps.setString(8, question.getReferenceAnswer());
                ps.setDouble(9, question.getPoints() != null && question.getPoints() > 0 ? question.getPoints() : 1.0);
                ps.setInt(10, order++);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private String normalizeOption(String option) {
        if (option == null) {
            return "";
        }
        String cleaned = option.trim().toUpperCase();
        return cleaned.matches("[ABCD]") ? cleaned : "";
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
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
            } catch (SQLException ignored) {
            }
        }
    }

    public List<ClassroomExamQuestion> getQuestionsByExamId(String examId) {
        try (Connection conn = DBContext.getConnection()) {
            return listQuestions(conn, examId);
        } catch (SQLException e) {
            lastError.set("Database error loading questions: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public List<ClassroomExamAttemptDto> listAttempts(String examId) {
        List<ClassroomExamAttemptDto> attempts = new ArrayList<>();
        // Fetch ALL accepted students in the classroom and LEFT JOIN their attempts
        String sql = "SELECT u.id as user_id, u.full_name, u.email, u.avatar_url, "
                   + "a.id as attempt_id, a.exam_id, a.score, a.total_questions, "
                   + "a.violation_count, a.status, a.started_at, a.submitted_at "
                   + "FROM classroom_enrollments ce "
                   + "JOIN users u ON ce.student_id = u.id "
                   + "JOIN classroom_exams e ON e.classroom_id = ce.classroom_id "
                   + "LEFT JOIN classroom_exam_attempts a ON a.student_id = u.id AND a.exam_id = e.id "
                   + "WHERE e.id = ?::uuid AND ce.status = 'accepted' "
                   + "ORDER BY a.started_at DESC NULLS LAST, u.full_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ClassroomExamAttemptDto dto = new ClassroomExamAttemptDto();
                    dto.setStudentName(rs.getString("full_name"));
                    dto.setStudentEmail(rs.getString("email"));
                    dto.setStudentAvatar(rs.getString("avatar_url"));
                    
                    attempts.add(dto);
                }
            }
        } catch (SQLException e) {
            lastError.set("Database error loading attempts: " + e.getMessage());
        }
        return attempts;
    }

    public boolean hasStudentSubmitted(String examId, String studentId) {
        String sql = "SELECT COUNT(*) FROM classroom_exam_attempts WHERE exam_id = ?::uuid AND student_id = ?::uuid AND status = 'completed'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            lastError.set("Database error checking submission: " + e.getMessage());
        }
        return false;
    }

    public boolean startAttempt(String examId, String studentId) {
        String checkSql = "SELECT id FROM classroom_exam_attempts WHERE exam_id = ?::uuid AND student_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setString(1, examId);
            psCheck.setString(2, studentId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    return true; // Already started or completed, don't insert again
                }
            }
            
            String insertSql = "INSERT INTO classroom_exam_attempts (exam_id, student_id, status, started_at) VALUES (?::uuid, ?::uuid, 'in_progress', now())";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setString(1, examId);
                psInsert.setString(2, studentId);
                return psInsert.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            lastError.set("Database error starting attempt: " + e.getMessage());
        }
        return false;
    }

    public boolean insertAttempt(ClassroomExamAttempt attempt) {
        String checkSql = "SELECT id FROM classroom_exam_attempts WHERE exam_id = ?::uuid AND student_id = ?::uuid";
        String existingId = null;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setString(1, attempt.getExamId());
            psCheck.setString(2, attempt.getStudentId());
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    existingId = rs.getString("id");
                }
            }
            
            if (existingId != null) {
                String updateSql = "UPDATE classroom_exam_attempts SET score = ?, total_questions = ?, violation_count = ?, status = 'completed', submitted_at = now() WHERE id = ?::uuid";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    if (attempt.getScore() != null) psUpdate.setDouble(1, attempt.getScore());
                    else psUpdate.setNull(1, java.sql.Types.NUMERIC);
                    psUpdate.setInt(2, attempt.getTotalQuestions());
                    psUpdate.setInt(3, attempt.getViolationCount());
                    psUpdate.setString(4, existingId);
                    if (psUpdate.executeUpdate() > 0) {
                        attempt.setId(existingId);
                        return true;
                    }
                }
            } else {
                String insertSql = "INSERT INTO classroom_exam_attempts (exam_id, student_id, score, total_questions, violation_count, status, started_at, submitted_at) "
                                 + "VALUES (?::uuid, ?::uuid, ?, ?, ?, 'completed', COALESCE(?, now()), now()) RETURNING id";
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setString(1, attempt.getExamId());
                    psInsert.setString(2, attempt.getStudentId());
                    if (attempt.getScore() != null) psInsert.setDouble(3, attempt.getScore());
                    else psInsert.setNull(3, java.sql.Types.NUMERIC);
                    psInsert.setInt(4, attempt.getTotalQuestions());
                    psInsert.setInt(5, attempt.getViolationCount());
                    psInsert.setTimestamp(6, attempt.getStartedAt());
                    try (ResultSet rs = psInsert.executeQuery()) {
                        if (rs.next()) {
                            attempt.setId(rs.getString("id"));
                            return true;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            lastError.set("Database error inserting/updating attempt: " + e.getMessage());
        }
        return false;
    }

    public boolean insertAnswers(List<ClassroomExamAnswer> answers) {
        if (answers == null || answers.isEmpty()) return true;
        String sql = "INSERT INTO classroom_exam_answers (attempt_id, question_id, selected_option, is_correct) "
                   + "VALUES (?::uuid, ?::uuid, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            try {
                for (ClassroomExamAnswer ans : answers) {
                    ps.setString(1, ans.getAttemptId());
                    ps.setString(2, ans.getQuestionId());
                    ps.setString(3, ans.getSelectedOption());
                    ps.setBoolean(4, ans.isCorrect());
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            lastError.set("Database error inserting answers: " + e.getMessage());
        }
        return false;
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
                    + "exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice' CHECK (exam_type IN ('multiple_choice', 'essay', 'flashcard')),"
                    + "creation_mode VARCHAR(20) NOT NULL DEFAULT 'manual' CHECK (creation_mode IN ('manual', 'ai')),"
                    + "raw_source_text TEXT,"
                    + "source_material_id UUID REFERENCES classroom_materials(id) ON DELETE SET NULL,"
                    + "status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('draft', 'open', 'closed')),"
                    + "max_score NUMERIC(5,2) NOT NULL DEFAULT 10 CHECK (max_score > 0),"
                    + "duration_minutes INTEGER NOT NULL DEFAULT 45 CHECK (duration_minutes > 0),"
                    + "start_at TIMESTAMPTZ,"
                    + "end_at TIMESTAMPTZ,"
                    + "created_by UUID REFERENCES users(id) ON DELETE SET NULL,"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("ALTER TABLE classroom_exams ADD COLUMN IF NOT EXISTS exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice'");
            st.execute("ALTER TABLE classroom_exams ADD COLUMN IF NOT EXISTS creation_mode VARCHAR(20) NOT NULL DEFAULT 'manual'");
            st.execute("ALTER TABLE classroom_exams ADD COLUMN IF NOT EXISTS raw_source_text TEXT");
            st.execute("ALTER TABLE classroom_exams ADD COLUMN IF NOT EXISTS max_score NUMERIC(5,2) NOT NULL DEFAULT 10 CHECK (max_score > 0)");
            st.execute("DO $$ BEGIN "
                    + "IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'classroom_exams_exam_type_check' "
                    + "AND conrelid = 'classroom_exams'::regclass) THEN "
                    + "ALTER TABLE classroom_exams ADD CONSTRAINT classroom_exams_exam_type_check "
                    + "CHECK (exam_type IN ('multiple_choice', 'essay', 'flashcard')); "
                    + "END IF; END $$");
            st.execute("DO $$ BEGIN "
                    + "IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'classroom_exams_creation_mode_check' "
                    + "AND conrelid = 'classroom_exams'::regclass) THEN "
                    + "ALTER TABLE classroom_exams ADD CONSTRAINT classroom_exams_creation_mode_check "
                    + "CHECK (creation_mode IN ('manual', 'ai')); "
                    + "END IF; END $$");
            st.execute("DO $$ BEGIN "
                    + "IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'classroom_exams_time_window_check' "
                    + "AND conrelid = 'classroom_exams'::regclass) THEN "
                    + "ALTER TABLE classroom_exams ADD CONSTRAINT classroom_exams_time_window_check "
                    + "CHECK (start_at IS NULL OR end_at IS NULL OR end_at > start_at); "
                    + "END IF; END $$");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_exam_questions ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "exam_id UUID NOT NULL REFERENCES classroom_exams(id) ON DELETE CASCADE,"
                    + "question_text TEXT NOT NULL,"
                    + "option_a TEXT,"
                    + "option_b TEXT,"
                    + "option_c TEXT,"
                    + "option_d TEXT,"
                    + "correct_option CHAR(1) CHECK (correct_option IN ('A', 'B', 'C', 'D')),"
                    + "reference_answer TEXT,"
                    + "points NUMERIC(5,2) NOT NULL DEFAULT 1 CHECK (points > 0),"
                    + "sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("ALTER TABLE classroom_exam_questions ALTER COLUMN points TYPE NUMERIC(5,2)");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_exam_attempts ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "exam_id UUID NOT NULL REFERENCES classroom_exams(id) ON DELETE CASCADE,"
                    + "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,"
                    + "score NUMERIC(5,2),"
                    + "total_questions INTEGER NOT NULL DEFAULT 0,"
                    + "violation_count INTEGER NOT NULL DEFAULT 0,"
                    + "status VARCHAR(20) NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed')),"
                    + "started_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "submitted_at TIMESTAMPTZ"
                    + ")");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_exam_answers ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "attempt_id UUID NOT NULL REFERENCES classroom_exam_attempts(id) ON DELETE CASCADE,"
                    + "question_id UUID NOT NULL REFERENCES classroom_exam_questions(id) ON DELETE CASCADE,"
                    + "selected_option CHAR(1),"
                    + "is_correct BOOLEAN NOT NULL DEFAULT FALSE"
                    + ")");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_exams_classroom ON classroom_exams(classroom_id, status, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_exams_code ON classroom_exams(exam_code)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_exam_questions_exam ON classroom_exam_questions(exam_id, sort_order)");
            st.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_classroom_exam_attempts_unique ON classroom_exam_attempts(exam_id, student_id)");
        } catch (SQLException e) {
            System.err.println("Error ensuring classroom_exams schema: " + e.getMessage());
        }
    }
}
