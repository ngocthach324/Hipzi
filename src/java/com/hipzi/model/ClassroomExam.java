package com.hipzi.model;

import java.sql.Timestamp;

public class ClassroomExam {
    private String id;
    private String classroomId;
    private String title;
    private String description;
    private String examCode;
    private String sourceMaterialId;
    private String status;
    private int durationMinutes;
    private Timestamp startAt;
    private Timestamp endAt;
    private String createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getClassroomId() { return classroomId; }
    public void setClassroomId(String classroomId) { this.classroomId = classroomId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getExamCode() { return examCode; }
    public void setExamCode(String examCode) { this.examCode = examCode; }

    public String getSourceMaterialId() { return sourceMaterialId; }
    public void setSourceMaterialId(String sourceMaterialId) { this.sourceMaterialId = sourceMaterialId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }

    public Timestamp getStartAt() { return startAt; }
    public void setStartAt(Timestamp startAt) { this.startAt = startAt; }

    public Timestamp getEndAt() { return endAt; }
    public void setEndAt(Timestamp endAt) { this.endAt = endAt; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getStatusLabel() {
        if ("draft".equals(status)) return "Bản nháp";
        if ("closed".equals(status)) return "Đã đóng";
        return "Đang mở";
    }
}
