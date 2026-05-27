package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.ClassroomEnrollmentDao;
import com.hipzi.dao.ClassroomModuleDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.ClassroomEnrollment;
import com.hipzi.model.ClassroomModule;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ClassDetailServlet", urlPatterns = {"/class-detail"})
public class ClassDetailServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();
    private final ClassroomEnrollmentDao classroomEnrollmentDao = new ClassroomEnrollmentDao();
    private final ClassroomModuleDao classroomModuleDao = new ClassroomModuleDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String classId = request.getParameter("id");
        Classroom classroom = null;

        if (classId != null && !classId.trim().isEmpty()) {
            classroom = classroomDao.findById(classId.trim());
            if (classroom == null) {
                classroom = findSampleClassroom(classId.trim());
            }
        }

        if (classroom == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lớp học.");
            return;
        }

        boolean canEditClassModules = canEditClassModules(request, classroom);
        ClassroomEnrollment joinRequest = loadCurrentJoinRequest(request, classroom);
        if (canEditClassModules) {
            seedDefaultModulesIfNeeded(classroom, "learning_content");
            seedDefaultModulesIfNeeded(classroom, "entry_requirement");
        }

        request.setAttribute("classroom", classroom);
        request.setAttribute("joinRequest", joinRequest);
        request.setAttribute("learningModules", loadModules(classroom, "learning_content"));
        request.setAttribute("requirementModules", loadModules(classroom, "entry_requirement"));
        request.setAttribute("canEditClassModules", canEditClassModules);
        request.getRequestDispatcher("/class-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = cleanParam(request.getParameter("action"));
        String classId = cleanParam(request.getParameter("classId"));

        Classroom classroom = !classId.isEmpty() ? classroomDao.findById(classId) : null;
        if (classroom == null && !classId.isEmpty()) {
            classroom = findSampleClassroom(classId);
        }
        if (classroom == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lớp học.");
            return;
        }

        HttpSession session = request.getSession(false);
        if ("requestJoin".equals(action)) {
            handleJoinRequest(request, response, session, classroom, classId);
            return;
        }

        if (!canEditClassModules(request, classroom)) {
            if (session != null) {
                session.setAttribute("toastMsg", "Chỉ giảng viên sở hữu lớp học mới có thể chỉnh sửa nội dung lớp.");
                session.setAttribute("toastType", "error");
            }
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        String moduleType = normalizeModuleType(request.getParameter("moduleType"));
        String moduleTitle = cleanParam(request.getParameter("moduleTitle"));
        String moduleDescription = cleanParam(request.getParameter("moduleDescription"));
        int sortOrder = parsePositiveInt(request.getParameter("sortOrder"), 1);

        if (moduleTitle.isEmpty() || moduleDescription.isEmpty()) {
            if (session != null) {
                session.setAttribute("toastMsg", "Vui lòng nhập đầy đủ tiêu đề và mô tả module.");
                session.setAttribute("toastType", "error");
            }
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        ClassroomModule module = new ClassroomModule();
        module.setClassroomId(classId);
        module.setModuleType(moduleType);
        module.setTitle(moduleTitle);
        module.setDescription(moduleDescription);
        module.setSortOrder(sortOrder);

        boolean saved = false;
        if ("addModule".equals(action)) {
            saved = classroomModuleDao.create(module);
        } else if ("updateModule".equals(action)) {
            String moduleId = cleanParam(request.getParameter("moduleId"));
            module.setId(moduleId);
            saved = !moduleId.isEmpty() && classroomModuleDao.updateForClassroom(module);
        }

        if (session != null) {
            session.setAttribute("toastMsg", saved ? "Đã lưu nội dung lớp học." : "Không thể lưu module. Vui lòng kiểm tra lại dữ liệu.");
            session.setAttribute("toastType", saved ? "success" : "error");
        }
        response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
    }

    private void handleJoinRequest(HttpServletRequest request, HttpServletResponse response, HttpSession session,
            Classroom classroom, String classId) throws IOException {
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("loggedUser");
        if (!hasRole(user, "student")) {
            session.setAttribute("toastMsg", "Chỉ học viên mới có thể gửi yêu cầu tham gia lớp.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        if ("closed".equals(classroom.getStatus())) {
            session.setAttribute("toastMsg", "Lớp học này đã đóng nên chưa thể nhận thêm học viên.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        if (!isUuid(classId)) {
            session.setAttribute("toastMsg", "Lớp mẫu chỉ dùng để xem trước, chưa thể gửi yêu cầu tham gia.");
            session.setAttribute("toastType", "error");
            response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
            return;
        }

        boolean saved = classroomEnrollmentDao.requestJoin(classId, user.getId());
        session.setAttribute("toastMsg", saved
                ? "Đã xin vào lớp, vui lòng đợi giảng viên chấp nhận."
                : "Chưa gửi được yêu cầu tham gia lớp. Vui lòng thử lại.");
        session.setAttribute("toastType", saved ? "success" : "error");
        response.sendRedirect(request.getContextPath() + "/class-detail?id=" + classId);
    }

    private List<ClassroomModule> loadModules(Classroom classroom, String moduleType) {
        if (classroom != null && classroom.getId() != null && isUuid(classroom.getId())) {
            List<ClassroomModule> modules = classroomModuleDao.findByClassroomId(classroom.getId(), moduleType);
            if (!modules.isEmpty()) {
                return modules;
            }
        }
        return defaultModules(moduleType);
    }

    private void seedDefaultModulesIfNeeded(Classroom classroom, String moduleType) {
        if (classroom == null || classroom.getId() == null || !isUuid(classroom.getId())) {
            return;
        }
        List<ClassroomModule> existingModules = classroomModuleDao.findByClassroomId(classroom.getId(), moduleType);
        if (!existingModules.isEmpty()) {
            return;
        }
        for (ClassroomModule module : defaultModules(moduleType)) {
            module.setClassroomId(classroom.getId());
            classroomModuleDao.create(module);
        }
    }

    private List<ClassroomModule> defaultModules(String moduleType) {
        List<ClassroomModule> modules = new ArrayList<>();
        if ("entry_requirement".equals(moduleType)) {
            modules.add(defaultModule(moduleType, 1, "Chuẩn bị thiết bị học tập", "Học viên nên có thiết bị học trực tuyến ổn định, vở ghi và tinh thần hoàn thành bài luyện sau mỗi buổi."));
            modules.add(defaultModule(moduleType, 2, "Nền tảng kiến thức", "Nếu chưa chắc kiến thức nền, giảng viên sẽ hướng dẫn lộ trình bổ sung trong các buổi đầu."));
        } else {
            modules.add(defaultModule(moduleType, 1, "Khởi động và đánh giá đầu vào", "Ôn lại kiến thức nền, xác định mục tiêu học tập và phân nhóm bài luyện phù hợp với trình độ hiện tại."));
            modules.add(defaultModule(moduleType, 2, "Học trọng tâm theo chuyên đề", "Mỗi buổi học đi vào một nhóm kiến thức chính, có ví dụ mẫu, bài tập vận dụng và phần chữa lỗi thường gặp."));
            modules.add(defaultModule(moduleType, 3, "Luyện tập sau buổi học", "Học viên nhận tài liệu, câu hỏi luyện tập và gợi ý tự học để củng cố nội dung vừa học."));
            modules.add(defaultModule(moduleType, 4, "Theo dõi tiến độ", "Kết quả học tập được tổng hợp theo từng giai đoạn để học viên và phụ huynh dễ nắm tiến trình."));
        }
        return modules;
    }

    private ClassroomModule defaultModule(String moduleType, int sortOrder, String title, String description) {
        ClassroomModule module = new ClassroomModule();
        module.setModuleType(moduleType);
        module.setSortOrder(sortOrder);
        module.setTitle(title);
        module.setDescription(description);
        return module;
    }

    private boolean canEditClassModules(HttpServletRequest request, Classroom classroom) {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        return user != null
                && classroom != null
                && classroom.getTeacherId() != null
                && classroom.getTeacherId().equals(user.getId())
                && hasRole(user, "teacher");
    }

    private ClassroomEnrollment loadCurrentJoinRequest(HttpServletRequest request, Classroom classroom) {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("loggedUser") : null;
        if (user == null || classroom == null || classroom.getId() == null || !isUuid(classroom.getId())) {
            return null;
        }
        return classroomEnrollmentDao.findByClassroomAndStudent(classroom.getId(), user.getId());
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

    private String normalizeModuleType(String value) {
        return "entry_requirement".equals(value) ? "entry_requirement" : "learning_content";
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }

    private int parsePositiveInt(String value, int fallback) {
        try {
            int parsed = Integer.parseInt(cleanParam(value));
            return parsed > 0 ? parsed : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private boolean isUuid(String value) {
        return value != null && value.matches("(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$");
    }

    private Classroom findSampleClassroom(String classId) {
        for (Classroom classroom : sampleClassrooms()) {
            if (classroom.getId().equalsIgnoreCase(classId)) {
                return classroom;
            }
        }
        return null;
    }

    private List<Classroom> sampleClassrooms() {
        List<Classroom> classes = new ArrayList<>();
        classes.add(new Classroom("CLS001", "Luyện thi THPTQG Toán học 12 Bứt phá 9+", "Toán", "Lớp 12", "TS. Trần Minh Tuấn", "ĐH Sư phạm Hà Nội", 1250, "Đang mở", "Tối T3, T5 (19:30 - 21:00)"));
        classes.add(new Classroom("CLS002", "Luyện đề Thực chiến Vật Lý 12 - Chuẩn cấu trúc Bộ", "Lý", "Lớp 12", "ThS. Nguyễn Văn An", "THPT Chuyên KHTN", 890, "Đang mở", "Tối T2, T4 (20:00 - 21:30)"));
        classes.add(new Classroom("CLS003", "Lấy gốc Tiếng Anh 11 - Từ vựng & Ngữ pháp toàn diện", "Anh", "Lớp 11", "Cô Phạm Thu Hà", "THPT Chuyên Lê Hồng Phong", 1540, "Sắp khai giảng", "Tối T6, CN (19:30 - 21:00)"));
        classes.add(new Classroom("CLS004", "Tổng ôn Hóa học Hữu cơ 11 chuyên sâu", "Hóa", "Lớp 11", "Thầy Lê Hoàng Long", "THPT Chuyên Lam Sơn", 620, "Đang mở", "Tối T3, T7 (20:00 - 21:30)"));
        classes.add(new Classroom("CLS005", "Đại số & Hình học 10 - Nền tảng vững chắc", "Toán", "Lớp 10", "Cô Nguyễn Mai Lan", "THPT Chu Văn An", 1100, "Đang mở", "Tối T4, CN (18:00 - 19:30)"));
        classes.add(new Classroom("CLS006", "Cảm thụ Ngữ Văn 12 - Viết bài nghị luận chuyên sâu", "Văn", "Lớp 12", "Cô Hoàng Vĩnh Lộc", "THPT Chuyên Quốc Học Huế", 940, "Đang mở", "Tối T2, T6 (19:30 - 21:00)"));
        classes.add(new Classroom("CLS007", "Chinh phục Di truyền học - Sinh học 12", "Sinh Học", "Lớp 12", "Thầy Đỗ Văn Hùng", "ĐH Khoa học Tự nhiên", 450, "Sắp khai giảng", "Tối T5, T7 (18:00 - 19:30)"));
        classes.add(new Classroom("CLS008", "Lập trình Python cơ bản đến nâng cao - Tin học 10", "Tin Học", "Lớp 10", "Thầy Phạm Quang Huy", "ĐH Bách Khoa", 780, "Đang mở", "Chiều T7, CN (14:30 - 16:00)"));
        return classes;
    }
}
