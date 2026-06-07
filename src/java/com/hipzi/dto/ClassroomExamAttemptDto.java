package com.hipzi.dto;

import com.hipzi.model.ClassroomExamAttempt;
import java.io.Serializable;

public class ClassroomExamAttemptDto implements Serializable {

    private ClassroomExamAttempt attempt;
    private String studentName;
    private String studentEmail;
    private String studentAvatar;
    private int attemptCount;
    private Double bestScore;

    public ClassroomExamAttemptDto() {
    }

    public ClassroomExamAttemptDto(ClassroomExamAttempt attempt, String studentName, String studentEmail, String studentAvatar) {
        this.attempt = attempt;
        this.studentName = studentName;
        this.studentEmail = studentEmail;
        this.studentAvatar = studentAvatar;
    }

    public ClassroomExamAttempt getAttempt() {
        return attempt;
    }

    public void setAttempt(ClassroomExamAttempt attempt) {
        this.attempt = attempt;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getStudentAvatar() {
        return studentAvatar;
    }

    public void setStudentAvatar(String studentAvatar) {
        this.studentAvatar = studentAvatar;
    }

    public int getAttemptCount() {
        return attemptCount;
    }

    public void setAttemptCount(int attemptCount) {
        this.attemptCount = attemptCount;
    }

    public Double getBestScore() {
        return bestScore;
    }

    public void setBestScore(Double bestScore) {
        this.bestScore = bestScore;
    }
}
