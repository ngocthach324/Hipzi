package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class WithdrawalRequest {
    private String id;
    private String requestCode;
    private String teacherId;
    private String teacherName;
    private String teacherEmail;
    private BigDecimal teacherWalletBalance;
    private BigDecimal amount;
    private String currency;
    private String payoutMethod;
    private String momoPhone;
    private String receiverName;
    private String teacherNote;
    private String status;
    private String staffId;
    private String staffNote;
    private String payoutReference;
    private Timestamp requestedAt;
    private Timestamp processingAt;
    private Timestamp paidAt;
    private Timestamp rejectedAt;
    private Timestamp failedAt;
    private Timestamp cancelledAt;
    private Timestamp updatedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getTeacherEmail() { return teacherEmail; }
    public void setTeacherEmail(String teacherEmail) { this.teacherEmail = teacherEmail; }

    public BigDecimal getTeacherWalletBalance() { return teacherWalletBalance; }
    public void setTeacherWalletBalance(BigDecimal teacherWalletBalance) { this.teacherWalletBalance = teacherWalletBalance; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getPayoutMethod() { return payoutMethod; }
    public void setPayoutMethod(String payoutMethod) { this.payoutMethod = payoutMethod; }

    public String getMomoPhone() { return momoPhone; }
    public void setMomoPhone(String momoPhone) { this.momoPhone = momoPhone; }

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public String getTeacherNote() { return teacherNote; }
    public void setTeacherNote(String teacherNote) { this.teacherNote = teacherNote; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStaffId() { return staffId; }
    public void setStaffId(String staffId) { this.staffId = staffId; }

    public String getStaffNote() { return staffNote; }
    public void setStaffNote(String staffNote) { this.staffNote = staffNote; }

    public String getPayoutReference() { return payoutReference; }
    public void setPayoutReference(String payoutReference) { this.payoutReference = payoutReference; }

    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }

    public Timestamp getProcessingAt() { return processingAt; }
    public void setProcessingAt(Timestamp processingAt) { this.processingAt = processingAt; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public Timestamp getRejectedAt() { return rejectedAt; }
    public void setRejectedAt(Timestamp rejectedAt) { this.rejectedAt = rejectedAt; }

    public Timestamp getFailedAt() { return failedAt; }
    public void setFailedAt(Timestamp failedAt) { this.failedAt = failedAt; }

    public Timestamp getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(Timestamp cancelledAt) { this.cancelledAt = cancelledAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getAmountLabel() {
        BigDecimal value = amount == null ? BigDecimal.ZERO : amount.abs();
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(value) + " " + (currency == null || currency.isEmpty() ? "VND" : currency);
    }

    public String getTeacherWalletBalanceLabel() {
        BigDecimal value = teacherWalletBalance == null ? BigDecimal.ZERO : teacherWalletBalance.abs();
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(value) + " VND";
    }

    public String getStatusLabel() {
        if ("processing".equalsIgnoreCase(status)) return "Đang xử lý";
        if ("paid".equalsIgnoreCase(status)) return "Đã thanh toán";
        if ("rejected".equalsIgnoreCase(status)) return "Từ chối";
        if ("failed".equalsIgnoreCase(status)) return "Thất bại";
        if ("cancelled".equalsIgnoreCase(status)) return "Đã hủy";
        return "Chờ xử lý";
    }

    public boolean isOpenStatus() {
        return "pending".equalsIgnoreCase(status) || "processing".equalsIgnoreCase(status);
    }
}
