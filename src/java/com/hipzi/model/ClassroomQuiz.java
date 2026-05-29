package com.hipzi.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ClassroomQuiz {
    private String id;
    private String classroomId;
    private String title;
    private String description;
    private String sourceImagePath;
    private String sourceFileName;
    private String rawScanText;
    private String status;
    private String createdBy;
    private Timestamp publishedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<ClassroomQuizQuestion> questions = new ArrayList<>();

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getClassroomId() { return classroomId; }
    public void setClassroomId(String classroomId) { this.classroomId = classroomId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getSourceImagePath() { return sourceImagePath; }
    public void setSourceImagePath(String sourceImagePath) { this.sourceImagePath = sourceImagePath; }

    public String getSourceFileName() { return sourceFileName; }
    public void setSourceFileName(String sourceFileName) { this.sourceFileName = sourceFileName; }

    public String getRawScanText() { return rawScanText; }
    public void setRawScanText(String rawScanText) { this.rawScanText = rawScanText; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public Timestamp getPublishedAt() { return publishedAt; }
    public void setPublishedAt(Timestamp publishedAt) { this.publishedAt = publishedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public List<ClassroomQuizQuestion> getQuestions() { return questions; }
    public void setQuestions(List<ClassroomQuizQuestion> questions) {
        this.questions = questions != null ? questions : new ArrayList<ClassroomQuizQuestion>();
    }

    public int getQuestionCount() {
        return questions != null ? questions.size() : 0;
    }

    public boolean isPublished() {
        return "published".equals(status);
    }
}
