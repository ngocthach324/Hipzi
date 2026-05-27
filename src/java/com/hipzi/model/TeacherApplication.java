package com.hipzi.model;

import java.sql.Timestamp;

public class TeacherApplication {
    private String id;
    private String userId;
    private String teacherType;
    private String status;
    private String institutionName;
    private String specialization;
    private String currentStudyYear;
    private String teachingSubjects;
    private String teachingExperience;
    private String workplace;
    private String credentialsSummary;
    private String teacherBio;
    private String evidenceSummary;
    private String applicantName;
    private String applicantEmail;
    private String applicantAvatarUrl;
    private String reviewNote;
    private Timestamp submittedAt;
    private Timestamp updatedAt;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getTeacherType() { return teacherType; }
    public void setTeacherType(String teacherType) { this.teacherType = teacherType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getInstitutionName() { return institutionName; }
    public void setInstitutionName(String institutionName) { this.institutionName = institutionName; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getCurrentStudyYear() { return currentStudyYear; }
    public void setCurrentStudyYear(String currentStudyYear) { this.currentStudyYear = currentStudyYear; }

    public String getTeachingSubjects() { return teachingSubjects; }
    public void setTeachingSubjects(String teachingSubjects) { this.teachingSubjects = teachingSubjects; }

    public String getTeachingExperience() { return teachingExperience; }
    public void setTeachingExperience(String teachingExperience) { this.teachingExperience = teachingExperience; }

    public String getWorkplace() { return workplace; }
    public void setWorkplace(String workplace) { this.workplace = workplace; }

    public String getCredentialsSummary() { return credentialsSummary; }
    public void setCredentialsSummary(String credentialsSummary) { this.credentialsSummary = credentialsSummary; }

    public String getTeacherBio() { return teacherBio; }
    public void setTeacherBio(String teacherBio) { this.teacherBio = teacherBio; }

    public String getEvidenceSummary() { return evidenceSummary; }
    public void setEvidenceSummary(String evidenceSummary) { this.evidenceSummary = evidenceSummary; }

    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }

    public String getApplicantEmail() { return applicantEmail; }
    public void setApplicantEmail(String applicantEmail) { this.applicantEmail = applicantEmail; }

    public String getApplicantAvatarUrl() { return applicantAvatarUrl; }
    public void setApplicantAvatarUrl(String applicantAvatarUrl) { this.applicantAvatarUrl = applicantAvatarUrl; }

    public String getReviewNote() { return reviewNote; }
    public void setReviewNote(String reviewNote) { this.reviewNote = reviewNote; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
