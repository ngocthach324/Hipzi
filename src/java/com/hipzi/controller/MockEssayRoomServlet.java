package com.hipzi.controller;

import com.hipzi.dao.MockExamDao;
import com.hipzi.model.MockExam;
import com.hipzi.model.MockExamEssay;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MockEssayRoomServlet", urlPatterns = {"/mock-essay-room"})
public class MockEssayRoomServlet extends HttpServlet {

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

        List<MockExamEssay> examEssays = mockExamDao.listEssaysByExamId(examId);

        request.setAttribute("mockExamRoomRequest", true);
        request.setAttribute("mockExam", mockExam);
        request.setAttribute("examEssays", examEssays);
        request.setAttribute("examQuestionCount", mockExam.getItemCount());

        request.getRequestDispatcher("/WEB-INF/views/mock-essay-room.jsp").forward(request, response);
    }
}
