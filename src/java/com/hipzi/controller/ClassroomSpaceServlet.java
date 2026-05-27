package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomHomeworkSubmissionDao;
import com.hipzi.dao.ClassroomMaterialDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomHomeworkSubmission;
import com.hipzi.model.ClassroomMaterial;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.SupabaseStorageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@WebServlet(name = "ClassroomSpaceServlet", urlPatterns = {"/classroom"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 50L * 1024 * 1024,
        maxRequestSize = 60L * 1024 * 1024
)
public class ClassroomSpaceServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomMaterialDao materialDao = new ClassroomMaterialDao();
    private final ClassroomHomeworkSubmissionDao submissionDao = new ClassroomHomeworkSubmissionDao();
    private final SupabaseStorageService storageService = new SupabaseStorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classId = cleanParam(request.getParameter("id"));
        Classroom classroom = !classId.isEmpty() ? classroomDao.findById(classId) : null;
        if (classroom == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay lop hoc.");
            return;
        }

        boolean canReviewEnrollments = isTeacherOwner(user, classroom);
        boolean canManageClassroom = canReviewEnrollments || hasRole(user, "staff") || hasRole(user, "admin");
        ClassroomEnrollment currentEnrollment = enrollmentDao.findByClassroomAndStudent(classId, user.getId());
        boolean acceptedStudent = currentEnrollment != null && "accepted".equals(currentEnrollment.getStatus());

        if (!canManageClassroom && !acceptedStudent) {
            if (session != null) {
                session.setAttribute("toastMsg", "Bạn cần được giảng viên chấp nhận trước khi vào không gian lớp.");
                session.setAttribute("toastType", "error");
            }
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        List<ClassroomMaterial> allMaterials = materialDao.listByClassroom(classId);
        boolean canSubmitHomework = acceptedStudent && hasRole(user, "student") && !canManageClassroom;
        request.setAttribute("classroom", classroom);
        request.setAttribute("canManageClassroom", canManageClassroom);
        request.setAttribute("canReviewEnrollments", canReviewEnrollments);
        request.setAttribute("canSubmitHomework", canSubmitHomework);
        request.setAttribute("currentEnrollment", currentEnrollment);
        if (canReviewEnrollments) {
            request.setAttribute("pendingEnrollments", enrollmentDao.listByClassroomAndStatus(classId, "pending"));
        }
        request.setAttribute("acceptedEnrollments", enrollmentDao.listByClassroomAndStatus(classId, "accepted"));
        request.setAttribute("classMaterials", filterMaterials(allMaterials, false));
        request.setAttribute("classHomework", filterMaterials(allMaterials, true));
        request.setAttribute("homeworkSubmissions", canManageClassroom
                ? submissionDao.listByClassroom(classId)
                : submissionDao.listByClassroomAndStudent(classId, user.getId()));
        request.getRequestDispatcher("/classroom.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String classId = cleanParam(request.getParameter("classId"));
        Classroom classroom = !classId.isEmpty() ? classroomDao.findById(classId) : null;
        if (classroom == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay lop hoc.");
            return;
        }

        String action = cleanParam(request.getParameter("action"));
        boolean canReviewEnrollments = isTeacherOwner(user, classroom);
        boolean canManageClassroom = canReviewEnrollments || hasRole(user, "staff") || hasRole(user, "admin");
        ClassroomEnrollment currentEnrollment = enrollmentDao.findByClassroomAndStudent(classId, user.getId());
        boolean canSubmitHomework = currentEnrollment != null
                && "accepted".equals(currentEnrollment.getStatus())
                && hasRole(user, "student")
                && !canManageClassroom;

        if ("submitHomework".equals(action)) {
            if (!canSubmitHomework) {
                session.setAttribute("toastMsg", "Ban chua co quyen nop bai tap cho lop nay.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
                return;
            }
            boolean saved;
            try {
                saved = handleHomeworkSubmission(request, classroom, user);
            } catch (Exception e) {
                saved = false;
                System.err.println("Error uploading homework submission to Supabase Storage: " + e.getMessage());
            }
            session.setAttribute("toastMsg", saved ? "Da nop bai tap thanh cong." : "Chua nop duoc bai tap. Vui long kiem tra file va thong tin nhap.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        if (!canManageClassroom) {
            session.setAttribute("toastMsg", "Bạn không có quyền quản lý lớp học này.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        if ("reviewEnrollment".equals(action)) {
            if (!canReviewEnrollments) {
                session.setAttribute("toastMsg", "Chỉ giảng viên phụ trách lớp mới có thể duyệt học viên.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
                return;
            }
            String enrollmentId = cleanParam(request.getParameter("enrollmentId"));
            String decision = cleanParam(request.getParameter("decision"));
            boolean saved = !enrollmentId.isEmpty()
                    && enrollmentDao.updateStatus(classId, enrollmentId, decision, user.getId());
            session.setAttribute("toastMsg", saved
                    ? ("accepted".equals(decision) ? "Đã chấp nhận học viên vào lớp." : "Đã từ chối yêu cầu tham gia lớp.")
                    : "Chưa cập nhật được yêu cầu tham gia lớp.");
            session.setAttribute("toastType", saved ? "success" : "error");
        } else if ("uploadClassMaterial".equals(action)) {
            boolean saved;
            try {
                saved = handleMaterialUpload(request, classroom, user);
            } catch (Exception e) {
                saved = false;
                System.err.println("Error uploading classroom material to Supabase Storage: " + e.getMessage());
            }
            session.setAttribute("toastMsg", saved ? "Đã đăng tải tài liệu nội bộ lớp." : "Chưa đăng tải được tài liệu. Vui lòng kiểm tra file và thông tin nhập.");
            session.setAttribute("toastType", saved ? "success" : "error");
        } else if ("deleteClassMaterial".equals(action)) {
            String materialId = cleanParam(request.getParameter("materialId"));
            ClassroomMaterial material = !materialId.isEmpty() ? materialDao.findById(materialId) : null;
            boolean deleted = material != null
                    && classId.equals(material.getClassroomId())
                    && materialDao.deleteForClassroom(materialId, classId);
            if (deleted) {
                deleteStoredFileFromStorage(material);
            }
            session.setAttribute("toastMsg", deleted ? "Đã xóa tài liệu khỏi lớp." : "Không thể xóa tài liệu này.");
            session.setAttribute("toastType", deleted ? "success" : "error");
        }

        response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
    }

    private boolean handleMaterialUpload(HttpServletRequest request, Classroom classroom, User user)
            throws Exception {
        String title = cleanParam(request.getParameter("materialTitle"));
        String description = cleanParam(request.getParameter("materialDescription"));
        String category = normalizeMaterialCategory(request.getParameter("materialCategory"));
        Part filePart = request.getPart("materialFile");

        if (title.isEmpty() || filePart == null || filePart.getSize() <= 0 || filePart.getSubmittedFileName() == null) {
            return false;
        }

        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (!isAllowedFile(originalFileName, filePart.getContentType()) || filePart.getSize() > 50L * 1024 * 1024) {
            return false;
        }

        String storedRelativePath = buildStorageObjectPath(classroom.getId(), originalFileName);
        byte[] fileBytes;
        try (java.io.InputStream input = filePart.getInputStream()) {
            fileBytes = input.readAllBytes();
        }
        storageService.uploadObject(storedRelativePath, fileBytes, filePart.getContentType());
        ClassroomMaterial material = new ClassroomMaterial();
        material.setClassroomId(classroom.getId());
        material.setTitle(title);
        material.setDescription(description);
        material.setCategory(category);
        material.setFilePath(storedRelativePath);
        material.setOriginalFileName(originalFileName);
        material.setFileType(filePart.getContentType());
        material.setFileSize(filePart.getSize());
        material.setUploadedBy(user.getId());
        boolean created = materialDao.create(material);
        if (!created) {
            try {
                storageService.deleteObject(storedRelativePath);
            } catch (Exception ignored) {
            }
        }
        return created;
    }

    private boolean handleHomeworkSubmission(HttpServletRequest request, Classroom classroom, User user)
            throws Exception {
        String title = cleanParam(request.getParameter("submissionTitle"));
        String note = cleanParam(request.getParameter("submissionNote"));
        Part filePart = request.getPart("submissionFile");

        if (filePart == null || filePart.getSize() <= 0 || filePart.getSubmittedFileName() == null) {
            return false;
        }

        String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        if (title.isEmpty()) {
            title = originalFileName;
        }
        if (!isAllowedFile(originalFileName, filePart.getContentType()) || filePart.getSize() > 50L * 1024 * 1024) {
            return false;
        }

        String storedRelativePath = buildSubmissionStorageObjectPath(classroom.getId(), user.getId(), originalFileName);
        byte[] fileBytes;
        try (java.io.InputStream input = filePart.getInputStream()) {
            fileBytes = input.readAllBytes();
        }
        storageService.uploadObject(storedRelativePath, fileBytes, filePart.getContentType());

        ClassroomHomeworkSubmission submission = new ClassroomHomeworkSubmission();
        submission.setClassroomId(classroom.getId());
        submission.setStudentId(user.getId());
        submission.setTitle(title);
        submission.setNote(note);
        submission.setFilePath(storedRelativePath);
        submission.setOriginalFileName(originalFileName);
        submission.setFileType(filePart.getContentType());
        submission.setFileSize(filePart.getSize());
        boolean created = submissionDao.create(submission);
        if (!created) {
            try {
                storageService.deleteObject(storedRelativePath);
            } catch (Exception ignored) {
            }
        }
        return created;
    }

    private String buildStorageObjectPath(String classroomId, String originalFileName) {
        String safeOriginalName = originalFileName.replaceAll("[^A-Za-z0-9._-]", "_");
        String extension = "";
        int dotIndex = safeOriginalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = safeOriginalName.substring(dotIndex).toLowerCase(Locale.ROOT);
        }

        String storedName = UUID.randomUUID() + extension;
        return "classrooms/" + classroomId + "/" + storedName;
    }

    private String buildSubmissionStorageObjectPath(String classroomId, String studentId, String originalFileName) {
        String safeOriginalName = originalFileName.replaceAll("[^A-Za-z0-9._-]", "_");
        String extension = "";
        int dotIndex = safeOriginalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = safeOriginalName.substring(dotIndex).toLowerCase(Locale.ROOT);
        }
        String safeStudentId = studentId == null ? "student" : studentId.replaceAll("[^A-Za-z0-9._-]", "_");
        return "classrooms/" + classroomId + "/submissions/" + safeStudentId + "/" + UUID.randomUUID() + extension;
    }

    private void deleteStoredFileFromStorage(ClassroomMaterial material) {
        if (material == null || material.getFilePath() == null || material.getFilePath().trim().isEmpty()) {
            return;
        }
        try {
            storageService.deleteObject(material.getFilePath());
        } catch (Exception ignored) {
        }
    }

    private boolean isAllowedFile(String fileName, String contentType) {
        String lower = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        boolean allowedExtension = lower.endsWith(".pdf")
                || lower.endsWith(".doc")
                || lower.endsWith(".docx")
                || lower.endsWith(".ppt")
                || lower.endsWith(".pptx")
                || lower.endsWith(".xls")
                || lower.endsWith(".xlsx")
                || lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".webp");
        return allowedExtension && contentType != null && !contentType.trim().isEmpty();
    }

    private String normalizeMaterialCategory(String category) {
        String cleaned = cleanParam(category);
        if ("homework".equals(cleaned) || "exam".equals(cleaned)
                || "theory".equals(cleaned) || "teaching".equals(cleaned)) {
            return cleaned;
        }
        return "document";
    }

    private List<ClassroomMaterial> filterMaterials(List<ClassroomMaterial> materials, boolean homeworkOnly) {
        List<ClassroomMaterial> filtered = new ArrayList<>();
        if (materials == null) {
            return filtered;
        }
        for (ClassroomMaterial material : materials) {
            boolean isHomework = material != null && "homework".equals(material.getCategory());
            if (homeworkOnly == isHomework) {
                filtered.add(material);
            }
        }
        return filtered;
    }

    private boolean isTeacherOwner(User user, Classroom classroom) {
        return user != null
                && classroom != null
                && classroom.getTeacherId() != null
                && classroom.getTeacherId().equals(user.getId())
                && hasRole(user, "teacher");
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
