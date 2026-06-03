package com.hipzi.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DBContext {

    private static final String DB_URL      = "jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
    private static final String DB_USER     = "postgres.aryzajaqbxbqpsjxjtmz";
    private static final String DB_PASSWORD = "boicoc25062006";
    private static final String DRIVER_CLASS = "org.postgresql.Driver";

    private static HikariDataSource dataSource;

    static {
        try {
            Class.forName(DRIVER_CLASS);
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(DB_URL);
            config.setUsername(DB_USER);
            config.setPassword(DB_PASSWORD);
            config.setDriverClassName(DRIVER_CLASS);
            config.setAutoCommit(true);
            config.setConnectionTimeout(10000);
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setIdleTimeout(300000);
            
            dataSource = new HikariDataSource(config);
            System.out.println("[DBContext] HikariCP initialized successfully.");
        } catch (Exception e) {
            System.err.println("[DBContext] Failed to initialize HikariCP: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("HikariDataSource is not initialized");
        }
        return dataSource.getConnection();
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DBContext] HikariCP pool closed.");
        }
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("Kết nối Supabase PostgreSQL thành công qua HikariCP!");
            }
        } catch (SQLException e) {
            System.err.println("Kết nối thất bại: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
