package com.hipzi.controller;

import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Material;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.SupabaseStorageService;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.List;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "MaterialRepositoryServlet", urlPatterns = {"/material-repository"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 50L * 1024 * 1024,
        maxRequestSize = 55L * 1024 * 1024
)
public class MaterialRepositoryServlet extends HttpServlet {

    private final com.hipzi.service.MaterialService materialService = new com.hipzi.service.MaterialService();
    private final RepositoryMaterialDao repositoryMaterialDao = new RepositoryMaterialDao();
    private final SupabaseStorageService storageService = new SupabaseStorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long requestStartedAt = System.nanoTime();
        
        String subject = request.getParameter("subject");
        String grade = request.getParameter("grade");
        String type = request.getParameter("type");
        String searchQuery = request.getParameter("q");
        String sort = request.getParameter("sort");
        
        if (subject == null || subject.isEmpty()) {
            subject = "Tất cả";
        }
        if (grade == null || grade.isEmpty()) {
            grade = "Tất cả";
        }
        if (type == null || type.isEmpty()) {
            type = "Tất cả";
        }
        
        long dataStartedAt = System.nanoTime();
        List<Material> materials = materialService.getMaterials(subject, grade, type, searchQuery, sort);
        long dataMs = elapsedMs(dataStartedAt);
        response.addHeader("Server-Timing", "material-data;dur=" + dataMs);
        response.addHeader("X-Hipzi-Perf-Material", "data=" + dataMs + "ms; rows=" + materials.size());
        
        request.setAttribute("materials", materials);
        request.setAttribute("currentSubject", subject);
        request.setAttribute("currentGrade", grade);
        request.setAttribute("currentType", type);
        request.setAttribute("currentSort", sort == null || sort.isEmpty() ? "newest" : sort);

        // Nếu là AJAX request (từ bộ lọc sidebar), chỉ trả về fragment kết quả
        String ajaxParam = request.getParameter("ajax");
        if ("1".equals(ajaxParam)) {
            long forwardStartedAt = System.nanoTime();
            request.getRequestDispatcher("/WEB-INF/fragments/material-repository-results.jsp").forward(request, response);
            logPerf("MaterialRepositoryServlet.doGet ajax=1 rows=" + materials.size(), dataMs, elapsedMs(forwardStartedAt), elapsedMs(requestStartedAt));
            return;
        }

        long forwardStartedAt = System.nanoTime();
        request.getRequestDispatcher("/material-repository.jsp").forward(request, response);
        logPerf("MaterialRepositoryServlet.doGet ajax=0 rows=" + materials.size(), dataMs, elapsedMs(forwardStartedAt), elapsedMs(requestStartedAt));
    }

    private long elapsedMs(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000L;
    }

    private void logPerf(String label, long dataMs, long forwardMs, long totalMs) {
        System.err.println("[PERF] " + label + " data=" + dataMs + "ms forward=" + forwardMs + "ms total=" + totalMs + "ms");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = cleanParam(request.getParameter("action"));
        if (!"uploadRepositoryMaterial".equals(action)) {
            doGet(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if (!hasRole(user, "teacher") && !hasRole(user, "admin") && !hasRole(user, "staff")) {
            session.setAttribute("toastMsg", "Chỉ tài khoản giảng viên mới có thể đăng tải tài liệu vào kho.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=upload-material");
            return;
        }

        boolean saved = false;
        String storedRelativePath = null;
        try {
            Material material = buildMaterialFromRequest(request, user);
            storedRelativePath = material.getFilePath();
            saved = repositoryMaterialDao.create(material);
            if (!saved && storedRelativePath != null) {
                try {
                    storageService.deleteObject(storedRelativePath);
                } catch (Exception ignored) {
                }
            }
        } catch (Exception e) {
            System.err.println("Error uploading repository material: " + e.getMessage());
            if (storedRelativePath != null) {
                try {
                    storageService.deleteObject(storedRelativePath);
                } catch (Exception ignored) {
                }
            }
        }

        session.setAttribute("toastMsg", saved
                ? "Đã đăng tải tài liệu vào kho tài liệu HIPZI."
                : "Chưa đăng tải được tài liệu. Vui lòng kiểm tra file và thông tin nhập.");
        session.setAttribute("toastType", saved ? "success" : "error");
        response.sendRedirect(request.getContextPath() + "/teacher-profile?tab=upload-material");
    }

    private Material buildMaterialFromRequest(HttpServletRequest request, User user)
            throws IOException, ServletException, InterruptedException {
        String title = cleanParam(request.getParameter("materialTitle"));
        String description = cleanParam(request.getParameter("materialDescription"));
        String subject = cleanParam(request.getParameter("materialSubject"));
        String grade = cleanParam(request.getParameter("materialGrade"));
        String type = cleanParam(request.getParameter("materialType"));
        Part filePart = request.getPart("materialFile");

        if (title.isEmpty() || subject.isEmpty() || grade.isEmpty() || type.isEmpty()
                || filePart == null || filePart.getSize() <= 0 || filePart.getSubmittedFileName() == null) {
            throw new IllegalArgumentException("Missing required material upload fields.");
        }

        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (!isAllowedFile(originalFileName, filePart.getContentType()) || filePart.getSize() > 50L * 1024 * 1024) {
            throw new IllegalArgumentException("Unsupported material file.");
        }

        String storedRelativePath = buildStorageObjectPath(user.getId(), originalFileName);
        byte[] fileBytes;
        try (java.io.InputStream input = filePart.getInputStream()) {
            fileBytes = input.readAllBytes();
        }
        storageService.uploadObject(storedRelativePath, fileBytes, filePart.getContentType());

        Material material = new Material();
        material.setTitle(title);
        material.setDescription(description);
        material.setSubject(subject);
        material.setGrade(grade);
        material.setType(type);
        material.setFilePath(storedRelativePath);
        material.setOriginalFileName(originalFileName);
        material.setFileType(filePart.getContentType());
        material.setFileSize(filePart.getSize());
        material.setUploadedBy(user.getId());
        material.setStatus("APPROVED");
        material.setVisibility("VISIBLE");
        return material;
    }

    private String buildStorageObjectPath(String userId, String originalFileName) {
        String safeName = originalFileName == null ? "material" : originalFileName
                .replaceAll("[\\\\/:*?\"<>|]+", "_")
                .replaceAll("\\s+", "_");
        return "repository-materials/" + userId + "/" + System.currentTimeMillis() + "-"
                + UUID.randomUUID() + "-" + safeName;
    }

    private boolean isAllowedFile(String fileName, String contentType) {
        String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        String lowerType = contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);
        return lowerName.endsWith(".pdf")
                || lowerName.endsWith(".doc")
                || lowerName.endsWith(".docx")
                || lowerName.endsWith(".ppt")
                || lowerName.endsWith(".pptx")
                || lowerName.endsWith(".xls")
                || lowerName.endsWith(".xlsx")
                || lowerName.endsWith(".png")
                || lowerName.endsWith(".jpg")
                || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".webp")
                || lowerType.equals("application/pdf")
                || lowerType.contains("word")
                || lowerType.contains("presentation")
                || lowerType.contains("spreadsheet")
                || lowerType.startsWith("image/");
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) return false;
        for (Role role : user.getRoles()) {
            if (role != null && roleName.equalsIgnoreCase(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
