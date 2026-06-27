package com.hipzi.model;

public class CourseAccessGrantJob {
    private String grantId;
    private String enrollmentId;
    private String courseId;
    private String courseTitle;
    private String teacherId;
    private String studentId;
    private String studentEmail;
    private String googleDriveFileId;
    private String googleDriveFolderId;
    private boolean requireDriveGrant;

    public String getGrantId() { return grantId; }
    public void setGrantId(String grantId) { this.grantId = grantId; }

    public String getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(String enrollmentId) { this.enrollmentId = enrollmentId; }

    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getTeacherId() { return teacherId; }
    public void setTeacherId(String teacherId) { this.teacherId = teacherId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getGoogleDriveFileId() { return googleDriveFileId; }
    public void setGoogleDriveFileId(String googleDriveFileId) { this.googleDriveFileId = googleDriveFileId; }

    public String getGoogleDriveFolderId() { return googleDriveFolderId; }
    public void setGoogleDriveFolderId(String googleDriveFolderId) { this.googleDriveFolderId = googleDriveFolderId; }

    public boolean isRequireDriveGrant() { return requireDriveGrant; }
    public void setRequireDriveGrant(boolean requireDriveGrant) { this.requireDriveGrant = requireDriveGrant; }

    public String getDriveResourceId() {
        if (googleDriveFolderId != null && !googleDriveFolderId.trim().isEmpty()) {
            return googleDriveFolderId.trim();
        }
        return googleDriveFileId == null ? "" : googleDriveFileId.trim();
    }
}
