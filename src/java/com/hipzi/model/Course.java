package com.hipzi.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class Course {
    private String id;
    private String courseCode;
    private String teacherId;
    private String title;
    private String shortDescription;
    private String subjectCode;
    private String subjectName;
    private String gradeLevel;
    private String levelName;
    private String priceType;
    private BigDecimal priceAmount;
    private String currency;
    private String thumbnailUrl;
    private String thumbnailGradient;
    private String badgeText;
    private int lessonsCount;
    private BigDecimal estimatedHours;
    private int studentsCount;
    private BigDecimal ratingAverage;
    private int ratingCount;
    private boolean featured;
    private boolean isNew;
    private String googleDriveUrl;
    private String googleDriveFileId;
    private String googleDriveFolderId;
    private String driveOwnerEmail;
    private String accessInstructions;
    private boolean requireDriveGrant;
    private String status;
    private String visibility;
    private String reviewNote;
    private String teacherName;
    private String teacherEmail;
    private String teacherAvatarUrl;
    private String teacherSchool;
    private boolean viewerEnrolled;
    private int viewerProgressPercent;
    private Timestamp submittedAt;
    private Timestamp reviewedAt;
    private Timestamp deletedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    private String learningObjectives;
    private String curriculumOutline;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getShortDescription() { return shortDescription; }
    public void setShortDescription(String shortDescription) { this.shortDescription = shortDescription; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getGradeLevel() { return gradeLevel; }
    public void setGradeLevel(String gradeLevel) { this.gradeLevel = gradeLevel; }

    public String getLevelName() { return levelName; }
    public void setLevelName(String levelName) { this.levelName = levelName; }

    public String getPriceType() { return priceType; }
    public void setPriceType(String priceType) { this.priceType = priceType; }

    public BigDecimal getPriceAmount() { return priceAmount; }
    public void setPriceAmount(BigDecimal priceAmount) { this.priceAmount = priceAmount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getThumbnailGradient() { return thumbnailGradient; }
    public void setThumbnailGradient(String thumbnailGradient) { this.thumbnailGradient = thumbnailGradient; }

    public String getBadgeText() { return badgeText; }
    public void setBadgeText(String badgeText) { this.badgeText = badgeText; }

    public int getLessonsCount() { return lessonsCount; }
    public void setLessonsCount(int lessonsCount) { this.lessonsCount = lessonsCount; }

    public BigDecimal getEstimatedHours() { return estimatedHours; }
    public void setEstimatedHours(BigDecimal estimatedHours) { this.estimatedHours = estimatedHours; }

    public int getStudentsCount() { return studentsCount; }
    public void setStudentsCount(int studentsCount) { this.studentsCount = studentsCount; }

    public BigDecimal getRatingAverage() { return ratingAverage; }
    public void setRatingAverage(BigDecimal ratingAverage) { this.ratingAverage = ratingAverage; }

    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }

    public boolean isFeatured() { return featured; }
    public void setFeatured(boolean featured) { this.featured = featured; }

    public boolean isNew() { return isNew; }
    public void setNew(boolean aNew) { isNew = aNew; }

    public String getGoogleDriveUrl() { return googleDriveUrl; }
    public void setGoogleDriveUrl(String googleDriveUrl) { this.googleDriveUrl = googleDriveUrl; }

    public String getGoogleDriveFileId() { return googleDriveFileId; }
    public void setGoogleDriveFileId(String googleDriveFileId) { this.googleDriveFileId = googleDriveFileId; }

    public String getGoogleDriveFolderId() { return googleDriveFolderId; }
    public void setGoogleDriveFolderId(String googleDriveFolderId) { this.googleDriveFolderId = googleDriveFolderId; }

    public String getDriveOwnerEmail() { return driveOwnerEmail; }
    public void setDriveOwnerEmail(String driveOwnerEmail) { this.driveOwnerEmail = driveOwnerEmail; }

    public String getAccessInstructions() { return accessInstructions; }
    public void setAccessInstructions(String accessInstructions) { this.accessInstructions = accessInstructions; }

    public boolean isRequireDriveGrant() { return requireDriveGrant; }
    public void setRequireDriveGrant(boolean requireDriveGrant) { this.requireDriveGrant = requireDriveGrant; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getVisibility() { return visibility; }
    public void setVisibility(String visibility) { this.visibility = visibility; }

    public String getReviewNote() { return reviewNote; }
    public void setReviewNote(String reviewNote) { this.reviewNote = reviewNote; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getTeacherEmail() { return teacherEmail; }
    public void setTeacherEmail(String teacherEmail) { this.teacherEmail = teacherEmail; }

    public String getTeacherAvatarUrl() { return teacherAvatarUrl; }
    public void setTeacherAvatarUrl(String teacherAvatarUrl) { this.teacherAvatarUrl = teacherAvatarUrl; }

    public String getTeacherSchool() { return teacherSchool; }
    public void setTeacherSchool(String teacherSchool) { this.teacherSchool = teacherSchool; }

    public boolean isViewerEnrolled() { return viewerEnrolled; }
    public void setViewerEnrolled(boolean viewerEnrolled) { this.viewerEnrolled = viewerEnrolled; }

    public int getViewerProgressPercent() { return viewerProgressPercent; }
    public void setViewerProgressPercent(int viewerProgressPercent) { this.viewerProgressPercent = viewerProgressPercent; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }

    public Timestamp getDeletedAt() { return deletedAt; }
    public void setDeletedAt(Timestamp deletedAt) { this.deletedAt = deletedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public boolean isFree() {
        return !"paid".equalsIgnoreCase(priceType) || priceAmount == null || priceAmount.compareTo(BigDecimal.ZERO) <= 0;
    }

    public String getPriceLabel() {
        if (isFree()) {
            return "Miễn phí";
        }
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(priceAmount) + " đ";
    }

    public String getDisplayRating() {
        if (ratingAverage == null || ratingAverage.compareTo(BigDecimal.ZERO) <= 0) {
            return "Mới";
        }
        return ratingAverage.setScale(1, java.math.RoundingMode.HALF_UP).toPlainString();
    }

    public String getStatusLabel() {
        if ("approved".equals(status)) return "Đã duyệt";
        if ("rejected".equals(status)) return "Từ chối";
        if ("needs_revision".equals(status)) return "Cần chỉnh sửa";
        if ("archived".equals(status)) return "Đã lưu trữ";
        if ("draft".equals(status)) return "Bản nháp";
        return "Chờ duyệt";
    }

    public String getThumbnailGradientOrDefault() {
        if (thumbnailGradient != null && !thumbnailGradient.trim().isEmpty()) {
            return thumbnailGradient;
        }
        return "linear-gradient(135deg,#3b82f6 0%,#6366f1 100%)";
    }

    public String getLearningObjectives() { return learningObjectives; }
    public void setLearningObjectives(String learningObjectives) { this.learningObjectives = learningObjectives; }

    public String getCurriculumOutline() { return curriculumOutline; }
    public void setCurriculumOutline(String curriculumOutline) { this.curriculumOutline = curriculumOutline; }

    public java.util.List<String> getLearningObjectivesList() {
        java.util.List<String> list = new java.util.ArrayList<>();
        if (learningObjectives != null && !learningObjectives.trim().isEmpty()) {
            String[] parts = learningObjectives.split("\\|\\|\\|");
            for (String part : parts) {
                if (!part.trim().isEmpty()) {
                    list.add(part.trim());
                }
            }
        }
        return list;
    }

    public java.util.List<java.util.Map<String, String>> getCurriculumList() {
        java.util.List<java.util.Map<String, String>> list = new java.util.ArrayList<>();
        if (curriculumOutline != null && !curriculumOutline.trim().isEmpty()) {
            String[] parts = curriculumOutline.split("\\|\\|\\|");
            for (String part : parts) {
                if (!part.trim().isEmpty()) {
                    String[] kv = part.split(":::!:::");
                    java.util.Map<String, String> map = new java.util.HashMap<>();
                    map.put("title", kv.length > 0 ? kv[0].trim() : "");
                    map.put("description", kv.length > 1 ? kv[1].trim() : "");
                    list.add(map);
                }
            }
        }
        return list;
    }
}
