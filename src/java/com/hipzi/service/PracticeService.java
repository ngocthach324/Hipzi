package com.hipzi.service;

import com.hipzi.model.Quiz;
import java.util.ArrayList;
import java.util.List;

public class PracticeService {

    public List<Quiz> getRecentQuizzes() {
        List<Quiz> quizzes = new ArrayList<>();
        quizzes.add(new Quiz("1", "Trắc nghiệm Tổng ôn Toán 12", "Toán", 50, "Trung bình", 3420));
        quizzes.add(new Quiz("2", "Kiểm tra 15p Dao động cơ", "Lý", 15, "Khó", 1250));
        quizzes.add(new Quiz("3", "Từ vựng IELTS Unit 1-5", "Anh", 100, "Dễ", 8900));
        quizzes.add(new Quiz("4", "Trắc nghiệm Hóa Hữu Cơ", "Hóa", 40, "Trung bình", 2100));
        return quizzes;
    }
}
