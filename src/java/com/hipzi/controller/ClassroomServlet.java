package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.model.Classroom;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ClassroomServlet", urlPatterns = {"/classes"})
public class ClassroomServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long requestStartedAt = System.nanoTime();
        String subjectParam = request.getParameter("subject");
        String gradeParam = request.getParameter("grade");
        String searchParam = request.getParameter("q");

        long dataStartedAt = System.nanoTime();
        List<Classroom> filteredClasses = classroomDao.listPublic(subjectParam, gradeParam, searchParam);
        long dataMs = elapsedMs(dataStartedAt);
        if (filteredClasses == null) {
            filteredClasses = new ArrayList<>();
        }
        
        response.addHeader("Server-Timing", "classroom-data;dur=" + dataMs);
        response.addHeader("X-Hipzi-Perf-Classroom", "data=" + dataMs + "ms; rows=" + filteredClasses.size());

        request.setAttribute("classrooms", filteredClasses);

        // Nếu là AJAX request (từ bộ lọc sidebar), chỉ trả về fragment kết quả
        String ajaxParam = request.getParameter("ajax");
        if ("1".equals(ajaxParam)) {
            long forwardStartedAt = System.nanoTime();
            request.getRequestDispatcher("/WEB-INF/fragments/classes-results.jsp").forward(request, response);
            logPerf("ClassroomServlet.doGet ajax=1 rows=" + filteredClasses.size(), dataMs, elapsedMs(forwardStartedAt), elapsedMs(requestStartedAt));
            return;
        }

        long forwardStartedAt = System.nanoTime();
        request.getRequestDispatcher("/WEB-INF/views/classes.jsp").forward(request, response);
        logPerf("ClassroomServlet.doGet ajax=0 rows=" + filteredClasses.size(), dataMs, elapsedMs(forwardStartedAt), elapsedMs(requestStartedAt));
    }

    private long elapsedMs(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000L;
    }

    private void logPerf(String label, long dataMs, long forwardMs, long totalMs) {
        System.err.println("[PERF] " + label + " data=" + dataMs + "ms forward=" + forwardMs + "ms total=" + totalMs + "ms");
    }


}