package com.hipzi.controller;

import com.hipzi.model.Quiz;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "PracticeServlet", urlPatterns = {"/practice"})
public class PracticeServlet extends HttpServlet {

    private com.hipzi.service.PracticeService practiceService = new com.hipzi.service.PracticeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String subjectParam = request.getParameter("subject");
        String gradeParam = request.getParameter("grade");
        String typeParam = request.getParameter("type");
        String searchParam = request.getParameter("q");

        List<Quiz> quizzes = practiceService.getFilteredQuizzes(subjectParam, gradeParam, typeParam, searchParam);

        request.setAttribute("quizzes", quizzes);

        // Nếu là AJAX request (từ bộ lọc sidebar), chỉ trả về fragment kết quả
        String ajaxParam = request.getParameter("ajax");
        if ("1".equals(ajaxParam)) {
            request.getRequestDispatcher("/WEB-INF/fragments/practice-results.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/practice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}