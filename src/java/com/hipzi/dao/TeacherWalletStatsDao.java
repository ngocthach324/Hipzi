package com.hipzi.dao;

import com.hipzi.model.TeacherWalletStats;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class TeacherWalletStatsDao {

    public TeacherWalletStats getStats(String teacherId) {
        TeacherWalletStats stats = new TeacherWalletStats();
        if (teacherId == null || teacherId.trim().isEmpty()) {
            stats.setWeeklyRevenue(defaultWeeklyRevenue());
            stats.setMonthlyRevenue(defaultMonthlyRevenue());
            return stats;
        }

        stats.setTotalRevenue(loadTotalRevenue(teacherId));
        stats.setWeeklyRevenue(loadWeeklyRevenue(teacherId));
        stats.setMonthlyRevenue(loadMonthlyRevenue(teacherId));
        return stats;
    }

    private BigDecimal loadTotalRevenue(String teacherId) {
        String sql = "SELECT COALESCE(SUM(coi.price_amount), 0) AS total_revenue "
                + "FROM course_order_items coi "
                + "JOIN course_orders co ON co.id = coi.order_id "
                + "WHERE coi.teacher_id = ?::uuid AND co.status = 'paid'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? valueOrZero(rs.getBigDecimal("total_revenue")) : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherWalletStatsDao.loadTotalRevenue: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    private java.util.List<TeacherWalletStats.Point> loadWeeklyRevenue(String teacherId) {
        Map<LocalDate, BigDecimal> values = new LinkedHashMap<>();
        LocalDate start = LocalDate.now().minusDays(6);
        for (int i = 0; i < 7; i++) {
            values.put(start.plusDays(i), BigDecimal.ZERO);
        }

        String sql = "SELECT COALESCE(co.paid_at::date, co.created_at::date) AS revenue_day, "
                + "COALESCE(SUM(coi.price_amount), 0) AS revenue "
                + "FROM course_order_items coi "
                + "JOIN course_orders co ON co.id = coi.order_id "
                + "WHERE coi.teacher_id = ?::uuid "
                + "AND co.status = 'paid' "
                + "AND COALESCE(co.paid_at::date, co.created_at::date) >= current_date - interval '6 days' "
                + "GROUP BY revenue_day ORDER BY revenue_day";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate day = rs.getDate("revenue_day").toLocalDate();
                    if (values.containsKey(day)) {
                        values.put(day, valueOrZero(rs.getBigDecimal("revenue")));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherWalletStatsDao.loadWeeklyRevenue: " + e.getMessage());
        }

        java.util.List<TeacherWalletStats.Point> points = new java.util.ArrayList<>();
        for (Map.Entry<LocalDate, BigDecimal> entry : values.entrySet()) {
            points.add(new TeacherWalletStats.Point(dayLabel(entry.getKey()), entry.getValue()));
        }
        return points;
    }

    private java.util.List<TeacherWalletStats.Point> loadMonthlyRevenue(String teacherId) {
        Map<YearMonth, BigDecimal> values = new LinkedHashMap<>();
        YearMonth start = YearMonth.now().minusMonths(5);
        for (int i = 0; i < 6; i++) {
            values.put(start.plusMonths(i), BigDecimal.ZERO);
        }

        String sql = "SELECT date_trunc('month', COALESCE(co.paid_at, co.created_at))::date AS revenue_month, "
                + "COALESCE(SUM(coi.price_amount), 0) AS revenue "
                + "FROM course_order_items coi "
                + "JOIN course_orders co ON co.id = coi.order_id "
                + "WHERE coi.teacher_id = ?::uuid "
                + "AND co.status = 'paid' "
                + "AND COALESCE(co.paid_at, co.created_at) >= date_trunc('month', now()) - interval '5 months' "
                + "GROUP BY revenue_month ORDER BY revenue_month";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YearMonth month = YearMonth.from(rs.getDate("revenue_month").toLocalDate());
                    if (values.containsKey(month)) {
                        values.put(month, valueOrZero(rs.getBigDecimal("revenue")));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherWalletStatsDao.loadMonthlyRevenue: " + e.getMessage());
        }

        java.util.List<TeacherWalletStats.Point> points = new java.util.ArrayList<>();
        for (Map.Entry<YearMonth, BigDecimal> entry : values.entrySet()) {
            points.add(new TeacherWalletStats.Point("Tháng " + entry.getKey().getMonthValue(), entry.getValue()));
        }
        return points;
    }

    private java.util.List<TeacherWalletStats.Point> defaultWeeklyRevenue() {
        java.util.List<TeacherWalletStats.Point> points = new java.util.ArrayList<>();
        LocalDate start = LocalDate.now().minusDays(6);
        for (int i = 0; i < 7; i++) {
            points.add(new TeacherWalletStats.Point(dayLabel(start.plusDays(i)), BigDecimal.ZERO));
        }
        return points;
    }

    private java.util.List<TeacherWalletStats.Point> defaultMonthlyRevenue() {
        java.util.List<TeacherWalletStats.Point> points = new java.util.ArrayList<>();
        YearMonth start = YearMonth.now().minusMonths(5);
        for (int i = 0; i < 6; i++) {
            YearMonth month = start.plusMonths(i);
            points.add(new TeacherWalletStats.Point("Tháng " + month.getMonthValue(), BigDecimal.ZERO));
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
        return prefix + " " + day.format(DateTimeFormatter.ofPattern("dd/MM", Locale.forLanguageTag("vi-VN")));
    }

    private BigDecimal valueOrZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
