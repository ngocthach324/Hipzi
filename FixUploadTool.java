import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.service.SupabaseStorageService;
import com.hipzi.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FixUploadTool {
    public static void main(String[] args) {
        System.out.println("Starting cleanup of old 'SYSTEM' materials...");
        SupabaseStorageService storage = new SupabaseStorageService();
        
        List<String> idsToDelete = new ArrayList<>();
        List<String> filePathsToDelete = new ArrayList<>();
        
        try (Connection conn = DBContext.getConnection()) {
            // Find all materials uploaded by SYSTEM and in the 'materials/' folder
            String findSql = "SELECT id, file_path FROM repository_materials WHERE uploaded_by = 'SYSTEM' AND file_path LIKE 'materials/%'";
            try (PreparedStatement ps = conn.prepareStatement(findSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    idsToDelete.add(rs.getString("id"));
                    filePathsToDelete.add(rs.getString("file_path"));
                }
            }
            
            System.out.println("Found " + idsToDelete.size() + " records to delete.");
            
            for (int i = 0; i < idsToDelete.size(); i++) {
                String id = idsToDelete.get(i);
                String filePath = filePathsToDelete.get(i);
                
                System.out.println("Deleting from storage: " + filePath);
                try {
                    storage.deleteObject(filePath);
                } catch (Exception e) {
                    System.err.println("Failed to delete storage file " + filePath + ": " + e.getMessage());
                }
                
                System.out.println("Deleting from DB: " + id);
                String deleteSql = "DELETE FROM repository_materials WHERE id = ?::uuid";
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }
            }
            
            System.out.println("Cleanup completed successfully.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
