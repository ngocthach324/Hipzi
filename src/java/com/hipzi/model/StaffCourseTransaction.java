package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class StaffCourseTransaction {
    private String orderCode;
    private String studentName;
    private String studentEmail;
    private String teacherName;
    private String teacherEmail;
    private String courseTitle;
    private BigDecimal amount;
    private String currency;
    private String status;
    private Timestamp transactionAt;

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getTeacherEmail() { return teacherEmail; }
    public void setTeacherEmail(String teacherEmail) { this.teacherEmail = teacherEmail; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getTransactionAt() { return transactionAt; }
    public void setTransactionAt(Timestamp transactionAt) { this.transactionAt = transactionAt; }

    public String getAmountLabel() {
        BigDecimal value = amount == null ? BigDecimal.ZERO : amount.abs();
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(value) + " " + (currency == null || currency.isEmpty() ? "VND" : currency);
    }

    public String getStatusLabel() {
        if ("paid".equalsIgnoreCase(status)) return "Đã thanh toán";
        if ("failed".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status)) return "Thất bại";
        if ("expired".equalsIgnoreCase(status)) return "Hết hạn";
        return "Chờ xử lý";
    }

    public boolean isPaid() {
        return "paid".equalsIgnoreCase(status);
    }
}
