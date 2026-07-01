package com.hipzi.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Đóng Tomcat JDBC connection pool sạch khi webapp undeploy / hot-reload.
 * Nếu không đóng đúng cách, pool cũ để lại Timer thread đã cancel,
 * dẫn đến IllegalStateException: Timer already cancelled ở lần tiếp theo.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Set default timezone for the whole application to Vietnam time
        java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));

        // Khởi động pool sẵn khi app start để phát hiện lỗi kết nối sớm
        try {
            java.sql.Connection conn = DBContext.getConnection();
            conn.close();
            System.out.println("[AppContextListener] DB pool sẵn sàng.");
        } catch (Exception e) {
            System.err.println("[AppContextListener] Cảnh báo: Không kết nối được DB lúc khởi động: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Đóng pool sạch khi undeploy / hot-reload để tránh Timer leak
        DBContext.closePool();
        System.out.println("[AppContextListener] DB pool đã đóng sạch.");
    }
}
