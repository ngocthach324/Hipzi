import java.sql.*;
public class QueryDB {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:postgresql://localhost:5432/hipzi";
        String user = "postgres";
        String password = "1";
        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT title, duration_minutes FROM mock_exams WHERE title LIKE '%12%'")) {
            while (rs.next()) {
                System.out.println("Title: " + rs.getString("title") + ", Duration: " + rs.getString("duration_minutes"));
            }
        }
    }
}