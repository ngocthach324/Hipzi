import com.hipzi.service.B2StorageService;
import com.hipzi.service.SupabaseStorageService;
import com.hipzi.util.DBContext;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MigrateSupabaseToB2Tool {
    static class FileMeta {
        String path;
        String type;
        public FileMeta(String path, String type) {
            this.path = path;
            this.type = type;
        }
    }

    public static void main(String[] args) {
        System.out.println("Starting Supabase to B2 Migration...");
        SupabaseStorageService supabase = new SupabaseStorageService();
        B2StorageService b2 = new B2StorageService();
        HttpClient client = HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NORMAL).build();

        List<FileMeta> files = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {
            // 1. Repository Materials
            try (PreparedStatement ps = conn.prepareStatement("SELECT file_path, file_type FROM repository_materials WHERE file_path IS NOT NULL")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    files.add(new FileMeta(rs.getString("file_path"), rs.getString("file_type")));
                }
            }

            // 2. Classroom Materials
            try (PreparedStatement ps = conn.prepareStatement("SELECT file_path, file_type FROM classroom_materials WHERE file_path IS NOT NULL")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    files.add(new FileMeta(rs.getString("file_path"), rs.getString("file_type")));
                }
            }

            // 3. Homework Submissions
            try (PreparedStatement ps = conn.prepareStatement("SELECT file_path, file_type FROM classroom_homework_submissions WHERE file_path IS NOT NULL")) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    files.add(new FileMeta(rs.getString("file_path"), rs.getString("file_type")));
                }
            } catch (Exception e) {
                System.out.println("Could not query classroom_homework_submissions: " + e.getMessage());
            }

            System.out.println("Found " + files.size() + " files in database to migrate.");

            int count = 0;
            for (FileMeta f : files) {
                if (f.path == null || f.path.isBlank()) continue;
                System.out.println("Migrating: " + f.path);
                try {
                    // Get download URL from Supabase
                    String downloadUrl = supabase.createSignedUrl(f.path, 300);
                    if (downloadUrl == null || downloadUrl.isBlank()) {
                        System.out.println("  [Error] Could not generate Supabase URL for " + f.path);
                        continue;
                    }

                    // Download file bytes
                    HttpRequest request = HttpRequest.newBuilder().uri(URI.create(downloadUrl)).GET().build();
                    HttpResponse<byte[]> response = client.send(request, HttpResponse.BodyHandlers.ofByteArray());
                    if (response.statusCode() != 200) {
                        System.out.println("  [Error] Failed to download from Supabase. HTTP " + response.statusCode());
                        continue;
                    }

                    // Upload to B2
                    b2.uploadObject(f.path, response.body(), f.type);
                    System.out.println("  [Success] Uploaded to B2.");
                    count++;
                } catch (Exception ex) {
                    System.out.println("  [Error] " + ex.getMessage());
                }
            }
            
            System.out.println("Migration complete! Migrated " + count + "/" + files.size() + " files.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
