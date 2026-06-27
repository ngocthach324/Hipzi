package com.hipzi.model;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class TeacherWalletStats {
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private List<Point> weeklyRevenue = new ArrayList<>();
    private List<Point> monthlyRevenue = new ArrayList<>();

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue == null ? BigDecimal.ZERO : totalRevenue;
    }

    public List<Point> getWeeklyRevenue() { return weeklyRevenue; }
    public void setWeeklyRevenue(List<Point> weeklyRevenue) {
        this.weeklyRevenue = weeklyRevenue == null ? new ArrayList<>() : weeklyRevenue;
    }

    public List<Point> getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(List<Point> monthlyRevenue) {
        this.monthlyRevenue = monthlyRevenue == null ? new ArrayList<>() : monthlyRevenue;
    }

    public String getTotalRevenueLabel() {
        return formatMoney(totalRevenue);
    }

    public static String formatMoney(BigDecimal amount) {
        NumberFormat format = NumberFormat.getInstance(new Locale("vi", "VN"));
        return format.format(amount == null ? BigDecimal.ZERO : amount) + " VND";
    }

    public static class Point {
        private String label;
        private BigDecimal amount;

        public Point(String label, BigDecimal amount) {
            this.label = label;
            this.amount = amount == null ? BigDecimal.ZERO : amount;
        }

        public String getLabel() { return label; }
        public BigDecimal getAmount() { return amount; }
        public long getAmountLong() { return amount == null ? 0L : amount.longValue(); }
    }
}
