package com.hipzi.model;

public class TeacherProfile {
    private String id;
    private String name;
    private String subject;
    private String school;
    private double rating;
    private int materialCount;

    public TeacherProfile() {
    }

    public TeacherProfile(String id, String name, String subject, String school, double rating, int materialCount) {
        this.id = id;
        this.name = name;
        this.subject = subject;
        this.school = school;
        this.rating = rating;
        this.materialCount = materialCount;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getSchool() { return school; }
    public void setSchool(String school) { this.school = school; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getMaterialCount() { return materialCount; }
    public void setMaterialCount(int materialCount) { this.materialCount = materialCount; }
}
