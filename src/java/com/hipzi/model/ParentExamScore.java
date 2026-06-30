package com.hipzi.model;

import java.math.BigDecimal;

public class ParentExamScore {
    private String examId;
    private String examTitle;
    private BigDecimal score;

    public String getExamId() { return examId; }
    public void setExamId(String examId) { this.examId = examId; }
    public String getExamTitle() { return examTitle; }
    public void setExamTitle(String examTitle) { this.examTitle = examTitle; }
    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }
    public String getScoreLabel() {
        if (score == null) return "Chờ chấm";
        return score.stripTrailingZeros().toPlainString() + " điểm";
    }
}