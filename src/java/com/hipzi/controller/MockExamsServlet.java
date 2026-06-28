package com.hipzi.controller;

import com.hipzi.dao.MockExamDao;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "MockExamsServlet", urlPatterns = {"/mock-exams"})
public class MockExamsServlet extends HttpServlet {
    private final MockExamDao mockExamDao = new MockExamDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("publishedMockMcqExams", mockExamDao.listPublishedByType("multiple_choice", 60));
        request.setAttribute("publishedMockEssayExams", mockExamDao.listPublishedByType("essay", 60));
        request.getRequestDispatcher("/WEB-INF/views/mock-exams.jsp").forward(request, response);
    }
}
