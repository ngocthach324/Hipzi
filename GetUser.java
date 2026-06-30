import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class GetUser {
    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres", "postgres.aryzajaqbxbqpsjxjtmz", "boicoc25062006");
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT id FROM users LIMIT 1")) {
            if (rs.next()) {
                System.out.println("User ID: " + rs.getString("id"));
            }
        }
    }
}
