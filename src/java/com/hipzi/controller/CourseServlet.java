package com.hipzi.controller;

import com.hipzi.dao.CourseDao;
import com.hipzi.model.Course;
import com.hipzi.model.User;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CourseServlet", urlPatterns = {"/courses"})
public class CourseServlet extends HttpServlet {

    private final CourseDao courseDao = new CourseDao();
    private static final ExecutorService executor = Executors.newCachedThreadPool();

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
        
        int page = 1;
        int pageSize = 20;
        
        final String finalSubject = subject;
        final String finalPrice = price;
        final String finalSearch = search;
        final String finalSort = sort;
        
        CompletableFuture<List<Course>> coursesFuture = CompletableFuture.supplyAsync(() -> 
            courseDao.listPublic(finalSubject, finalPrice, finalSearch, finalSort, viewerId, page, pageSize), executor);
            
        CompletableFuture<List<Course>> featuredCoursesFuture = CompletableFuture.supplyAsync(() -> 
            courseDao.listFeaturedPublic(10, viewerId), executor);
            
        CompletableFuture<List<Course>> subjectsFuture = CompletableFuture.supplyAsync(() -> 
            courseDao.listSubjects(), executor);
            
        CompletableFuture<java.util.Set<String>> cartCourseIdsFuture = CompletableFuture.supplyAsync(() -> {
            java.util.Set<String> cartCourseIds = new java.util.HashSet<>();
            if (viewerId != null) {
                com.hipzi.service.CartService cartService = new com.hipzi.service.CartService();
                List<com.hipzi.model.CartItem> cartItems = cartService.getCartItems(viewerId);
                for (com.hipzi.model.CartItem item : cartItems) {
                    cartCourseIds.add(item.getCourseId());
                }
            }
            return cartCourseIds;
        }, executor);

        try {
            CompletableFuture.allOf(coursesFuture, featuredCoursesFuture, subjectsFuture, cartCourseIdsFuture).join();
            
            request.setAttribute("courses", coursesFuture.get());
            request.setAttribute("featuredCourses", featuredCoursesFuture.get());
            request.setAttribute("subjects", subjectsFuture.get());
            request.setAttribute("cartCourseIds", cartCourseIdsFuture.get());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
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
