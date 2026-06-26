package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.CourseReviewService;
import com.hipzi.dao.CourseDao;
import com.hipzi.model.Course;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/course/review")
public class CourseReviewServlet extends HttpServlet {

    private final CourseReviewService reviewService = new CourseReviewService();
    private final CourseDao courseDao = new CourseDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String courseId = request.getParameter("courseId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        if (courseId == null || courseId.trim().isEmpty() || ratingStr == null || ratingStr.trim().isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId + "#reviews-section");
            return;
        }

        int rating = 0;
        try {
            rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Số sao đánh giá không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId + "#reviews-section");
            return;
        }

        // Fetch course to check if it exists
        Course course = courseDao.findById(courseId, user.getId());
        if (course == null) {
            request.getSession().setAttribute("errorMsg", "Khóa học không tồn tại.");
            response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId + "#reviews-section");
            return;
        }

        boolean success = reviewService.submitReview(courseId, user.getId(), rating, reviewText);

        if (success) {
            request.getSession().setAttribute("successMsg", "Cảm ơn bạn đã gửi đánh giá!");
        } else {
            request.getSession().setAttribute("errorMsg", "Có lỗi xảy ra khi lưu đánh giá. Vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + "/course-detail?id=" + courseId + "#reviews-section");
    }
}
