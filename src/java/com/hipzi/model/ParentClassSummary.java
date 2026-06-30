package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Time;
import java.time.LocalDate;
import java.text.NumberFormat;
import java.util.Locale;

public class ParentClassSummary {
    private String classroomId;
    private String title;
    private String scheduleDays;
    private Time startTime;
    private Time endTime;
    private BigDecimal tuitionFee;
    private LocalDate tuitionDueDate;

    public String getClassroomId() { return classroomId; }
    public void setClassroomId(String classroomId) { this.classroomId = classroomId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getScheduleDays() { return scheduleDays; }
    public void setScheduleDays(String scheduleDays) { this.scheduleDays = scheduleDays; }
    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }
    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }
    public BigDecimal getTuitionFee() { return tuitionFee; }
    public void setTuitionFee(BigDecimal tuitionFee) { this.tuitionFee = tuitionFee; }
    public LocalDate getTuitionDueDate() { return tuitionDueDate; }
    public void setTuitionDueDate(LocalDate tuitionDueDate) { this.tuitionDueDate = tuitionDueDate; }

    public String getScheduleLabel() {
        String days = scheduleDays == null || scheduleDays.trim().isEmpty() ? "Chưa cập nhật lịch" : scheduleDays.trim();
        if (startTime == null || endTime == null) return days;
        return days + " · " + startTime.toLocalTime().toString().substring(0, 5)
                + " - " + endTime.toLocalTime().toString().substring(0, 5);
    }
    public String getTuitionLabel() {
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(tuitionFee == null ? BigDecimal.ZERO : tuitionFee) + " ₫";
    }
}