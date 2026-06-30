package com.hipzi.controller;

import com.hipzi.dao.CourseDao;
import com.hipzi.dao.CourseReviewDao;
import com.hipzi.model.Course;
import com.hipzi.model.CourseReview;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.CartService;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/course-detail")
public class CourseDetailServlet extends HttpServlet {

    private final CourseDao courseDao = new CourseDao();
    private final CartService cartService = new CartService();
    private final CourseReviewDao reviewDao = new CourseReviewDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Course ID is required");
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        String viewerId = user != null ? user.getId() : null;

        Course course = courseDao.findById(id, viewerId);

        if (course == null || !"approved".equals(course.getStatus()) || !"public".equals(course.getVisibility())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Course not found or not available");
            return;
        }

        boolean isInCart = false;
        boolean profileHasStudent = false;
        
        if (user != null && user.getRoles() != null) {
            for (Role role : user.getRoles()) {
                if ("student".equals(role.getName())) {
                    profileHasStudent = true;
                    break;
                }
            }
        }
        
        if (profileHasStudent) {
            isInCart = cartService.getCartItems(viewerId).stream()
                                  .anyMatch(item -> item.getCourseId().equals(course.getId()));
        }

        // Fetch course reviews
        List<CourseReview> reviews = reviewDao.findByCourseId(course.getId());
        CourseReview userReview = null;
        if (viewerId != null) {
            userReview = reviewDao.findByCourseAndStudent(course.getId(), viewerId);
        }

        // Fetch related courses (same subject, newest first, exclude current)
        List<Course> relatedCourses = courseDao.findRelatedCourses(course.getId(), course.getSubjectName(), 4, viewerId);

        request.setAttribute("course", course);
        request.setAttribute("isInCart", isInCart);
        request.setAttribute("profileHasStudent", profileHasStudent);
        request.setAttribute("reviews", reviews);
        request.setAttribute("userReview", userReview);
        request.setAttribute("relatedCourses", relatedCourses);

        request.getRequestDispatcher("/WEB-INF/views/course-detail.jsp").forward(request, response);
    }
}
