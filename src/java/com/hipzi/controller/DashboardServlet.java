package com.hipzi.controller;

import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.dao.UserRoleDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final UserRoleDao userRoleDao = new UserRoleDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (!user.isOnboardingCompleted()) {
            response.sendRedirect(request.getContextPath() + "/onboarding");
            return;
        }

        // Lấy danh sách vai trò cập nhật nhất từ cơ sở dữ liệu nếu có
        List<Role> roles = user.getRoles();
        if (roles == null || roles.isEmpty()) {
            roles = userRoleDao.getRolesByUserId(user.getId());
            user.setRoles(roles);
            session.setAttribute("loggedUser", user);
        }

        // --- Thiết lập thông báo Toast sau khi đăng ký hoặc hoàn tất xác minh ---
        String welcome = request.getParameter("welcome");
        if ("true".equals(welcome)) {
            request.setAttribute("toastMsg", "Chào mừng bạn gia nhập cộng đồng học tập thông minh HIPZI!");
            request.setAttribute("toastType", "success");
        }

        // Định dạng ngày hiện tại hiển thị trang trọng
        SimpleDateFormat sdf = new SimpleDateFormat("EEEE, dd/MM/yyyy");
        String currentDateDisplay = sdf.format(new Date());

        // Gán các thuộc tính cần thiết sang trang JSP
        request.setAttribute("user", user);
        request.setAttribute("roles", roles);
        request.setAttribute("currentDateDisplay", currentDateDisplay);

        // Chuyển tiếp luồng điều khiển tới giao diện Bảng điều khiển trung tâm theo vai trò
        String targetJsp = "/student-profile.jsp";
        if (roles != null) {
            boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
            for (Role r : roles) {
                String rn = r.getName().toLowerCase();
                if ("parent".equals(rn)) hasParent = true;
                if ("teacher".equals(rn)) hasTeacher = true;
                if ("staff".equals(rn)) hasStaff = true;
                if ("admin".equals(rn)) hasAdmin = true;
            }
            if (hasAdmin) targetJsp = "/admin-profile.jsp";
            else if (hasStaff) targetJsp = "/staff-profile.jsp";
            else if (hasTeacher) targetJsp = "/teacher-profile.jsp";
            else if (hasParent) targetJsp = "/parent-profile.jsp";
        }
        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
