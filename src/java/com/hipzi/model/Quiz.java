package com.hipzi.model;

public class Quiz {
    private String id;
    private String title;
    private String subject;
    private String grade;
    private String type;
    private String teacherName;
    private String examCategory;
    private String examStatus;
    private String accessDescription;
    private int questionCount;
    private String difficulty; // Easy, Medium, Hard
    private int attemptCount;

    public Quiz() {
    }

    public Quiz(String id, String title, String subject, int questionCount, String difficulty, int attemptCount) {
        this(id, title, subject, "", "Quizlet", "", "", "open", "", questionCount, difficulty, attemptCount);
    }

    public Quiz(String id, String title, String subject, String grade, String type, String teacherName, int questionCount, String difficulty, int attemptCount) {
        this(id, title, subject, grade, type, teacherName, "", "open", "", questionCount, difficulty, attemptCount);
    }

    public Quiz(String id, String title, String subject, String grade, String type, String teacherName,
                String examCategory, String examStatus, String accessDescription,
                int questionCount, String difficulty, int attemptCount) {
        this.id = id;
        this.title = title;
        this.subject = subject;
        this.grade = grade;
        this.type = type;
        this.teacherName = teacherName;
        this.examCategory = examCategory;
        this.examStatus = examStatus;
        this.accessDescription = accessDescription;
        this.questionCount = questionCount;
        this.difficulty = difficulty;
        this.attemptCount = attemptCount;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getExamCategory() { return examCategory; }
    public void setExamCategory(String examCategory) { this.examCategory = examCategory; }

    public String getExamStatus() { return examStatus; }
    public void setExamStatus(String examStatus) { this.examStatus = examStatus; }

    public String getAccessDescription() { return accessDescription; }
    public void setAccessDescription(String accessDescription) { this.accessDescription = accessDescription; }

    public String getExamCategoryLabel() {
        if ("mock_exam".equals(examCategory)) return "Thi thử";
        if ("class_exam".equals(examCategory)) return "Bài thi lớp học";
        if ("hipzi_contest".equals(examCategory)) return "Kỳ thi HIPZI";
        return "";
    }

    public String getExamStatusLabel() {
        if ("upcoming".equals(examStatus)) return "Sắp diễn ra";
        if ("open".equals(examStatus)) return "Đang mở";
        if ("closed".equals(examStatus)) return "Đã đóng";
        if ("grading".equals(examStatus)) return "Đang chấm";
        if ("published".equals(examStatus)) return "Đã công bố kết quả";
        return "";
    }
    
    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
    
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    
    public int getAttemptCount() { return attemptCount; }
    public void setAttemptCount(int attemptCount) { this.attemptCount = attemptCount; }
}
