package com.hipzi.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Kết nối trực tiếp đến Supabase PostgreSQL qua DriverManager.
 *
 * Lý do KHÔNG dùng Tomcat JDBC pool:
 *   Tomcat JDBC pool dùng static Timer được load từ classloader của Tomcat,
 *   không phải webapp. Sau mỗi lần hot-reload, Timer bị cancel nhưng vẫn còn
 *   trong classloader dùng chung → lần tạo pool mới ném IllegalStateException.
 *
 * Supabase đã tích hợp PgBouncer (connection pooler) phía server nên không
 * cần thêm pool tầng ứng dụng khi kết nối qua URL pooler.
 */
public class DBContext {

    private static final String DB_URL      = "jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
    private static final String DB_USER     = "postgres.aryzajaqbxbqpsjxjtmz";
    private static final String DB_PASSWORD = "boicoc25062006";
    private static final String DRIVER_CLASS = "org.postgresql.Driver";

    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            System.err.println("[DBContext] Không tải được PostgreSQL Driver: " + e.getMessage());
        }
    }

    /**
     * Trả về Connection mới đến database.
     * Caller phải đóng connection sau khi dùng (try-with-resources).
     */
    public static Connection getConnection() throws SQLException {
        long startedAt = System.nanoTime();
        Properties props = new Properties();
        props.setProperty("user", DB_USER);
        props.setProperty("password", DB_PASSWORD);
        // Tắt autoCommit mặc định để tương thích với code hiện tại
        props.setProperty("defaultAutoCommit", "true");
        // Timeout kết nối 10 giây
        props.setProperty("loginTimeout", "10");
        try {
            Connection conn = DriverManager.getConnection(DB_URL, props);
            logPerf("DBContext.getConnection", startedAt);
            return conn;
        } catch (SQLException e) {
            logPerf("DBContext.getConnection FAILED", startedAt);
            throw e;
        }
    }

    /**
     * Không còn pool để đóng — giữ method này để AppContextListener biên dịch được.
     */
    public static void closePool() {
        System.out.println("[DBContext] Dùng DriverManager, không có pool để đóng.");
    }

    private static void logPerf(String label, long startedAt) {
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;
        if (elapsedMs > 500) {
            System.err.println("[PERF SLOW] " + label + " " + elapsedMs + "ms");
        }
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("Kết nối Supabase PostgreSQL thành công!");
            }
        } catch (SQLException e) {
            System.err.println("Kết nối thất bại: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
