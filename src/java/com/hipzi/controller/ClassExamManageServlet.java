package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.dto.ClassroomExamAnswerDetailDto;
import com.hipzi.dto.ClassroomExamAttemptDto;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamAttempt;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/class-exam-manage")
public class ClassExamManageServlet extends HttpServlet {

    private final ClassroomExamDao examDao = new ClassroomExamDao();
    private final ClassroomDao classDao = new ClassroomDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=" + request.getRequestURI() + "?" + request.getQueryString());
            return;
        }

        User loggedUser = (User) session.getAttribute("loggedUser");
        String classId = request.getParameter("classId");
        String examCode = request.getParameter("code");

        if (classId == null || classId.trim().isEmpty() || examCode == null || examCode.trim().isEmpty()) {
            session.setAttribute("toastMsg", "Mã lớp hoặc mã đề thi không hợp lệ.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classes");
            return;
        }

        Classroom classroom = classDao.findById(classId);
        if (classroom == null) {
            session.setAttribute("toastMsg", "Không tìm thấy lớp học.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classes");
            return;
        }

        boolean isTeacher = loggedUser.getId().equals(classroom.getTeacherId());
        boolean hasAdminAccess = loggedUser.getRoles() != null && loggedUser.getRoles().stream().anyMatch(r -> "admin".equals(r.getName()) || "staff".equals(r.getName()));
        boolean canManageClassroom = isTeacher || hasAdminAccess;

        if (!canManageClassroom) {
            session.setAttribute("toastMsg", "Bạn không có quyền quản lý bài thi của lớp này.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        ClassroomExam foundExam = null;
        List<ClassroomExam> classroomExams = examDao.listByClassroom(classId, false);
        for (ClassroomExam exam : classroomExams) {
            if (exam.getExamCode().equalsIgnoreCase(examCode.trim())) {
                foundExam = exam;
                break;
            }
        }

        if (foundExam == null) {
            session.setAttribute("toastMsg", "Không tìm thấy bài thi trong lớp này.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        List<ClassroomExamQuestion> questions = examDao.getQuestionsByExamId(foundExam.getId());
        List<ClassroomExamAttemptDto> attempts = examDao.listAttempts(foundExam.getId());
        Map<String, List<ClassroomExamAttempt>> attemptHistories = new HashMap<>();
        for (ClassroomExamAttemptDto dto : attempts) {
            if (dto.getAttempt() != null && dto.getAttempt().getStudentId() != null) {
                attemptHistories.put(dto.getAttempt().getStudentId(),
                        examDao.listStudentAttempts(foundExam.getId(), dto.getAttempt().getStudentId()));
            }
        }
        String attemptId = cleanParam(request.getParameter("attemptId"));
        ClassroomExamAttemptDto selectedAttempt = null;
        List<ClassroomExamAnswerDetailDto> selectedAnswers = null;
        if (!attemptId.isEmpty()) {
            selectedAttempt = examDao.findAttemptDto(foundExam.getId(), attemptId);
            if (selectedAttempt != null) {
                selectedAnswers = examDao.listAnswerDetails(attemptId);
            } else {
                session.setAttribute("toastMsg", "Không tìm thấy bài làm của học viên trong đề thi này.");
                session.setAttribute("toastType", "error");
            }
        }

        request.setAttribute("classroom", classroom);
        request.setAttribute("exam", foundExam);
        request.setAttribute("questions", questions);
        request.setAttribute("attempts", attempts);
        request.setAttribute("attemptHistories", attemptHistories);
        request.setAttribute("selectedAttempt", selectedAttempt);
        request.setAttribute("selectedAnswers", selectedAnswers);

        request.getRequestDispatcher("/WEB-INF/views/class-exam-manage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User loggedUser = (User) session.getAttribute("loggedUser");
        String action = cleanParam(request.getParameter("action"));
        String classId = cleanParam(request.getParameter("classId"));
        String examCode = cleanParam(request.getParameter("code"));
        String attemptId = cleanParam(request.getParameter("attemptId"));

        Classroom classroom = !classId.isEmpty() ? classDao.findById(classId) : null;
        if (classroom == null || examCode.isEmpty()) {
            session.setAttribute("toastMsg", "Mã lớp hoặc mã đề thi không hợp lệ.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classes");
            return;
        }

        boolean isTeacher = loggedUser.getId().equals(classroom.getTeacherId());
        boolean hasAdminAccess = loggedUser.getRoles() != null
                && loggedUser.getRoles().stream().anyMatch(r -> "admin".equals(r.getName()) || "staff".equals(r.getName()));
        if (!isTeacher && !hasAdminAccess) {
            session.setAttribute("toastMsg", "Bạn không có quyền quản lý bài thi của lớp này.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        ClassroomExam foundExam = findExamByClassAndCode(classId, examCode);
        if (foundExam == null) {
            session.setAttribute("toastMsg", "Không tìm thấy bài thi trong lớp này.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        if ("saveFeedback".equals(action)) {
            String feedback = cleanParam(request.getParameter("teacherFeedback"));
            boolean saved = !attemptId.isEmpty()
                    && examDao.updateAttemptFeedback(foundExam.getId(), attemptId, feedback, loggedUser.getId());
            session.setAttribute("toastMsg", saved ? "Đã lưu feedback cho học viên." : "Chưa lưu được feedback cho bài làm này.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/class-exam-manage?classId=" + url(classId)
                    + "&code=" + url(foundExam.getExamCode())
                    + (!attemptId.isEmpty() ? "&attemptId=" + url(attemptId) + "#attempt-detail" : ""));
            return;
        }

        if ("grantExtraAttempt".equals(action)) {
            String studentId = cleanParam(request.getParameter("studentId"));
            boolean granted = !studentId.isEmpty()
                    && examDao.grantExtraAttempt(foundExam.getId(), studentId, loggedUser.getId());
            session.setAttribute("toastMsg", granted ? "Đã thêm 1 lượt làm bài cho học viên." : "Chưa thêm được lượt làm bài.");
            session.setAttribute("toastType", granted ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/class-exam-manage?classId=" + url(classId)
                    + "&code=" + url(foundExam.getExamCode()));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/class-exam-manage?classId=" + url(classId)
                + "&code=" + url(foundExam.getExamCode()));
    }

    private ClassroomExam findExamByClassAndCode(String classId, String examCode) {
        List<ClassroomExam> classroomExams = examDao.listByClassroom(classId, false);
        for (ClassroomExam exam : classroomExams) {
            if (exam.getExamCode() != null && exam.getExamCode().equalsIgnoreCase(examCode.trim())) {
                return exam;
            }
        }
        return null;
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private String url(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
