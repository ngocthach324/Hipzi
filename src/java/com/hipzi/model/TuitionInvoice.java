package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.text.NumberFormat;
import java.util.Locale;

public class TuitionInvoice {
    private String id;
    private String invoiceCode;
    private String classroomId;
    private String studentId;
    private String teacherId;
    private String classroomTitle;
    private String teacherName;
    private BigDecimal amount;
    private String currency;
    private LocalDate dueDate;
    private String status;
    private String paymentContent;
    private String paymentReference;
    private Timestamp paidAt;
    private Timestamp createdAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getInvoiceCode() { return invoiceCode; }
    public void setInvoiceCode(String invoiceCode) { this.invoiceCode = invoiceCode; }
    public String getClassroomId() { return classroomId; }
    public void setClassroomId(String classroomId) { this.classroomId = classroomId; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }
    public String getClassroomTitle() { return classroomTitle; }
    public void setClassroomTitle(String classroomTitle) { this.classroomTitle = classroomTitle; }
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPaymentContent() { return paymentContent; }
    public void setPaymentContent(String paymentContent) { this.paymentContent = paymentContent; }
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isPaid() { return "paid".equalsIgnoreCase(status); }
    public boolean isOverdue() { return !isPaid() && dueDate != null && dueDate.isBefore(LocalDate.now()); }
    public long getDaysUntilDue() { return dueDate == null ? 0 : ChronoUnit.DAYS.between(LocalDate.now(), dueDate); }
    public String getAmountLabel() {
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(amount == null ? BigDecimal.ZERO : amount) + " ₫";
    }
}