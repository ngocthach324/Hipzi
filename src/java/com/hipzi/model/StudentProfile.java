package com.hipzi.model;

import java.sql.Date;
import java.sql.Timestamp;

public class StudentProfile {
    private String id;
    private String userId;
    private String gradeLevel;
    private String schoolName;
    
    // Caching statistics
    private int currentLevel;
    private int currentXp;
    private int currentStreak;
    private Date lastActivityDate;
    private int completedQuizzesCount;
    private double averageAccuracy;
    private int activeClassesCount;
    
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public StudentProfile() {
        this.currentLevel = 1;
        this.currentXp = 0;
        this.currentStreak = 0;
        this.completedQuizzesCount = 0;
        this.averageAccuracy = 0.0;
        this.activeClassesCount = 0;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getGradeLevel() { return gradeLevel; }
    public void setGradeLevel(String gradeLevel) { this.gradeLevel = gradeLevel; }

    public String getSchoolName() { return schoolName; }
    public void setSchoolName(String schoolName) { this.schoolName = schoolName; }

    public int getCurrentLevel() { return currentLevel; }
    public void setCurrentLevel(int currentLevel) { this.currentLevel = currentLevel; }

    public int getCurrentXp() { return currentXp; }
    public void setCurrentXp(int currentXp) { this.currentXp = currentXp; }

    public int getCurrentStreak() { return currentStreak; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }

    public Date getLastActivityDate() { return lastActivityDate; }
    public void setLastActivityDate(Date lastActivityDate) { this.lastActivityDate = lastActivityDate; }

    public int getCompletedQuizzesCount() { return completedQuizzesCount; }
    public void setCompletedQuizzesCount(int completedQuizzesCount) { this.completedQuizzesCount = completedQuizzesCount; }

    public double getAverageAccuracy() { return averageAccuracy; }
    public void setAverageAccuracy(double averageAccuracy) { this.averageAccuracy = averageAccuracy; }

    public int getActiveClassesCount() { return activeClassesCount; }
    public void setActiveClassesCount(int activeClassesCount) { this.activeClassesCount = activeClassesCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
