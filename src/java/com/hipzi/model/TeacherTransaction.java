package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class TeacherTransaction {
    private String transactionCode;
    private Timestamp transactionAt;
    private String description;
    private BigDecimal amount;
    private String currency;
    private String status;
    private boolean credit;

    public String getTransactionCode() { return transactionCode; }
    public void setTransactionCode(String transactionCode) { this.transactionCode = transactionCode; }

    public Timestamp getTransactionAt() { return transactionAt; }
    public void setTransactionAt(Timestamp transactionAt) { this.transactionAt = transactionAt; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isCredit() { return credit; }
    public void setCredit(boolean credit) { this.credit = credit; }

    public String getAmountLabel() {
        BigDecimal displayAmount = amount == null ? BigDecimal.ZERO : amount.abs();
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        String sign = credit ? "+" : "-";
        return sign + format.format(displayAmount) + " " + (currency == null || currency.isEmpty() ? "VND" : currency);
    }

    public String getStatusLabel() {
        if ("paid".equalsIgnoreCase(status) || "success".equalsIgnoreCase(status) || "completed".equalsIgnoreCase(status)) {
            return "Thành công";
        }
        if ("rejected".equalsIgnoreCase(status)) {
            return "Từ chối";
        }
        if ("failed".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status)) {
            return "Thất bại";
        }
        if ("expired".equalsIgnoreCase(status)) {
            return "Hết hạn";
        }
        if ("pending".equalsIgnoreCase(status)) {
            return "Chờ xử lý";
        }
        return status == null || status.isEmpty() ? "Không rõ" : status;
    }

    public boolean isSuccessStatus() {
        return "paid".equalsIgnoreCase(status) || "success".equalsIgnoreCase(status) || "completed".equalsIgnoreCase(status);
    }

    public boolean isFailedStatus() {
        return "failed".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status)
                || "expired".equalsIgnoreCase(status) || "rejected".equalsIgnoreCase(status);
    }
}
