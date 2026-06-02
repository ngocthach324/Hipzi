package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Locale;

@WebServlet(name = "ClassExamRoomServlet", urlPatterns = {"/class-exam-room"})
public class ClassExamRoomServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomExamDao examDao = new ClassroomExamDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classId = cleanParam(request.getParameter("classId"));
        String examCode = normalizeExamCode(request.getParameter("code"));
        ClassroomExam exam = null;
        Classroom classroom = null;
        String lookupError = "";

        if (!examCode.isEmpty()) {
            ClassroomExam foundExam = examDao.findByCode(examCode);
            if (foundExam != null
                    && (classId.isEmpty() || classId.equals(foundExam.getClassroomId()))) {
                classroom = classroomDao.findById(foundExam.getClassroomId());
                if (canAccessExam(user, classroom, foundExam)) {
                    exam = foundExam;
                    classId = foundExam.getClassroomId();
                }
            }
            if (exam == null) {
                lookupError = "Không tìm thấy đề thi đang mở hoặc bạn chưa có quyền truy cập đề này.";
            }
        }

        request.setAttribute("classExamRoomRequest", Boolean.TRUE);
        request.setAttribute("classroom", classroom);
        request.setAttribute("classroomExam", exam);
        request.setAttribute("classId", classId);
        request.setAttribute("examCode", examCode);
        request.setAttribute("examLookupError", lookupError);
        request.getRequestDispatcher("/class-exam-room.jsp").forward(request, response);
    }

    private boolean canAccessExam(User user, Classroom classroom, ClassroomExam exam) {
        if (user == null || classroom == null || exam == null) {
            return false;
        }
        if (hasRole(user, "staff") || hasRole(user, "admin")
                || (hasRole(user, "teacher") && user.getId().equals(classroom.getTeacherId()))) {
            return true;
        }
        ClassroomEnrollment enrollment = enrollmentDao.findByClassroomAndStudent(classroom.getId(), user.getId());
        return hasRole(user, "student")
                && enrollment != null
                && "accepted".equals(enrollment.getStatus())
                && isOpenNow(exam);
    }

    private boolean isOpenNow(ClassroomExam exam) {
        if (!"open".equals(exam.getStatus())) {
            return false;
        }
        Timestamp now = new Timestamp(System.currentTimeMillis());
        return (exam.getStartAt() == null || !now.before(exam.getStartAt()))
                && (exam.getEndAt() == null || !now.after(exam.getEndAt()));
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

    private String normalizeExamCode(String value) {
        return cleanParam(value).toUpperCase(Locale.ROOT);
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
