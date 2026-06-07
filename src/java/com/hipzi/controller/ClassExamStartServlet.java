package com.hipzi.controller;

import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "ClassExamStartServlet", urlPatterns = {"/api/class-exam/start"})
public class ClassExamStartServlet extends HttpServlet {

    private final ClassroomExamDao examDao = new ClassroomExamDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập.\"}");
            return;
        }

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            String body = sb.toString().trim();
            // Simple JSON parse for examId
            String examId = extractJsonString(body, "examId");

            if (examId == null || examId.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Dữ liệu bắt đầu bài thi không hợp lệ.\"}");
                return;
            }

            String attemptId = examDao.startAttempt(examId, user.getId());
            if (attemptId == null || attemptId.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("{\"success\":false,\"message\":\"Bạn đã dùng hết lượt làm bài. Vui lòng liên hệ giáo viên để được cấp thêm lượt.\"}");
                return;
            }
            out.print("{\"success\":true,\"attemptId\":\"" + attemptId + "\",\"message\":\"Đã đánh dấu bắt đầu.\"}");

        } catch (Exception e) {
            System.err.println("Error in ClassExamStartServlet: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Đã xảy ra lỗi hệ thống.\"}");
        }
    }

    /**
     * Trích xuất giá trị string từ JSON đơn giản (không dùng thư viện).
     */
    private String extractJsonString(String json, String key) {
        if (json == null || key == null) return null;
        String search = "\"" + key + "\"";
        int keyIdx = json.indexOf(search);
        if (keyIdx < 0) return null;
        int colonIdx = json.indexOf(':', keyIdx + search.length());
        if (colonIdx < 0) return null;
        int quoteStart = json.indexOf('"', colonIdx + 1);
        if (quoteStart < 0) return null;
        int quoteEnd = json.indexOf('"', quoteStart + 1);
        if (quoteEnd < 0) return null;
        return json.substring(quoteStart + 1, quoteEnd);
    }
}
