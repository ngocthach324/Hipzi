package com.hipzi.dao;

import com.hipzi.model.AdminFinancialStats;
import com.hipzi.model.SystemOverviewStats;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


public class AdminStatsDao {

    public SystemOverviewStats getSystemOverview() {
        SystemOverviewStats stats = new SystemOverviewStats();
        try (Connection conn = DBContext.getConnection()) {
            loadUserTotals(conn, stats);
            stats.setRoleCounts(loadRoleCounts(conn));
            stats.setUsersWithoutRole(loadUsersWithoutRole(conn));
            stats.setTotalMaterials(loadFirstAvailableCount(conn, 10,
                    "repository_materials", "materials", "learning_materials"));
            stats.setTotalCourses(loadFirstAvailableCount(conn, 0,
                    "courses"));
            stats.setTotalClassrooms(loadFirstAvailableCount(conn, 8,
                    "classrooms", "classes"));
            stats.setTotalRevenue(loadTotalRevenue(conn));
        } catch (SQLException e) {
            System.err.println("Error in AdminStatsDao.getSystemOverview: " + e.getMessage());
        }
        return stats;
    }

    private void loadUserTotals(Connection conn, SystemOverviewStats stats) throws SQLException {
        String sql = "SELECT COUNT(*) AS total_users, " +
                     "COUNT(*) FILTER (WHERE account_status = 'active') AS active_users, " +
                     "COUNT(*) FILTER (WHERE account_status <> 'active' OR account_status IS NULL) AS inactive_users, " +
                     "COUNT(*) FILTER (WHERE email_verified = true) AS verified_users " +
                     "FROM users WHERE deleted_at IS NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.setTotalUsers(rs.getInt("total_users"));
                stats.setActiveUsers(rs.getInt("active_users"));
                stats.setInactiveUsers(rs.getInt("inactive_users"));
                stats.setVerifiedUsers(rs.getInt("verified_users"));
            }
        }
    }

    private int loadFirstAvailableCount(Connection conn, int fallback, String... tableNames) {
        for (String tableName : tableNames) {
            String sql = "SELECT COUNT(*) AS total FROM " + tableName;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            } catch (SQLException ignored) {
                // Keep the dashboard usable while this module still uses in-code sample data.
            }
        }
        return fallback;
    }

    private Map<String, Integer> loadRoleCounts(Connection conn) throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("student", 0);
        counts.put("parent", 0);
        counts.put("teacher", 0);
        counts.put("staff", 0);
        counts.put("admin", 0);

        String sql = "SELECT LOWER(r.name) AS role_name, COUNT(DISTINCT u.id) AS total " +
                     "FROM roles r " +
                     "LEFT JOIN user_roles ur ON ur.role_id = r.id AND ur.is_active = true " +
                     "LEFT JOIN users u ON u.id = ur.user_id AND u.deleted_at IS NULL " +
                     "GROUP BY LOWER(r.name) " +
                     "ORDER BY LOWER(r.name)";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("role_name"), rs.getInt("total"));
            }
        }
        return counts;
    }

    private int loadUsersWithoutRole(Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) AS total " +
                     "FROM users u " +
                     "WHERE u.deleted_at IS NULL " +
                     "AND NOT EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id = u.id AND ur.is_active = true)";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt("total") : 0;
        }
    }

    private BigDecimal loadTotalRevenue(Connection conn) {
        String[] queries = {
            "SELECT COALESCE(SUM(amount), 0) AS total FROM payments WHERE LOWER(status) IN ('paid', 'success', 'completed')",
            "SELECT COALESCE(SUM(amount), 0) AS total FROM transactions WHERE LOWER(status) IN ('paid', 'success', 'completed')",
            "SELECT COALESCE(SUM(total_amount), 0) AS total FROM orders WHERE LOWER(status) IN ('paid', 'success', 'completed')",
            "SELECT COALESCE(SUM(price), 0) AS total FROM subscriptions WHERE LOWER(status) IN ('active', 'paid', 'success', 'completed')",
            "SELECT COALESCE(SUM(amount), 0) AS total FROM payments",
            "SELECT COALESCE(SUM(amount), 0) AS total FROM transactions"
        };

        for (String sql : queries) {
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total");
                    return total != null ? total : BigDecimal.ZERO;
                }
            } catch (SQLException ignored) {
                // Some projects do not have a revenue table yet; try the next known shape.
            }
        }
        return BigDecimal.ZERO;
    }

    public AdminFinancialStats getFinancialOverview() {
        AdminFinancialStats stats = new AdminFinancialStats();
        try (Connection conn = DBContext.getConnection()) {
            // 1. Total Course Revenue (course_orders where status='paid')
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(SUM(total_amount), 0) AS total FROM course_orders WHERE status = 'paid'")) {
                if (rs.next()) stats.setTotalCourseRevenue(rs.getBigDecimal("total"));
            } catch (SQLException ignored) {}

            // 2. Total Wallet Deposits
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(SUM(amount), 0) AS total FROM wallet_transactions WHERE transaction_type = 'deposit'")) {
                if (rs.next()) stats.setTotalWalletDeposits(rs.getBigDecimal("total"));
            } catch (SQLException ignored) {}

            // 3. Total Momo Withdrawals
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(SUM(amount), 0) AS total FROM momo_withdrawals WHERE status = 'completed'")) {
                if (rs.next()) stats.setTotalWithdrawals(rs.getBigDecimal("total"));
            } catch (SQLException ignored) {}

            // 4. Total Wallet Balance (system liability)
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COALESCE(SUM(wallet_balance), 0) AS total FROM users WHERE deleted_at IS NULL")) {
                if (rs.next()) stats.setTotalWalletBalance(rs.getBigDecimal("total"));
            } catch (SQLException ignored) {}

            // 5. Recent 10 Course Orders
            List<Map<String, Object>> recentTransactions = new ArrayList<>();
            String sql = "SELECT o.order_code, o.total_amount, o.status, o.created_at, u.full_name " +
                         "FROM course_orders o " +
                         "JOIN users u ON o.student_id = u.id " +
                         "ORDER BY o.created_at DESC LIMIT 10";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {
                while (rs.next()) {
                    Map<String, Object> tx = new HashMap<>();
                    tx.put("code", rs.getString("order_code"));
                    tx.put("amount", rs.getBigDecimal("total_amount"));
                    tx.put("status", rs.getString("status"));
                    tx.put("date", rs.getTimestamp("created_at"));
                    tx.put("user", rs.getString("full_name"));
                    recentTransactions.add(tx);
                }
            } catch (SQLException ignored) {}
            stats.setRecentTransactions(recentTransactions);

        } catch (SQLException e) {
            System.err.println("Error in AdminStatsDao.getFinancialOverview: " + e.getMessage());
        }
        return stats;
    }
}
