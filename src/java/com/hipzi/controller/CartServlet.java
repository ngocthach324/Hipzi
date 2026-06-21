package com.hipzi.controller;


import com.hipzi.model.CartItem;
import com.hipzi.model.User;
import com.hipzi.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private CartService cartService;

    @Override
    public void init() throws ServletException {
        cartService = new CartService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if ("count".equals(action)) {
            handleGetCount(user, response);
        } else if ("items".equals(action)) {
            handleGetItems(user, response);
        } else {
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            List<CartItem> cartItems = cartService.getCartItems(user.getId());
            BigDecimal total = cartService.getTotalPrice(user.getId());
            
            request.setAttribute("cartItems", cartItems);
            request.setAttribute("cartTotal", total);
            
            request.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loggedUser") : null;

        if ("add".equals(action)) {
            handleAdd(request, user, response);
        } else if ("remove".equals(action)) {
            handleRemove(request, user, response);
        } else if ("clear".equals(action)) {
            handleClear(user, request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    private void handleGetCount(User user, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (user == null) {
            response.getWriter().write("{\"count\": 0}");
        } else {
            int count = cartService.getCartCount(user.getId());
            response.getWriter().write("{\"count\": " + count + "}");
        }
    }

    private void handleGetItems(User user, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (user == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"Vui l\\u00f2ng \\u0111\\u0103ng nh\\u1eadp\"}");
        } else {
            List<CartItem> items = cartService.getCartItems(user.getId());
            BigDecimal total = cartService.getTotalPrice(user.getId());
            
            NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
            String totalFormatted = format.format(total) + " \\u0111";
            
            StringBuilder itemsJson = new StringBuilder("[");
            for (int i = 0; i < items.size(); i++) {
                CartItem item = items.get(i);
                itemsJson.append("{")
                         .append("\"courseId\":\"").append(item.getCourseId()).append("\",")
                         .append("\"courseTitle\":\"").append(item.getCourseTitle().replace("\"", "\\\"")).append("\",")
                         .append("\"thumbnailUrl\":\"").append(item.getThumbnailUrl() != null ? item.getThumbnailUrl() : "").append("\",")
                         .append("\"price\":").append(item.getPriceAmount()).append(",")
                         .append("\"teacherName\":\"").append(item.getTeacherName().replace("\"", "\\\"")).append("\"")
                         .append("}");
                if (i < items.size() - 1) {
                    itemsJson.append(",");
                }
            }
            itemsJson.append("]");
            
            response.getWriter().write("{\"success\": true, \"items\": " + itemsJson.toString() + ", \"totalLabel\": \"" + totalFormatted + "\"}");
        }
    }

    private void handleAdd(HttpServletRequest request, User user, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String courseId = request.getParameter("courseId");
        
        String error = cartService.addToCart(user, courseId);
        if (error == null) {
            int count = cartService.getCartCount(user.getId());
            response.getWriter().write("{\"success\": true, \"message\": \"\\u0110\\u00e3 th\\u00eam kh\\u00f3a h\\u1ecdc v\\u00e0o gi\\u1ecf h\\u00e0ng!\", \"count\": " + count + "}");
        } else {
            response.getWriter().write("{\"success\": false, \"message\": \"" + error.replace("\"", "\\\"") + "\"}");
        }
    }

    private void handleRemove(HttpServletRequest request, User user, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (user == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"Vui l\\u00f2ng \\u0111\\u0103ng nh\\u1eadp\"}");
            return;
        }
        
        String courseId = request.getParameter("courseId");
        boolean success = cartService.removeFromCart(user.getId(), courseId);
        
        if (success) {
            int count = cartService.getCartCount(user.getId());
            BigDecimal total = cartService.getTotalPrice(user.getId());
            NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
            String totalLabel = format.format(total) + " \\u0111";
            
            response.getWriter().write("{\"success\": true, \"count\": " + count + ", \"totalLabel\": \"" + totalLabel + "\"}");
        } else {
            response.getWriter().write("{\"success\": false, \"message\": \"Kh\\u00f4ng th\\u1ec3 x\\u00f3a kh\\u1ecfi gi\\u1ecf h\\u00e0ng.\"}");
        }
    }

    private void handleClear(User user, HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (user != null) {
            cartService.clearCart(user.getId());
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
