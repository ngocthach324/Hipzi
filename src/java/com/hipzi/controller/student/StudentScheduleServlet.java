package com.hipzi.controller.student;

import com.hipzi.dao.TeachingScheduleDao;
import com.hipzi.model.TeachingSchedule;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StudentScheduleServlet", urlPatterns = {"/student/schedule"})
public class StudentScheduleServlet extends HttpServlet {

    private final TeachingScheduleDao scheduleDao = new TeachingScheduleDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedUser");

        // Load schedules for the student's enrolled classes
        List<TeachingSchedule> schedules = scheduleDao.findByStudentId(user.getId());
        request.setAttribute("schedules", schedules);
        
        session.setAttribute("activeTab", "tab-my-schedule");
        request.getRequestDispatcher("/WEB-INF/views/student-profile.jsp").forward(request, response);
    }
}
