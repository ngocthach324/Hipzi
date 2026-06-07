package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.dto.ClassroomExamAttemptDto;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

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

        request.setAttribute("classroom", classroom);
        request.setAttribute("exam", foundExam);
        request.setAttribute("questions", questions);
        request.setAttribute("attempts", attempts);

        request.getRequestDispatcher("/WEB-INF/views/class-exam-manage.jsp").forward(request, response);
    }
}
