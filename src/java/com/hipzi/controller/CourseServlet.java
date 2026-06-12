package com.hipzi.controller;

import com.hipzi.dao.CourseDao;
import com.hipzi.model.Course;
import com.hipzi.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CourseServlet", urlPatterns = {"/courses"})
public class CourseServlet extends HttpServlet {

    private final CourseDao courseDao = new CourseDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String subject = cleanParam(request.getParameter("subject"));
        String price = cleanParam(request.getParameter("price"));
        String search = cleanParam(request.getParameter("q"));
        String sort = cleanParam(request.getParameter("sort"));
        if (subject.isEmpty()) subject = "all";
        if (price.isEmpty()) price = "all";
        if (sort.isEmpty()) sort = "popular";

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        String viewerId = user != null ? user.getId() : null;
        List<Course> courses = courseDao.listPublic(subject, price, search, sort, viewerId);
        request.setAttribute("courses", courses);
        request.setAttribute("currentSubject", subject);
        request.setAttribute("currentPrice", price);
        request.setAttribute("currentSearch", search);
        request.setAttribute("currentSort", sort);

        request.getRequestDispatcher("/WEB-INF/views/courses.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
