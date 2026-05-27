package com.hipzi.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // UPDATE THESE VALUES WITH YOUR SUPABASE CREDENTIALS
    // Example JDBC URL from Supabase: 
    // jdbc:postgresql://db.xxxxxxxxx.supabase.co:5432/postgres
    private static final String DB_URL = "jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres";
    private static final String DB_USER = "postgres.aryzajaqbxbqpsjxjtmz";
    private static final String DB_PASSWORD = "boicoc25062006"; 
    
    // Using PostgreSQL driver
    private static final String DRIVER_CLASS = "org.postgresql.Driver";

    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            System.err.println("Error loading PostgreSQL Driver: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Get a connection to the Supabase PostgreSQL database.
     *
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
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
