package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomMaterialDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomMaterial;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.B2StorageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ClassroomFileServlet", urlPatterns = {"/classroom-file"})
public class ClassroomFileServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomMaterialDao materialDao = new ClassroomMaterialDao();
    private final B2StorageService storageService = new B2StorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String materialId = cleanParam(request.getParameter("id"));
        ClassroomMaterial material = !materialId.isEmpty() ? materialDao.findById(materialId) : null;
        if (material == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay tai lieu.");
            return;
        }

        Classroom classroom = classroomDao.findById(material.getClassroomId());
        if (classroom == null || !canAccessClassroomFile(user, classroom)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Ban chua co quyen xem tai lieu nay.");
            return;
        }

        try {
            String signedUrl = storageService.createSignedUrl(material.getFilePath(), 600);
            String mode = cleanParam(request.getParameter("mode"));
            if ("preview".equalsIgnoreCase(mode)) {
                response.sendRedirect(signedUrl);
            } else {
                response.sendRedirect(signedUrl + (signedUrl.contains("?") ? "&" : "?") + "download");
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Khong tao duoc link tai file tu Supabase Storage.");
        }
    }

    private boolean canAccessClassroomFile(User user, Classroom classroom) {
        if (user == null || classroom == null) {
            return false;
        }
        if (classroom.getTeacherId() != null && classroom.getTeacherId().equals(user.getId()) && hasRole(user, "teacher")) {
            return true;
        }
        if (hasRole(user, "staff") || hasRole(user, "admin")) {
            return true;
        }
        ClassroomEnrollment enrollment = enrollmentDao.findByClassroomAndStudent(classroom.getId(), user.getId());
        return enrollment != null && "accepted".equals(enrollment.getStatus());
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
