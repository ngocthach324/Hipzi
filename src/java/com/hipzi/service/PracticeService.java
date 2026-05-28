package com.hipzi.service;

import com.hipzi.model.Quiz;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public class PracticeService {

    public List<Quiz> getRecentQuizzes() {
        List<Quiz> quizzes = new ArrayList<>();
        quizzes.add(new Quiz("PR001", "Quizlet Tổng ôn Toán 12", "Toán", "Lớp 12", "Quizlet", "TS. Trần Minh Tuấn", 50, "Trung bình", 3420));
        quizzes.add(new Quiz("PR002", "Flashcard Từ vựng IELTS Unit 1-5", "Anh", "Lớp 11", "Flashcard", "Cô Phạm Thu Hà", 100, "Dễ", 8900));
        quizzes.add(new Quiz("PR003", "Quizlet Hóa Hữu Cơ", "Hóa", "Lớp 11", "Quizlet", "Thầy Lê Hoàng Long", 40, "Trung bình", 2100));
        quizzes.add(new Quiz("PR004", "Flashcard Java Servlet cơ bản", "Tin Học", "Lớp 12", "Flashcard", "Thầy Phạm Quang Huy", 72, "Trung bình", 1350));
        return quizzes;
    }

    public List<Quiz> getFilteredQuizzes(String subject, String grade, String type, String searchQuery) {
        String normalizedSubject = normalize(subject);
        String normalizedGrade = normalize(grade);
        String normalizedType = normalize(type);
        String keyword = searchQuery == null ? "" : searchQuery.trim().toLowerCase(Locale.ROOT);

        return getRecentQuizzes().stream()
                .filter(quiz -> isAll(normalizedSubject) || normalize(quiz.getSubject()).equalsIgnoreCase(normalizedSubject))
                .filter(quiz -> isAll(normalizedGrade) || normalize(quiz.getGrade()).equalsIgnoreCase(normalizedGrade))
                .filter(quiz -> isAll(normalizedType) || normalize(quiz.getType()).equalsIgnoreCase(normalizedType))
                .filter(quiz -> keyword.isEmpty()
                        || contains(quiz.getTitle(), keyword)
                        || contains(quiz.getSubject(), keyword)
                        || contains(quiz.getTeacherName(), keyword))
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
