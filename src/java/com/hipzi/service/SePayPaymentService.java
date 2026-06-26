package com.hipzi.service;

import com.hipzi.dao.CoursePaymentDao;
import com.hipzi.model.PaymentProcessResult;

import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import jakarta.servlet.http.HttpServletRequest;

public class SePayPaymentService {
    private static final Pattern ORDER_CODE_PATTERN = Pattern.compile("\\b(?:HIPZI\\d{6,8}|HZ\\d{16})\\b", Pattern.CASE_INSENSITIVE);
    private final CoursePaymentDao paymentDao;

    public SePayPaymentService() {
        this.paymentDao = new CoursePaymentDao();
    }

    public PaymentProcessResult handleWebhook(String rawPayload, HttpServletRequest request) {
        if (!isAuthorized(request)) {
            return PaymentProcessResult.failure("Webhook không hợp lệ.", "", "unauthorized");
        }

        String content = firstString(rawPayload,
                "content", "description", "transaction_content", "transferContent", "transactionContent");
        String reference = firstString(rawPayload,
                "referenceCode", "reference_code", "transactionId", "transaction_id", "id", "code");
        String providerEventId = firstString(rawPayload,
                "id", "transactionId", "transaction_id", "referenceCode", "reference_code");
        BigDecimal amount = firstDecimal(rawPayload,
                "transferAmount", "transfer_amount", "amount", "creditAmount", "credit_amount", "money");

        String orderCode = extractOrderCode(content);
        if (orderCode.isEmpty()) {
            orderCode = extractOrderCode(rawPayload);
        }

        return paymentDao.processSePayPayment(orderCode, amount, reference, content, providerEventId, rawPayload);
    }

    private boolean isAuthorized(HttpServletRequest request) {
        String expectedSecret = configValue("SEPAY_WEBHOOK_SECRET");
        if (expectedSecret == null || expectedSecret.trim().isEmpty()) {
            return true;
        }

        String headerSecret = request.getHeader("X-SePay-Webhook-Secret");
        if (expectedSecret.equals(headerSecret)) {
            return true;
        }

        String authorization = request.getHeader("Authorization");
        return authorization != null && authorization.equals("Bearer " + expectedSecret);
    }

    private String configValue(String key) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        return value;
    }

    private String extractOrderCode(String text) {
        if (text == null) {
            return "";
        }
        Matcher matcher = ORDER_CODE_PATTERN.matcher(text);
        if (matcher.find()) {
            return matcher.group().toUpperCase();
        }
        return "";
    }

    private String firstString(String json, String... keys) {
        for (String key : keys) {
            String value = extractString(json, key);
            if (!value.isEmpty()) {
                return value;
            }
        }
        return "";
    }

    private BigDecimal firstDecimal(String json, String... keys) {
        for (String key : keys) {
            String value = extractRawValue(json, key);
            BigDecimal decimal = parseDecimal(value);
            if (decimal != null) {
                return decimal;
            }
        }
        return null;
    }

    private String extractString(String json, String key) {
        String value = extractRawValue(json, key);
        if (value == null) {
            return "";
        }
        value = value.trim();
        if (value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) {
            value = value.substring(1, value.length() - 1);
        }
        return unescapeJson(value).trim();
    }

    private String extractRawValue(String json, String key) {
        if (json == null || json.trim().isEmpty()) {
            return null;
        }
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(\"(?:\\\\.|[^\"])*\"|-?\\d+(?:\\.\\d+)?|null)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private BigDecimal parseDecimal(String rawValue) {
        if (rawValue == null) {
            return null;
        }
        String value = rawValue.trim();
        if (value.equalsIgnoreCase("null") || value.isEmpty()) {
            return null;
        }
        if (value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) {
            value = unescapeJson(value.substring(1, value.length() - 1));
        }
        value = value.replace(",", "").replace(" ", "");
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String unescapeJson(String value) {
        return value.replace("\\\"", "\"")
                .replace("\\\\", "\\")
                .replace("\\/", "/")
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t");
    }
}
