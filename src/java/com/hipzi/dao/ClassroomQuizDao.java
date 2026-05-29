package com.hipzi.dao;

import com.hipzi.model.ClassroomQuiz;
import com.hipzi.model.ClassroomQuizAttempt;
import com.hipzi.model.ClassroomQuizQuestion;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ClassroomQuizDao {

    public ClassroomQuizDao() {
        ensureSchema();
    }

    public List<ClassroomQuiz> listByClassroom(String classroomId, boolean publishedOnly) {
        String sql = "SELECT * FROM classroom_quizzes "
                + "WHERE classroom_id = ?::uuid "
                + (publishedOnly ? "AND status = 'published' " : "")
                + "ORDER BY CASE WHEN status = 'draft' THEN 0 ELSE 1 END, created_at DESC";
        List<ClassroomQuiz> quizzes = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    quizzes.add(mapQuiz(rs));
                }
            }
            attachQuestions(conn, quizzes);
        } catch (SQLException e) {
            System.err.println("Error in ClassroomQuizDao.listByClassroom: " + e.getMessage());
        }
        return quizzes;
    }

    public ClassroomQuiz findById(String quizId) {
        String sql = "SELECT * FROM classroom_quizzes WHERE id = ?::uuid LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ClassroomQuiz quiz = mapQuiz(rs);
                    quiz.setQuestions(listQuestions(conn, quiz.getId()));
                    return quiz;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomQuizDao.findById: " + e.getMessage());
        }
        return null;
    }

    public boolean createWithQuestions(ClassroomQuiz quiz, List<ClassroomQuizQuestion> questions) {
        String sql = "INSERT INTO classroom_quizzes "
                + "(classroom_id, title, description, source_image_path, source_file_name, raw_scan_text, status, created_by, published_at) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, ?::uuid, CASE WHEN ? = 'published' THEN NOW() ELSE NULL END) "
                + "RETURNING id";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String status = normalizeStatus(quiz.getStatus());
                ps.setString(1, quiz.getClassroomId());
                ps.setString(2, quiz.getTitle());
                ps.setString(3, quiz.getDescription());
                ps.setString(4, quiz.getSourceImagePath());
                ps.setString(5, quiz.getSourceFileName());
                ps.setString(6, quiz.getRawScanText());
                ps.setString(7, status);
                ps.setString(8, quiz.getCreatedBy());
                ps.setString(9, status);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        quiz.setId(rs.getString("id"));
                    }
                }
            }
            insertQuestions(conn, quiz.getId(), questions);
            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("Error in ClassroomQuizDao.createWithQuestions: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    public boolean updateWithQuestions(ClassroomQuiz quiz, List<ClassroomQuizQuestion> questions) {
        String sql = "UPDATE classroom_quizzes SET "
                + "title = ?, description = ?, raw_scan_text = ?, status = ?, "
                + "published_at = CASE WHEN ? = 'published' AND published_at IS NULL THEN NOW() "
                + "WHEN ? <> 'published' THEN NULL ELSE published_at END, "
                + "updated_at = NOW() "
                + "WHERE id = ?::uuid AND classroom_id = ?::uuid";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                String status = normalizeStatus(quiz.getStatus());
                ps.setString(1, quiz.getTitle());
                ps.setString(2, quiz.getDescription());
                ps.setString(3, quiz.getRawScanText());
                ps.setString(4, status);
                ps.setString(5, status);
                ps.setString(6, status);
                ps.setString(7, quiz.getId());
                ps.setString(8, quiz.getClassroomId());
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM classroom_quiz_questions WHERE quiz_id = ?::uuid")) {
                ps.setString(1, quiz.getId());
                ps.executeUpdate();
            }
            insertQuestions(conn, quiz.getId(), questions);
            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("Error in ClassroomQuizDao.updateWithQuestions: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    public boolean updateStatus(String quizId, String classroomId, String status) {
        String normalized = normalizeStatus(status);
        String sql = "UPDATE classroom_quizzes SET status = ?, "
                + "published_at = CASE WHEN ? = 'published' THEN COALESCE(published_at, NOW()) ELSE NULL END, "
                + "updated_at = NOW() "
                + "WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, normalized);
            ps.setString(2, normalized);
            ps.setString(3, quizId);
            ps.setString(4, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomQuizDao.updateStatus: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteForClassroom(String quizId, String classroomId) {
        String sql = "DELETE FROM classroom_quizzes WHERE id = ?::uuid AND classroom_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            ps.setString(2, classroomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomQuizDao.deleteForClassroom: " + e.getMessage());
        }
        return false;
    }

    public boolean createAttempt(ClassroomQuiz quiz, String studentId, Map<String, String> selectedAnswers) {
        if (quiz == null || quiz.getQuestions() == null || quiz.getQuestions().isEmpty()) {
            return false;
        }
        int total = quiz.getQuestions().size();
        int score = 0;
        for (ClassroomQuizQuestion question : quiz.getQuestions()) {
            String selected = normalizeOption(selectedAnswers.get(question.getId()));
            if (!selected.isEmpty() && selected.equals(normalizeOption(question.getCorrectOption()))) {
                score++;
            }
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            String attemptId = null;
            String attemptSql = "INSERT INTO classroom_quiz_attempts "
                    + "(quiz_id, classroom_id, student_id, score, total_questions) "
                    + "VALUES (?::uuid, ?::uuid, ?::uuid, ?, ?) RETURNING id";
            try (PreparedStatement ps = conn.prepareStatement(attemptSql)) {
                ps.setString(1, quiz.getId());
                ps.setString(2, quiz.getClassroomId());
                ps.setString(3, studentId);
                ps.setInt(4, score);
                ps.setInt(5, total);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        attemptId = rs.getString("id");
                    }
                }
            }
            String answerSql = "INSERT INTO classroom_quiz_answers "
                    + "(attempt_id, question_id, selected_option, is_correct) "
                    + "VALUES (?::uuid, ?::uuid, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(answerSql)) {
                for (ClassroomQuizQuestion question : quiz.getQuestions()) {
                    String selected = normalizeOption(selectedAnswers.get(question.getId()));
                    ps.setString(1, attemptId);
                    ps.setString(2, question.getId());
                    ps.setString(3, selected.isEmpty() ? null : selected);
                    ps.setBoolean(4, !selected.isEmpty() && selected.equals(normalizeOption(question.getCorrectOption())));
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("Error in ClassroomQuizDao.createAttempt: " + e.getMessage());
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    public Map<String, ClassroomQuizAttempt> latestAttemptsForStudent(String classroomId, String studentId) {
        String sql = "SELECT DISTINCT ON (quiz_id) * "
                + "FROM classroom_quiz_attempts "
                + "WHERE classroom_id = ?::uuid AND student_id = ?::uuid "
                + "ORDER BY quiz_id, submitted_at DESC";
        Map<String, ClassroomQuizAttempt> attempts = new HashMap<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, classroomId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ClassroomQuizAttempt attempt = mapAttempt(rs);
                    attempts.put(attempt.getQuizId(), attempt);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomQuizDao.latestAttemptsForStudent: " + e.getMessage());
        }
        return attempts;
    }

    private void attachQuestions(Connection conn, List<ClassroomQuiz> quizzes) throws SQLException {
        if (quizzes == null || quizzes.isEmpty()) {
            return;
        }
        Map<String, ClassroomQuiz> byId = new LinkedHashMap<>();
        StringBuilder ids = new StringBuilder();
        for (ClassroomQuiz quiz : quizzes) {
            byId.put(quiz.getId(), quiz);
            if (ids.length() > 0) {
                ids.append(",");
            }
            ids.append("'").append(quiz.getId().replace("'", "''")).append("'::uuid");
        }
        String sql = "SELECT * FROM classroom_quiz_questions WHERE quiz_id IN (" + ids + ") ORDER BY sort_order ASC";
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                ClassroomQuizQuestion question = mapQuestion(rs);
                ClassroomQuiz quiz = byId.get(question.getQuizId());
                if (quiz != null) {
                    quiz.getQuestions().add(question);
                }
            }
        }
    }

    private List<ClassroomQuizQuestion> listQuestions(Connection conn, String quizId) throws SQLException {
        String sql = "SELECT * FROM classroom_quiz_questions WHERE quiz_id = ?::uuid ORDER BY sort_order ASC";
        List<ClassroomQuizQuestion> questions = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapQuestion(rs));
                }
            }
        }
        return questions;
    }

    private void insertQuestions(Connection conn, String quizId, List<ClassroomQuizQuestion> questions) throws SQLException {
        if (questions == null || questions.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO classroom_quiz_questions "
                + "(quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, sort_order) "
                + "VALUES (?::uuid, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int order = 1;
            for (ClassroomQuizQuestion question : questions) {
                if (isBlank(question.getQuestionText())) {
                    continue;
                }
                ps.setString(1, quizId);
                ps.setString(2, question.getQuestionText());
                ps.setString(3, question.getOptionA());
                ps.setString(4, question.getOptionB());
                ps.setString(5, question.getOptionC());
                ps.setString(6, question.getOptionD());
                String correct = normalizeOption(question.getCorrectOption());
                ps.setString(7, correct.isEmpty() ? null : correct);
                ps.setString(8, question.getExplanation());
                ps.setInt(9, order++);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private ClassroomQuiz mapQuiz(ResultSet rs) throws SQLException {
        ClassroomQuiz quiz = new ClassroomQuiz();
        quiz.setId(rs.getString("id"));
        quiz.setClassroomId(rs.getString("classroom_id"));
        quiz.setTitle(rs.getString("title"));
        quiz.setDescription(rs.getString("description"));
        quiz.setSourceImagePath(rs.getString("source_image_path"));
        quiz.setSourceFileName(rs.getString("source_file_name"));
        quiz.setRawScanText(rs.getString("raw_scan_text"));
        quiz.setStatus(rs.getString("status"));
        quiz.setCreatedBy(rs.getString("created_by"));
        quiz.setPublishedAt(rs.getTimestamp("published_at"));
        quiz.setCreatedAt(rs.getTimestamp("created_at"));
        quiz.setUpdatedAt(rs.getTimestamp("updated_at"));
        return quiz;
    }

    private ClassroomQuizQuestion mapQuestion(ResultSet rs) throws SQLException {
        ClassroomQuizQuestion question = new ClassroomQuizQuestion();
        question.setId(rs.getString("id"));
        question.setQuizId(rs.getString("quiz_id"));
        question.setQuestionText(rs.getString("question_text"));
        question.setOptionA(rs.getString("option_a"));
        question.setOptionB(rs.getString("option_b"));
        question.setOptionC(rs.getString("option_c"));
        question.setOptionD(rs.getString("option_d"));
        question.setCorrectOption(rs.getString("correct_option"));
        question.setExplanation(rs.getString("explanation"));
        question.setSortOrder(rs.getInt("sort_order"));
        question.setCreatedAt(rs.getTimestamp("created_at"));
        return question;
    }

    private ClassroomQuizAttempt mapAttempt(ResultSet rs) throws SQLException {
        ClassroomQuizAttempt attempt = new ClassroomQuizAttempt();
        attempt.setId(rs.getString("id"));
        attempt.setQuizId(rs.getString("quiz_id"));
        attempt.setClassroomId(rs.getString("classroom_id"));
        attempt.setStudentId(rs.getString("student_id"));
        attempt.setScore(rs.getInt("score"));
        attempt.setTotalQuestions(rs.getInt("total_questions"));
        attempt.setSubmittedAt(rs.getTimestamp("submitted_at"));
        return attempt;
    }

    private String normalizeStatus(String status) {
        return "published".equals(status) ? "published" : "draft";
    }

    private String normalizeOption(String option) {
        if (option == null) {
            return "";
        }
        String trimmed = option.trim().toUpperCase();
        return trimmed.matches("[ABCD]") ? trimmed : "";
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

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS classroom_quizzes ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,"
                    + "title TEXT NOT NULL,"
                    + "description TEXT,"
                    + "source_image_path TEXT,"
                    + "source_file_name TEXT,"
                    + "raw_scan_text TEXT,"
                    + "status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),"
                    + "created_by UUID REFERENCES users(id) ON DELETE SET NULL,"
                    + "published_at TIMESTAMPTZ,"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(),"
                    + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_quiz_questions ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "quiz_id UUID NOT NULL REFERENCES classroom_quizzes(id) ON DELETE CASCADE,"
                    + "question_text TEXT NOT NULL,"
                    + "option_a TEXT,"
                    + "option_b TEXT,"
                    + "option_c TEXT,"
                    + "option_d TEXT,"
                    + "correct_option CHAR(1) CHECK (correct_option IN ('A', 'B', 'C', 'D')),"
                    + "explanation TEXT,"
                    + "sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),"
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_quiz_attempts ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "quiz_id UUID NOT NULL REFERENCES classroom_quizzes(id) ON DELETE CASCADE,"
                    + "classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,"
                    + "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,"
                    + "score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),"
                    + "total_questions INTEGER NOT NULL DEFAULT 0 CHECK (total_questions >= 0),"
                    + "submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                    + ")");
            st.execute("CREATE TABLE IF NOT EXISTS classroom_quiz_answers ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(),"
                    + "attempt_id UUID NOT NULL REFERENCES classroom_quiz_attempts(id) ON DELETE CASCADE,"
                    + "question_id UUID NOT NULL REFERENCES classroom_quiz_questions(id) ON DELETE CASCADE,"
                    + "selected_option CHAR(1) CHECK (selected_option IN ('A', 'B', 'C', 'D')),"
                    + "is_correct BOOLEAN NOT NULL DEFAULT false"
                    + ")");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_quizzes_classroom_status ON classroom_quizzes(classroom_id, status, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_quiz_questions_quiz ON classroom_quiz_questions(quiz_id, sort_order)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_quiz_attempts_student ON classroom_quiz_attempts(classroom_id, student_id, submitted_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_quiz_attempts_quiz ON classroom_quiz_attempts(quiz_id, score DESC, submitted_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_classroom_quiz_answers_attempt ON classroom_quiz_answers(attempt_id)");
        } catch (SQLException e) {
            System.err.println("Error ensuring classroom quiz schema: " + e.getMessage());
        }
    }
}
