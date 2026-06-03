import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckDB {
    public static void main(String[] args) {
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery("SELECT count(*) FROM classroom_materials");
            rs.next();
            System.out.println("classroom_materials count: " + rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT count(*) FROM classroom_homework_submissions");
            rs.next();
            System.out.println("classroom_homework_submissions count: " + rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT count(*) FROM repository_materials");
            rs.next();
            System.out.println("repository_materials count: " + rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT file_path FROM classroom_materials");
            while (rs.next()) {
                System.out.println("classroom_materials file: " + rs.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
