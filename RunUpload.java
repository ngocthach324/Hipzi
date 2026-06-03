import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class RunUpload {
    public static void main(String[] args) {
        try (Connection conn = DBContext.getConnection()) {
            System.out.println("Cleaning up fake SYSTEM records in DB...");
            String deleteSql = "DELETE FROM repository_materials WHERE uploaded_by = 'SYSTEM'";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                int count = ps.executeUpdate();
                System.out.println("Deleted " + count + " records.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
