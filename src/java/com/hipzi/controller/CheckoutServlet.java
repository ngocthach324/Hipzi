package com.hipzi.controller;

import com.hipzi.dao.CourseAccessGrantDao;
import com.hipzi.model.CourseAccessSummary;
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
    private final CourseAccessGrantDao accessGrantDao = new CourseAccessGrantDao();

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
        request.setAttribute("accessSummary", accessGrantDao.summarizeByOrderId(order.getId()));
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

        String discountCode = request.getParameter("discountCode");

        CheckoutService.CheckoutResult result = checkoutService.createOrderFromCart(user, selectedCourseIds, discountCode);
        if (!result.isSuccess()) {
            request.getSession().setAttribute("errorMsg", result.getError());
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if (result.getOrder().isPaid()) {
            com.hipzi.service.CourseAccessGrantService accessService = new com.hipzi.service.CourseAccessGrantService();
            accessService.processOrderAccessGrants(result.getOrder().getOrderCode(), request.getServletContext());
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

        CourseAccessSummary accessSummary = accessGrantDao.summarizeByOrderId(order.getId());
        response.getWriter().write("{"
                + "\"success\":true,"
                + "\"orderId\":\"" + escapeJson(order.getId()) + "\","
                + "\"orderCode\":\"" + escapeJson(order.getOrderCode()) + "\","
                + "\"status\":\"" + escapeJson(order.getStatus()) + "\","
                + "\"paid\":" + order.isPaid() + ","
                + "\"accessStatus\":\"" + escapeJson(accessStatus(order, accessSummary)) + "\","
                + "\"accessMessage\":\"" + escapeJson(accessMessage(order, accessSummary)) + "\","
                + "\"accessEmail\":\"" + escapeJson(accessSummary.getStudentEmail()) + "\","
                + "\"totalLabel\":\"" + escapeJson(order.getTotalLabel()) + "\""
                + "}");
    }

    private String accessStatus(CourseOrder order, CourseAccessSummary summary) {
        if (order == null || !order.isPaid()) {
            return "waiting_payment";
        }
        if (summary != null && summary.isAllGranted()) {
            return "granted";
        }
        if (summary != null && summary.hasFailure()) {
            return "failed";
        }
        return "pending_access";
    }

    private String accessMessage(CourseOrder order, CourseAccessSummary summary) {
        if (order == null || !order.isPaid()) {
            return "Sau khi chuyển khoản đúng số tiền và nội dung, SePay sẽ gửi webhook về HIPZI để kích hoạt khóa học.";
        }
        String email = summary != null ? summary.getStudentEmail() : "";
        if (summary != null && summary.isAllGranted()) {
            return "Khóa học đã được gửi qua email " + valueOrDefault(email, "của bạn") + ". Vui lòng kiểm tra Google Drive hoặc hộp thư của bạn.";
        }
        if (summary != null && summary.hasFailure()) {
            return "Thanh toán đã được ghi nhận, nhưng HIPZI chưa thể tự động cấp quyền Google Drive. Bộ phận hỗ trợ hoặc giáo viên sẽ xử lý lại cho bạn.";
        }
        return "Thanh toán thành công. HIPZI đang cấp quyền truy cập khóa học qua email của bạn, vui lòng kiểm tra lại sau ít phút.";
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }
}
