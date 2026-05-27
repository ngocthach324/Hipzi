package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomHomeworkSubmissionDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomHomeworkSubmission;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.SupabaseStorageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "HomeworkSubmissionFileServlet", urlPatterns = {"/homework-submission-file"})
public class HomeworkSubmissionFileServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomHomeworkSubmissionDao submissionDao = new ClassroomHomeworkSubmissionDao();
    private final SupabaseStorageService storageService = new SupabaseStorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String submissionId = cleanParam(request.getParameter("id"));
        ClassroomHomeworkSubmission submission = !submissionId.isEmpty() ? submissionDao.findById(submissionId) : null;
        if (submission == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay bai nop.");
            return;
        }

        Classroom classroom = classroomDao.findById(submission.getClassroomId());
        if (classroom == null || !canAccessSubmissionFile(user, classroom, submission)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Ban chua co quyen tai bai nop nay.");
            return;
        }

        try {
            String signedUrl = storageService.createSignedUrl(submission.getFilePath(), 600);
            response.sendRedirect(signedUrl + (signedUrl.contains("?") ? "&" : "?") + "download");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Khong tao duoc link tai bai nop tu Supabase Storage.");
        }
    }

    private boolean canAccessSubmissionFile(User user, Classroom classroom, ClassroomHomeworkSubmission submission) {
        if (user == null || classroom == null || submission == null) {
            return false;
        }
        if (classroom.getTeacherId() != null && classroom.getTeacherId().equals(user.getId()) && hasRole(user, "teacher")) {
            return true;
        }
        if (hasRole(user, "staff") || hasRole(user, "admin")) {
            return true;
        }
        if (submission.getStudentId() != null && submission.getStudentId().equals(user.getId())) {
            ClassroomEnrollment enrollment = enrollmentDao.findByClassroomAndStudent(classroom.getId(), user.getId());
            return enrollment != null && "accepted".equals(enrollment.getStatus());
        }
        return false;
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) return false;
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
