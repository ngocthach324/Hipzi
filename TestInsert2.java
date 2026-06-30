import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;
import java.sql.DriverManager;
import java.sql.SQLException;

public class TestInsert2 {
    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres", "postgres.aryzajaqbxbqpsjxjtmz", "boicoc25062006")) {
            String sql = "INSERT INTO courses "
                + "(course_code, teacher_id, title, short_description, subject_code, subject_name, grade_level, level_name, "
                + "price_type, price_amount, currency, thumbnail_url, thumbnail_gradient, badge_text, lessons_count, estimated_hours, "
                + "google_drive_url, google_drive_file_id, google_drive_folder_id, drive_owner_email, access_instructions, "
                + "status, visibility, submitted_at, learning_objectives, curriculum_outline) "
                + "VALUES (?, ?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_review', 'private', NOW(), ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "CRS-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
            ps.setString(2, "e59071cf-2676-4485-a978-c8959bd2311f"); 
            ps.setString(3, "Title");
            ps.setString(4, "Desc");
            ps.setString(5, "math");
            ps.setString(6, "Math");
            ps.setString(7, "grade");
            ps.setString(8, "level");
            ps.setString(9, "free");
            ps.setBigDecimal(10, BigDecimal.ZERO);
            ps.setString(11, "VND");
            ps.setString(12, "");
            ps.setString(13, "");
            ps.setString(14, "");
            ps.setInt(15, 0);
            ps.setBigDecimal(16, BigDecimal.ZERO);
            ps.setString(17, "http://drive");
            ps.setString(18, "");
            ps.setString(19, "");
            ps.setString(20, "email");
            ps.setString(21, "inst");
            ps.setString(22, "obj");
            ps.setString(23, "outline");
            System.out.println("Insert result: " + ps.executeUpdate());
        } catch(SQLException e) {
            e.printStackTrace();
        }
    }
}
