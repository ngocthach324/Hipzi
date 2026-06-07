package com.hipzi.controller;

import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamAnswer;
import com.hipzi.model.ClassroomExamAttempt;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "ClassExamSubmitServlet", urlPatterns = {"/api/class-exam/submit"})
public class ClassExamSubmitServlet extends HttpServlet {

    private final ClassroomExamDao examDao = new ClassroomExamDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            return;
        }

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            String body = sb.toString().trim();
            String examId = extractJsonString(body, "examId");
            int violationCount = extractJsonInt(body, "violationCount");
            Map<String, String> answers = extractAnswersMap(body);

            if (examId == null || examId.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Dữ liệu nộp bài không hợp lệ.\"}");
                return;
            }

            // Check if already submitted
            if (examDao.hasStudentSubmitted(examId, user.getId())) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("{\"success\":false,\"message\":\"Bạn đã nộp bài thi này rồi.\"}");
                return;
            }

            ClassroomExam exam = findExamById(examId);
            if (exam == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Không tìm thấy bài thi.\"}");
                return;
            }

            if (!"open".equals(exam.getStatus())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Bài thi đã đóng.\"}");
                return;
            }

            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (exam.getStartAt() != null && now.before(exam.getStartAt())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Bài thi chưa mở.\"}");
                return;
            }

            // Grade the exam
            double totalScore = 0;
            int totalQuestions = exam.getQuestions() != null ? exam.getQuestions().size() : 0;
            double maxScore = exam.getMaxScore() != null ? exam.getMaxScore() : 10.0;
            double scorePerQuestion = totalQuestions > 0 ? maxScore / totalQuestions : 0;

            List<ClassroomExamAnswer> answerList = new ArrayList<>();

            for (ClassroomExamQuestion q : exam.getQuestions()) {
                String selected = answers.get(q.getId());
                boolean isCorrect = false;

                if (selected != null && !selected.trim().isEmpty()
                        && selected.equalsIgnoreCase(q.getCorrectOption())) {
                    isCorrect = true;
                    Double points = q.getPoints();
                    if (points != null && points > 0) {
                        totalScore += points;
                    } else {
                        totalScore += scorePerQuestion;
                    }
                }

                ClassroomExamAnswer ans = new ClassroomExamAnswer();
                ans.setQuestionId(q.getId());
                ans.setSelectedOption(selected);
                ans.setCorrect(isCorrect);
                answerList.add(ans);
            }

            if (totalScore > maxScore) totalScore = maxScore;
            totalScore = Math.round(totalScore * 100.0) / 100.0;

            ClassroomExamAttempt attempt = new ClassroomExamAttempt();
            attempt.setExamId(exam.getId());
            attempt.setStudentId(user.getId());
            attempt.setScore(totalScore);
            attempt.setTotalQuestions(totalQuestions);
            attempt.setViolationCount(violationCount);
            attempt.setStatus("completed");

            boolean success = examDao.insertAttempt(attempt);

            if (success) {
                for (ClassroomExamAnswer ans : answerList) {
                    ans.setAttemptId(attempt.getId());
                }
                examDao.insertAnswers(answerList);
                out.print("{\"success\":true,\"score\":" + totalScore + ",\"message\":\"Nộp bài thành công!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Lỗi lưu dữ liệu bài làm.\"}");
            }

        } catch (Exception e) {
            System.err.println("Error in ClassExamSubmitServlet: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Đã xảy ra lỗi hệ thống.\"}");
        }
    }

    /** Trích xuất giá trị string từ JSON đơn giản */
    private String extractJsonString(String json, String key) {
        if (json == null || key == null) return null;
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return null;
        int colonIdx = json.indexOf(':', keyIdx + search.length());
        if (colonIdx < 0) return null;
        int quoteStart = json.indexOf('"', colonIdx + 1);
        if (quoteStart < 0) return null;
        int quoteEnd = json.indexOf('"', quoteStart + 1);
        if (quoteEnd < 0) return null;
        return json.substring(quoteStart + 1, quoteEnd);
    }

    /** Trích xuất giá trị int từ JSON đơn giản */
    private int extractJsonInt(String json, String key) {
        if (json == null || key == null) return 0;
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return 0;
        int colonIdx = json.indexOf(':', keyIdx + search.length());
        if (colonIdx < 0) return 0;
        // Tìm số sau dấu ':'
        int start = colonIdx + 1;
        while (start < json.length() && (json.charAt(start) == ' ' || json.charAt(start) == '\t')) start++;
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)) || json.charAt(end) == '-')) end++;
        if (start >= end) return 0;
        try {
            return Integer.parseInt(json.substring(start, end));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    /**
     * Trích xuất answers map từ JSON body.
     * Format mong đợi: {"examId":"...","violationCount":0,"answers":{"uuid1":"A","uuid2":"C"}}
     */
    private Map<String, String> extractAnswersMap(String json) {
        Map<String, String> map = new HashMap<>();
        if (json == null) return map;
        int answersIdx = json.indexOf("\"answers\"");
        if (answersIdx < 0) return map;
        int braceStart = json.indexOf('{', answersIdx + 9);
        if (braceStart < 0) return map;
        int braceEnd = json.indexOf('}', braceStart);
        if (braceEnd < 0) return map;
        String answersJson = json.substring(braceStart + 1, braceEnd);
        // Parse key-value pairs: "uuid":"A"
        Pattern p = Pattern.compile("\"([^\"]+)\"\\s*:\\s*\"([^\"]*?)\"");
        Matcher m = p.matcher(answersJson);
        while (m.find()) {
            map.put(m.group(1), m.group(2));
        }
        return map;
    }

    private ClassroomExam findExamById(String id) {
        String sql = "SELECT * FROM classroom_exams WHERE id = ?::uuid";
        try (java.sql.Connection conn = com.hipzi.util.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ClassroomExam exam = new ClassroomExam();
                    exam.setId(rs.getString("id"));
                    exam.setClassroomId(rs.getString("classroom_id"));
                    exam.setExamCode(rs.getString("exam_code"));
                    exam.setStatus(rs.getString("status"));
                    exam.setStartAt(rs.getTimestamp("start_at"));
                    exam.setEndAt(rs.getTimestamp("end_at"));
                    double ms = rs.getDouble("max_score");
                    exam.setMaxScore(rs.wasNull() ? null : ms);

                    String qSql = "SELECT * FROM classroom_exam_questions WHERE exam_id = ?::uuid ORDER BY sort_order ASC";
                    try (java.sql.PreparedStatement qps = conn.prepareStatement(qSql)) {
                        qps.setString(1, id);
                        try (java.sql.ResultSet qrs = qps.executeQuery()) {
                            List<ClassroomExamQuestion> questions = new ArrayList<>();
                            while (qrs.next()) {
                                ClassroomExamQuestion q = new ClassroomExamQuestion();
                                q.setId(qrs.getString("id"));
                                q.setCorrectOption(qrs.getString("correct_option"));
                                double pts = qrs.getDouble("points");
                                q.setPoints(qrs.wasNull() ? null : pts);
                                questions.add(q);
                            }
                            exam.setQuestions(questions);
                        }
                    }
                    return exam;
                }
            }
        } catch (Exception e) {
            System.err.println("Error finding exam by ID: " + e.getMessage());
        }
        return null;
    }
}
