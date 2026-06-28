package com.hipzi.dto;

import com.hipzi.model.ClassroomExamAttempt;
import java.io.Serializable;

public class ClassroomExamResultAttemptDto implements Serializable {

    private ClassroomExamAttempt attempt;
    private int attemptNumber;
    private int correctCount;
    private int wrongCount;
    private int totalCount;

    public ClassroomExamResultAttemptDto() {
    }

    public ClassroomExamResultAttemptDto(ClassroomExamAttempt attempt, int attemptNumber,
            int correctCount, int wrongCount, int totalCount) {
        this.attempt = attempt;
        this.attemptNumber = attemptNumber;
        this.correctCount = correctCount;
        this.wrongCount = wrongCount;
        this.totalCount = totalCount;
    }

    public ClassroomExamAttempt getAttempt() {
        return attempt;
    }

    public void setAttempt(ClassroomExamAttempt attempt) {
        this.attempt = attempt;
    }

    public int getAttemptNumber() {
        return attemptNumber;
    }

    public void setAttemptNumber(int attemptNumber) {
        this.attemptNumber = attemptNumber;
    }

    public int getCorrectCount() {
        return correctCount;
    }

    public void setCorrectCount(int correctCount) {
        this.correctCount = correctCount;
    }

    public int getWrongCount() {
        return wrongCount;
    }

    public void setWrongCount(int wrongCount) {
        this.wrongCount = wrongCount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }
}
