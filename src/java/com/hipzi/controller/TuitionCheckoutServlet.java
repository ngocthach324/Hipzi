package com.hipzi.controller;

import com.hipzi.dao.TuitionInvoiceDao;
import com.hipzi.model.TuitionInvoice;
import com.hipzi.model.User;
import com.hipzi.util.PaymentConfig;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/tuition-checkout")
public class TuitionCheckoutServlet extends HttpServlet {
    private final TuitionInvoiceDao invoiceDao = new TuitionInvoiceDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        String id = clean(request.getParameter("id"));
        TuitionInvoice invoice = invoiceDao.findByIdForStudent(id, user.getId());
        if ("status".equals(clean(request.getParameter("action")))) {
            response.setContentType("application/json"); response.setCharacterEncoding("UTF-8");
            if (invoice == null) { response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy hóa đơn.\"}"); return; }
            response.getWriter().write("{\"success\":true,\"paid\":" + invoice.isPaid()
                    + ",\"status\":\"" + escape(invoice.getStatus()) + "\"}");
            return;
        }
        if (invoice == null) { response.sendRedirect(request.getContextPath() + "/student-profile?tab=wallet-history"); return; }
        request.setAttribute("invoice", invoice);
        request.setAttribute("vietQrUrl", PaymentConfig.vietQrUrl(invoice.getAmount(), invoice.getPaymentContent()));
        request.setAttribute("bankLabel", PaymentConfig.bankLabel());
        request.setAttribute("bankAccountName", PaymentConfig.bankAccountName());
        request.getRequestDispatcher("/WEB-INF/views/tuition-checkout.jsp").forward(request, response);
    }
    private String clean(String value) { return value == null ? "" : value.trim(); }
    private String escape(String value) { return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\""); }
}