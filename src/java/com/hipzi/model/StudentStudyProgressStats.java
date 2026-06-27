package com.hipzi.model;

import java.util.ArrayList;
import java.util.List;

public class StudentStudyProgressStats {
    private List<Point> weeklyPoints = new ArrayList<>();
    private List<Point> monthlyPoints = new ArrayList<>();
    private long weeklyTotalSeconds;
    private long previousWeeklyTotalSeconds;

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

    public long getWeeklyTotalSeconds() {
        return weeklyTotalSeconds;
    }

    public void setWeeklyTotalSeconds(long weeklyTotalSeconds) {
        this.weeklyTotalSeconds = Math.max(0, weeklyTotalSeconds);
    }

    public long getPreviousWeeklyTotalSeconds() {
        return previousWeeklyTotalSeconds;
    }

    public void setPreviousWeeklyTotalSeconds(long previousWeeklyTotalSeconds) {
        this.previousWeeklyTotalSeconds = Math.max(0, previousWeeklyTotalSeconds);
    }

    public String getWeeklyTotalHoursLabel() {
        return formatHours(weeklyTotalSeconds);
    }

    public String getTrendPercentLabel() {
        if (previousWeeklyTotalSeconds <= 0) {
            return weeklyTotalSeconds > 0 ? "100%" : "0%";
        }
        long diff = weeklyTotalSeconds - previousWeeklyTotalSeconds;
        long percent = Math.round((diff * 100.0) / previousWeeklyTotalSeconds);
        return percent + "%";
    }

    public static String formatHours(long seconds) {
        if (seconds <= 0) {
            return "0";
        }
        double hours = seconds / 3600.0;
        if (hours >= 10 || Math.abs(hours - Math.round(hours)) < 0.05) {
            return String.valueOf(Math.round(hours));
        }
        return String.format(java.util.Locale.US, "%.1f", hours);
    }

    public static class Point {
        private final String label;
        private final String fullLabel;
        private final long seconds;

        public Point(String label, String fullLabel, long seconds) {
            this.label = label;
            this.fullLabel = fullLabel;
            this.seconds = Math.max(0, seconds);
        }

        public String getLabel() {
            return label;
        }

        public String getFullLabel() {
            return fullLabel;
        }

        public long getSeconds() {
            return seconds;
        }

        public double getHours() {
            return seconds / 3600.0;
        }

        public String getHoursLabel() {
            return formatHours(seconds) + " giờ";
        }
    }
}
