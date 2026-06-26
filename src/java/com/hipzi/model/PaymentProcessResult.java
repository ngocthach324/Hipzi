package com.hipzi.model;

public class PaymentProcessResult {
    private final boolean success;
    private final boolean duplicate;
    private final String message;
    private final String orderCode;
    private final String status;

    private PaymentProcessResult(boolean success, boolean duplicate, String message, String orderCode, String status) {
        this.success = success;
        this.duplicate = duplicate;
        this.message = message;
        this.orderCode = orderCode;
        this.status = status;
    }

    public static PaymentProcessResult success(String message, String orderCode, String status) {
        return new PaymentProcessResult(true, false, message, orderCode, status);
    }

    public static PaymentProcessResult duplicate(String message, String orderCode, String status) {
        return new PaymentProcessResult(true, true, message, orderCode, status);
    }

    public static PaymentProcessResult failure(String message, String orderCode, String status) {
        return new PaymentProcessResult(false, false, message, orderCode, status);
    }

    public boolean isSuccess() { return success; }
    public boolean isDuplicate() { return duplicate; }
    public String getMessage() { return message; }
    public String getOrderCode() { return orderCode; }
    public String getStatus() { return status; }
}
