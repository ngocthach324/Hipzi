package com.hipzi.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ClassroomExam {
    private String id;
    private String classroomId;
    private String title;
    private String description;
    private String examCode;
    private String examType;
    private String creationMode;
    private String rawSourceText;
    private String sourceMaterialId;
    private String status;
    private int durationMinutes;
    private Timestamp startAt;
    private Timestamp endAt;
    private String createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<ClassroomExamQuestion> questions = new ArrayList<>();

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

    public String getExamType() { return examType; }
    public void setExamType(String examType) { this.examType = examType; }

    public String getCreationMode() { return creationMode; }
    public void setCreationMode(String creationMode) { this.creationMode = creationMode; }

    public String getRawSourceText() { return rawSourceText; }
    public void setRawSourceText(String rawSourceText) { this.rawSourceText = rawSourceText; }

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

    public List<ClassroomExamQuestion> getQuestions() { return questions; }
    public void setQuestions(List<ClassroomExamQuestion> questions) {
        this.questions = questions != null ? questions : new ArrayList<ClassroomExamQuestion>();
    }

    public String getExamTypeLabel() {
        if ("essay".equals(examType)) return "Tự luận";
        if ("flashcard".equals(examType)) return "Flashcard";
        return "Trắc nghiệm";
    }

    public String getStatusLabel() {
        if ("draft".equals(status)) return "Bản nháp";
        if ("closed".equals(status)) return "Đã đóng";
        return "Đang mở";
    }
}
