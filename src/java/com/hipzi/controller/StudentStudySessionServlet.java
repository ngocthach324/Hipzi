package com.hipzi.controller;

import com.hipzi.dao.StudentStudyProgressDao;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StudentStudySessionServlet", urlPatterns = {"/student-study-session"})
public class StudentStudySessionServlet extends HttpServlet {
    private final StudentStudyProgressDao studyProgressDao = new StudentStudyProgressDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null || !hasRole(user, "student")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int seconds = parseSeconds(request.getParameter("seconds"));
        if (seconds > 0) {
            studyProgressDao.recordStudySeconds(user.getId(), seconds);
        }
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":true}");
    }

    private int parseSeconds(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        try {
            return Math.max(0, Integer.parseInt(value.trim()));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private boolean hasRole(User user, String roleName) {
        return user.getRoles() != null && user.getRoles().stream()
                .anyMatch(role -> roleName.equalsIgnoreCase(role.getName()));
    }
}
