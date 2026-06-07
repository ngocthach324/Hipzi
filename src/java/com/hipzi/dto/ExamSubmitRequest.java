package com.hipzi.dto;

import java.util.Map;

public class ExamSubmitRequest {

    private String examId;
    private int violationCount;
    // Map of questionId -> selectedOption
    private Map<String, String> answers;

    public ExamSubmitRequest() {
    }

    public String getExamId() {
        return examId;
    }

    public void setExamId(String examId) {
        this.examId = examId;
    }

    public int getViolationCount() {
        return violationCount;
    }

    public void setViolationCount(int violationCount) {
        this.violationCount = violationCount;
    }

    public Map<String, String> getAnswers() {
        return answers;
    }

    public void setAnswers(Map<String, String> answers) {
        this.answers = answers;
    }
}
