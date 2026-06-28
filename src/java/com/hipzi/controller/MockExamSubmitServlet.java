package com.hipzi.controller;

import com.hipzi.dao.MockExamDao;
import com.hipzi.model.MockExamQuestion;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MockExamSubmitServlet", urlPatterns = {"/api/mock-exam/submit"})
public class MockExamSubmitServlet extends HttpServlet {

    private final MockExamDao mockExamDao = new MockExamDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String body = sb.toString();

            // Extract examId
            String examId = "";
            if (body.contains("\"examId\":\"")) {
                int start = body.indexOf("\"examId\":\"") + 10;
                int end = body.indexOf("\"", start);
                examId = body.substring(start, end);
            }

            if (examId.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Missing examId\"}");
                return;
            }

            List<MockExamQuestion> questions = mockExamDao.listQuestionsByExamId(examId);
            int correctCount = 0;
            int totalCount = questions.size();

            // Basic parsing for answers { "uuid": "A" }
            for (MockExamQuestion q : questions) {
                String idStr = "\"" + q.getId() + "\":\"";
                if (body.contains(idStr)) {
                    int start = body.indexOf(idStr) + idStr.length();
                    int end = body.indexOf("\"", start);
                    String answer = body.substring(start, end);
                    if (answer.equalsIgnoreCase(q.getCorrectOption())) {
                        correctCount++;
                    }
                }
            }

            out.print("{\"success\": true, \"score\": " + correctCount + ", \"total\": " + totalCount + "}");

        } catch (Exception e) {
            out.print("{\"success\": false, \"message\": \"Internal Error\"}");
        }
    }
}
