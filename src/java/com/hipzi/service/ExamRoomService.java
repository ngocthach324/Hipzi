package com.hipzi.service;

import com.hipzi.model.Quiz;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public class ExamRoomService {

    public List<Quiz> getExams() {
        List<Quiz> exams = new ArrayList<>();
        exams.add(new Quiz("EX001", "Thi thử Toán 10 học kỳ 1", "Toán", "Lớp 10", "Đề thi", "Cô Nguyễn Mai Lan",
                "mock_exam", "open", "Public cho học viên luyện tập", 35, "Trung bình", 980));
        exams.add(new Quiz("EX002", "Thi thử THPT Quốc gia môn Toán", "Toán", "Lớp 12", "Đề thi", "TS. Trần Minh Tuấn",
                "mock_exam", "open", "Có thể làm lại nhiều lần", 50, "Khó", 3420));
        exams.add(new Quiz("EX003", "Quiz sau buổi 1 - Lớp Toán 10 nền tảng", "Toán", "Lớp 10", "Đề thi", "Cô Nguyễn Mai Lan",
                "class_exam", "open", "Chỉ học viên trong lớp", 20, "Dễ", 320));
        exams.add(new Quiz("EX004", "Bài kiểm tra giữa lớp Java Web", "Tin Học", "Lớp 12", "Đề thi", "Thầy Phạm Quang Huy",
                "class_exam", "closed", "Gắn với lớp học cụ thể", 30, "Trung bình", 210));
        exams.add(new Quiz("EX005", "Kỳ thi HIPZI cuối tuần: Đại số cơ bản", "Toán", "Lớp 10", "Đề thi", "HIPZI",
                "hipzi_contest", "upcoming", "Học viên đủ điều kiện tham gia", 40, "Trung bình", 0));
        exams.add(new Quiz("EX006", "HIPZI Challenge: Java Servlet cơ bản", "Tin Học", "Lớp 12", "Đề thi", "HIPZI",
                "hipzi_contest", "published", "Có bảng xếp hạng và kết quả", 45, "Khó", 760));
        return exams;
    }

    public List<Quiz> getFilteredExams(String subject, String grade, String examCategory, String searchQuery) {
        String normalizedSubject = normalize(subject);
        String normalizedGrade = normalize(grade);
        String normalizedExamCategory = normalize(examCategory);
        String keyword = searchQuery == null ? "" : searchQuery.trim().toLowerCase(Locale.ROOT);

        return getExams().stream()
                .filter(exam -> isAll(normalizedSubject) || normalize(exam.getSubject()).equalsIgnoreCase(normalizedSubject))
                .filter(exam -> isAll(normalizedGrade) || normalize(exam.getGrade()).equalsIgnoreCase(normalizedGrade))
                .filter(exam -> isAll(normalizedExamCategory) || normalize(exam.getExamCategory()).equalsIgnoreCase(normalizedExamCategory))
                .filter(exam -> keyword.isEmpty()
                        || contains(exam.getTitle(), keyword)
                        || contains(exam.getSubject(), keyword)
                        || contains(exam.getTeacherName(), keyword)
                        || contains(exam.getExamCategoryLabel(), keyword))
                .collect(Collectors.toList());
    }

    private boolean isAll(String value) {
        return value.isEmpty() || "Tất cả".equalsIgnoreCase(value) || "ALL".equalsIgnoreCase(value);
    }

    private boolean contains(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
