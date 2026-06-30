package com.hipzi.dao;

import com.hipzi.model.StaffUserGrowthStats;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class StaffUserGrowthStatsDao {

    public StaffUserGrowthStats getStats() {
        StaffUserGrowthStats stats = new StaffUserGrowthStats();
        List<StaffUserGrowthStats.Point> weeklyPoints = loadWeeklyPoints();
        stats.setWeeklyPoints(weeklyPoints);
        stats.setMonthlyPoints(loadMonthlyPoints());
        stats.setWeeklyTotal(weeklyPoints.stream().mapToInt(StaffUserGrowthStats.Point::getCount).sum());
        stats.setPreviousWeeklyTotal(loadPreviousWeekTotal());
        return stats;
    }

    private List<StaffUserGrowthStats.Point> loadWeeklyPoints() {
        Map<LocalDate, Integer> values = new LinkedHashMap<>();
        LocalDate start = LocalDate.now().minusDays(6);
        for (int i = 0; i < 7; i++) {
            values.put(start.plusDays(i), 0);
        }

        String sql = "SELECT created_at::date AS signup_day, COUNT(*) AS total "
                + "FROM users "
                + "WHERE deleted_at IS NULL AND created_at::date BETWEEN current_date - interval '6 days' AND current_date "
                + "GROUP BY signup_day ORDER BY signup_day";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LocalDate day = rs.getDate("signup_day").toLocalDate();
                if (values.containsKey(day)) {
                    values.put(day, rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in StaffUserGrowthStatsDao.loadWeeklyPoints: " + e.getMessage());
        }
        return weeklyPointsFromMap(values);
    }

    private List<StaffUserGrowthStats.Point> loadMonthlyPoints() {
        List<StaffUserGrowthStats.Point> points = new ArrayList<>();
        LocalDate start = LocalDate.now().minusDays(29);
        
        Map<LocalDate, Integer> dailyStats = new java.util.HashMap<>();
        String sql = "SELECT created_at::date AS signup_day, COUNT(*) AS total "
                   + "FROM users "
                   + "WHERE deleted_at IS NULL AND created_at::date >= ? "
                   + "GROUP BY signup_day";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(start));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dailyStats.put(rs.getDate("signup_day").toLocalDate(), rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in StaffUserGrowthStatsDao.loadMonthlyPoints: " + e.getMessage());
        }

        for (int i = 0; i < 7; i++) {
            LocalDate bucketStart = start.plusDays(i * 5L);
            if (bucketStart.isAfter(LocalDate.now())) {
                bucketStart = LocalDate.now();
            }
            LocalDate bucketEnd = i == 6 ? LocalDate.now() : bucketStart.plusDays(4);
            if (bucketEnd.isAfter(LocalDate.now())) {
                bucketEnd = LocalDate.now();
            }
            
            int totalCount = 0;
            LocalDate current = bucketStart;
            while (!current.isAfter(bucketEnd)) {
                totalCount += dailyStats.getOrDefault(current, 0);
                current = current.plusDays(1);
            }
            
            points.add(new StaffUserGrowthStats.Point(
                    dateLabel(bucketStart),
                    dateLabel(bucketStart) + (bucketEnd.equals(bucketStart) ? "" : " - " + dateLabel(bucketEnd)),
                    totalCount
            ));
        }
        return points;
    }

    private int loadPreviousWeekTotal() {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM users "
                + "WHERE deleted_at IS NULL "
                + "AND created_at::date BETWEEN current_date - interval '13 days' AND current_date - interval '7 days'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt("total") : 0;
        } catch (SQLException e) {
            System.err.println("Error in StaffUserGrowthStatsDao.loadPreviousWeekTotal: " + e.getMessage());
        }
        return 0;
    }

    private List<StaffUserGrowthStats.Point> weeklyPointsFromMap(Map<LocalDate, Integer> values) {
        List<StaffUserGrowthStats.Point> points = new ArrayList<>();
        for (Map.Entry<LocalDate, Integer> entry : values.entrySet()) {
            points.add(new StaffUserGrowthStats.Point(dayLabel(entry.getKey()), dateLabel(entry.getKey()), entry.getValue()));
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
}
