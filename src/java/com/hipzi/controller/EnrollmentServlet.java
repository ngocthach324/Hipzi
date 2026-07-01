package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.EnrollmentService;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/enroll")
public class EnrollmentServlet extends HttpServlet {

    private final EnrollmentService enrollmentService = new EnrollmentService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String courseId = request.getParameter("courseId");
        
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String error = enrollmentService.enrollFree(user, courseId, getServletContext());
        
        if (error != null) {
            request.getSession().setAttribute("errorMsg", error);
            response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId);
            return;
        }

        request.getSession().setAttribute("successMsg", "Đăng ký khóa học thành công! Bạn hiện có thể xem hướng dẫn truy cập.");
        response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId);
    }
}
