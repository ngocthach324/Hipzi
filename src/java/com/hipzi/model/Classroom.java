package com.hipzi.model;

import java.sql.Time;
import java.sql.Timestamp;

public class Classroom {
    private String id;
    private String classCode;
    private String teacherId;
    private String title;
    private String subject;
    private String grade;
    private String description;
    private String teacherName;
    private String teacherSchool;
    private String teacherAvatarUrl;
    private int studentCount;
    private String status;
    private String scheduleDays;
    private Time startTime;
    private Time endTime;
    private String schedule;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Classroom() {
    }

    public Classroom(String id, String title, String subject, String grade, String teacherName, String teacherSchool, int studentCount, String status, String schedule) {
        this.id = id;
        this.title = title;
        this.subject = subject;
        this.grade = grade;
        this.teacherName = teacherName;
        this.teacherSchool = teacherSchool;
        this.studentCount = studentCount;
        this.status = status;
        this.schedule = schedule;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getClassCode() { return classCode; }
    public void setClassCode(String classCode) { this.classCode = classCode; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getTeacherSchool() { return teacherSchool; }
    public void setTeacherSchool(String teacherSchool) { this.teacherSchool = teacherSchool; }

    public String getTeacherAvatarUrl() { return teacherAvatarUrl; }
    public void setTeacherAvatarUrl(String teacherAvatarUrl) { this.teacherAvatarUrl = teacherAvatarUrl; }

    public int getStudentCount() { return studentCount; }
    public void setStudentCount(int studentCount) { this.studentCount = studentCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStatusLabel() {
        if ("open".equals(status)) return "Đang mở";
        if ("upcoming".equals(status)) return "Sắp khai giảng";
        if ("closed".equals(status)) return "Đã đóng";
        return status;
    }

    public String getScheduleDays() { return scheduleDays; }
    public void setScheduleDays(String scheduleDays) { this.scheduleDays = scheduleDays; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
