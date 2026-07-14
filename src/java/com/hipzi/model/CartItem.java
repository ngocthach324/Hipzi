package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class CartItem {
    private String id;
    private String studentId;
    private String courseId;
    private String courseTitle;
    private String courseSubjectName;
    private String thumbnailGradient;
    private String thumbnailUrl;
    private BigDecimal priceAmount;
    private String currency;
    private String teacherName;
    private Timestamp addedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getCourseSubjectName() { return courseSubjectName; }
    public void setCourseSubjectName(String courseSubjectName) { this.courseSubjectName = courseSubjectName; }

    public String getThumbnailGradient() { return thumbnailGradient; }
    public void setThumbnailGradient(String thumbnailGradient) { this.thumbnailGradient = thumbnailGradient; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getThumbnailServletUrl(String contextPath) {
        if (thumbnailUrl == null || thumbnailUrl.isBlank()) return null;
        if (thumbnailUrl.startsWith("b2:")) {
            String objectPath = thumbnailUrl.substring(3);
            return contextPath + "/course-thumbnail?p=" 
                   + java.net.URLEncoder.encode(objectPath, java.nio.charset.StandardCharsets.UTF_8);
        }
        return thumbnailUrl;
    }

    public BigDecimal getPriceAmount() { return priceAmount; }
    public void setPriceAmount(BigDecimal priceAmount) { this.priceAmount = priceAmount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public Timestamp getAddedAt() { return addedAt; }
    public void setAddedAt(Timestamp addedAt) { this.addedAt = addedAt; }

    public String getPriceLabel() {
        if (priceAmount == null || priceAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return "Miễn phí";
        }
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(priceAmount) + " đ";
    }

    public String getThumbnailGradientOrDefault() {
        if (thumbnailGradient != null && !thumbnailGradient.trim().isEmpty()) {
            return thumbnailGradient;
        }
        return "linear-gradient(135deg,#3b82f6 0%,#6366f1 100%)";
    }
}
