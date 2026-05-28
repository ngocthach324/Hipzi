package com.hipzi.controller;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.model.Classroom;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "ClassroomServlet", urlPatterns = {"/classes"})
public class ClassroomServlet extends HttpServlet {

    private final ClassroomDao classroomDao = new ClassroomDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String subjectParam = request.getParameter("subject");
        String gradeParam = request.getParameter("grade");
        String searchParam = request.getParameter("q");

        List<Classroom> filteredClasses = classroomDao.listPublic(subjectParam, gradeParam, searchParam);
        if (filteredClasses == null) {
            filteredClasses = filterSampleClasses(subjectParam, gradeParam, searchParam);
        }

        request.setAttribute("classrooms", filteredClasses);

        // Nếu là AJAX request (từ bộ lọc sidebar), chỉ trả về fragment kết quả
        String ajaxParam = request.getParameter("ajax");
        if ("1".equals(ajaxParam)) {
            request.getRequestDispatcher("/WEB-INF/fragments/classes-results.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/classes.jsp").forward(request, response);
    }

    private List<Classroom> filterSampleClasses(String subjectParam, String gradeParam, String searchParam) {
        List<Classroom> allClasses = new ArrayList<>();
        allClasses.add(new Classroom("CLS001", "Luyện thi THPTQG Toán học 12 Bứt phá 9+", "Toán", "Lớp 12", "TS. Trần Minh Tuấn", "ĐH Sư phạm Hà Nội", 1250, "Đang mở", "Tối T3, T5 (19:30 - 21:00)"));
        allClasses.add(new Classroom("CLS002", "Luyện đề Thực chiến Vật Lý 12 - Chuẩn cấu trúc Bộ", "Lý", "Lớp 12", "ThS. Nguyễn Văn An", "THPT Chuyên KHTN", 890, "Đang mở", "Tối T2, T4 (20:00 - 21:30)"));
        allClasses.add(new Classroom("CLS003", "Lấy gốc Tiếng Anh 11 - Từ vựng & Ngữ pháp toàn diện", "Anh", "Lớp 11", "Cô Phạm Thu Hà", "THPT Chuyên Lê Hồng Phong", 1540, "Sắp khai giảng", "Tối T6, CN (19:30 - 21:00)"));
        allClasses.add(new Classroom("CLS004", "Tổng ôn Hóa học Hữu cơ 11 chuyên sâu", "Hóa", "Lớp 11", "Thầy Lê Hoàng Long", "THPT Chuyên Lam Sơn", 620, "Đang mở", "Tối T3, T7 (20:00 - 21:30)"));
        allClasses.add(new Classroom("CLS005", "Đại số & Hình học 10 - Nền tảng vững chắc", "Toán", "Lớp 10", "Cô Nguyễn Mai Lan", "THPT Chu Văn An", 1100, "Đang mở", "Tối T4, CN (18:00 - 19:30)"));
        allClasses.add(new Classroom("CLS006", "Cảm thụ Ngữ Văn 12 - Viết bài nghị luận chuyên sâu", "Văn", "Lớp 12", "Cô Hoàng Vĩnh Lộc", "THPT Chuyên Quốc Học Huế", 940, "Đang mở", "Tối T2, T6 (19:30 - 21:00)"));
        allClasses.add(new Classroom("CLS007", "Chinh phục Di truyền học - Sinh học 12", "Sinh Học", "Lớp 12", "Thầy Đỗ Văn Hùng", "ĐH Khoa học Tự nhiên", 450, "Sắp khai giảng", "Tối T5, T7 (18:00 - 19:30)"));
        allClasses.add(new Classroom("CLS008", "Lập trình Python cơ bản đến nâng cao - Tin học 10", "Tin Học", "Lớp 10", "Thầy Phạm Quang Huy", "ĐH Bách Khoa", 780, "Đang mở", "Chiều T7, CN (14:30 - 16:00)"));

        return allClasses.stream()
                .filter(c -> {
                    boolean matchSubject = (subjectParam == null || subjectParam.isEmpty() || subjectParam.equalsIgnoreCase("Tất cả"))
                            || c.getSubject().equalsIgnoreCase(subjectParam);
                    boolean matchGrade = (gradeParam == null || gradeParam.isEmpty() || gradeParam.equalsIgnoreCase("Tất cả"))
                            || c.getGrade().equalsIgnoreCase(gradeParam);
                    boolean matchSearch = (searchParam == null || searchParam.trim().isEmpty())
                            || c.getTitle().toLowerCase().contains(searchParam.trim().toLowerCase())
                            || c.getSubject().toLowerCase().contains(searchParam.trim().toLowerCase())
                            || c.getTeacherName().toLowerCase().contains(searchParam.trim().toLowerCase());
                    return matchSubject && matchGrade && matchSearch;
                })
                .collect(Collectors.toList());
    }
}
