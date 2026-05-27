package com.hipzi.service;

import com.hipzi.model.TeacherProfile;
import java.util.ArrayList;
import java.util.List;

public class TeacherService {

    public List<TeacherProfile> getProminentTeachers() {
        List<TeacherProfile> teachers = new ArrayList<>();
        teachers.add(new TeacherProfile("1", "ThS. Trần Minh Tuấn", "Toán", "THPT Chuyên Lê Quý Đôn", 4.9, 45));
        teachers.add(new TeacherProfile("2", "Cô Ngọc Quyên", "Văn", "ĐH Sư Phạm", 4.8, 30));
        teachers.add(new TeacherProfile("3", "Thầy Alex Nguyễn", "Anh", "IELTS 8.5", 5.0, 120));
        teachers.add(new TeacherProfile("4", "Cô Phương Trinh", "Lý", "THPT Phan Châu Trinh", 4.7, 25));
        return teachers;
    }
}
