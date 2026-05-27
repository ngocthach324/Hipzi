package com.hipzi.model;

import java.sql.Timestamp;

public class ParentStudentLink {
    private String id;
    private String parentId;
    private String studentId;
    private String status; // pending, linked, rejected
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joins for UI display
    private String studentName;
    private String studentAvatar;
    private String studentCode;
    private String studentEmail;
    private String gradeLevel;
    private int currentLevel = 1;
    private int currentStreak;
    private int completedQuizzesCount;

    public ParentStudentLink() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getParentId() { return parentId; }
    public void setParentId(String parentId) { this.parentId = parentId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentAvatar() { return studentAvatar; }
    public void setStudentAvatar(String studentAvatar) { this.studentAvatar = studentAvatar; }

    public String getStudentCode() { return studentCode; }
    public void setStudentCode(String studentCode) { this.studentCode = studentCode; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getGradeLevel() { return gradeLevel; }
    public void setGradeLevel(String gradeLevel) { this.gradeLevel = gradeLevel; }

    public int getCurrentLevel() { return currentLevel; }
    public void setCurrentLevel(int currentLevel) { this.currentLevel = currentLevel; }

    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }

    public int getCompletedQuizzesCount() { return completedQuizzesCount; }
    public void setCompletedQuizzesCount(int completedQuizzesCount) { this.completedQuizzesCount = completedQuizzesCount; }
}
