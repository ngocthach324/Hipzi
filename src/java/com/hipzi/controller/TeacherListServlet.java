package com.hipzi.controller;

import com.hipzi.dao.TeacherApplicationDao;
import com.hipzi.model.TeacherApplication;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "TeacherListServlet", urlPatterns = {"/teachers"})
public class TeacherListServlet extends HttpServlet {

    private final TeacherApplicationDao teacherApplicationDao = new TeacherApplicationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchQuery = cleanParam(request.getParameter("q"));
        String subject = cleanParam(request.getParameter("subject"));
        String teacherType = cleanParam(request.getParameter("teacherType"));
        if (subject.isEmpty()) {
            subject = "Tất cả";
        }
        if (teacherType.isEmpty()) {
            teacherType = "ALL";
        }

        List<TeacherApplication> teachers = teacherApplicationDao.listApprovedTeachers(searchQuery, teacherType, subject);
        request.setAttribute("teachers", teachers);
        request.setAttribute("searchQuery", searchQuery);
        request.setAttribute("currentSubject", subject);
        request.setAttribute("currentTeacherType", teacherType);

        request.getRequestDispatcher("/WEB-INF/views/teacher-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}