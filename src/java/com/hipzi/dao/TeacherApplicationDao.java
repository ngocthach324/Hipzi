package com.hipzi.dao;

import com.hipzi.model.TeacherApplication;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TeacherApplicationDao {

    public TeacherApplication findLatestByUserId(String userId) {
        String sql = "SELECT * FROM teacher_applications WHERE user_id = ?::uuid ORDER BY submitted_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.findLatestByUserId: " + e.getMessage());
        }
        return null;
    }

    public boolean upsertApplication(TeacherApplication application) {
        String sql = "INSERT INTO teacher_applications "
                + "(user_id, teacher_type, status, institution_name, specialization, current_study_year, "
                + "teaching_subjects, teaching_experience, workplace, credentials_summary, teacher_bio, evidence_summary) "
                + "VALUES (?::uuid, ?, 'pending', ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON CONFLICT (user_id) DO UPDATE SET "
                + "teacher_type = EXCLUDED.teacher_type, "
                + "status = 'pending', "
                + "institution_name = EXCLUDED.institution_name, "
                + "specialization = EXCLUDED.specialization, "
                + "current_study_year = EXCLUDED.current_study_year, "
                + "teaching_subjects = EXCLUDED.teaching_subjects, "
                + "teaching_experience = EXCLUDED.teaching_experience, "
                + "workplace = EXCLUDED.workplace, "
                + "credentials_summary = EXCLUDED.credentials_summary, "
                + "teacher_bio = EXCLUDED.teacher_bio, "
                + "evidence_summary = EXCLUDED.evidence_summary, "
                + "submitted_at = NOW(), "
                + "updated_at = NOW()";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, application.getUserId());
            ps.setString(2, application.getTeacherType());
            ps.setString(3, application.getInstitutionName());
            ps.setString(4, application.getSpecialization());
            ps.setString(5, application.getCurrentStudyYear());
            ps.setString(6, application.getTeachingSubjects());
            ps.setString(7, application.getTeachingExperience());
            ps.setString(8, application.getWorkplace());
            ps.setString(9, application.getCredentialsSummary());
            ps.setString(10, application.getTeacherBio());
            ps.setString(11, application.getEvidenceSummary());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.upsertApplication: " + e.getMessage());
        }
        return false;
    }

    public List<TeacherApplication> listForStaffReview() {
        String sql = "SELECT ta.*, u.display_name AS applicant_name, u.email AS applicant_email, u.avatar_url AS applicant_avatar_url "
                + "FROM teacher_applications ta "
                + "JOIN users u ON u.id = ta.user_id "
                + "WHERE ta.status = 'pending' "
                + "ORDER BY ta.submitted_at ASC";

        List<TeacherApplication> applications = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                applications.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.listForStaffReview: " + e.getMessage());
        }
        return applications;
    }

    public List<TeacherApplication> listApprovedTeachers(String searchQuery, String teacherTypeFilter) {
        return listApprovedTeachers(searchQuery, teacherTypeFilter, null);
    }

    public List<TeacherApplication> listApprovedTeachers(String searchQuery, String teacherTypeFilter, String subjectFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT ta.*, u.display_name AS applicant_name, u.email AS applicant_email, u.avatar_url AS applicant_avatar_url "
                + "FROM teacher_applications ta "
                + "JOIN users u ON u.id = ta.user_id "
                + "WHERE ta.status = 'approved' ");

        List<Object> params = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (u.display_name ILIKE ? OR ta.teaching_subjects ILIKE ? OR ta.institution_name ILIKE ? "
                    + "OR ta.specialization ILIKE ? OR ta.workplace ILIKE ? OR ta.teacher_bio ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
        }

        if (teacherTypeFilter != null && !teacherTypeFilter.trim().isEmpty() && !"ALL".equals(teacherTypeFilter)) {
            sql.append("AND ta.teacher_type = ? ");
            params.add(teacherTypeFilter.trim());
        }

        if (subjectFilter != null && !subjectFilter.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(subjectFilter.trim())) {
            sql.append("AND ta.teaching_subjects ILIKE ? ");
            params.add("%" + subjectFilter.trim() + "%");
        }

        sql.append("ORDER BY ta.updated_at DESC");

        List<TeacherApplication> applications = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    applications.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.listApprovedTeachers: " + e.getMessage());
        }
        return applications;
    }

    public TeacherApplication findApprovedTeacherById(String applicationId) {
        String sql = "SELECT ta.*, u.display_name AS applicant_name, u.email AS applicant_email, u.avatar_url AS applicant_avatar_url "
                + "FROM teacher_applications ta "
                + "JOIN users u ON u.id = ta.user_id "
                + "WHERE ta.id::text = ? AND ta.status = 'approved' "
                + "LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, applicationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.findApprovedTeacherById: " + e.getMessage());
        }
        return null;
    }

    public boolean updateStatus(String applicationId, String status, String reviewNote, String reviewerId) {
        String sql = "UPDATE teacher_applications "
                + "SET status = ?, review_note = ?, reviewed_by = ?::uuid, reviewed_at = NOW(), updated_at = NOW() "
                + "WHERE id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, reviewNote);
            ps.setString(3, reviewerId);
            ps.setString(4, applicationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeacherApplicationDao.updateStatus: " + e.getMessage());
        }
        return false;
    }

    private TeacherApplication mapRow(ResultSet rs) throws SQLException {
        TeacherApplication application = new TeacherApplication();
        application.setId(rs.getString("id"));
        application.setUserId(rs.getString("user_id"));
        application.setTeacherType(rs.getString("teacher_type"));
        application.setStatus(rs.getString("status"));
        application.setInstitutionName(rs.getString("institution_name"));
        application.setSpecialization(rs.getString("specialization"));
        application.setCurrentStudyYear(rs.getString("current_study_year"));
        application.setTeachingSubjects(rs.getString("teaching_subjects"));
        application.setTeachingExperience(rs.getString("teaching_experience"));
        application.setWorkplace(rs.getString("workplace"));
        application.setCredentialsSummary(rs.getString("credentials_summary"));
        application.setTeacherBio(rs.getString("teacher_bio"));
        application.setEvidenceSummary(rs.getString("evidence_summary"));
        application.setReviewNote(rs.getString("review_note"));
        try {
            application.setApplicantName(rs.getString("applicant_name"));
            application.setApplicantEmail(rs.getString("applicant_email"));
            application.setApplicantAvatarUrl(rs.getString("applicant_avatar_url"));
        } catch (SQLException ignored) {
            // Optional columns are only present in review joins.
        }
        application.setSubmittedAt(rs.getTimestamp("submitted_at"));
        application.setUpdatedAt(rs.getTimestamp("updated_at"));
        return application;
    }
}
