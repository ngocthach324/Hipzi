import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class GetTriggers {
    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres", "postgres.aryzajaqbxbqpsjxjtmz", "boicoc25062006");
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT tgname FROM pg_trigger WHERE tgrelid = 'courses'::regclass")) {
            while (rs.next()) {
                System.out.println("Trigger: " + rs.getString("tgname"));
            }
        }
    }
}
