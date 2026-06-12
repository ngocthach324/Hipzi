package com.hipzi.controller;

import com.hipzi.model.Notification;
import com.hipzi.model.Classroom;
import com.hipzi.model.Course;
import com.hipzi.model.StudentProfile;
import com.hipzi.model.TeacherApplication;
import com.hipzi.model.TeacherGoogleAccount;
import com.hipzi.model.User;
import com.hipzi.service.AuthService;
import com.hipzi.service.GoogleDriveOAuthService;
import com.hipzi.service.OtpService;
import com.hipzi.service.NotificationService;
import com.hipzi.service.StudentProfileService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import com.hipzi.model.ParentStudentLink;
import com.hipzi.dao.ParentStudentLinkDao;
import com.hipzi.dao.AdminStatsDao;
import com.hipzi.dao.AdminUserDao;
import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.CourseDao;
import com.hipzi.dao.TeacherApplicationDao;
import com.hipzi.dao.TeacherGoogleAccountDao;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.Normalizer;
import java.sql.Time;
import java.util.List;
import java.util.Locale;


@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/student-profile", "/parent-profile", "/teacher-profile", "/staff-profile", "/admin-profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class ProfileServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final OtpService  otpService  = new OtpService();
    private final StudentProfileService studentProfileService = new StudentProfileService();
    private final NotificationService notificationService = new NotificationService();
    private final ParentStudentLinkDao linkDao = new ParentStudentLinkDao();
    private final AdminStatsDao adminStatsDao = new AdminStatsDao();
    private final AdminUserDao adminUserDao = new AdminUserDao();
    private final TeacherApplicationDao teacherApplicationDao = new TeacherApplicationDao();
    private final TeacherGoogleAccountDao teacherGoogleAccountDao = new TeacherGoogleAccountDao();
    private final ClassroomDao classroomDao = new ClassroomDao();
    private final CourseDao courseDao = new CourseDao();
    private final GoogleDriveOAuthService googleDriveOAuthService = new GoogleDriveOAuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // --- Xử lý thông báo sau khi tắt 2FA thành công ---
        String success = request.getParameter("success");
        if ("2fa_disabled".equals(success)) {
            request.setAttribute("toastMsg", "Đã tắt tính năng xác thực 2 lớp thành công!");
            request.setAttribute("toastType", "success");
        }

        String path = request.getServletPath();
        User user = (User) session.getAttribute("loggedUser");
        if (!user.isOnboardingCompleted()) {
            response.sendRedirect(request.getContextPath() + "/onboarding");
            return;
        }

        // Nếu truy cập qua path chung "/profile", chuyển hướng sang path định danh vai trò cụ thể
        if ("/profile".equals(path)) {
            String rolePath = "/student-profile";
            List<com.hipzi.model.Role> roles = user.getRoles();
            if (roles != null) {
                boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
                for (com.hipzi.model.Role r : roles) {
                    String rn = r.getName().toLowerCase();
                    if ("parent".equals(rn)) hasParent = true;
                    if ("teacher".equals(rn)) hasTeacher = true;
                    if ("staff".equals(rn)) hasStaff = true;
                    if ("admin".equals(rn)) hasAdmin = true;
                }
                if (hasAdmin) rolePath = "/admin-profile";
                else if (hasStaff) rolePath = "/staff-profile";
                else if (hasTeacher) rolePath = "/teacher-profile";
                else if (hasParent) rolePath = "/parent-profile";
            }
            String queryString = request.getQueryString();
            String redirectUrl = request.getContextPath() + rolePath + (queryString != null ? "?" + queryString : "");
            response.sendRedirect(redirectUrl);
            return;
        }

        String targetJsp = "/WEB-INF/views/student-profile.jsp";
        if ("/parent-profile".equals(path)) targetJsp = "/WEB-INF/views/parent-profile.jsp";
        else if ("/teacher-profile".equals(path)) targetJsp = "/WEB-INF/views/teacher-profile.jsp";
        else if ("/staff-profile".equals(path)) targetJsp = "/WEB-INF/views/staff-profile.jsp";
        else if ("/admin-profile".equals(path)) targetJsp = "/WEB-INF/views/admin-profile.jsp";

        request.setAttribute("user", user);

        // Tải dữ liệu caching thống kê nếu truy cập giao diện học viên
        if ("/WEB-INF/views/student-profile.jsp".equals(targetJsp)) {
            StudentProfile studentProfile = studentProfileService.getProfileByUserId(user.getId());
            request.setAttribute("studentProfile", studentProfile);
        } else if ("/WEB-INF/views/parent-profile.jsp".equals(targetJsp)) {
            List<ParentStudentLink> trackedStudents = linkDao.findLinksByParentId(user.getId());
            request.setAttribute("trackedStudents", trackedStudents);
        } else if ("/WEB-INF/views/teacher-profile.jsp".equals(targetJsp)) {
            TeacherApplication teacherApplication = teacherApplicationDao.findLatestByUserId(user.getId());
            request.setAttribute("teacherApplication", teacherApplication);
            request.setAttribute("teacherClassrooms", classroomDao.findByTeacherId(user.getId()));
            request.setAttribute("teacherCourses", courseDao.findByTeacherId(user.getId()));
            request.setAttribute("teacherGoogleAccount", teacherGoogleAccountDao.findActiveByTeacherId(user.getId()));
        } else if ("/WEB-INF/views/staff-profile.jsp".equals(targetJsp)) {
            request.setAttribute("teacherApplications", teacherApplicationDao.listForStaffReview());
            
            String searchTeacher = cleanParam(request.getParameter("searchTeacher"));
            String teacherType = cleanParam(request.getParameter("teacherType"));
            request.setAttribute("approvedTeachers", teacherApplicationDao.listApprovedTeachers(searchTeacher, teacherType));
            request.setAttribute("searchTeacher", searchTeacher);
            request.setAttribute("teacherType", teacherType);

            String classTitle = cleanParam(request.getParameter("classTitle"));
            String classSubject = cleanParam(request.getParameter("classSubject"));
            String classStatus = cleanParam(request.getParameter("classStatus"));
            request.setAttribute("managedClassrooms", classroomDao.listForStaff(classTitle, classSubject, classStatus));
            request.setAttribute("classSubjects", classroomDao.listSubjects());
            request.setAttribute("classTitle", classTitle);
            request.setAttribute("classSubject", classSubject);
            request.setAttribute("classStatus", classStatus);

            String courseTitle = cleanParam(request.getParameter("courseTitle"));
            String courseSubject = cleanParam(request.getParameter("courseSubject"));
            String courseStatus = cleanParam(request.getParameter("courseStatus"));
            request.setAttribute("managedCourses", courseDao.listForStaff(courseTitle, courseSubject, courseStatus));
            request.setAttribute("courseSubjects", courseDao.listSubjects());
            request.setAttribute("courseTitle", courseTitle);
            request.setAttribute("courseSubject", courseSubject);
            request.setAttribute("courseStatus", courseStatus);
        } else if ("/WEB-INF/views/admin-profile.jsp".equals(targetJsp)) {
            request.setAttribute("systemOverview", adminStatsDao.getSystemOverview());
            int adminUserPage = parsePositiveInt(request.getParameter("userPage"), 1);
            int adminUserPageSize = 10;
            int totalManagedUsers = adminUserDao.countManagedUsers();
            int adminUserTotalPages = Math.max(1, (int) Math.ceil(totalManagedUsers / (double) adminUserPageSize));
            if (adminUserPage > adminUserTotalPages) {
                adminUserPage = adminUserTotalPages;
            }
            request.setAttribute("adminUsers", adminUserDao.listManagedUsers(adminUserPage, adminUserPageSize));
            request.setAttribute("adminUserPage", adminUserPage);
            request.setAttribute("adminUserTotalPages", adminUserTotalPages);
            request.setAttribute("adminUserTotalCount", totalManagedUsers);
        }

        // Tải danh sách thông báo hệ thống gần nhất (Giới hạn 10 thông báo)
        List<Notification> notifications = notificationService.getRecentNotifications(user.getId(), 10);
        request.setAttribute("notifications", notifications);

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (!user.isOnboardingCompleted()) {
            response.sendRedirect(request.getContextPath() + "/onboarding");
            return;
        }
        String action = request.getParameter("action");

        try {
            if ("toggle2FA".equals(action)) {
                if (user.isTwoFactorEnabled()) {
                    // Đang bật → Yêu cầu OTP để tắt
                    otpService.generateAndSend(user.getEmail(), user.getId(), user.getDisplayName(), "disable_2fa");
                    response.sendRedirect(request.getContextPath() + "/verify-otp?purpose=disable_2fa");
                    return;
                } else {
                    // Đang tắt → Bật trực tiếp
                    if (otpService.enableTwoFactor(user.getId())) {
                        user.setTwoFactorEnabled(true);
                        session.setAttribute("loggedUser", user);
                        session.setAttribute("toastMsg", "Đã bật tính năng xác thực 2 lớp thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMsg", "Không thể bật xác thực 2 lớp!");
                        session.setAttribute("toastType", "error");
                    }
                }
            } else if ("updateName".equals(action)) {
                String newDisplayName = request.getParameter("displayName");
                if (newDisplayName != null && !newDisplayName.trim().isEmpty()) {
                    user.setDisplayName(newDisplayName.trim());
                    if (authService.updateProfile(user)) {
                        session.setAttribute("loggedUser", user);
                        session.setAttribute("toastMsg", "Họ và tên của bạn đã được cập nhật thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMsg", "Không thể lưu thay đổi vào cơ sở dữ liệu!");
                        session.setAttribute("toastType", "error");
                    }
                }
            } else if ("updateAvatar".equals(action)) {
                Part part = request.getPart("avatarFile");
                if (part != null && part.getSize() > 0) {
                    String contentType = part.getContentType();
                    if (contentType == null || !contentType.startsWith("image/")) {
                        session.setAttribute("toastMsg", "Vui lòng chọn file hình ảnh hợp lệ!");
                        session.setAttribute("toastType", "error");
                        String errPath = request.getServletPath();
                        response.sendRedirect(request.getContextPath() + (errPath != null ? errPath : "/student-profile"));
                        return;
                    }

                    String uploadPath = request.getServletContext().getRealPath("/uploads/avatars");
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    String submittedName = part.getSubmittedFileName();
                    String extension = "";
                    if (submittedName != null && submittedName.contains(".")) {
                        extension = submittedName.substring(submittedName.lastIndexOf("."));
                    }
                    String safeFileName = "avatar_" + user.getId() + "_" + System.currentTimeMillis() + extension;
                    part.write(uploadPath + File.separator + safeFileName);

                    String avatarUrl = request.getContextPath() + "/uploads/avatars/" + safeFileName;
                    user.setAvatarUrl(avatarUrl);
                    if (authService.updateProfile(user)) {
                        session.setAttribute("loggedUser", user);
                        session.setAttribute("toastMsg", "Ảnh đại diện đã được cập nhật thành công!");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMsg", "Không thể cập nhật đường dẫn ảnh vào cơ sở dữ liệu!");
                        session.setAttribute("toastType", "error");
                    }
                }
            } else if ("changePassword".equals(action)) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");
                
                if (newPassword == null || !newPassword.equals(confirmPassword)) {
                    session.setAttribute("toastMsg", "Mật khẩu xác nhận không khớp với mật khẩu mới!");
                    session.setAttribute("toastType", "error");
                } else {
                    try {
                        authService.changePassword(user.getId(), currentPassword, newPassword);
                        user.setPasswordHash(com.hipzi.util.PasswordUtil.hashPassword(newPassword));
                        session.setAttribute("loggedUser", user);
                        session.setAttribute("toastMsg", "Mật khẩu của bạn đã được thay đổi thành công!");
                        session.setAttribute("toastType", "success");
                    } catch (Exception ex) {
                        session.setAttribute("toastMsg", ex.getMessage());
                        session.setAttribute("toastType", "error");
                    }
                }
            } else if ("banUser".equals(action)) {
                String targetUserId = request.getParameter("targetUserId");
                if (adminUserDao.banUser(targetUserId, user.getId())) {
                    session.setAttribute("toastMsg", "Đã khóa tài khoản người dùng thành công.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể khóa tài khoản này.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("registerClass".equals(action)) {
                Classroom classroom = buildClassroomFromRequest(request, user.getId(), null);
                TeacherApplication teacherApplication = teacherApplicationDao.findLatestByUserId(user.getId());

                if (!canManageClassrooms(user, teacherApplication)) {
                    session.setAttribute("toastMsg", "Hồ sơ giảng viên của bạn cần được phê duyệt trước khi đăng kí lớp học.");
                    session.setAttribute("toastType", "error");
                } else if (!isApprovedSubject(teacherApplication, classroom.getSubject())) {
                    session.setAttribute("toastMsg", "Bạn chỉ được mở lớp cho môn học đã được phê duyệt trong hồ sơ giảng dạy.");
                    session.setAttribute("toastType", "error");
                } else if (!isValidClassroom(classroom)) {
                    session.setAttribute("toastMsg", "Vui lòng điền đầy đủ tên lớp, môn học, thứ học và khung giờ học hợp lệ.");
                    session.setAttribute("toastType", "error");
                } else if (classroomDao.create(classroom)) {
                    session.setAttribute("toastMsg", "Đăng kí lớp học '" + classroom.getTitle() + "' thành công.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Chưa lưu được lớp học. Vui lòng kiểm tra migration classrooms trên Supabase.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("updateClass".equals(action)) {
                String classId = cleanParam(request.getParameter("classId"));
                Classroom classroom = buildClassroomFromRequest(request, user.getId(), classId);
                TeacherApplication teacherApplication = teacherApplicationDao.findLatestByUserId(user.getId());

                if (classId.isEmpty()) {
                    session.setAttribute("toastMsg", "Không tìm thấy lớp học cần chỉnh sửa.");
                    session.setAttribute("toastType", "error");
                } else if (!canManageClassrooms(user, teacherApplication)) {
                    session.setAttribute("toastMsg", "Hồ sơ giảng viên của bạn cần được phê duyệt trước khi chỉnh sửa lớp học.");
                    session.setAttribute("toastType", "error");
                } else if (!isApprovedSubject(teacherApplication, classroom.getSubject())) {
                    session.setAttribute("toastMsg", "Bạn chỉ được chọn môn học đã được phê duyệt trong hồ sơ giảng dạy.");
                    session.setAttribute("toastType", "error");
                } else if (!isValidClassroom(classroom)) {
                    session.setAttribute("toastMsg", "Vui lòng điền đầy đủ thông tin lớp và khung giờ học hợp lệ.");
                    session.setAttribute("toastType", "error");
                } else if (classroomDao.updateForTeacher(classroom)) {
                    session.setAttribute("toastMsg", "Đã cập nhật lớp học '" + classroom.getTitle() + "'.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể cập nhật lớp học này.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("deleteClass".equals(action)) {
                String classId = cleanParam(request.getParameter("classId"));
                if (classId.isEmpty()) {
                    session.setAttribute("toastMsg", "Không tìm thấy lớp học cần xóa.");
                    session.setAttribute("toastType", "error");
                } else if (classroomDao.deleteForTeacher(classId, user.getId())) {
                    session.setAttribute("toastMsg", "Đã xóa lớp học.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể xóa lớp học này.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("deleteManagedClass".equals(action)) {
                String classId = cleanParam(request.getParameter("classId"));
                if (!hasRole(user, "staff") && !hasRole(user, "admin")) {
                    session.setAttribute("toastMsg", "Bạn không có quyền xóa lớp học trong khu vực quản lý.");
                    session.setAttribute("toastType", "error");
                } else if (classId.isEmpty()) {
                    session.setAttribute("toastMsg", "Không tìm thấy lớp học cần xóa.");
                    session.setAttribute("toastType", "error");
                } else if (classroomDao.deleteById(classId)) {
                    session.setAttribute("toastMsg", "Đã xóa lớp học khỏi hệ thống.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể xóa lớp học này.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("registerCourse".equals(action)) {
                Course course = buildCourseFromRequest(request, user);
                TeacherApplication teacherApplication = teacherApplicationDao.findLatestByUserId(user.getId());
                TeacherGoogleAccount googleAccount = teacherGoogleAccountDao.findActiveByTeacherId(user.getId());

                if (!canManageClassrooms(user, teacherApplication)) {
                    session.setAttribute("toastMsg", "Hồ sơ giảng viên của bạn cần được phê duyệt trước khi đăng khóa học.");
                    session.setAttribute("toastType", "error");
                } else if (googleAccount == null || !googleAccount.isConnected()) {
                    session.setAttribute("toastMsg", "Vui lòng kết nối Google Drive trước khi đăng khóa học.");
                    session.setAttribute("toastType", "error");
                } else if (!isApprovedSubject(teacherApplication, course.getSubjectName())) {
                    session.setAttribute("toastMsg", "Bạn chỉ được đăng khóa học cho môn đã được phê duyệt trong hồ sơ giảng dạy.");
                    session.setAttribute("toastType", "error");
                } else if (!isValidCourse(course)) {
                    session.setAttribute("toastMsg", "Vui lòng điền đầy đủ tên khóa học, môn học, số bài, giá hợp lệ và link Google Drive.");
                    session.setAttribute("toastType", "error");
                } else {
                    course.setDriveOwnerEmail(googleAccount.getGoogleEmail());
                    String accessToken = googleDriveOAuthService.accessTokenForTeacher(
                            user.getId(),
                            config("GOOGLE_CLIENT_ID"),
                            config("GOOGLE_CLIENT_SECRET"),
                            tokenEncryptionKey()
                    );
                    googleDriveOAuthService.verifyShareableResource(accessToken, courseDriveResourceId(course));
                    if (courseDao.createForTeacher(course)) {
                        session.setAttribute("toastMsg", "Đã gửi khóa học '" + course.getTitle() + "' vào hàng đợi duyệt của nhân viên.");
                        session.setAttribute("toastType", "success");
                    } else {
                        session.setAttribute("toastMsg", "Chưa lưu được khóa học. Vui lòng kiểm tra migration courses.");
                        session.setAttribute("toastType", "error");
                    }
                }
            } else if ("reviewCourse".equals(action)) {
                String courseId = cleanParam(request.getParameter("courseId"));
                String decision = cleanParam(request.getParameter("decision"));
                String reviewNote = cleanParam(request.getParameter("reviewNote"));

                if (!hasRole(user, "staff") && !hasRole(user, "admin")) {
                    session.setAttribute("toastMsg", "Bạn không có quyền duyệt khóa học.");
                    session.setAttribute("toastType", "error");
                } else if (courseId.isEmpty()
                        || (!"approved".equals(decision) && !"rejected".equals(decision) && !"needs_revision".equals(decision))) {
                    session.setAttribute("toastMsg", "Yêu cầu duyệt khóa học không hợp lệ.");
                    session.setAttribute("toastType", "error");
                } else if (courseDao.reviewCourse(courseId, decision, reviewNote, user.getId())) {
                    session.setAttribute("toastMsg", "Đã cập nhật trạng thái khóa học.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể cập nhật trạng thái khóa học.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("deleteManagedCourse".equals(action)) {
                String courseId = cleanParam(request.getParameter("courseId"));
                String deleteReason = cleanParam(request.getParameter("deleteReason"));
                if (!hasRole(user, "staff") && !hasRole(user, "admin")) {
                    session.setAttribute("toastMsg", "Bạn không có quyền xóa khóa học trong khu vực quản lý.");
                    session.setAttribute("toastType", "error");
                } else if (courseId.isEmpty()) {
                    session.setAttribute("toastMsg", "Không tìm thấy khóa học cần xóa.");
                    session.setAttribute("toastType", "error");
                } else if (courseDao.softDeleteByStaff(courseId, user.getId(), deleteReason)) {
                    session.setAttribute("toastMsg", "Đã xóa tạm khóa học khỏi danh sách hiển thị.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể xóa khóa học này.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("submitTeachingRegistration".equals(action)) {
                String teacherType = cleanParam(request.getParameter("teacherType"));
                String institutionName = cleanParam(request.getParameter("institutionName"));
                String specialization = cleanParam(request.getParameter("specialization"));
                String currentStudyYear = cleanParam(request.getParameter("currentStudyYear"));
                String[] teachingSubjectsArr = request.getParameterValues("teachingSubjects");
                String teachingSubjects = teachingSubjectsArr != null ? String.join(", ", teachingSubjectsArr) : "";
                String teachingExperience = cleanParam(request.getParameter("teachingExperience"));
                String workplace = cleanParam(request.getParameter("workplace"));
                String credentialsSummary = cleanParam(request.getParameter("credentialsSummary"));
                String teacherBio = cleanParam(request.getParameter("teacherBio"));

                if (!hasRole(user, "teacher")) {
                    session.setAttribute("toastMsg", "Chỉ tài khoản có vai trò giảng viên mới có thể gửi hồ sơ đăng kí giảng dạy.");
                    session.setAttribute("toastType", "error");
                } else if (teacherType.isEmpty() || institutionName.isEmpty() || specialization.isEmpty()
                        || teachingSubjects.isEmpty() || teacherBio.isEmpty()) {
                    session.setAttribute("toastMsg", "Vui lòng hoàn tất các thông tin bắt buộc trong hồ sơ đăng kí giảng dạy.");
                    session.setAttribute("toastType", "error");
                } else {
                    String evidenceSummary = saveTeachingEvidenceFiles(request, user);
                    String teacherTypeLabel = teacherTypeLabel(teacherType);
                    TeacherApplication application = new TeacherApplication();
                    application.setUserId(user.getId());
                    application.setTeacherType(teacherType);
                    application.setInstitutionName(institutionName);
                    application.setSpecialization(specialization);
                    application.setCurrentStudyYear(currentStudyYear);
                    application.setTeachingSubjects(teachingSubjects);
                    application.setTeachingExperience(teachingExperience);
                    application.setWorkplace(workplace);
                    application.setCredentialsSummary(credentialsSummary);
                    application.setTeacherBio(teacherBio);
                    application.setEvidenceSummary(evidenceSummary);
                    boolean savedApplication = teacherApplicationDao.upsertApplication(application);

                    String content = "Loại giảng viên: " + teacherTypeLabel + "\n"
                            + "Trường/đơn vị: " + institutionName + "\n"
                            + "Chuyên ngành/lĩnh vực: " + specialization + "\n"
                            + "Năm học hiện tại: " + studyYearLabel(currentStudyYear) + "\n"
                            + "Môn có thể dạy: " + teachingSubjects + "\n"
                            + "Kinh nghiệm giảng dạy: " + valueOrEmpty(teachingExperience) + "\n"
                            + "Nơi từng/đang công tác: " + valueOrEmpty(workplace) + "\n"
                            + "Thành tích/chứng chỉ/bằng cấp: " + valueOrEmpty(credentialsSummary) + "\n\n"
                            + "Hồ sơ cá nhân:\n" + teacherBio + "\n\n"
                            + "Minh chứng đã tải lên:\n" + evidenceSummary;

                    com.hipzi.util.EmailService.sendSupportRequest(
                            user.getEmail(),
                            user.getDisplayName(),
                            "Hồ sơ đăng kí giảng dạy - " + teacherTypeLabel,
                            content
                    );
                    session.setAttribute("teacherRegistrationSubmitted", Boolean.TRUE);
                    session.setAttribute("toastMsg", savedApplication
                            ? "Đã gửi hồ sơ đăng kí giảng dạy. Đội ngũ quản trị sẽ xem xét và phản hồi qua email."
                            : "Đã gửi hồ sơ qua email, nhưng chưa lưu được vào cơ sở dữ liệu. Vui lòng kiểm tra migration teacher_applications.");
                    session.setAttribute("toastType", "success");
                }
            } else if ("reviewTeacherApplication".equals(action)) {
                String applicationId = cleanParam(request.getParameter("applicationId"));
                String decision = cleanParam(request.getParameter("decision"));
                String reviewNote = cleanParam(request.getParameter("reviewNote"));

                if (!hasRole(user, "staff") && !hasRole(user, "admin")) {
                    session.setAttribute("toastMsg", "Bạn không có quyền duyệt hồ sơ giảng viên.");
                    session.setAttribute("toastType", "error");
                } else if (applicationId.isEmpty()
                        || (!"approved".equals(decision) && !"rejected".equals(decision) && !"needs_more_info".equals(decision))) {
                    session.setAttribute("toastMsg", "Yêu cầu duyệt hồ sơ không hợp lệ.");
                    session.setAttribute("toastType", "error");
                } else if (teacherApplicationDao.updateStatus(applicationId, decision, reviewNote, user.getId())) {
                    session.setAttribute("toastMsg", "Đã cập nhật trạng thái hồ sơ giảng viên.");
                    session.setAttribute("toastType", "success");
                } else {
                    session.setAttribute("toastMsg", "Không thể cập nhật trạng thái hồ sơ. Vui lòng thử lại.");
                    session.setAttribute("toastType", "error");
                }
            } else if ("submitSupport".equals(action)) {
                String title = request.getParameter("title");
                String message = request.getParameter("message");
                
                if (title != null && !title.trim().isEmpty() && message != null && !message.trim().isEmpty()) {
                    try {
                        com.hipzi.util.EmailService.sendSupportRequest(user.getEmail(), user.getDisplayName(), title, message);
                        session.setAttribute("toastMsg", "Gửi hỗ trợ thành công! Quản trị viên sẽ phản hồi qua email.");
                        session.setAttribute("toastType", "success");
                    } catch (Exception ex) {
                        session.setAttribute("toastMsg", "Không thể gửi yêu cầu hỗ trợ. Vui lòng thử lại sau.");
                        session.setAttribute("toastType", "error");
                    }
                }
            }
        } catch (IllegalStateException e) {
            session.setAttribute("toastMsg", e.getMessage());
            session.setAttribute("toastType", "error");
        } catch (Exception e) {
            System.err.println("Error updating profile: " + e.getMessage());
            session.setAttribute("toastMsg", e.getMessage() != null ? e.getMessage() : "Có lỗi hệ thống xảy ra khi xử lý yêu cầu!");
            session.setAttribute("toastType", "error");
        }

        String returnPath = request.getServletPath();
        if (returnPath == null || "/profile".equals(returnPath)) {
            returnPath = "/student-profile";
            List<com.hipzi.model.Role> roles = user.getRoles();
            if (roles != null) {
                boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
                for (com.hipzi.model.Role r : roles) {
                    String rn = r.getName().toLowerCase();
                    if ("parent".equals(rn)) hasParent = true;
                    if ("teacher".equals(rn)) hasTeacher = true;
                    if ("staff".equals(rn)) hasStaff = true;
                    if ("admin".equals(rn)) hasAdmin = true;
                }
                if (hasAdmin) returnPath = "/admin-profile";
                else if (hasStaff) returnPath = "/staff-profile";
                else if (hasTeacher) returnPath = "/teacher-profile";
                else if (hasParent) returnPath = "/parent-profile";
            }
        }
        if ("changePassword".equals(action) || "toggle2FA".equals(action)) {
            returnPath += "?tab=security";
        } else if ("banUser".equals(action)) {
            String userPage = request.getParameter("userPage");
            returnPath += "?tab=materials&userPage=" + (userPage != null ? userPage : "1");
        } else if ("submitSupport".equals(action)) {
            returnPath += "?tab=support";
        } else if ("registerClass".equals(action) || "updateClass".equals(action) || "deleteClass".equals(action)) {
            returnPath += "?tab=class-registration";
        } else if ("deleteManagedClass".equals(action)) {
            returnPath += "?tab=manage-classes";
        } else if ("registerCourse".equals(action)) {
            returnPath += "?tab=course-registration";
        } else if ("reviewCourse".equals(action) || "deleteManagedCourse".equals(action)) {
            returnPath += "?tab=manage-courses";
        } else if ("submitTeachingRegistration".equals(action)) {
            returnPath += "?tab=teaching-registration";
        } else if ("reviewTeacherApplication".equals(action)) {
            returnPath += "?tab=teacher-approval";
        }
        response.sendRedirect(request.getContextPath() + returnPath);
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private String config(String name) {
        String value = getServletContext().getInitParameter(name);
        if (value == null || value.trim().isEmpty()) {
            value = getServletContext().getInitParameter(name.toLowerCase().replace('_', '.'));
        }
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(name);
        }
        return value;
    }

    private String tokenEncryptionKey() {
        String value = config("HIPZI_TOKEN_ENCRYPTION_KEY");
        return value == null || value.trim().isEmpty() ? config("TOKEN_ENCRYPTION_KEY") : value;
    }

    private Classroom buildClassroomFromRequest(HttpServletRequest request, String teacherId, String classId) {
        Classroom classroom = new Classroom();
        classroom.setId(classId);
        if (classId == null || classId.trim().isEmpty()) {
            classroom.setClassCode(generateClassCode());
        }
        classroom.setTeacherId(teacherId);
        classroom.setTitle(cleanParam(request.getParameter("className")));
        classroom.setSubject(cleanParam(request.getParameter("classSubject")));
        classroom.setGrade(cleanParam(request.getParameter("classGrade")));
        classroom.setDescription(cleanParam(request.getParameter("classDescription")));
        String[] scheduleDayValues = request.getParameterValues("scheduleDays");
        classroom.setScheduleDays(scheduleDayValues != null
                ? String.join(", ", scheduleDayValues)
                : cleanParam(request.getParameter("scheduleDays")));
        classroom.setStartTime(parseTimeParam(request.getParameter("startTime")));
        classroom.setEndTime(parseTimeParam(request.getParameter("endTime")));

        String status = cleanParam(request.getParameter("classStatus"));
        if (!"upcoming".equals(status) && !"closed".equals(status)) {
            status = "open";
        }
        classroom.setStatus(status);
        return classroom;
    }

    private Course buildCourseFromRequest(HttpServletRequest request, User user)
            throws IOException, ServletException {
        String subjectName = cleanParam(request.getParameter("courseSubject"));
        BigDecimal priceAmount = parseMoneyParam(request.getParameter("coursePriceAmount"));
        String subjectCode = subjectCodeFromName(subjectName);
        String thumbnailUrl = cleanParam(request.getParameter("courseThumbnailUrl"));
        Part thumbnailPart = request.getPart("courseThumbnailFile");
        if (thumbnailPart != null && thumbnailPart.getSize() > 0) {
            thumbnailUrl = saveCourseThumbnailFile(request, user, thumbnailPart);
        }

        Course course = new Course();
        course.setTeacherId(user.getId());
        course.setTitle(cleanParam(request.getParameter("courseTitle")));
        course.setShortDescription(cleanParam(request.getParameter("courseDescription")));
        course.setSubjectName(subjectName);
        course.setSubjectCode(subjectCode);
        course.setGradeLevel(cleanParam(request.getParameter("courseGrade")));
        course.setLevelName(cleanParam(request.getParameter("courseLevel")));
        course.setPriceAmount(priceAmount);
        course.setPriceType(priceAmount.compareTo(BigDecimal.ZERO) > 0 ? "paid" : "free");
        course.setCurrency("VND");
        course.setThumbnailUrl(thumbnailUrl);
        course.setThumbnailGradient(courseGradientForSubject(subjectCode));
        course.setBadgeText(cleanParam(request.getParameter("courseBadge")));
        course.setLessonsCount(parsePositiveInt(request.getParameter("courseLessonsCount"), 0));
        course.setEstimatedHours(parseDecimalParam(request.getParameter("courseEstimatedHours")));
        String driveUrl = cleanParam(request.getParameter("courseGoogleDriveUrl"));
        String fileId = cleanParam(request.getParameter("courseGoogleDriveFileId"));
        String folderId = cleanParam(request.getParameter("courseGoogleDriveFolderId"));
        if (fileId.isEmpty() && folderId.isEmpty()) {
            String extractedId = extractGoogleDriveResourceId(driveUrl);
            if (driveUrl.contains("/folders/")) {
                folderId = extractedId;
            } else {
                fileId = extractedId;
            }
        }
        course.setGoogleDriveUrl(driveUrl);
        course.setGoogleDriveFileId(fileId);
        course.setGoogleDriveFolderId(folderId);
        course.setDriveOwnerEmail(user.getEmail());
        course.setAccessInstructions(cleanParam(request.getParameter("courseAccessInstructions")));
        return course;
    }

    private boolean isValidCourse(Course course) {
        return course != null
                && course.getTitle() != null && !course.getTitle().trim().isEmpty()
                && course.getSubjectName() != null && !course.getSubjectName().trim().isEmpty()
                && course.getSubjectCode() != null && !course.getSubjectCode().trim().isEmpty()
                && course.getLessonsCount() > 0
                && course.getPriceAmount() != null
                && course.getPriceAmount().compareTo(BigDecimal.ZERO) >= 0
                && isValidGoogleCourseUrl(course.getGoogleDriveUrl())
                && !courseDriveResourceId(course).isEmpty();
    }

    private String courseDriveResourceId(Course course) {
        if (course == null) {
            return "";
        }
        String folderId = cleanParam(course.getGoogleDriveFolderId());
        if (!folderId.isEmpty()) {
            return folderId;
        }
        String fileId = cleanParam(course.getGoogleDriveFileId());
        if (!fileId.isEmpty()) {
            return fileId;
        }
        return extractGoogleDriveResourceId(course.getGoogleDriveUrl());
    }

    private String extractGoogleDriveResourceId(String url) {
        String value = cleanParam(url);
        if (value.isEmpty()) {
            return "";
        }
        String[] markers = {"/folders/", "/file/d/", "/document/d/", "/spreadsheets/d/", "/presentation/d/", "/forms/d/"};
        for (String marker : markers) {
            int start = value.indexOf(marker);
            if (start >= 0) {
                start += marker.length();
                int end = start;
                while (end < value.length()) {
                    char c = value.charAt(end);
                    if (c == '/' || c == '?' || c == '&' || c == '#') {
                        break;
                    }
                    end++;
                }
                return value.substring(start, end);
            }
        }
        int idIndex = value.indexOf("id=");
        if (idIndex >= 0) {
            int start = idIndex + 3;
            int end = start;
            while (end < value.length()) {
                char c = value.charAt(end);
                if (c == '&' || c == '#') {
                    break;
                }
                end++;
            }
            return value.substring(start, end);
        }
        return "";
    }

    private String saveCourseThumbnailFile(HttpServletRequest request, User user, Part part)
            throws IOException {
        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Logo khóa học phải là file hình ảnh hợp lệ.");
        }

        String uploadPath = request.getServletContext().getRealPath("/uploads/course-thumbnails");
        if (uploadPath == null) {
            throw new IOException("Không thể xác định thư mục tải lên logo khóa học.");
        }
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String submittedName = part.getSubmittedFileName();
        String extension = "";
        if (submittedName != null && submittedName.contains(".")) {
            extension = submittedName.substring(submittedName.lastIndexOf(".")).replaceAll("[^a-zA-Z0-9.]", "");
        }
        String safeFileName = "course_thumb_" + user.getId() + "_" + System.currentTimeMillis() + extension;
        part.write(uploadPath + File.separator + safeFileName);
        return request.getContextPath() + "/uploads/course-thumbnails/" + safeFileName;
    }

    private boolean isValidGoogleCourseUrl(String value) {
        String url = cleanParam(value).toLowerCase(Locale.ROOT);
        return (url.startsWith("https://") || url.startsWith("http://"))
                && (url.contains("drive.google.com") || url.contains("docs.google.com"));
    }

    private BigDecimal parseMoneyParam(String value) {
        String cleaned = cleanParam(value).replaceAll("[^0-9]", "");
        if (cleaned.isEmpty()) {
            return BigDecimal.ZERO;
        }
        try {
            return new BigDecimal(cleaned);
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private BigDecimal parseDecimalParam(String value) {
        String cleaned = cleanParam(value).replace(",", ".");
        if (cleaned.isEmpty()) {
            return BigDecimal.ZERO;
        }
        try {
            return new BigDecimal(cleaned);
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private String subjectCodeFromName(String subjectName) {
        String normalized = Normalizer.normalize(cleanParam(subjectName), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT);
        if (normalized.contains("toan")) return "math";
        if (normalized.contains("anh") || normalized.contains("english")) return "english";
        if (normalized.contains("ly") || normalized.contains("vat")) return "physics";
        if (normalized.contains("hoa")) return "chemistry";
        if (normalized.contains("van")) return "literature";
        if (normalized.contains("sinh")) return "biology";
        if (normalized.contains("lich")) return "history";
        if (normalized.contains("tin") || normalized.contains("cong nghe")) return "it";
        return "other";
    }

    private String courseGradientForSubject(String subjectCode) {
        if ("math".equals(subjectCode)) return "linear-gradient(135deg,#3b82f6 0%,#6366f1 100%)";
        if ("english".equals(subjectCode)) return "linear-gradient(135deg,#0f766e 0%,#14b8a6 50%,#7c3aed 100%)";
        if ("physics".equals(subjectCode)) return "linear-gradient(135deg,#0ea5e9 0%,#8b5cf6 100%)";
        if ("chemistry".equals(subjectCode)) return "linear-gradient(135deg,#f59e0b 0%,#ef4444 100%)";
        if ("literature".equals(subjectCode)) return "linear-gradient(135deg,#ec4899 0%,#f97316 100%)";
        if ("biology".equals(subjectCode)) return "linear-gradient(135deg,#16a34a 0%,#84cc16 100%)";
        if ("history".equals(subjectCode)) return "linear-gradient(135deg,#92400e 0%,#f59e0b 100%)";
        if ("it".equals(subjectCode)) return "linear-gradient(135deg,#111827 0%,#2563eb 100%)";
        return "linear-gradient(135deg,#475569 0%,#14b8a6 100%)";
    }

    private Time parseTimeParam(String value) {
        String cleaned = cleanParam(value);
        if (!cleaned.matches("^(([01]\\d|2[0-3]):[0-5]\\d|24:00)$")) {
            return null;
        }
        try {
            if ("24:00".equals(cleaned)) {
                return Time.valueOf("23:59:59");
            }
            return Time.valueOf(cleaned + ":00");
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private boolean isValidClassroom(Classroom classroom) {
        return classroom != null
                && !classroom.getTitle().isEmpty()
                && !classroom.getSubject().isEmpty()
                && !classroom.getScheduleDays().isEmpty()
                && classroom.getStartTime() != null
                && classroom.getEndTime() != null
                && classroom.getEndTime().after(classroom.getStartTime());
    }

    private boolean canManageClassrooms(User user, TeacherApplication application) {
        return hasRole(user, "teacher")
                && application != null
                && "approved".equals(application.getStatus());
    }

    private boolean isApprovedSubject(TeacherApplication application, String selectedSubject) {
        if (application == null || selectedSubject == null || selectedSubject.trim().isEmpty()
                || application.getTeachingSubjects() == null) {
            return false;
        }
        String selected = selectedSubject.trim();
        for (String subject : application.getTeachingSubjects().split("\\s*,\\s*")) {
            if (selected.equalsIgnoreCase(subject.trim())) {
                return true;
            }
        }
        return false;
    }

    private String valueOrEmpty(String value) {
        return value == null || value.trim().isEmpty() ? "Chưa cung cấp" : value.trim();
    }

    private String teacherTypeLabel(String teacherType) {
        if ("student_tutor".equals(teacherType)) {
            return "Gia sư sinh viên";
        }
        if ("certified_pedagogy".equals(teacherType)) {
            return "Giảng viên có chứng chỉ sư phạm";
        }
        if ("degree_specialist".equals(teacherType)) {
            return "Giảng viên chuyên môn";
        }
        return "Chưa phân loại";
    }

    private String studyYearLabel(String studyYear) {
        if ("year_1".equals(studyYear)) return "Năm 1";
        if ("year_2".equals(studyYear)) return "Năm 2";
        if ("year_3".equals(studyYear)) return "Năm 3";
        if ("year_4".equals(studyYear)) return "Năm 4";
        if ("year_5_plus".equals(studyYear)) return "Năm 5 trở lên";
        if ("graduated".equals(studyYear)) return "Đã tốt nghiệp";
        return "Không áp dụng";
    }

    private String saveTeachingEvidenceFiles(HttpServletRequest request, User user)
            throws IOException, ServletException {
        String uploadPath = request.getServletContext().getRealPath("/uploads/teacher-evidence");
        if (uploadPath == null) {
            throw new IOException("Không thể xác định thư mục tải lên minh chứng.");
        }
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        StringBuilder evidenceSummary = new StringBuilder();
        int savedCount = 0;
        for (Part part : request.getParts()) {
            if (!"evidenceFiles".equals(part.getName()) || part.getSize() <= 0) {
                continue;
            }

            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.trim().isEmpty()) {
                continue;
            }

            String safeOriginalName = submittedName.replaceAll("[^a-zA-Z0-9._-]", "_");
            String safeFileName = "teacher_evidence_" + user.getId() + "_" + System.currentTimeMillis() + "_" + savedCount + "_" + safeOriginalName;
            part.write(uploadPath + File.separator + safeFileName);

            evidenceSummary.append("- ")
                    .append(submittedName)
                    .append(" (")
                    .append(part.getSize())
                    .append(" bytes): ")
                    .append(request.getContextPath())
                    .append("/uploads/teacher-evidence/")
                    .append(safeFileName)
                    .append("\n");
            savedCount++;
        }

        return savedCount > 0 ? evidenceSummary.toString() : "Chưa đính kèm minh chứng.";
    }

    private boolean hasRole(User user, String roleName) {
        if (user == null || user.getRoles() == null || roleName == null) {
            return false;
        }
        for (com.hipzi.model.Role role : user.getRoles()) {
            if (role != null && roleName.equalsIgnoreCase(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private int parsePositiveInt(String value, int fallback) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : fallback;
        } catch (Exception e) {
            return fallback;
        }
    }

    private String generateClassCode() {
        return java.util.UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }
}
