package com.hipzi.controller;

import com.hipzi.model.CourseOrder;
import com.hipzi.model.User;
import com.hipzi.service.CheckoutService;
import com.hipzi.util.PaymentConfig;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private final CheckoutService checkoutService = new CheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderId = cleanParam(request.getParameter("id"));
        if ("status".equalsIgnoreCase(cleanParam(request.getParameter("action")))) {
            handleStatus(user, orderId, response);
            return;
        }

        if (orderId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        CourseOrder order = checkoutService.findOrderForUser(user, orderId);
        if (order == null) {
            request.getSession().setAttribute("errorMsg", "Không tìm thấy đơn thanh toán.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        request.setAttribute("order", order);
        request.setAttribute("vietQrUrl", PaymentConfig.vietQrUrl(order));
        request.setAttribute("bankLabel", PaymentConfig.bankLabel());
        request.setAttribute("bankAccountName", PaymentConfig.bankAccountName());
        request.setAttribute("bankAccountNo", PaymentConfig.bankAccountNo());
        request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String[] selected = request.getParameterValues("courseId");
        List<String> selectedCourseIds = selected == null
                ? Collections.emptyList()
                : Arrays.asList(selected);

        CheckoutService.CheckoutResult result = checkoutService.createOrderFromCart(user, selectedCourseIds);
        if (!result.isSuccess()) {
            request.getSession().setAttribute("errorMsg", result.getError());
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/checkout?id=" + result.getOrder().getId());
    }

    private void handleStatus(User user, String orderId, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        CourseOrder order = checkoutService.findOrderForUser(user, orderId);
        if (order == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy đơn thanh toán.\"}");
            return;
        }

        response.getWriter().write("{"
                + "\"success\":true,"
                + "\"orderId\":\"" + escapeJson(order.getId()) + "\","
                + "\"orderCode\":\"" + escapeJson(order.getOrderCode()) + "\","
                + "\"status\":\"" + escapeJson(order.getStatus()) + "\","
                + "\"paid\":" + order.isPaid() + ","
                + "\"totalLabel\":\"" + escapeJson(order.getTotalLabel()) + "\""
                + "}");
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
