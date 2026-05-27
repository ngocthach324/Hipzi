package com.hipzi.controller;

import com.hipzi.dao.RoleDao;
import com.hipzi.dao.UserDao;
import com.hipzi.dao.UserRoleDao;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.StudentProfileService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "OnboardingServlet", urlPatterns = {"/onboarding"})
public class OnboardingServlet extends HttpServlet {

    private static final Set<String> ALLOWED_ROLES =
            new HashSet<>(Arrays.asList("student", "parent", "teacher"));

    private final RoleDao roleDao = new RoleDao();
    private final UserDao userDao = new UserDao();
    private final UserRoleDao userRoleDao = new UserRoleDao();
    private final StudentProfileService studentProfileService = new StudentProfileService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (user.isOnboardingCompleted()) {
            response.sendRedirect(request.getContextPath() + profilePathFromRoles(user.getRoles()));
            return;
        }

        request.setAttribute("user", user);
        request.getRequestDispatcher("/onboarding.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (user.isOnboardingCompleted()) {
            response.sendRedirect(request.getContextPath() + profilePathFromRoles(user.getRoles()));
            return;
        }

        String selectedRole = normalizeRole(request.getParameter("role"));
        if (!ALLOWED_ROLES.contains(selectedRole)) {
            request.setAttribute("errorMsg", "Vui lòng chọn một vai trò hợp lệ.");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/onboarding.jsp").forward(request, response);
            return;
        }

        Role role = roleDao.findRoleByName(selectedRole);
        if (role == null) {
            request.setAttribute("errorMsg", "Vai trò bạn chọn chưa tồn tại trong hệ thống.");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/onboarding.jsp").forward(request, response);
            return;
        }

        boolean roleUpdated = userRoleDao.replaceActivePublicRole(user.getId(), role.getId());
        boolean onboardingCompleted = roleUpdated && userDao.completeOnboarding(user.getId());

        if (!onboardingCompleted) {
            request.setAttribute("errorMsg", "Chưa thể lưu vai trò. Vui lòng thử lại.");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/onboarding.jsp").forward(request, response);
            return;
        }

        if ("student".equals(selectedRole)) {
            studentProfileService.createDefaultProfile(user.getId());
        }

        List<Role> roles = userRoleDao.getRolesByUserId(user.getId());
        user.setRoles(roles);
        user.setOnboardingCompleted(true);
        session.setAttribute("loggedUser", user);

        response.sendRedirect(request.getContextPath() + profilePathForRole(selectedRole) + "?welcome=true");
    }

    private String normalizeRole(String roleName) {
        return roleName == null ? "" : roleName.trim().toLowerCase();
    }

    private String profilePathForRole(String roleName) {
        switch (roleName) {
            case "parent":
                return "/parent-profile";
            case "teacher":
                return "/teacher-profile";
            default:
                return "/student-profile";
        }
    }

    private String profilePathFromRoles(List<Role> roles) {
        if (roles != null) {
            boolean hasParent = false;
            boolean hasTeacher = false;
            boolean hasStaff = false;
            boolean hasAdmin = false;
            for (Role role : roles) {
                if (role == null || role.getName() == null) continue;
                String roleName = role.getName().toLowerCase();
                if ("parent".equals(roleName)) hasParent = true;
                if ("teacher".equals(roleName)) hasTeacher = true;
                if ("staff".equals(roleName)) hasStaff = true;
                if ("admin".equals(roleName)) hasAdmin = true;
            }
            if (hasAdmin) return "/admin-profile";
            if (hasStaff) return "/staff-profile";
            if (hasTeacher) return "/teacher-profile";
            if (hasParent) return "/parent-profile";
        }
        return "/student-profile";
    }
}
