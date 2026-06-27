package com.hipzi.model;

import java.util.ArrayList;
import java.util.List;

public class StaffUserGrowthStats {
    private List<Point> weeklyPoints = new ArrayList<>();
    private List<Point> monthlyPoints = new ArrayList<>();
    private int weeklyTotal;
    private int previousWeeklyTotal;

    public List<Point> getWeeklyPoints() {
        return weeklyPoints;
    }

    public void setWeeklyPoints(List<Point> weeklyPoints) {
        this.weeklyPoints = weeklyPoints == null ? new ArrayList<>() : weeklyPoints;
    }

    public List<Point> getMonthlyPoints() {
        return monthlyPoints;
    }

    public void setMonthlyPoints(List<Point> monthlyPoints) {
        this.monthlyPoints = monthlyPoints == null ? new ArrayList<>() : monthlyPoints;
    }

    public int getWeeklyTotal() {
        return weeklyTotal;
    }

    public void setWeeklyTotal(int weeklyTotal) {
        this.weeklyTotal = Math.max(0, weeklyTotal);
    }

    public int getPreviousWeeklyTotal() {
        return previousWeeklyTotal;
    }

    public void setPreviousWeeklyTotal(int previousWeeklyTotal) {
        this.previousWeeklyTotal = Math.max(0, previousWeeklyTotal);
    }

    public String getTrendPercentLabel() {
        if (previousWeeklyTotal <= 0) {
            return weeklyTotal > 0 ? "100%" : "0%";
        }
        int diff = weeklyTotal - previousWeeklyTotal;
        long percent = Math.round((diff * 100.0) / previousWeeklyTotal);
        return percent + "%";
    }

    public static class Point {
        private final String label;
        private final String fullLabel;
        private final int count;

        public Point(String label, String fullLabel, int count) {
            this.label = label;
            this.fullLabel = fullLabel;
            this.count = Math.max(0, count);
        }

        public String getLabel() {
            return label;
        }

        public String getFullLabel() {
            return fullLabel;
        }

        public int getCount() {
            return count;
        }

        public String getCountLabel() {
            return count + " tài khoản";
        }
    }
}
