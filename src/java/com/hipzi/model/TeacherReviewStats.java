package com.hipzi.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;

public class TeacherReviewStats {
    private int totalReviews;
    private BigDecimal averageRating = BigDecimal.ZERO;
    private int satisfiedCount;
    private int okayCount;
    private int needsImprovementCount;

    public int getTotalReviews() {
        return totalReviews;
    }

    public void setTotalReviews(int totalReviews) {
        this.totalReviews = Math.max(0, totalReviews);
    }

    public BigDecimal getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(BigDecimal averageRating) {
        this.averageRating = averageRating == null ? BigDecimal.ZERO : averageRating;
    }

    public int getSatisfiedCount() {
        return satisfiedCount;
    }

    public void setSatisfiedCount(int satisfiedCount) {
        this.satisfiedCount = Math.max(0, satisfiedCount);
    }

    public int getOkayCount() {
        return okayCount;
    }

    public void setOkayCount(int okayCount) {
        this.okayCount = Math.max(0, okayCount);
    }

    public int getNeedsImprovementCount() {
        return needsImprovementCount;
    }

    public void setNeedsImprovementCount(int needsImprovementCount) {
        this.needsImprovementCount = Math.max(0, needsImprovementCount);
    }

    public String getAverageRatingLabel() {
        if (totalReviews <= 0) {
            return "0.0";
        }
        DecimalFormat format = new DecimalFormat("0.0");
        return format.format(averageRating.setScale(1, RoundingMode.HALF_UP));
    }

    public int getSatisfiedPercent() {
        return percentOf(satisfiedCount);
    }

    public int getOkayPercent() {
        return percentOf(okayCount);
    }

    public int getNeedsImprovementPercent() {
        if (totalReviews <= 0) {
            return 0;
        }
        return Math.max(0, 100 - getSatisfiedPercent() - getOkayPercent());
    }

    public int getOkayEndPercent() {
        return Math.min(100, getSatisfiedPercent() + getOkayPercent());
    }

    private int percentOf(int count) {
        if (totalReviews <= 0 || count <= 0) {
            return 0;
        }
        return (int) Math.round((count * 100.0) / totalReviews);
    }
}
