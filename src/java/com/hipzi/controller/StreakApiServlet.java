package com.hipzi.controller;

import com.hipzi.dao.UserDao;
import com.hipzi.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/api/user/streak")
public class StreakApiServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    // GET: Lấy trạng thái streak hiện tại
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }

        User sessionUser = (User) session.getAttribute("loggedUser");
        User user = userDao.findByEmail(sessionUser.getEmail());
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print("{\"error\":\"User not found\"}");
            return;
        }

        int streakCount = user.getStreakCount();
        LocalDate lastDate = user.getLastStreakDate();
        LocalDate today = LocalDate.now();
        boolean isClaimedToday = false;

        if (lastDate != null) {
            long daysBetween = ChronoUnit.DAYS.between(lastDate, today);
            if (daysBetween == 0) {
                isClaimedToday = true;
            } else if (daysBetween > 1) {
                // Đứt chuỗi - reset về 0
                streakCount = 0;
            }
        }

        String lastDateStr = (lastDate != null) ? "\"" + lastDate.toString() + "\"" : "null";
        out.print("{\"streakCount\":" + streakCount
                + ",\"isClaimedToday\":" + isClaimedToday
                + ",\"lastStreakDate\":" + lastDateStr + "}");
    }

    // POST: Click thắp lửa → cộng streak
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }

        User sessionUser = (User) session.getAttribute("loggedUser");
        User user = userDao.findByEmail(sessionUser.getEmail());
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print("{\"error\":\"User not found\"}");
            return;
        }

        LocalDate lastDate = user.getLastStreakDate();
        LocalDate today = LocalDate.now();
        int currentStreak = user.getStreakCount();

        if (lastDate != null) {
            long daysBetween = ChronoUnit.DAYS.between(lastDate, today);
            if (daysBetween == 0) {
                // Đã thắp hôm nay rồi
                out.print("{\"success\":false,\"streakCount\":" + currentStreak + "}");
                return;
            } else if (daysBetween == 1) {
                currentStreak++; // Liên tiếp → cộng thêm
            } else {
                currentStreak = 1; // Đứt chuỗi → bắt đầu lại từ 1
            }
        } else {
            currentStreak = 1; // Lần đầu tiên
        }

        boolean ok = userDao.updateStreak(user.getId(), currentStreak, today);

        if (ok) {
            sessionUser.setStreakCount(currentStreak);
            sessionUser.setLastStreakDate(today);
            session.setAttribute("loggedUser", sessionUser);
            out.print("{\"success\":true,\"streakCount\":" + currentStreak + "}");
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"error\":\"DB error\"}");
        }
    }
}
