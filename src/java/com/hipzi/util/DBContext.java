package com.hipzi.util;

import java.sql.Connection;
import java.sql.SQLException;
import org.apache.tomcat.jdbc.pool.DataSource;

public class DBContext {

    // UPDATE THESE VALUES WITH YOUR SUPABASE CREDENTIALS
    // Example JDBC URL from Supabase: 
    // jdbc:postgresql://db.xxxxxxxxx.supabase.co:5432/postgres
    private static final String DB_URL = "jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
    private static final String DB_USER = "postgres.aryzajaqbxbqpsjxjtmz";
    private static final String DB_PASSWORD = "boicoc25062006"; 
    
    // Using PostgreSQL driver
    private static final String DRIVER_CLASS = "org.postgresql.Driver";
    private static DataSource DATA_SOURCE = createDataSource();

    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            System.err.println("Error loading PostgreSQL Driver: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static DataSource createDataSource() {
        DataSource ds = new DataSource();
        ds.setDriverClassName(DRIVER_CLASS);
        ds.setUrl(DB_URL);
        ds.setUsername(DB_USER);
        ds.setPassword(DB_PASSWORD);
        ds.setInitialSize(1);
        ds.setMinIdle(1);
        ds.setMaxIdle(4);
        ds.setMaxActive(10);
        ds.setMaxWait(8000);
        ds.setTestOnBorrow(true);
        ds.setValidationQuery("SELECT 1");
        ds.setValidationInterval(30000);
        ds.setRemoveAbandoned(true);
        ds.setRemoveAbandonedTimeout(60);
        return ds;
    }

    /**
     * Get a connection to the Supabase PostgreSQL database.
     *
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        long startedAt = System.nanoTime();
        try {
            Connection conn = DATA_SOURCE.getConnection();
            logPerf("DBContext.getConnection", startedAt);
            return conn;
        } catch (SQLException e) {
            logPerf("DBContext.getConnection FAILED", startedAt);
            throw e;
        } catch (IllegalStateException e) {
            // Fix for Tomcat JDBC hot-reload issue where internal timer is cancelled
            System.err.println("DB Pool corrupted: " + e.getMessage() + ". Re-initializing pool...");
            if (DATA_SOURCE != null) {
                try { DATA_SOURCE.close(); } catch (Exception ignored) {}
            }
            DATA_SOURCE = createDataSource();
            Connection conn = DATA_SOURCE.getConnection();
            logPerf("DBContext.getConnection (RECOVERED)", startedAt);
            return conn;
        }
    }

    private static void logPerf(String label, long startedAt) {
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;
        System.err.println("[PERF] " + label + " " + elapsedMs + "ms");
    }

    public static void main(String[] args) {
        // Quick test method
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("Successfully connected to Supabase PostgreSQL!");
            }
        } catch (SQLException e) {
            System.err.println("Failed to connect to the database.");
            e.printStackTrace();
        }
    }
}
