package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.TeacherApplicationDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.TeacherApplication;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "TeacherDetailServlet", urlPatterns = {"/teachers/detail"})
public class TeacherDetailServlet extends HttpServlet {

    private final TeacherApplicationDao teacherApplicationDao = new TeacherApplicationDao();
    private final ClassroomDao classroomDao = new ClassroomDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = cleanParam(request.getParameter("id"));
        if (id.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/teachers");
            return;
        }

        TeacherApplication teacher = teacherApplicationDao.findApprovedTeacherById(id);
        if (teacher == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        } else {
            request.setAttribute("teacher", teacher);
            request.setAttribute("teacherClassrooms", publicClassrooms(teacher.getUserId()));
        }

        request.getRequestDispatcher("/WEB-INF/views/teacher-detail.jsp").forward(request, response);
    }

    private List<Classroom> publicClassrooms(String teacherId) {
        List<Classroom> source = classroomDao.findByTeacherId(teacherId);
        List<Classroom> visible = new ArrayList<>();
        if (source == null) {
            return visible;
        }
        for (Classroom classroom : source) {
            if (classroom == null) {
                continue;
            }
            String status = classroom.getStatus();
            if ("open".equals(status) || "upcoming".equals(status)) {
                visible.add(classroom);
            }
        }
        return visible;
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}