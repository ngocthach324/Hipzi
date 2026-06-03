import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Material;
import com.hipzi.service.B2StorageService;
import java.io.File;
import java.nio.file.Files;
import java.util.UUID;

public class UploadTool {
    public static void main(String[] args) {
        try {
            File dir = new File("e:/PRJ/HipZi/Data/Toán-THPT");
            if (!dir.exists() || !dir.isDirectory()) {
                System.out.println("Directory not found!");
                return;
            }

            B2StorageService storage = new B2StorageService();
            RepositoryMaterialDao dao = new RepositoryMaterialDao();

            File[] files = dir.listFiles();
            if (files == null) return;

            for (File file : files) {
                if (!file.isFile()) continue;

                System.out.println("Processing: " + file.getName());

                // Read bytes
                byte[] bytes = Files.readAllBytes(file.toPath());

                // Generate a unique path for Supabase
                String uniqueFilename = UUID.randomUUID().toString() + "-" + file.getName().replaceAll("[^a-zA-Z0-9.-]", "_");
                String objectPath = "repository-materials/SYSTEM/" + uniqueFilename;

                // Determine content type (approximate)
                String contentType = "application/pdf";
                if (file.getName().endsWith(".docx")) contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                else if (file.getName().endsWith(".doc")) contentType = "application/msword";

                // Upload
                storage.uploadObject(objectPath, bytes, contentType);
                System.out.println("Uploaded to Supabase: " + objectPath);

                // Create DB Record
                Material m = new Material();
                m.setTitle(file.getName().replace(".pdf", "").replace("-", " "));
                m.setDescription("Tài liệu ôn thi THPT môn Toán (" + file.getName() + ")");
                m.setSubject("Toán");
                m.setGrade("Ôn thi THPT");
                m.setType("Đề ôn tập");
                m.setFilePath(objectPath);
                m.setOriginalFileName(file.getName());
                m.setFileType("pdf");
                if (file.getName().endsWith(".docx")) m.setFileType("docx");
                m.setFileSize(file.length());
                m.setUploadedBy("SYSTEM");
                m.setStatus("APPROVED");
                m.setVisibility("VISIBLE");

                boolean success = dao.create(m);
                System.out.println("DB Insert: " + success);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
