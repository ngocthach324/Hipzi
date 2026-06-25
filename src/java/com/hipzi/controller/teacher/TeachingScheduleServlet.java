package com.hipzi.controller.teacher;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.TeachingScheduleDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.TeachingSchedule;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

@WebServlet(name = "TeachingScheduleServlet", urlPatterns = {"/teacher/schedule"})
public class TeachingScheduleServlet extends HttpServlet {

    private final TeachingScheduleDao scheduleDao = new TeachingScheduleDao();
    private final ClassroomDao classroomDao = new ClassroomDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedUser");

        // We can load schedules directly here, or we can just let it load via AJAX.
        // Assuming we render server-side for now, or just provide the data.
        List<TeachingSchedule> schedules = scheduleDao.findByTeacherId(user.getId());
        List<Classroom> classes = classroomDao.findByTeacherId(user.getId());

        request.setAttribute("schedules", schedules);
        request.setAttribute("classes", classes);
        
        // Actually, the user wants this inside teacher-profile.jsp tab.
        // So this might just be an API endpoint or we forward back to profile.
        // If we forward back to profile with a specific tab:
        session.setAttribute("activeTab", "tab-teaching-schedule");
        request.getRequestDispatcher("/WEB-INF/views/teacher-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("loggedUser");

        String action = request.getParameter("action");
        if ("addSession".equals(action)) {
            TeachingSchedule s = new TeachingSchedule();
            s.setTeacherId(user.getId());
            s.setClassroomId(request.getParameter("classroomId"));
            s.setTitle(request.getParameter("title"));
            s.setDescription(request.getParameter("description"));
            s.setSessionDate(Date.valueOf(request.getParameter("sessionDate")));
            s.setStartTime(Time.valueOf(request.getParameter("startTime") + ":00"));
            s.setEndTime(Time.valueOf(request.getParameter("endTime") + ":00"));
            s.setMeetLink(request.getParameter("meetLink"));
            s.setLocation(request.getParameter("location"));
            s.setSessionType(request.getParameter("sessionType"));
            s.setSource("manual");

            if (scheduleDao.create(s)) {
                session.setAttribute("toastMsg", "Đã thêm buổi học thủ công thành công.");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMsg", "Lỗi khi thêm buổi học.");
                session.setAttribute("toastType", "error");
            }

        } else if ("updateSession".equals(action)) {
            TeachingSchedule s = new TeachingSchedule();
            s.setId(request.getParameter("id"));
            s.setTeacherId(user.getId());
            s.setTitle(request.getParameter("title"));
            s.setDescription(request.getParameter("description"));
            s.setSessionDate(Date.valueOf(request.getParameter("sessionDate")));
            s.setStartTime(Time.valueOf(request.getParameter("startTime") + ":00"));
            s.setEndTime(Time.valueOf(request.getParameter("endTime") + ":00"));
            s.setMeetLink(request.getParameter("meetLink"));
            s.setLocation(request.getParameter("location"));
            s.setSessionType(request.getParameter("sessionType"));
            s.setStatus(request.getParameter("status"));

            if (scheduleDao.update(s)) {
                session.setAttribute("toastMsg", "Đã cập nhật buổi học thành công.");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMsg", "Lỗi khi cập nhật buổi học.");
                session.setAttribute("toastType", "error");
            }

        } else if ("cancelSession".equals(action)) {
            String id = request.getParameter("id");
            String reason = request.getParameter("reason");
            if (scheduleDao.cancel(id, user.getId(), reason)) {
                session.setAttribute("toastMsg", "Đã hủy buổi học.");
                session.setAttribute("toastType", "success");
            } else {
                session.setAttribute("toastMsg", "Lỗi khi hủy buổi học.");
                session.setAttribute("toastType", "error");
            }
        }

        session.setAttribute("activeTab", "tab-teaching-schedule");
        response.sendRedirect(request.getContextPath() + "/teacher-profile");
    }
}
