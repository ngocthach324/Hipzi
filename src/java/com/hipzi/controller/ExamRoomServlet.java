package com.hipzi.controller;

import com.hipzi.model.Quiz;
import com.hipzi.service.ExamRoomService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ExamRoomServlet", urlPatterns = {"/exam-room"})
public class ExamRoomServlet extends HttpServlet {

    private final ExamRoomService examRoomService = new ExamRoomService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String subjectParam = request.getParameter("subject");
        String gradeParam = request.getParameter("grade");
        String examCategoryParam = request.getParameter("examCategory");
        String searchParam = request.getParameter("q");

        List<Quiz> exams = examRoomService.getFilteredExams(subjectParam, gradeParam, examCategoryParam, searchParam);
        request.setAttribute("exams", exams);

        request.getRequestDispatcher("/WEB-INF/views/exam-room.jsp").forward(request, response);
    }
}