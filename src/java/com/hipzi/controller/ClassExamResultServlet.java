package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.dto.ClassroomExamAnswerDetailDto;
import com.hipzi.dto.ClassroomExamResultAttemptDto;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamAnswer;
import com.hipzi.model.ClassroomExamAttempt;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ClassExamResultServlet", urlPatterns = {"/class-exam-result"})
public class ClassExamResultServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomExamDao examDao = new ClassroomExamDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String classId = cleanParam(request.getParameter("classId"));
        String examCode = cleanParam(request.getParameter("code"));
        if (classId.isEmpty() || examCode.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/classes");
            return;
        }

        Classroom classroom = classroomDao.findById(classId);
        ClassroomExam exam = examDao.findByCode(examCode);
        if (classroom == null || exam == null || !classId.equals(exam.getClassroomId())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay bai thi.");
            return;
        }

        if (!canViewStudentResult(user, classroom)) {
            if (session != null) {
                session.setAttribute("toastMsg", "Bạn chưa có quyền xem kết quả bài thi này.");
                session.setAttribute("toastType", "error");
            }
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-exams");
            return;
        }

        List<ClassroomExamAttempt> attempts = examDao.listStudentAttempts(exam.getId(), user.getId());
        List<ClassroomExamResultAttemptDto> resultAttempts = buildResultAttempts(attempts);

        request.setAttribute("classExamResultRequest", Boolean.TRUE);
        request.setAttribute("classroom", classroom);
        request.setAttribute("exam", exam);
        request.setAttribute("resultAttempts", resultAttempts);
        request.getRequestDispatcher("/WEB-INF/views/class-exam-result.jsp").forward(request, response);
    }

    private List<ClassroomExamResultAttemptDto> buildResultAttempts(List<ClassroomExamAttempt> attempts) {
        List<ClassroomExamResultAttemptDto> results = new ArrayList<>();
        if (attempts == null || attempts.isEmpty()) {
            return results;
        }
        for (int i = 0; i < attempts.size(); i++) {
            ClassroomExamAttempt attempt = attempts.get(i);
            if (attempt == null || !"completed".equals(attempt.getStatus()) || attempt.getId() == null) {
                continue;
            }
            List<ClassroomExamAnswerDetailDto> details = examDao.listAnswerDetails(attempt.getId());
            int correct = 0;
            int total = 0;
            if (details != null) {
                for (ClassroomExamAnswerDetailDto detail : details) {
                    if (detail == null || detail.getQuestion() == null || isEssay(detail.getQuestion())) {
                        continue;
                    }
                    total++;
                    ClassroomExamAnswer answer = detail.getAnswer();
                    if (answer != null && answer.isCorrect()) {
                        correct++;
                    }
                }
            }
            if (total == 0 && attempt.getTotalQuestions() > 0) {
                total = attempt.getTotalQuestions();
            }
            int wrong = Math.max(0, total - correct);
            results.add(new ClassroomExamResultAttemptDto(attempt, i + 1, correct, wrong, total));
        }
        return results;
    }

    private boolean canViewStudentResult(User user, Classroom classroom) {
        if (user == null || classroom == null || !hasRole(user, "student")) {
            return false;
        }
        ClassroomEnrollment enrollment = enrollmentDao.findByClassroomAndStudent(classroom.getId(), user.getId());
        return enrollment != null && "accepted".equals(enrollment.getStatus());
    }

    private boolean isEssay(ClassroomExamQuestion question) {
        return question != null && "essay".equals(question.getQuestionType());
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) {
            return false;
        }
        for (Role role : user.getRoles()) {
            if (role != null && roleName.equalsIgnoreCase(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
