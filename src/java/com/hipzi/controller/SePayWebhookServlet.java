package com.hipzi.controller;

import com.hipzi.model.PaymentProcessResult;
import com.hipzi.service.SePayPaymentService;

import java.io.BufferedReader;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/payment/sepay/webhook")
public class SePayWebhookServlet extends HttpServlet {
    private final SePayPaymentService paymentService = new SePayPaymentService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String rawPayload = readBody(request);
        PaymentProcessResult result = paymentService.handleWebhook(rawPayload, request);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (!result.isSuccess()) {
            if ("unauthorized".equals(result.getStatus())) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        }

        response.getWriter().write("{"
                + "\"success\":" + result.isSuccess() + ","
                + "\"duplicate\":" + result.isDuplicate() + ","
                + "\"orderCode\":\"" + escapeJson(result.getOrderCode()) + "\","
                + "\"status\":\"" + escapeJson(result.getStatus()) + "\","
                + "\"message\":\"" + escapeJson(result.getMessage()) + "\""
                + "}");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":true,\"message\":\"SePay webhook endpoint is ready.\"}");
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        return body.toString();
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
