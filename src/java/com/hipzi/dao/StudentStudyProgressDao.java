package com.hipzi.dao;

import com.hipzi.model.StudentStudyProgressStats;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class StudentStudyProgressDao {
    private static final int MAX_SECONDS_PER_PULSE = 120;

    public void recordStudySeconds(String studentId, int seconds) {
        if (studentId == null || studentId.trim().isEmpty() || seconds <= 0) {
            return;
        }
        int safeSeconds = Math.min(seconds, MAX_SECONDS_PER_PULSE);
        ensureSchema();
        String sql = "INSERT INTO student_study_daily_stats (student_id, study_date, seconds_spent, updated_at) "
                + "VALUES (?::uuid, current_date, ?, now()) "
                + "ON CONFLICT (student_id, study_date) DO UPDATE SET "
                + "seconds_spent = student_study_daily_stats.seconds_spent + EXCLUDED.seconds_spent, "
                + "updated_at = now()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, safeSeconds);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in StudentStudyProgressDao.recordStudySeconds: " + e.getMessage());
        }
    }

    public StudentStudyProgressStats getStats(String studentId) {
        StudentStudyProgressStats stats = new StudentStudyProgressStats();
        if (studentId == null || studentId.trim().isEmpty()) {
            stats.setWeeklyPoints(defaultWeeklyPoints());
            stats.setMonthlyPoints(defaultMonthlyPoints());
            return stats;
        }

        ensureSchema();
        List<StudentStudyProgressStats.Point> weeklyPoints = loadWeeklyPoints(studentId);
        stats.setWeeklyPoints(weeklyPoints);
        stats.setMonthlyPoints(loadMonthlyPoints(studentId));
        stats.setWeeklyTotalSeconds(weeklyPoints.stream().mapToLong(StudentStudyProgressStats.Point::getSeconds).sum());
        stats.setPreviousWeeklyTotalSeconds(loadPreviousWeekSeconds(studentId));
        return stats;
    }

    private List<StudentStudyProgressStats.Point> loadWeeklyPoints(String studentId) {
        Map<LocalDate, Long> values = new LinkedHashMap<>();
        LocalDate start = LocalDate.now().minusDays(6);
        for (int i = 0; i < 7; i++) {
            values.put(start.plusDays(i), 0L);
        }

        String sql = "SELECT study_date, seconds_spent "
                + "FROM student_study_daily_stats "
                + "WHERE student_id = ?::uuid AND study_date BETWEEN current_date - interval '6 days' AND current_date "
                + "ORDER BY study_date";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate day = rs.getDate("study_date").toLocalDate();
                    if (values.containsKey(day)) {
                        values.put(day, rs.getLong("seconds_spent"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in StudentStudyProgressDao.loadWeeklyPoints: " + e.getMessage());
        }
        return weeklyPointsFromMap(values);
    }

    private List<StudentStudyProgressStats.Point> loadMonthlyPoints(String studentId) {
        List<StudentStudyProgressStats.Point> points = new ArrayList<>();
        LocalDate start = LocalDate.now().minusDays(29);
        for (int i = 0; i < 7; i++) {
            LocalDate bucketStart = start.plusDays(i * 5L);
            if (bucketStart.isAfter(LocalDate.now())) {
                bucketStart = LocalDate.now();
            }
            LocalDate bucketEnd = i == 6 ? LocalDate.now() : bucketStart.plusDays(4);
            if (bucketEnd.isAfter(LocalDate.now())) {
                bucketEnd = LocalDate.now();
            }
            points.add(new StudentStudyProgressStats.Point(
                    dateLabel(bucketStart),
                    dateLabel(bucketStart) + (bucketEnd.equals(bucketStart) ? "" : " - " + dateLabel(bucketEnd)),
                    loadSecondsBetween(studentId, bucketStart, bucketEnd)
            ));
        }
        return points;
    }

    private long loadPreviousWeekSeconds(String studentId) {
        String sql = "SELECT COALESCE(SUM(seconds_spent), 0) AS total_seconds "
                + "FROM student_study_daily_stats "
                + "WHERE student_id = ?::uuid "
                + "AND study_date BETWEEN current_date - interval '13 days' AND current_date - interval '7 days'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong("total_seconds") : 0L;
            }
        } catch (SQLException e) {
            System.err.println("Error in StudentStudyProgressDao.loadPreviousWeekSeconds: " + e.getMessage());
        }
        return 0L;
    }

    private long loadSecondsBetween(String studentId, LocalDate start, LocalDate end) {
        String sql = "SELECT COALESCE(SUM(seconds_spent), 0) AS total_seconds "
                + "FROM student_study_daily_stats "
                + "WHERE student_id = ?::uuid AND study_date BETWEEN ? AND ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong("total_seconds") : 0L;
            }
        } catch (SQLException e) {
            System.err.println("Error in StudentStudyProgressDao.loadSecondsBetween: " + e.getMessage());
        }
        return 0L;
    }

    private List<StudentStudyProgressStats.Point> defaultWeeklyPoints() {
        Map<LocalDate, Long> values = new LinkedHashMap<>();
        LocalDate start = LocalDate.now().minusDays(6);
        for (int i = 0; i < 7; i++) {
            values.put(start.plusDays(i), 0L);
        }
        return weeklyPointsFromMap(values);
    }

    private List<StudentStudyProgressStats.Point> defaultMonthlyPoints() {
        List<StudentStudyProgressStats.Point> points = new ArrayList<>();
        LocalDate start = LocalDate.now().minusDays(29);
        for (int i = 0; i < 7; i++) {
            LocalDate day = start.plusDays(i * 5L);
            if (day.isAfter(LocalDate.now())) {
                day = LocalDate.now();
            }
            points.add(new StudentStudyProgressStats.Point(dateLabel(day), dateLabel(day), 0));
        }
        return points;
    }

    private List<StudentStudyProgressStats.Point> weeklyPointsFromMap(Map<LocalDate, Long> values) {
        List<StudentStudyProgressStats.Point> points = new ArrayList<>();
        for (Map.Entry<LocalDate, Long> entry : values.entrySet()) {
            points.add(new StudentStudyProgressStats.Point(dayLabel(entry.getKey()), dateLabel(entry.getKey()), entry.getValue()));
        }
        return points;
    }

    private String dayLabel(LocalDate day) {
        DayOfWeek dow = day.getDayOfWeek();
        String prefix;
        switch (dow) {
            case MONDAY: prefix = "T2"; break;
            case TUESDAY: prefix = "T3"; break;
            case WEDNESDAY: prefix = "T4"; break;
            case THURSDAY: prefix = "T5"; break;
            case FRIDAY: prefix = "T6"; break;
            case SATURDAY: prefix = "T7"; break;
            default: prefix = "CN"; break;
        }
        return prefix + " " + dateLabel(day);
    }

    private String dateLabel(LocalDate day) {
        return day.format(DateTimeFormatter.ofPattern("dd/MM", Locale.forLanguageTag("vi-VN")));
    }

    private void ensureSchema() {
        String sql = "CREATE TABLE IF NOT EXISTS student_study_daily_stats ("
                + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), "
                + "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                + "study_date DATE NOT NULL DEFAULT current_date, "
                + "seconds_spent INTEGER NOT NULL DEFAULT 0 CHECK (seconds_spent >= 0), "
                + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(), "
                + "updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), "
                + "UNIQUE(student_id, study_date)"
                + ")";
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute(sql);
            st.execute("CREATE INDEX IF NOT EXISTS idx_student_study_daily_student_date ON student_study_daily_stats(student_id, study_date DESC)");
        } catch (SQLException e) {
            System.err.println("Error in StudentStudyProgressDao.ensureSchema: " + e.getMessage());
        }
    }
}
