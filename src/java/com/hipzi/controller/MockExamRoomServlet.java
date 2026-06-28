package com.hipzi.controller;

import com.hipzi.dao.MockExamDao;
import com.hipzi.model.MockExam;
import com.hipzi.model.MockExamQuestion;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MockExamRoomServlet", urlPatterns = {"/mock-exam-room"})
public class MockExamRoomServlet extends HttpServlet {

    private final MockExamDao mockExamDao = new MockExamDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String examId = request.getParameter("examId");
        if (examId == null || examId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/mock-exams");
            return;
        }

        MockExam mockExam = mockExamDao.findByIdAndStatus(examId, "published");
        if (mockExam == null) {
            response.sendRedirect(request.getContextPath() + "/mock-exams");
            return;
        }

        List<MockExamQuestion> examQuestions = mockExamDao.listQuestionsByExamId(examId);

        request.setAttribute("mockExamRoomRequest", true);
        request.setAttribute("mockExam", mockExam);
        request.setAttribute("examQuestions", examQuestions);
        request.setAttribute("examQuestionCount", mockExam.getItemCount());

        request.getRequestDispatcher("/WEB-INF/views/mock-exam-room.jsp").forward(request, response);
    }
}
