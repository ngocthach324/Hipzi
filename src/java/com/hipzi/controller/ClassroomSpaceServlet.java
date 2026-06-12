package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomExamDao;
import com.hipzi.dao.ClassroomHomeworkSubmissionDao;
import com.hipzi.dao.ClassroomMaterialDao;
import com.hipzi.dao.ClassroomQuizDao;
import com.hipzi.dao.ClassroomRuleDao;
import com.hipzi.dto.ClassroomExamAttemptDto;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomRule;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomExam;
import com.hipzi.model.ClassroomExamQuestion;
import com.hipzi.model.ClassroomHomeworkSubmission;
import com.hipzi.model.ClassroomMaterial;
import com.hipzi.model.ClassroomQuiz;
import com.hipzi.model.ClassroomQuizAttempt;
import com.hipzi.model.ClassroomQuizQuestion;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.AiQuizParserService;
import com.hipzi.service.AiClassExamParserService;
import com.hipzi.service.B2StorageService;
import com.hipzi.service.DatalabOcrService;
import com.hipzi.service.DocxTextExtractionService;
import com.hipzi.service.OcrProvider;
import com.hipzi.service.OcrResult;
import com.hipzi.service.TesseractOcrService;
import com.hipzi.service.TesseractOcrProvider;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "ClassroomSpaceServlet", urlPatterns = {"/classroom"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 50L * 1024 * 1024,
        maxRequestSize = 60L * 1024 * 1024
)
public class ClassroomSpaceServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao enrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomExamDao examDao = new ClassroomExamDao();
    private final ClassroomMaterialDao materialDao = new ClassroomMaterialDao();
    private final ClassroomHomeworkSubmissionDao submissionDao = new ClassroomHomeworkSubmissionDao();
    private final ClassroomQuizDao quizDao = new ClassroomQuizDao();
    private final ClassroomRuleDao ruleDao = new ClassroomRuleDao();
    private final B2StorageService storageService = new B2StorageService();
    private final TesseractOcrService ocrService = new TesseractOcrService();
    private final DocxTextExtractionService docxTextExtractionService = new DocxTextExtractionService();
    private final OcrProvider sourceOcrProvider = createOcrProvider();
    private final AiQuizParserService aiQuizParserService = new AiQuizParserService();
    private final AiClassExamParserService aiClassExamParserService = new AiClassExamParserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
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
                session.setAttribute("toastMsg", "Báº¡n cáº§n Ä‘Æ°á»£c giáº£ng viÃªn cháº¥p nháº­n trÆ°á»›c khi vÃ o khÃ´ng gian lá»›p.");
                session.setAttribute("toastType", "error");
            }
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        List<ClassroomMaterial> allMaterials = materialDao.listByClassroom(classId);
        boolean canSubmitHomework = acceptedStudent && hasRole(user, "student") && !canManageClassroom;
        List<ClassroomQuiz> classroomQuizzes = quizDao.listByClassroom(classId, !canManageClassroom);
        Map<String, ClassroomQuizAttempt> latestQuizAttempts = acceptedStudent
                ? quizDao.latestAttemptsForStudent(classId, user.getId())
                : new LinkedHashMap<String, ClassroomQuizAttempt>();
        Map<String, ClassroomExamAttemptDto> classExamAttemptUsage = acceptedStudent
                ? examDao.listAttemptUsageForStudent(classId, user.getId())
                : new LinkedHashMap<String, ClassroomExamAttemptDto>();
        request.setAttribute("classroom", classroom);
        request.setAttribute("canManageClassroom", canManageClassroom);
        request.setAttribute("canReviewEnrollments", canReviewEnrollments);
        request.setAttribute("canSubmitHomework", canSubmitHomework);
        request.setAttribute("currentEnrollment", currentEnrollment);
        if (canReviewEnrollments) {
            request.setAttribute("pendingEnrollments", enrollmentDao.listByClassroomAndStatus(classId, "pending"));
        }
        request.setAttribute("acceptedEnrollments", enrollmentDao.listByClassroomAndStatus(classId, "accepted"));
        request.setAttribute("classMaterials", filterMaterialsByCategory(allMaterials, "document", "teaching", "theory"));
        request.setAttribute("classHomework", filterMaterialsByCategory(allMaterials, "homework"));
        request.setAttribute("classExamMaterials", filterMaterialsByCategory(allMaterials, "exam"));
        request.setAttribute("classroomExams", examDao.listByClassroom(classId, !canManageClassroom));
        request.setAttribute("classroomRules", ruleDao.findByClassroomId(classId));
        request.setAttribute("classroomQuizzes", classroomQuizzes);
        request.setAttribute("latestQuizAttempts", latestQuizAttempts);
        request.setAttribute("classExamAttemptUsage", classExamAttemptUsage);
        request.setAttribute("homeworkSubmissions", canManageClassroom
                ? submissionDao.listByClassroom(classId)
                : submissionDao.listByClassroomAndStudent(classId, user.getId()));
        request.getRequestDispatcher("/WEB-INF/views/classroom.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
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
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-materials");
            return;
        }

        if ("submitQuizAttempt".equals(action)) {
            boolean acceptedStudent = currentEnrollment != null && "accepted".equals(currentEnrollment.getStatus());
            if (!acceptedStudent || !hasRole(user, "student") || canManageClassroom) {
                session.setAttribute("toastMsg", "Ban chua co quyen lam bai luyen tap trong lop nay.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
                return;
            }
            String quizId = cleanParam(request.getParameter("quizId"));
            ClassroomQuiz quiz = !quizId.isEmpty() ? quizDao.findById(quizId) : null;
            if (quiz == null || !classId.equals(quiz.getClassroomId()) || !quiz.isPublished()) {
                session.setAttribute("toastMsg", "Bai luyen tap nay chua san sang cho hoc vien.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
                return;
            }
            boolean saved = quizDao.createAttempt(quiz, user.getId(), collectQuizAnswers(request, quiz));
            session.setAttribute("toastMsg", saved ? "Da nop bai luyen tap." : "Chua nop duoc bai luyen tap.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        }

        if (!canManageClassroom) {
            session.setAttribute("toastMsg", "Báº¡n khÃ´ng cÃ³ quyá»n quáº£n lÃ½ lá»›p há»c nÃ y.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
            return;
        }

        if ("reviewEnrollment".equals(action)) {
            if (!canReviewEnrollments) {
                session.setAttribute("toastMsg", "Chá»‰ giáº£ng viÃªn phá»¥ trÃ¡ch lá»›p má»›i cÃ³ thá»ƒ duyá»‡t há»c viÃªn.");
                session.setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId);
                return;
            }
            String enrollmentId = cleanParam(request.getParameter("enrollmentId"));
            String decision = cleanParam(request.getParameter("decision"));
            boolean saved = !enrollmentId.isEmpty()
                    && enrollmentDao.updateStatus(classId, enrollmentId, decision, user.getId());
            session.setAttribute("toastMsg", saved
                    ? ("accepted".equals(decision) ? "ÄÃ£ cháº¥p nháº­n há»c viÃªn vÃ o lá»›p." : "ÄÃ£ tá»« chá»‘i yÃªu cáº§u tham gia lá»›p.")
                    : "ChÆ°a cáº­p nháº­t Ä‘Æ°á»£c yÃªu cáº§u tham gia lá»›p.");
            session.setAttribute("toastType", saved ? "success" : "error");
        } else if ("uploadClassMaterial".equals(action)) {
            boolean saved;
            try {
                saved = handleMaterialUpload(request, classroom, user);
            } catch (Exception e) {
                saved = false;
                System.err.println("Error uploading classroom material to Supabase Storage: " + e.getMessage());
            }
            session.setAttribute("toastMsg", saved ? "ÄÃ£ Ä‘Äƒng táº£i tÃ i liá»‡u ná»™i bá»™ lá»›p." : "ChÆ°a Ä‘Äƒng táº£i Ä‘Æ°á»£c tÃ i liá»‡u. Vui lÃ²ng kiá»ƒm tra file vÃ  thÃ´ng tin nháº­p.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-materials");
            return;
        } else if ("deleteClassMaterial".equals(action)) {
            String materialId = cleanParam(request.getParameter("materialId"));
            ClassroomMaterial material = !materialId.isEmpty() ? materialDao.findById(materialId) : null;
            boolean deleted = material != null
                    && classId.equals(material.getClassroomId())
                    && materialDao.deleteForClassroom(materialId, classId);
            if (deleted) {
                deleteStoredFileFromStorage(material);
            }
            session.setAttribute("toastMsg", deleted ? "ÄÃ£ xÃ³a tÃ i liá»‡u khá»i lá»›p." : "KhÃ´ng thá»ƒ xÃ³a tÃ i liá»‡u nÃ y.");
            session.setAttribute("toastType", deleted ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-materials");
            return;
        } else if ("scanClassExamAi".equals(action)) {
            boolean scanned;
            String scanError = "";
            try {
                scanned = handleClassExamAiScan(request, session);
            } catch (Exception e) {
                scanned = false;
                scanError = compactErrorMessage(e);
                System.err.println("Error scanning classroom exam with AI: " + scanError);
                e.printStackTrace(System.err);
            }
            session.setAttribute("toastMsg", scanned
                    ? "Da phan tich de thi bang AI. Hay kiem tra va chinh sua cau hoi truoc khi luu."
                    : (!scanError.isEmpty()
                            ? "Chua phan tich duoc de thi: " + scanError
                            : "Chua phan tich duoc de thi. Kiem tra DATALAB_API_KEY, OPENAI_API_KEY, file de hoac text de."));
            session.setAttribute("toastType", scanned ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-exams");
            return;
        } else if ("createClassExam".equals(action)) {
            boolean saved = handleClassExamCreate(request, classroom, user);
            String examError = (String) session.getAttribute("classExamCreateError");
            session.removeAttribute("classExamCreateError");
            session.setAttribute("toastMsg", saved
                    ? "Da tao bai thi lop hoc."
                    : (examError != null ? examError : "Chua tao duoc bai thi. Vui long kiem tra thong tin, thoi gian mo dong va cau hoi."));
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-exams");
            return;
        } else if ("updateClassExam".equals(action)) {
            boolean updated = handleClassExamUpdate(request, classroom);
            String updateError = (String) session.getAttribute("classExamUpdateError");
            session.removeAttribute("classExamUpdateError");
            session.setAttribute("toastMsg", updated 
                    ? "Da cap nhat thong tin bai thi." 
                    : (updateError != null ? updateError : "Khong cap nhat duoc bai thi."));
            session.setAttribute("toastType", updated ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-exams");
            return;
        } else if ("deleteClassExam".equals(action)) {
            String examId = cleanParam(request.getParameter("examId"));
            boolean deleted = !examId.isEmpty() && examDao.deleteForClassroom(examId, classId);
            session.setAttribute("toastMsg", deleted ? "Da xoa bai thi lop hoc." : "Khong the xoa bai thi nay.");
            session.setAttribute("toastType", deleted ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-exams");
            return;
        } else if ("scanQuizImage".equals(action) || "scanQuizImageAi".equals(action)) {
            boolean scanned;
            String scanError = "";
            try {
                scanned = handleQuizImageScan(request, session, "scanQuizImageAi".equals(action));
            } catch (Exception e) {
                scanned = false;
                scanError = compactErrorMessage(e);
                System.err.println("Error scanning classroom quiz image: " + scanError);
                e.printStackTrace(System.err);
            }
            session.setAttribute("toastMsg", scanned
                    ? ("scanQuizImageAi".equals(action) ? "Da scan AI. Hay kiem tra lai cau hoi da nhan dien." : "Da scan anh de. Hay kiem tra lai noi dung scan.")
                    : (!scanError.isEmpty()
                            ? "Chua scan duoc: " + scanError
                            : ("scanQuizImageAi".equals(action) ? "Chua scan AI duoc. Kiem tra DATALAB_API_KEY, OPENAI_API_KEY hoac file de." : "Chua scan duoc anh de. Kiem tra DATALAB_API_KEY hoac chon file ro hon.")));
            session.setAttribute("toastType", scanned ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        } else if ("createQuizDraft".equals(action)) {
            boolean saved;
            try {
                saved = handleQuizDraftCreate(request, classroom, user);
            } catch (Exception e) {
                saved = false;
                System.err.println("Error creating classroom quiz draft: " + e.getMessage());
            }
            session.setAttribute("toastMsg", saved ? "Da tao ban nhap de luyen tap." : "Chua tao duoc ban nhap. Vui long nhap tieu de va noi dung scan.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        } else if ("updateQuizDraft".equals(action)) {
            boolean saved = handleQuizDraftUpdate(request, classroom);
            session.setAttribute("toastMsg", saved ? "Da luu de luyen tap." : "Chua luu duoc de. Moi de can co tieu de va it nhat mot cau hoi.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        } else if ("publishQuiz".equals(action) || "unpublishQuiz".equals(action)) {
            String quizId = cleanParam(request.getParameter("quizId"));
            String nextStatus = "publishQuiz".equals(action) ? "published" : "draft";
            boolean saved = !quizId.isEmpty() && quizDao.updateStatus(quizId, classId, nextStatus);
            session.setAttribute("toastMsg", saved
                    ? ("published".equals(nextStatus) ? "Da publish de cho lop." : "Da dua de ve ban nhap.")
                    : "Chua cap nhat duoc trang thai de.");
            session.setAttribute("toastType", saved ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        } else if ("deleteQuiz".equals(action)) {
            String quizId = cleanParam(request.getParameter("quizId"));
            boolean deleted = !quizId.isEmpty() && quizDao.deleteForClassroom(quizId, classId);
            session.setAttribute("toastMsg", deleted ? "Da xoa de luyen tap." : "Khong the xoa de nay.");
            session.setAttribute("toastType", deleted ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-quiz");
            return;
        } else if ("addClassroomRule".equals(action)) {
            ClassroomRule rule = new ClassroomRule();
            rule.setClassroomId(classId);
            rule.setTitle(cleanParam(request.getParameter("ruleTitle")));
            rule.setRuleText(cleanParam(request.getParameter("ruleText")));
            rule.setSortOrder(parsePositiveInt(request.getParameter("sortOrder"), 1));
            boolean created = ruleDao.create(rule);
            session.setAttribute("toastMsg", created ? "Ä Ã£ thÃªm ná»™i quy." : "KhÃ´ng thá»ƒ thÃªm ná»™i quy.");
            session.setAttribute("toastType", created ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-rules");
            return;
        } else if ("updateClassroomRule".equals(action)) {
            ClassroomRule rule = new ClassroomRule();
            rule.setId(cleanParam(request.getParameter("ruleId")));
            rule.setClassroomId(classId);
            rule.setTitle(cleanParam(request.getParameter("ruleTitle")));
            rule.setRuleText(cleanParam(request.getParameter("ruleText")));
            rule.setSortOrder(parsePositiveInt(request.getParameter("sortOrder"), 1));
            boolean updated = !rule.getId().isEmpty() && ruleDao.updateForClassroom(rule);
            session.setAttribute("toastMsg", updated ? "Ä Ã£ cáº­p nháº­t ná»™i quy." : "KhÃ´ng thá»ƒ cáº­p nháº­t ná»™i quy.");
            session.setAttribute("toastType", updated ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-rules");
            return;
        } else if ("deleteClassroomRule".equals(action)) {
            String ruleId = cleanParam(request.getParameter("ruleId"));
            boolean deleted = !ruleId.isEmpty() && ruleDao.deleteForClassroom(ruleId, classId);
            session.setAttribute("toastMsg", deleted ? "Ä Ã£ xÃ³a ná»™i quy." : "KhÃ´ng thá»ƒ xÃ³a ná»™i quy.");
            session.setAttribute("toastType", deleted ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/classroom?id=" + classId + "#tab-rules");
            return;
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

    private boolean handleClassExamCreate(HttpServletRequest request, Classroom classroom, User user) {
        request.getSession().removeAttribute("classExamCreateError");
        String title = cleanParam(request.getParameter("examTitle"));
        String code = normalizeExamCode(request.getParameter("examCode"));
        String description = cleanParam(request.getParameter("examDescription"));
        String examType = normalizeClassExamType(request.getParameter("examType"));
        String creationMode = normalizeClassExamCreationMode(request.getParameter("examCreationMode"));
        String rawSourceText = cleanParam(request.getParameter("examSourceText"));
        String sourceMaterialId = cleanParam(request.getParameter("sourceMaterialId"));
        int duration = parsePositiveInt(request.getParameter("durationMinutes"), 45);
        int attemptLimit = parsePositiveInt(request.getParameter("attemptLimit"), 1);
        Double maxScore = parsePositiveDouble(request.getParameter("examMaxScore"), 10.0);
        String startAtValue = buildExamDateTimeValue(request, "examStart");
        String endAtValue = buildExamDateTimeValue(request, "examEnd");
        Timestamp startAt = parseDateTimeLocal(startAtValue);
        Timestamp endAt = parseDateTimeLocal(endAtValue);
        List<ClassroomExamQuestion> questions = collectClassExamQuestions(request, examType);
        if (title.isEmpty() || code.isEmpty()) {
            return rejectClassExam(request, "Vui long nhap tieu de va ma de.");
        }
        if ("flashcard".equals(examType)) {
            return rejectClassExam(request, "Dang flashcard chua duoc ho tro.");
        }
        if (startAt == null || endAt == null || !endAt.after(startAt)) {
            return rejectClassExam(request, "Thoi gian khong hop le. Mo de: "
                    + startAtValue + ", dong de: " + endAtValue + ".");
        }
        if (questions.isEmpty() || !areClassExamQuestionsValid(questions, examType)) {
            return rejectClassExam(request, "Moi cau hoi can noi dung, diem hop le va dap an/cau tra loi dung voi tung dang cau.");
        }
        if (examDao.findByCode(code) != null) {
            return rejectClassExam(request, "Ma de da ton tai. Vui long dung ma de khac.");
        }
        if (!sourceMaterialId.isEmpty() && !isExamMaterialForClassroom(sourceMaterialId, classroom.getId())) {
            return rejectClassExam(request, "Tai lieu de thi khong thuoc lop hoc nay.");
        }
        ClassroomExam exam = new ClassroomExam();
        exam.setClassroomId(classroom.getId());
        exam.setTitle(title);
        exam.setDescription(description);
        exam.setExamCode(code);
        exam.setExamType(examType);
        exam.setCreationMode(creationMode);
        exam.setRawSourceText(rawSourceText);
        exam.setStatus("open");
        exam.setMaxScore(maxScore);
        exam.setAttemptLimit(attemptLimit);
        exam.setDurationMinutes(duration);
        exam.setStartAt(startAt);
        exam.setEndAt(endAt);
        exam.setSourceMaterialId(sourceMaterialId);
        exam.setCreatedBy(user.getId());
        exam.setQuestions(questions);
        boolean saved = examDao.createWithQuestions(exam, questions);
        if (!saved) {
            String daoError = cleanParam(examDao.getLastError());
            return rejectClassExam(request, daoError.isEmpty()
                    ? "Khong luu duoc bai thi vao database."
                    : "Khong luu duoc bai thi vao database: " + daoError);
        }
        return true;
    }

    private boolean rejectClassExam(HttpServletRequest request, String message) {
        request.getSession().setAttribute("classExamCreateError", message);
        return false;
    }

    private boolean handleClassExamUpdate(HttpServletRequest request, Classroom classroom) {
        request.getSession().removeAttribute("classExamUpdateError");
        String examId = cleanParam(request.getParameter("examId"));
        String title = cleanParam(request.getParameter("examTitle"));
        String code = normalizeExamCode(request.getParameter("examCode"));
        String description = cleanParam(request.getParameter("examDescription"));
        int duration = parsePositiveInt(request.getParameter("durationMinutes"), 45);
        Double maxScore = parsePositiveDouble(request.getParameter("examMaxScore"), 10.0);
        String startAtValue = buildExamDateTimeValue(request, "examStart");
        String endAtValue = buildExamDateTimeValue(request, "examEnd");
        Timestamp startAt = parseDateTimeLocal(startAtValue);
        Timestamp endAt = parseDateTimeLocal(endAtValue);
        
        if (examId.isEmpty()) return rejectClassExamUpdate(request, "Thieu ID bai thi.");
        if (title.isEmpty() || code.isEmpty()) {
            return rejectClassExamUpdate(request, "Vui long nhap tieu de va ma de.");
        }
        if (startAt == null || endAt == null || !endAt.after(startAt)) {
            return rejectClassExamUpdate(request, "Thoi gian khong hop le. Mo de: " + startAtValue + ", dong de: " + endAtValue + ".");
        }
        
        ClassroomExam existing = examDao.findByCode(code);
        if (existing != null && !existing.getId().equals(examId)) {
            return rejectClassExamUpdate(request, "Ma de da ton tai. Vui long dung ma de khac.");
        }
        
        ClassroomExam exam = new ClassroomExam();
        exam.setId(examId);
        exam.setTitle(title);
        exam.setExamCode(code);
        exam.setDescription(description);
        exam.setMaxScore(maxScore);
        exam.setDurationMinutes(duration);
        exam.setStartAt(startAt);
        exam.setEndAt(endAt);
        
        boolean updated = examDao.updateMetadata(exam);
        if (!updated) {
            return rejectClassExamUpdate(request, "Loi khi luu vao database.");
        }
        return true;
    }

    private boolean rejectClassExamUpdate(HttpServletRequest request, String message) {
        request.getSession().setAttribute("classExamUpdateError", message);
        return false;
    }

    private boolean handleClassExamAiScan(HttpServletRequest request, HttpSession session) throws Exception {
        String examType = normalizeClassExamType(request.getParameter("examType"));
        if ("flashcard".equals(examType)) {
            return false;
        }
        String sourceText = cleanTeacherSourceText(request.getParameter("examSourceText"));
        Part imagePart = request.getPart("examSourceImage");
        OcrResult ocrResult = null;
        if (imagePart != null && imagePart.getSize() > 0 && imagePart.getSubmittedFileName() != null) {
            String originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            if (!isAllowedOcrSource(originalFileName, imagePart.getContentType()) || imagePart.getSize() > maxOcrSourceBytes()) {
                return false;
            }
            ocrResult = extractOcrFromUploadedPart(imagePart, originalFileName);
        }
        String aiSourceText = buildAiSourceText(sourceText, ocrResult);
        if (aiSourceText.trim().isEmpty()) {
            return false;
        }
        List<ClassroomExamQuestion> questions = aiClassExamParserService.parseQuestions(aiSourceText, examType);
        if (questions.isEmpty()) {
            return false;
        }
        session.setAttribute("examDraftTitle", cleanParam(request.getParameter("examTitle")));
        session.setAttribute("examDraftCode", normalizeExamCode(request.getParameter("examCode")));
        session.setAttribute("examDraftDescription", cleanParam(request.getParameter("examDescription")));
        session.setAttribute("examDraftType", examType);
        session.setAttribute("examDraftStartAt", buildExamDateTimeValue(request, "examStart"));
        session.setAttribute("examDraftEndAt", buildExamDateTimeValue(request, "examEnd"));
        session.setAttribute("examDraftDuration", parsePositiveInt(request.getParameter("durationMinutes"), 45));
        session.setAttribute("examDraftAttemptLimit", parsePositiveInt(request.getParameter("attemptLimit"), 1));
        session.setAttribute("examDraftMaxScore", parsePositiveDouble(request.getParameter("examMaxScore"), 10.0));
        session.setAttribute("examDraftSourceMaterialId", cleanParam(request.getParameter("sourceMaterialId")));
        session.setAttribute("examDraftSourceText", sourceText);
        session.setAttribute("examDraftCreationMode", "ai");
        session.setAttribute("examDraftQuestions", questions);
        return true;
    }

    private String cleanTeacherSourceText(String rawSourceText) {
        String cleaned = cleanParam(rawSourceText);
        if (cleaned.isEmpty() || !cleaned.contains("### OCR ")) {
            return cleaned;
        }

        int teacherBlockIndex = cleaned.indexOf("### TEACHER SOURCE TEXT");
        if (teacherBlockIndex >= 0) {
            int contentStart = cleaned.indexOf('\n', teacherBlockIndex);
            if (contentStart < 0) {
                return "";
            }
            int nextBlock = cleaned.indexOf("\n### ", contentStart + 1);
            String teacherText = nextBlock >= 0
                    ? cleaned.substring(contentStart + 1, nextBlock)
                    : cleaned.substring(contentStart + 1);
            return cleanParam(teacherText);
        }

        int firstGeneratedBlock = cleaned.indexOf("### OCR ");
        return firstGeneratedBlock > 0 ? cleanParam(cleaned.substring(0, firstGeneratedBlock)) : "";
    }

    private OcrProvider createOcrProvider() {
        String provider = System.getenv("HIPZI_OCR_PROVIDER");
        if (provider != null && "tesseract".equalsIgnoreCase(provider.trim())) {
            return new TesseractOcrProvider(ocrService);
        }
        return new DatalabOcrService();
    }

    private OcrResult extractOcrFromUploadedPart(Part part, String originalFileName) throws Exception {
        byte[] fileBytes;
        try (java.io.InputStream input = part.getInputStream()) {
            fileBytes = input.readAllBytes();
        }

        java.nio.file.Path tempFile = Files.createTempFile("hipzi-ocr-source-", ocrSourceExtension(originalFileName, part.getContentType()));
        try {
            Files.write(tempFile, fileBytes);
            byte[] storedBytes = Files.readAllBytes(tempFile);
            if (isDocxSource(originalFileName, part.getContentType())) {
                return docxTextExtractionService.extract(storedBytes, originalFileName);
            }
            return sourceOcrProvider.extract(storedBytes, part.getContentType(), originalFileName);
        } finally {
            try {
                Files.deleteIfExists(tempFile);
            } catch (IOException ignored) {
            }
        }
    }

    private String extractOcrText(byte[] fileBytes, String contentType, String originalFileName) throws Exception {
        OcrResult result = isDocxSource(originalFileName, contentType)
                ? docxTextExtractionService.extract(fileBytes, originalFileName)
                : sourceOcrProvider.extract(fileBytes, contentType, originalFileName);
        if (result == null) {
            return "";
        }
        if (result.getPlainText() != null && !result.getPlainText().trim().isEmpty()) {
            return result.getPlainText().trim();
        }
        if (result.getMarkdown() != null && !result.getMarkdown().trim().isEmpty()) {
            return result.getMarkdown().trim();
        }
        return "";
    }

    private String buildAiSourceText(String teacherText, OcrResult ocrResult) {
        StringBuilder source = new StringBuilder();
        appendSourceBlock(source, "TEACHER SOURCE TEXT", teacherText);
        if (ocrResult != null) {
            appendSourceBlock(source, "OCR PROVIDER", ocrResult.getProvider());
            appendSourceBlock(source, "OCR MARKDOWN", ocrResult.getMarkdown());
            appendSourceBlock(source, "OCR PLAIN TEXT", ocrResult.getPlainText());
            appendSourceBlock(source, "OCR LAYOUT JSON", limitText(ocrResult.getLayoutJson(), 12000));
        }
        return source.toString().trim();
    }

    private void appendSourceBlock(StringBuilder source, String title, String value) {
        String cleaned = value == null ? "" : value.trim();
        if (cleaned.isEmpty()) {
            return;
        }
        if (source.length() > 0) {
            source.append("\n\n");
        }
        source.append("### ").append(title).append("\n").append(cleaned);
    }

    private String limitText(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength) + "\n...[truncated]";
    }

    private List<ClassroomExamQuestion> collectClassExamQuestions(HttpServletRequest request, String examType) {
        String[] questionTexts = request.getParameterValues("examQuestionText");
        String[] optionAs = request.getParameterValues("examOptionA");
        String[] optionBs = request.getParameterValues("examOptionB");
        String[] optionCs = request.getParameterValues("examOptionC");
        String[] optionDs = request.getParameterValues("examOptionD");
        String[] correctOptions = request.getParameterValues("examCorrectOption");
        String[] referenceAnswers = request.getParameterValues("examReferenceAnswer");
        String[] pointValues = request.getParameterValues("examPoints");
        List<ClassroomExamQuestion> questions = new ArrayList<>();
        if (questionTexts == null) {
            return questions;
        }
        String fallbackQuestionType = defaultQuestionTypeForExam(examType);
        String[] questionTypes = request.getParameterValues("examQuestionType");
        for (int i = 0; i < questionTexts.length; i++) {
            String text = cleanParam(questionTexts[i]);
            if (text.isEmpty()) {
                continue;
            }
            String questionType = normalizeClassQuestionType(valueAt(questionTypes, i));
            if (questionType.isEmpty()) {
                questionType = fallbackQuestionType;
            }
            ClassroomExamQuestion question = new ClassroomExamQuestion();
            question.setQuestionType(questionType);
            question.setQuestionText(text);
            if ("multiple_choice".equals(questionType)) {
                question.setOptionA(valueAt(optionAs, i));
                question.setOptionB(valueAt(optionBs, i));
                question.setOptionC(valueAt(optionCs, i));
                question.setOptionD(valueAt(optionDs, i));
                question.setCorrectOption(normalizeQuestionOption(valueAt(correctOptions, i)));
            } else if ("true_false".equals(questionType)) {
                question.setOptionA(defaultIfBlank(valueAt(optionAs, i), "Đúng"));
                question.setOptionB(defaultIfBlank(valueAt(optionBs, i), "Sai"));
                question.setOptionC("");
                question.setOptionD("");
                question.setCorrectOption(normalizeTrueFalseOption(valueAt(correctOptions, i)));
            } else {
                question.setOptionA("");
                question.setOptionB("");
                question.setOptionC("");
                question.setOptionD("");
                question.setCorrectOption("");
            }
            question.setReferenceAnswer(valueAt(referenceAnswers, i));
            question.setPoints(parsePositiveDouble(valueAt(pointValues, i), 1.0));
            question.setSortOrder(questions.size() + 1);
            questions.add(question);
        }
        return questions;
    }

    private boolean areClassExamQuestionsValid(List<ClassroomExamQuestion> questions, String examType) {
        if (questions == null || questions.isEmpty()) {
            return false;
        }
        for (ClassroomExamQuestion question : questions) {
            if (question == null || cleanParam(question.getQuestionText()).isEmpty()
                    || question.getPoints() == null || question.getPoints() <= 0) {
                return false;
            }
            String questionType = normalizeClassQuestionType(question.getQuestionType());
            if (!isQuestionTypeAllowedForExam(examType, questionType)) {
                return false;
            }
            if ("multiple_choice".equals(questionType)) {
                if (cleanParam(question.getOptionA()).isEmpty()
                        || cleanParam(question.getOptionB()).isEmpty()
                        || cleanParam(question.getOptionC()).isEmpty()
                        || cleanParam(question.getOptionD()).isEmpty()
                        || normalizeQuestionOption(question.getCorrectOption()).isEmpty()) {
                    return false;
                }
            } else if ("true_false".equals(questionType)) {
                if (normalizeTrueFalseOption(question.getCorrectOption()).isEmpty()) {
                    return false;
                }
            }
        }
        return true;
    }

    private boolean isExamMaterialForClassroom(String materialId, String classroomId) {
        ClassroomMaterial material = materialDao.findById(materialId);
        return material != null
                && classroomId.equals(material.getClassroomId())
                && "exam".equals(material.getCategory());
    }

    private boolean handleQuizDraftCreate(HttpServletRequest request, Classroom classroom, User user)
            throws Exception {
        String title = cleanParam(request.getParameter("quizTitle"));
        String description = cleanParam(request.getParameter("quizDescription"));
        String rawScanText = cleanParam(request.getParameter("quizScanText"));
        if (title.isEmpty()) {
            return false;
        }

        String storedRelativePath = "";
        String originalFileName = "";
        Part imagePart = request.getPart("quizSourceImage");
        if (imagePart != null && imagePart.getSize() > 0 && imagePart.getSubmittedFileName() != null) {
            originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            if (!isAllowedQuizImage(originalFileName, imagePart.getContentType()) || imagePart.getSize() > 10L * 1024 * 1024) {
                return false;
            }
            storedRelativePath = buildQuizSourceStorageObjectPath(classroom.getId(), originalFileName);
            byte[] fileBytes;
            try (java.io.InputStream input = imagePart.getInputStream()) {
                fileBytes = input.readAllBytes();
            }
            storageService.uploadObject(storedRelativePath, fileBytes, imagePart.getContentType());
            if (rawScanText.isEmpty()) {
                rawScanText = extractOcrText(fileBytes, imagePart.getContentType(), originalFileName);
            }
        }

        if (rawScanText.isEmpty()) {
            if (!storedRelativePath.isEmpty()) {
                try {
                    storageService.deleteObject(storedRelativePath);
                } catch (Exception ignored) {
                }
            }
            return false;
        }

        ClassroomQuiz quiz = new ClassroomQuiz();
        quiz.setClassroomId(classroom.getId());
        quiz.setTitle(title);
        quiz.setDescription(description);
        quiz.setRawScanText(rawScanText);
        quiz.setSourceImagePath(storedRelativePath);
        quiz.setSourceFileName(originalFileName);
        quiz.setStatus("draft");
        quiz.setCreatedBy(user.getId());
        List<ClassroomQuizQuestion> questions = collectQuizQuestions(request);
        if (questions.isEmpty()) {
            questions = parseQuizQuestions(rawScanText);
        }
        boolean created = quizDao.createWithQuestions(quiz, questions);
        if (!created && !storedRelativePath.isEmpty()) {
            try {
                storageService.deleteObject(storedRelativePath);
            } catch (Exception ignored) {
            }
        }
        return created;
    }

    private boolean handleQuizImageScan(HttpServletRequest request, HttpSession session, boolean useAi) throws Exception {
        Part imagePart = request.getPart("quizSourceImage");
        if (imagePart == null || imagePart.getSize() <= 0 || imagePart.getSubmittedFileName() == null) {
            return false;
        }
        String originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
        if (!isAllowedQuizImage(originalFileName, imagePart.getContentType()) || imagePart.getSize() > 10L * 1024 * 1024) {
            return false;
        }

        byte[] fileBytes;
        try (java.io.InputStream input = imagePart.getInputStream()) {
            fileBytes = input.readAllBytes();
        }
        String scannedText = extractOcrText(fileBytes, imagePart.getContentType(), originalFileName);
        if (scannedText == null || scannedText.trim().isEmpty()) {
            return false;
        }

        List<ClassroomQuizQuestion> recognizedQuestions = useAi
                ? aiQuizParserService.parseQuestions(scannedText)
                : parseQuizQuestions(scannedText);
        if (recognizedQuestions.isEmpty()) {
            return false;
        }

        session.setAttribute("quizDraftTitle", cleanParam(request.getParameter("quizTitle")));
        session.setAttribute("quizDraftDescription", cleanParam(request.getParameter("quizDescription")));
        session.setAttribute("quizDraftScanText", scannedText);
        session.setAttribute("quizDraftQuestions", recognizedQuestions);
        return true;
    }

    private String scanQuizImage(byte[] fileBytes, String originalFileName) throws Exception {
        String extension = ".png";
        String safeName = originalFileName == null ? "" : originalFileName.toLowerCase(Locale.ROOT);
        int dotIndex = safeName.lastIndexOf('.');
        if (dotIndex >= 0) {
            String ext = safeName.substring(dotIndex);
            if (ext.matches("\\.(png|jpg|jpeg|webp)")) {
                extension = ext;
            }
        }
        File tempFile = Files.createTempFile("hipzi-quiz-ocr-", extension).toFile();
        try {
            Files.write(tempFile.toPath(), fileBytes);
            return ocrService.scan(tempFile);
        } finally {
            try {
                Files.deleteIfExists(tempFile.toPath());
            } catch (IOException ignored) {
            }
        }
    }

    private boolean handleQuizDraftUpdate(HttpServletRequest request, Classroom classroom) {
        String quizId = cleanParam(request.getParameter("quizId"));
        String title = cleanParam(request.getParameter("quizTitle"));
        if (quizId.isEmpty() || title.isEmpty()) {
            return false;
        }
        ClassroomQuiz existing = quizDao.findById(quizId);
        if (existing == null || !classroom.getId().equals(existing.getClassroomId())) {
            return false;
        }
        List<ClassroomQuizQuestion> questions = collectQuizQuestions(request);
        if (questions.isEmpty()) {
            return false;
        }
        existing.setTitle(title);
        existing.setDescription(cleanParam(request.getParameter("quizDescription")));
        existing.setRawScanText(cleanParam(request.getParameter("quizScanText")));
        existing.setStatus(normalizeQuizStatus(request.getParameter("quizStatus")));
        return quizDao.updateWithQuestions(existing, questions);
    }

    private List<ClassroomQuizQuestion> parseQuizQuestions(String rawScanText) {
        List<ClassroomQuizQuestion> questions = new ArrayList<>();
        if (rawScanText == null || rawScanText.trim().isEmpty()) {
            return questions;
        }
        Pattern questionStart = Pattern.compile("^\\(?\\s*(?:c(?:a|Ã¢)u\\s*)?(\\d+)[\\.|\\)|:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
        Pattern optionLine = Pattern.compile("^([A-Da-d])\\s*[\\.|\\)|:]\\s*(.+)$");
        Pattern inlineOption = Pattern.compile("(?i)(?:^|\\s)([A-D])\\s*[\\.|\\)]\\s*(.+?)(?=\\s+[A-D]\\s*[\\.|\\)]|$)");
        Pattern answerLine = Pattern.compile("^(?:Ä‘Ã¡p\\s*Ã¡n|dap\\s*an|answer)\\s*[:\\-]?\\s*([A-Da-d]).*$", Pattern.CASE_INSENSITIVE);
        ClassroomQuizQuestion current = null;

        String[] lines = normalizeScanTextForParsing(rawScanText).split("\n+");
        for (String line : lines) {
            String cleaned = cleanParam(line);
            if (cleaned.isEmpty()) {
                continue;
            }
            Matcher answerMatcher = answerLine.matcher(cleaned);
            if (answerMatcher.matches() && current != null) {
                current.setCorrectOption(answerMatcher.group(1).toUpperCase(Locale.ROOT));
                continue;
            }
            Matcher optionMatcher = optionLine.matcher(cleaned);
            if (optionMatcher.matches()) {
                if (current == null) {
                    current = new ClassroomQuizQuestion();
                    current.setQuestionText("CÃ¢u há»i cáº§n kiá»ƒm tra láº¡i");
                }
                if (cleaned.matches("(?i).*\\s+[A-D]\\s*[\\.|\\)].*")) {
                    extractInlineOptions(current, cleaned);
                } else {
                    setQuestionOption(current, optionMatcher.group(1), optionMatcher.group(2));
                }
                continue;
            }
            Matcher questionMatcher = questionStart.matcher(cleaned);
            boolean startsQuestion = questionMatcher.matches();
            if (startsQuestion && current != null && hasQuestionContent(current)) {
                questions.add(current);
                current = new ClassroomQuizQuestion();
                current.setQuestionText(extractInlineOptions(current, questionMatcher.group(2)));
                continue;
            }
            if (current == null) {
                current = new ClassroomQuizQuestion();
                current.setQuestionText(startsQuestion ? extractInlineOptions(current, questionMatcher.group(2)) : cleaned);
            } else {
                Matcher inlineMatcher = inlineOption.matcher(cleaned);
                boolean foundInlineOption = false;
                int firstOptionIndex = -1;
                while (inlineMatcher.find()) {
                    if (firstOptionIndex < 0) {
                        firstOptionIndex = inlineMatcher.start();
                    }
                    setQuestionOption(current, inlineMatcher.group(1), inlineMatcher.group(2));
                    foundInlineOption = true;
                }
                if (foundInlineOption) {
                    String prefix = firstOptionIndex > 0 ? cleaned.substring(0, firstOptionIndex).trim() : "";
                    if (!prefix.isEmpty()) {
                        current.setQuestionText(cleanParam(current.getQuestionText() + " " + prefix));
                    }
                } else {
                    current.setQuestionText(cleanParam(current.getQuestionText() + " " + cleaned));
                }
            }
        }
        if (current != null && hasQuestionContent(current)) {
            questions.add(current);
        }
        if (questions.isEmpty()) {
            ClassroomQuizQuestion fallback = new ClassroomQuizQuestion();
            fallback.setQuestionText(rawScanText.trim());
            questions.add(fallback);
        }
        int order = 1;
        for (ClassroomQuizQuestion question : questions) {
            question.setSortOrder(order++);
        }
        return questions;
    }

    private String extractInlineOptions(ClassroomQuizQuestion question, String text) {
        if (text == null || text.trim().isEmpty()) {
            return "";
        }
        Pattern inlineOption = Pattern.compile("(?i)(?:^|\\s)([A-D])\\s*[\\.|\\)]\\s*(.+?)(?=\\s+[A-D]\\s*[\\.|\\)]|$)");
        Matcher matcher = inlineOption.matcher(text);
        int firstOptionIndex = -1;
        while (matcher.find()) {
            if (firstOptionIndex < 0) {
                firstOptionIndex = matcher.start();
            }
            setQuestionOption(question, matcher.group(1), matcher.group(2));
        }
        if (firstOptionIndex >= 0) {
            return text.substring(0, firstOptionIndex).trim();
        }
        return text.trim();
    }

    private String normalizeScanTextForParsing(String rawScanText) {
        String text = rawScanText == null ? "" : rawScanText.replace("\r", "\n");
        text = text.replaceAll("(?i)\\s+(\\(?\\s*c(?:a|Ã¢)u\\s*\\d+[\\.|\\)|:])", "\n$1");
        text = text.replaceAll("(?i)\\s+(\\d+[\\.|\\)]\\s+)", "\n$1");
        text = text.replaceAll("(?i)\\s+(Ä‘Ã¡p\\s*Ã¡n|dap\\s*an|answer)\\s*[:\\-]?", "\n$1: ");
        text = text.replaceAll("\\n{2,}", "\n");
        return text.trim();
    }

    private List<ClassroomQuizQuestion> collectQuizQuestions(HttpServletRequest request) {
        String[] questionTexts = request.getParameterValues("questionText");
        String[] optionAs = request.getParameterValues("optionA");
        String[] optionBs = request.getParameterValues("optionB");
        String[] optionCs = request.getParameterValues("optionC");
        String[] optionDs = request.getParameterValues("optionD");
        String[] correctOptions = request.getParameterValues("correctOption");
        String[] explanations = request.getParameterValues("explanation");
        List<ClassroomQuizQuestion> questions = new ArrayList<>();
        if (questionTexts == null) {
            return questions;
        }
        for (int i = 0; i < questionTexts.length; i++) {
            String text = cleanParam(questionTexts[i]);
            if (text.isEmpty()) {
                continue;
            }
            ClassroomQuizQuestion question = new ClassroomQuizQuestion();
            question.setQuestionText(text);
            question.setOptionA(valueAt(optionAs, i));
            question.setOptionB(valueAt(optionBs, i));
            question.setOptionC(valueAt(optionCs, i));
            question.setOptionD(valueAt(optionDs, i));
            question.setCorrectOption(normalizeQuestionOption(valueAt(correctOptions, i)));
            question.setExplanation(valueAt(explanations, i));
            question.setSortOrder(questions.size() + 1);
            questions.add(question);
        }
        return questions;
    }

    private Map<String, String> collectQuizAnswers(HttpServletRequest request, ClassroomQuiz quiz) {
        Map<String, String> answers = new LinkedHashMap<>();
        if (quiz == null || quiz.getQuestions() == null) {
            return answers;
        }
        for (ClassroomQuizQuestion question : quiz.getQuestions()) {
            answers.put(question.getId(), normalizeQuestionOption(request.getParameter("answer_" + question.getId())));
        }
        return answers;
    }

    private void setQuestionOption(ClassroomQuizQuestion question, String optionLetter, String optionText) {
        String letter = normalizeQuestionOption(optionLetter);
        if ("A".equals(letter)) {
            question.setOptionA(optionText);
        } else if ("B".equals(letter)) {
            question.setOptionB(optionText);
        } else if ("C".equals(letter)) {
            question.setOptionC(optionText);
        } else if ("D".equals(letter)) {
            question.setOptionD(optionText);
        }
    }

    private boolean hasQuestionContent(ClassroomQuizQuestion question) {
        return question != null && question.getQuestionText() != null && !question.getQuestionText().trim().isEmpty();
    }

    private String valueAt(String[] values, int index) {
        return values != null && index >= 0 && index < values.length ? cleanParam(values[index]) : "";
    }

    private String normalizeQuestionOption(String value) {
        if (value == null) {
            return "";
        }
        String cleaned = value.trim().toUpperCase(Locale.ROOT);
        return cleaned.matches("[ABCD]") ? cleaned : "";
    }

    private String normalizeTrueFalseOption(String value) {
        String cleaned = normalizeQuestionOption(value);
        return "A".equals(cleaned) || "B".equals(cleaned) ? cleaned : "";
    }

    private String normalizeClassQuestionType(String value) {
        String cleaned = cleanParam(value);
        if ("essay".equals(cleaned) || "true_false".equals(cleaned)) {
            return cleaned;
        }
        if ("multiple_choice".equals(cleaned)) {
            return cleaned;
        }
        return "";
    }

    private String defaultQuestionTypeForExam(String examType) {
        if ("essay".equals(examType)) {
            return "essay";
        }
        if ("true_false".equals(examType)) {
            return "true_false";
        }
        return "multiple_choice";
    }

    private boolean isQuestionTypeAllowedForExam(String examType, String questionType) {
        if ("mixed_mc_essay".equals(examType)) {
            return "multiple_choice".equals(questionType) || "essay".equals(questionType);
        }
        if ("mixed_mc_true_false".equals(examType)) {
            return "multiple_choice".equals(questionType) || "true_false".equals(questionType);
        }
        if ("essay".equals(examType)) {
            return "essay".equals(questionType);
        }
        if ("true_false".equals(examType)) {
            return "true_false".equals(questionType);
        }
        return "multiple_choice".equals(questionType);
    }

    private String defaultIfBlank(String value, String fallback) {
        return cleanParam(value).isEmpty() ? fallback : cleanParam(value);
    }

    private String normalizeQuizStatus(String value) {
        return "published".equals(cleanParam(value)) ? "published" : "draft";
    }

    private String normalizeClassExamType(String value) {
        String cleaned = cleanParam(value);
        if ("essay".equals(cleaned)
                || "true_false".equals(cleaned)
                || "mixed_mc_essay".equals(cleaned)
                || "mixed_mc_true_false".equals(cleaned)
                || "flashcard".equals(cleaned)) {
            return cleaned;
        }
        return "multiple_choice";
    }

    private String normalizeClassExamCreationMode(String value) {
        return "ai".equals(cleanParam(value)) ? "ai" : "manual";
    }

    private String normalizeExamCode(String value) {
        String cleaned = cleanParam(value).toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9-]", "-");
        cleaned = cleaned.replaceAll("-{2,}", "-").replaceAll("^-|-$", "");
        return cleaned;
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(cleanParam(value));
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private Double parsePositiveDouble(String value, Double defaultValue) {
        try {
            Double parsed = Double.parseDouble(cleanParam(value));
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException | NullPointerException e) {
            return defaultValue;
        }
    }

    private Timestamp parseDateTimeLocal(String value) {
        String cleaned = cleanParam(value);
        if (cleaned.isEmpty()) {
            return null;
        }
        // datetime-local input gá»­i lÃªn dáº¡ng "yyyy-MM-ddTHH:mm" (khÃ´ng cÃ³ giÃ¢y)
        // LocalDateTime.parse() máº·c Ä‘á»‹nh yÃªu cáº§u cáº£ giÃ¢y, nÃªn cáº§n bá»• sung ":00" náº¿u thiáº¿u
        if (cleaned.matches("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}")) {
            cleaned = cleaned + ":00";
        }
        try {
            return Timestamp.valueOf(LocalDateTime.parse(cleaned));
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private String buildExamDateTimeValue(HttpServletRequest request, String prefix) {
        String date = cleanParam(request.getParameter(prefix + "Date"));
        String hour = cleanParam(request.getParameter(prefix + "Hour"));
        String minute = cleanParam(request.getParameter(prefix + "Minute"));
        if (!date.matches("\\d{4}-\\d{2}-\\d{2}")
                || !hour.matches("\\d{2}")
                || !minute.matches("\\d{2}")) {
            return "";
        }
        return date + "T" + hour + ":" + minute + ":00";
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

    private String buildQuizSourceStorageObjectPath(String classroomId, String originalFileName) {
        String safeOriginalName = originalFileName.replaceAll("[^A-Za-z0-9._-]", "_");
        String extension = "";
        int dotIndex = safeOriginalName.lastIndexOf('.');
        if (dotIndex >= 0) {
            extension = safeOriginalName.substring(dotIndex).toLowerCase(Locale.ROOT);
        }
        return "classrooms/" + classroomId + "/quiz-sources/" + UUID.randomUUID() + extension;
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

    private boolean isAllowedQuizImage(String fileName, String contentType) {
        String lower = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        boolean allowedExtension = lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".webp");
        return allowedExtension
                && contentType != null
                && contentType.toLowerCase(Locale.ROOT).startsWith("image/");
    }

    private boolean isAllowedOcrSource(String fileName, String contentType) {
        String lower = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        String lowerType = contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);
        boolean allowedExtension = lower.endsWith(".png")
                || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg")
                || lower.endsWith(".webp")
                || lower.endsWith(".pdf")
                || lower.endsWith(".docx");
        boolean allowedContentType = lowerType.startsWith("image/")
                || "application/pdf".equals(lowerType)
                || isDocxSource(fileName, contentType)
                || lower.endsWith(".pdf");
        return allowedExtension && allowedContentType;
    }

    private boolean isDocxSource(String fileName, String contentType) {
        String lower = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        String lowerType = contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);
        return lower.endsWith(".docx")
                || "application/vnd.openxmlformats-officedocument.wordprocessingml.document".equals(lowerType);
    }

    private long maxOcrSourceBytes() {
        String raw = System.getenv("HIPZI_OCR_MAX_FILE_MB");
        int maxMb = 25;
        try {
            if (raw != null && !raw.trim().isEmpty()) {
                int parsed = Integer.parseInt(raw.trim());
                if (parsed > 0) {
                    maxMb = parsed;
                }
            }
        } catch (NumberFormatException ignored) {
        }
        return maxMb * 1024L * 1024L;
    }

    private String ocrSourceExtension(String fileName, String contentType) {
        String lower = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        int dotIndex = lower.lastIndexOf('.');
        if (dotIndex >= 0) {
            String extension = lower.substring(dotIndex);
            if (extension.matches("\\.(png|jpg|jpeg|webp|pdf|docx)")) {
                return extension;
            }
        }
        if (isDocxSource(fileName, contentType)) {
            return ".docx";
        }
        return "application/pdf".equalsIgnoreCase(contentType) ? ".pdf" : ".png";
    }

    private String normalizeMaterialCategory(String category) {
        String cleaned = cleanParam(category);
        if ("homework".equals(cleaned) || "exam".equals(cleaned)
                || "theory".equals(cleaned) || "teaching".equals(cleaned)) {
            return cleaned;
        }
        return "document";
    }

    private List<ClassroomMaterial> filterMaterialsByCategory(List<ClassroomMaterial> materials, String... categories) {
        List<ClassroomMaterial> filtered = new ArrayList<>();
        if (materials == null) {
            return filtered;
        }
        for (ClassroomMaterial material : materials) {
            if (material == null) {
                continue;
            }
            String category = material.getCategory() == null || material.getCategory().trim().isEmpty()
                    ? "document"
                    : material.getCategory().trim();
            for (String allowedCategory : categories) {
                if (category.equals(allowedCategory)) {
                    filtered.add(material);
                    break;
                }
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

    private String compactErrorMessage(Exception exception) {
        if (exception == null) {
            return "";
        }
        String message = exception.getMessage();
        if (message == null || message.trim().isEmpty()) {
            message = exception.getClass().getSimpleName();
        }
        message = message.replaceAll("(?i)(bearer\\s+)[A-Za-z0-9._\\-]+", "$1***")
                .replaceAll("(?i)(api[_ -]?key[\"':=\\s]+)[A-Za-z0-9._\\-]+", "$1***")
                .replaceAll("\\s+", " ")
                .trim();
        return message.length() > 220 ? message.substring(0, 220) + "..." : message;
    }
}
