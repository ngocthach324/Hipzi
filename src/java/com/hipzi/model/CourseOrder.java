package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class CourseOrder {
    private String id;
    private String orderCode;
    private String studentId;
    private BigDecimal totalAmount;
    private String currency;
    private String status;
    private String paymentProvider;
    private String paymentReference;
    private String paymentContent;
    private Timestamp paidAt;
    private Timestamp expiresAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String discountCodeId;
    private BigDecimal discountAmount;
    private List<CourseOrderItem> items = new ArrayList<>();

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentProvider() { return paymentProvider; }
    public void setPaymentProvider(String paymentProvider) { this.paymentProvider = paymentProvider; }

    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }

    public String getPaymentContent() { return paymentContent; }
    public void setPaymentContent(String paymentContent) { this.paymentContent = paymentContent; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public List<CourseOrderItem> getItems() { return items; }
    public void setItems(List<CourseOrderItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public String getDiscountCodeId() { return discountCodeId; }
    public void setDiscountCodeId(String discountCodeId) { this.discountCodeId = discountCodeId; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public String getTotalLabel() {
        if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return "0 đ";
        }
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(totalAmount) + " đ";
    }

    public boolean isPending() {
        return "pending".equalsIgnoreCase(status);
    }

    public boolean isPaid() {
        return "paid".equalsIgnoreCase(status);
    }
}
