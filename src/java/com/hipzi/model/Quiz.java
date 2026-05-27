package com.hipzi.model;

public class Quiz {
    private String id;
    private String title;
    private String subject;
    private int questionCount;
    private String difficulty; // Easy, Medium, Hard
    private int attemptCount;

    public Quiz() {
    }

    public Quiz(String id, String title, String subject, int questionCount, String difficulty, int attemptCount) {
        this.id = id;
        this.title = title;
        this.subject = subject;
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
    
    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
    
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    
    public int getAttemptCount() { return attemptCount; }
    public void setAttemptCount(int attemptCount) { this.attemptCount = attemptCount; }
}
