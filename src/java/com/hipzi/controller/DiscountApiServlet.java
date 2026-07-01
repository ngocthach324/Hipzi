package com.hipzi.controller;

import com.hipzi.dao.DiscountCodeDao;
import com.hipzi.model.DiscountCode;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/discount/apply")
public class DiscountApiServlet extends HttpServlet {
    private final DiscountCodeDao discountCodeDao = new DiscountCodeDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (code == null || code.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập mã giảm giá.\"}");
            return;
        }

        DiscountCode dc = discountCodeDao.findByCode(code);
        if (dc == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Mã giảm giá không tồn tại.\"}");
            return;
        }

        if (!dc.isValid()) {
            if (!dc.isActive()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Mã giảm giá đã bị khóa.\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Mã giảm giá đã hết lượt sử dụng.\"}");
            }
            return;
        }

        response.getWriter().write("{"
                + "\"success\":true,"
                + "\"discount_amount\":" + dc.getDiscountAmount() + ","
                + "\"code\":\"" + dc.getCode() + "\","
                + "\"message\":\"Áp dụng mã thành công!\""
                + "}");
    }
}
