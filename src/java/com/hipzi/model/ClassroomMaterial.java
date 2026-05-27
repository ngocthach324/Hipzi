package com.hipzi.model;

import java.sql.Timestamp;

public class ClassroomMaterial {
    private String id;
    private String classroomId;
    private String title;
    private String description;
    private String materialUrl;
    private String filePath;
    private String originalFileName;
    private String fileType;
    private long fileSize;
    private String category;
    private String uploadedBy;
    private String uploadedByName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getClassroomId() { return classroomId; }
    public void setClassroomId(String classroomId) { this.classroomId = classroomId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getMaterialUrl() { return materialUrl; }
    public void setMaterialUrl(String materialUrl) { this.materialUrl = materialUrl; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getOriginalFileName() { return originalFileName; }
    public void setOriginalFileName(String originalFileName) { this.originalFileName = originalFileName; }

    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(String uploadedBy) { this.uploadedBy = uploadedBy; }

    public String getUploadedByName() { return uploadedByName; }
    public void setUploadedByName(String uploadedByName) { this.uploadedByName = uploadedByName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCategoryLabel() {
        if ("homework".equals(category)) return "Bài tập về nhà";
        if ("exam".equals(category)) return "Đề thi riêng";
        if ("theory".equals(category)) return "Lý thuyết";
        if ("teaching".equals(category)) return "Tài liệu giảng dạy";
        return "Tài liệu lớp học";
    }

    public String getFormattedFileSize() {
        if (fileSize <= 0) return "Không rõ dung lượng";
        double size = fileSize;
        String[] units = {"B", "KB", "MB", "GB"};
        int unitIndex = 0;
        while (size >= 1024 && unitIndex < units.length - 1) {
            size /= 1024;
            unitIndex++;
        }
        return String.format(unitIndex == 0 ? "%.0f %s" : "%.1f %s", size, units[unitIndex]);
    }
}
