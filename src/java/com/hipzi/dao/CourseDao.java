package com.hipzi.dao;

import com.hipzi.model.Course;
import com.hipzi.util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

public class CourseDao {
    private static volatile boolean schemaReady = false;

    public CourseDao() {
        ensureSchema();
    }

    public Course findById(String id, String viewerId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school, "
                + "(ce.id IS NOT NULL) AS viewer_enrolled, COALESCE(ce.progress_percent, 0) AS viewer_progress_percent "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "LEFT JOIN course_enrollments ce ON ce.course_id = c.id "
                + "AND ce.student_id = ?::uuid "
                + "AND ce.status IN ('pending_access', 'active') "
                + "WHERE c.id = ?::uuid AND c.deleted_at IS NULL";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, viewerId);
            ps.setString(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.findById: " + e.getMessage());
        }
        return null;
    }

    public List<Course> listPublic(String subjectCode, String priceFilter, String searchQuery, String sort, String viewerId, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school, "
                + "(ce.id IS NOT NULL) AS viewer_enrolled, COALESCE(ce.progress_percent, 0) AS viewer_progress_percent "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "LEFT JOIN course_enrollments ce ON ce.course_id = c.id "
                + "AND ce.student_id = ?::uuid "
                + "AND ce.status IN ('pending_access', 'active') "
                + "WHERE c.deleted_at IS NULL AND c.status = 'approved' AND c.visibility = 'public' ");

        List<Object> params = new ArrayList<>();
        params.add(uuidOrNull(viewerId));

        if (subjectCode != null && !subjectCode.trim().isEmpty() && !"all".equalsIgnoreCase(subjectCode.trim())) {
            sql.append("AND c.subject_code = ? ");
            params.add(subjectCode.trim());
        }
        if ("free".equalsIgnoreCase(priceFilter)) {
            sql.append("AND c.price_type = 'free' ");
        } else if ("paid".equalsIgnoreCase(priceFilter)) {
            sql.append("AND c.price_type = 'paid' ");
        } else if ("enrolled".equalsIgnoreCase(priceFilter)) {
            sql.append("AND ce.id IS NOT NULL ");
        }
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (c.title ILIKE ? OR c.short_description ILIKE ? OR c.subject_name ILIKE ? OR u.display_name ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
        }

        String sortValue = sort == null ? "" : sort.trim().toLowerCase(Locale.ROOT);
        if ("rating".equals(sortValue)) {
            sql.append("ORDER BY c.rating_average DESC, c.rating_count DESC, c.created_at DESC");
        } else if ("newest".equals(sortValue)) {
            sql.append("ORDER BY c.created_at DESC");
        } else if ("price-asc".equals(sortValue)) {
            sql.append("ORDER BY c.price_amount ASC, c.created_at DESC");
        } else if ("price-desc".equals(sortValue)) {
            sql.append("ORDER BY c.price_amount DESC, c.created_at DESC");
        } else {
            sql.append("ORDER BY c.students_count DESC, c.rating_average DESC, c.created_at DESC ");
        }

        sql.append("LIMIT ? OFFSET ?");

        List<Course> courses = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParams(ps, params);
            int offset = (page - 1) * pageSize;
            ps.setInt(params.size() + 1, pageSize);
            ps.setInt(params.size() + 2, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.listPublic: " + e.getMessage());
        }
        return courses;
    }

    public List<Course> listFeaturedPublic(int limit, String viewerId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school, "
                + "(ce.id IS NOT NULL) AS viewer_enrolled, COALESCE(ce.progress_percent, 0) AS viewer_progress_percent "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "LEFT JOIN course_enrollments ce ON ce.course_id = c.id "
                + "AND ce.student_id = ?::uuid "
                + "AND ce.status IN ('pending_access', 'active') "
                + "WHERE c.deleted_at IS NULL AND c.status = 'approved' AND c.visibility = 'public' "
                + "ORDER BY c.rating_average DESC, c.rating_count DESC, c.created_at DESC "
                + "LIMIT ?";

        List<Course> courses = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, uuidOrNull(viewerId));
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.listFeaturedPublic: " + e.getMessage());
        }
        return courses;
    }

    public List<Course> findByTeacherId(String teacherId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "WHERE c.teacher_id = ?::uuid AND c.deleted_at IS NULL "
                + "ORDER BY c.updated_at DESC";

        List<Course> courses = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.findByTeacherId: " + e.getMessage());
        }
        return courses;
    }

    public List<Course> findPurchasedByStudent(String studentId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM courses c "
                + "JOIN course_enrollments ce ON c.id = ce.course_id "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "WHERE ce.student_id = ?::uuid AND ce.status IN ('pending_access', 'active') AND c.deleted_at IS NULL "
                + "ORDER BY ce.created_at DESC";

        List<Course> courses = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.findPurchasedByStudent: " + e.getMessage());
        }
        return courses;
    }

    public List<Course> listForStaff(String titleFilter, String subjectFilter, String statusFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "WHERE c.deleted_at IS NULL ");

        List<Object> params = new ArrayList<>();
        if (titleFilter != null && !titleFilter.trim().isEmpty()) {
            sql.append("AND (c.title ILIKE ? OR u.display_name ILIKE ?) ");
            String keyword = "%" + titleFilter.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }
        if (subjectFilter != null && !subjectFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(subjectFilter.trim())) {
            sql.append("AND c.subject_code = ? ");
            params.add(subjectFilter.trim());
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND c.status = ? ");
            params.add(statusFilter.trim());
        }
        sql.append("ORDER BY CASE WHEN c.status = 'pending_review' THEN 0 WHEN c.status = 'needs_revision' THEN 1 ELSE 2 END, c.updated_at DESC");

        List<Course> courses = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.listForStaff: " + e.getMessage());
        }
        return courses;
    }

    public List<Course> listSubjects() {
        String sql = "SELECT DISTINCT subject_code, subject_name FROM courses WHERE deleted_at IS NULL AND status = 'approved' AND visibility = 'public' ORDER BY subject_name";
        Map<String, Course> subjects = defaultSubjectMap();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String code = rs.getString("subject_code");
                if (code == null || code.trim().isEmpty()) {
                    continue;
                }
                if ("other".equalsIgnoreCase(code.trim())) {
                    continue;
                }
                subjects.putIfAbsent(code, subjectOption(code, rs.getString("subject_name")));
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.listSubjects: " + e.getMessage());
        }
        return new ArrayList<>(subjects.values());
    }

    private Map<String, Course> defaultSubjectMap() {
        Map<String, Course> subjects = new LinkedHashMap<>();
        addSubject(subjects, "math", "Toán học");
        addSubject(subjects, "literature", "Ngữ văn");
        addSubject(subjects, "english", "Tiếng Anh");
        addSubject(subjects, "physics", "Vật lý");
        addSubject(subjects, "chemistry", "Hóa học");
        addSubject(subjects, "biology", "Sinh học");
        addSubject(subjects, "history", "Lịch sử");
        addSubject(subjects, "geography", "Địa lý");
        addSubject(subjects, "civics", "GDCD");
        addSubject(subjects, "it", "Tin học");
        addSubject(subjects, "technology", "Công nghệ");
        return subjects;
    }

    private void addSubject(Map<String, Course> subjects, String code, String name) {
        subjects.put(code, subjectOption(code, name));
    }

    private Course subjectOption(String code, String name) {
        Course course = new Course();
        course.setSubjectCode(code);
        course.setSubjectName(name == null || name.trim().isEmpty() ? code : name);
        return course;
    }

    public int countExistingCourses() {
        String sql = "SELECT COUNT(*) FROM courses WHERE deleted_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.countExistingCourses: " + e.getMessage());
        }
        return 0;
    }

    public boolean createForTeacher(Course course) {
        if (course.getCourseCode() == null || course.getCourseCode().trim().isEmpty()) {
            course.setCourseCode("CRS-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase(Locale.ROOT));
        }
        String sql = "INSERT INTO courses "
                + "(course_code, teacher_id, title, short_description, subject_code, subject_name, grade_level, level_name, "
                + "price_type, price_amount, currency, thumbnail_url, thumbnail_gradient, badge_text, lessons_count, estimated_hours, "
                + "google_drive_url, google_drive_file_id, google_drive_folder_id, drive_owner_email, access_instructions, "
                + "status, visibility, submitted_at, learning_objectives, curriculum_outline) "
                + "VALUES (?, ?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_review', 'private', NOW(), ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, course.getCourseCode());
            ps.setString(2, course.getTeacherId());
            ps.setString(3, course.getTitle());
            ps.setString(4, course.getShortDescription());
            ps.setString(5, course.getSubjectCode());
            ps.setString(6, course.getSubjectName());
            ps.setString(7, course.getGradeLevel());
            ps.setString(8, course.getLevelName());
            ps.setString(9, course.getPriceType());
            ps.setBigDecimal(10, valueOrZero(course.getPriceAmount()));
            ps.setString(11, course.getCurrency() != null ? course.getCurrency() : "VND");
            ps.setString(12, course.getThumbnailUrl());
            ps.setString(13, course.getThumbnailGradient());
            ps.setString(14, course.getBadgeText());
            ps.setInt(15, Math.max(0, course.getLessonsCount()));
            ps.setBigDecimal(16, valueOrZero(course.getEstimatedHours()));
            ps.setString(17, course.getGoogleDriveUrl());
            ps.setString(18, course.getGoogleDriveFileId());
            ps.setString(19, course.getGoogleDriveFolderId());
            ps.setString(20, course.getDriveOwnerEmail());
            ps.setString(21, course.getAccessInstructions());
            ps.setString(22, course.getLearningObjectives());
            ps.setString(23, course.getCurriculumOutline());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.createForTeacher: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean reviewCourse(String courseId, String decision, String reviewNote, String reviewerId) {
        String normalized = decision == null ? "" : decision.trim();
        if (!"approved".equals(normalized) && !"rejected".equals(normalized) && !"needs_revision".equals(normalized)) {
            return false;
        }
        String visibility = "approved".equals(normalized) ? "public" : "private";
        String sql = "UPDATE courses SET status = ?, visibility = ?, review_note = ?, reviewed_by = ?::uuid, "
                + "reviewed_at = NOW(), updated_at = NOW(), is_new = CASE WHEN ? = 'approved' THEN true ELSE is_new END "
                + "WHERE id = ?::uuid AND deleted_at IS NULL";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, normalized);
            ps.setString(2, visibility);
            ps.setString(3, reviewNote);
            ps.setString(4, reviewerId);
            ps.setString(5, normalized);
            ps.setString(6, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.reviewCourse: " + e.getMessage());
        }
        return false;
    }

    public boolean updateForTeacher(String courseId, String teacherId, Course course) {
        String sql = "UPDATE courses SET title = ?, short_description = ?, subject_code = ?, subject_name = ?, "
                + "grade_level = ?, level_name = ?, price_type = ?, price_amount = ?, currency = ?, "
                + "thumbnail_url = COALESCE(NULLIF(?, ''), thumbnail_url), thumbnail_gradient = COALESCE(NULLIF(?, ''), thumbnail_gradient), badge_text = ?, lessons_count = ?, estimated_hours = ?, "
                + "google_drive_url = ?, google_drive_file_id = ?, google_drive_folder_id = ?, drive_owner_email = ?, "
                + "access_instructions = ?, learning_objectives = ?, curriculum_outline = ?, updated_at = NOW() "
                + "WHERE id = ?::uuid AND teacher_id = ?::uuid AND deleted_at IS NULL";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, course.getTitle());
            ps.setString(2, course.getShortDescription());
            ps.setString(3, course.getSubjectCode());
            ps.setString(4, course.getSubjectName());
            ps.setString(5, course.getGradeLevel());
            ps.setString(6, course.getLevelName());
            ps.setString(7, course.getPriceType());
            ps.setBigDecimal(8, valueOrZero(course.getPriceAmount()));
            ps.setString(9, course.getCurrency() != null ? course.getCurrency() : "VND");
            ps.setString(10, course.getThumbnailUrl());
            ps.setString(11, course.getThumbnailGradient());
            ps.setString(12, course.getBadgeText());
            ps.setInt(13, Math.max(0, course.getLessonsCount()));
            ps.setBigDecimal(14, valueOrZero(course.getEstimatedHours()));
            ps.setString(15, course.getGoogleDriveUrl());
            ps.setString(16, course.getGoogleDriveFileId());
            ps.setString(17, course.getGoogleDriveFolderId());
            ps.setString(18, course.getDriveOwnerEmail());
            ps.setString(19, course.getAccessInstructions());
            ps.setString(20, course.getLearningObjectives());
            ps.setString(21, course.getCurriculumOutline());
            ps.setString(22, courseId);
            ps.setString(23, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.updateForTeacher: " + e.getMessage());
        }
        return false;
    }

    public boolean softDeleteForTeacher(String courseId, String teacherId) {
        String sql = "UPDATE courses SET status = 'archived', visibility = 'private', deleted_at = NOW(), updated_at = NOW() "
                + "WHERE id = ?::uuid AND teacher_id = ?::uuid AND deleted_at IS NULL";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, courseId);
            ps.setString(2, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.softDeleteForTeacher: " + e.getMessage());
        }
        return false;
    }

    public boolean softDeleteByStaff(String courseId, String staffId, String deleteReason) {
        String sql = "UPDATE courses SET status = 'archived', visibility = 'private', deleted_at = NOW(), "
                + "deleted_by = ?::uuid, delete_reason = ?, updated_at = NOW() "
                + "WHERE id = ?::uuid AND deleted_at IS NULL";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffId);
            ps.setString(2, deleteReason);
            ps.setString(3, courseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.softDeleteByStaff: " + e.getMessage());
        }
        return false;
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof UUID) {
                ps.setObject(i + 1, value);
            } else if (value == null) {
                ps.setNull(i + 1, Types.OTHER);
            } else {
                ps.setObject(i + 1, value);
            }
        }
    }

    public List<Course> findRelatedCourses(String courseId, String subjectName, int limit, String viewerId) {
        List<Course> courses = new ArrayList<>();
        if (subjectName == null || subjectName.trim().isEmpty()) {
            return courses;
        }
        
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.email AS teacher_email, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school, "
                + "(ce.id IS NOT NULL) AS viewer_enrolled, COALESCE(ce.progress_percent, 0) AS viewer_progress_percent "
                + "FROM courses c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace FROM teacher_applications "
                + "WHERE user_id = c.teacher_id ORDER BY submitted_at DESC LIMIT 1"
                + ") ta ON true "
                + "LEFT JOIN course_enrollments ce ON ce.course_id = c.id "
                + "AND ce.student_id = ?::uuid "
                + "AND ce.status IN ('pending_access', 'active') "
                + "WHERE c.id != ?::uuid AND c.subject_name = ? AND c.status = 'approved' AND c.visibility = 'public' AND c.deleted_at IS NULL "
                + "ORDER BY c.created_at DESC LIMIT ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
             ps.setString(1, viewerId);
             ps.setString(2, courseId);
             ps.setString(3, subjectName);
             ps.setInt(4, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.findRelatedCourses: " + e.getMessage());
        }
        return courses;
    }

    private UUID uuidOrNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private BigDecimal valueOrZero(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    private Course mapRow(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setId(rs.getString("id"));
        course.setCourseCode(rs.getString("course_code"));
        course.setTeacherId(rs.getString("teacher_id"));
        course.setTitle(rs.getString("title"));
        course.setShortDescription(rs.getString("short_description"));
        course.setSubjectCode(rs.getString("subject_code"));
        course.setSubjectName(rs.getString("subject_name"));
        course.setGradeLevel(rs.getString("grade_level"));
        course.setLevelName(rs.getString("level_name"));
        course.setPriceType(rs.getString("price_type"));
        course.setPriceAmount(rs.getBigDecimal("price_amount"));
        course.setCurrency(rs.getString("currency"));
        course.setThumbnailUrl(rs.getString("thumbnail_url"));
        course.setThumbnailGradient(rs.getString("thumbnail_gradient"));
        course.setBadgeText(rs.getString("badge_text"));
        course.setLessonsCount(rs.getInt("lessons_count"));
        course.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
        course.setStudentsCount(rs.getInt("students_count"));
        course.setRatingAverage(rs.getBigDecimal("rating_average"));
        course.setRatingCount(rs.getInt("rating_count"));
        course.setFeatured(rs.getBoolean("is_featured"));
        course.setNew(rs.getBoolean("is_new"));
        course.setGoogleDriveUrl(rs.getString("google_drive_url"));
        course.setGoogleDriveFileId(rs.getString("google_drive_file_id"));
        course.setGoogleDriveFolderId(rs.getString("google_drive_folder_id"));
        course.setDriveOwnerEmail(rs.getString("drive_owner_email"));
        course.setAccessInstructions(rs.getString("access_instructions"));
        course.setRequireDriveGrant(rs.getBoolean("require_drive_grant"));
        course.setStatus(rs.getString("status"));
        course.setVisibility(rs.getString("visibility"));
        course.setReviewNote(rs.getString("review_note"));
        course.setTeacherName(readOptionalString(rs, "teacher_name"));
        course.setTeacherEmail(readOptionalString(rs, "teacher_email"));
        course.setTeacherAvatarUrl(readOptionalString(rs, "teacher_avatar_url"));
        course.setTeacherSchool(readOptionalString(rs, "teacher_school"));
        course.setViewerEnrolled(readOptionalBoolean(rs, "viewer_enrolled"));
        course.setViewerProgressPercent(readOptionalInt(rs, "viewer_progress_percent"));
        course.setSubmittedAt(rs.getTimestamp("submitted_at"));
        course.setReviewedAt(rs.getTimestamp("reviewed_at"));
        course.setDeletedAt(rs.getTimestamp("deleted_at"));
        course.setCreatedAt(rs.getTimestamp("created_at"));
        course.setUpdatedAt(rs.getTimestamp("updated_at"));
        course.setLearningObjectives(readOptionalString(rs, "learning_objectives"));
        course.setCurriculumOutline(readOptionalString(rs, "curriculum_outline"));
        return course;
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }

    private boolean readOptionalBoolean(ResultSet rs, String columnName) {
        try {
            return rs.getBoolean(columnName);
        } catch (SQLException ignored) {
            return false;
        }
    }

    private int readOptionalInt(ResultSet rs, String columnName) {
        try {
            return rs.getInt(columnName);
        } catch (SQLException ignored) {
            return 0;
        }
    }

    private void ensureSchema() {
        if (schemaReady) return;
        synchronized (CourseDao.class) {
            if (schemaReady) return;
            try (Connection conn = DBContext.getConnection();
                 Statement st = conn.createStatement()) {

                st.execute("CREATE TABLE IF NOT EXISTS courses ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), "
                    + "course_code VARCHAR(24) UNIQUE NOT NULL, "
                    + "teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                    + "title TEXT NOT NULL, short_description TEXT, subject_code VARCHAR(40) NOT NULL, subject_name TEXT NOT NULL, "
                    + "grade_level TEXT, level_name TEXT, price_type VARCHAR(20) NOT NULL DEFAULT 'free', "
                    + "price_amount NUMERIC(12,2) NOT NULL DEFAULT 0, currency VARCHAR(10) NOT NULL DEFAULT 'VND', "
                    + "thumbnail_url TEXT, thumbnail_gradient TEXT, badge_text TEXT, lessons_count INTEGER NOT NULL DEFAULT 0, "
                    + "estimated_hours NUMERIC(6,2) NOT NULL DEFAULT 0, students_count INTEGER NOT NULL DEFAULT 0, "
                    + "rating_average NUMERIC(3,2) NOT NULL DEFAULT 0, rating_count INTEGER NOT NULL DEFAULT 0, "
                    + "is_featured BOOLEAN NOT NULL DEFAULT false, is_new BOOLEAN NOT NULL DEFAULT true, "
                    + "google_drive_url TEXT NOT NULL, google_drive_file_id TEXT, google_drive_folder_id TEXT, drive_owner_email TEXT, "
                    + "access_instructions TEXT, require_drive_grant BOOLEAN NOT NULL DEFAULT true, "
                    + "status VARCHAR(24) NOT NULL DEFAULT 'pending_review', visibility VARCHAR(20) NOT NULL DEFAULT 'private', "
                    + "submitted_at TIMESTAMPTZ, reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL, reviewed_at TIMESTAMPTZ, review_note TEXT, "
                    + "deleted_at TIMESTAMPTZ, deleted_by UUID REFERENCES users(id) ON DELETE SET NULL, delete_reason TEXT, "
                    + "learning_objectives TEXT, curriculum_outline TEXT, "
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_courses_teacher_id ON courses(teacher_id, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_courses_public_listing ON courses(status, visibility, subject_code, created_at DESC) WHERE deleted_at IS NULL");
            st.execute("CREATE INDEX IF NOT EXISTS idx_courses_review_queue ON courses(status, submitted_at ASC) WHERE deleted_at IS NULL");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS course_code VARCHAR(24)");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS short_description TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS subject_code VARCHAR(40)");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS subject_name TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS grade_level TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS level_name TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS price_type VARCHAR(20) NOT NULL DEFAULT 'free'");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS price_amount NUMERIC(12,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS currency VARCHAR(10) NOT NULL DEFAULT 'VND'");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS thumbnail_url TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS thumbnail_gradient TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS badge_text TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS lessons_count INTEGER NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS estimated_hours NUMERIC(6,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS students_count INTEGER NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS rating_average NUMERIC(3,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS rating_count INTEGER NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS is_featured BOOLEAN NOT NULL DEFAULT false");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS is_new BOOLEAN NOT NULL DEFAULT true");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS google_drive_url TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS google_drive_file_id TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS google_drive_folder_id TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS drive_owner_email TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS access_instructions TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS require_drive_grant BOOLEAN NOT NULL DEFAULT true");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS status VARCHAR(24) NOT NULL DEFAULT 'pending_review'");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS visibility VARCHAR(20) NOT NULL DEFAULT 'private'");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS review_note TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES users(id) ON DELETE SET NULL");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS delete_reason TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS learning_objectives TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS curriculum_outline TEXT");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now()");
            st.execute("ALTER TABLE courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now()");
            st.execute("UPDATE courses SET course_code = 'CRS-' || upper(substr(replace(id::text, '-', ''), 1, 6)) WHERE course_code IS NULL OR btrim(course_code) = ''");
            st.execute("ALTER TABLE courses ALTER COLUMN course_code SET NOT NULL");
            st.execute("CREATE UNIQUE INDEX IF NOT EXISTS uq_courses_course_code ON courses(course_code)");

            st.execute("CREATE TABLE IF NOT EXISTS course_modules ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, "
                    + "title TEXT NOT NULL, description TEXT, sort_order INTEGER NOT NULL DEFAULT 1, "
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_modules_course_order ON course_modules(course_id, sort_order)");

            st.execute("CREATE TABLE IF NOT EXISTS course_lessons ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, "
                    + "module_id UUID REFERENCES course_modules(id) ON DELETE SET NULL, title TEXT NOT NULL, description TEXT, "
                    + "lesson_type VARCHAR(30) NOT NULL DEFAULT 'drive_file', google_drive_url TEXT, google_drive_file_id TEXT, "
                    + "duration_minutes INTEGER NOT NULL DEFAULT 0, is_preview BOOLEAN NOT NULL DEFAULT false, sort_order INTEGER NOT NULL DEFAULT 1, "
                    + "status VARCHAR(20) NOT NULL DEFAULT 'published', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_lessons_course_order ON course_lessons(course_id, module_id, sort_order)");

            st.execute("CREATE TABLE IF NOT EXISTS course_enrollments ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, "
                    + "student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, status VARCHAR(24) NOT NULL DEFAULT 'pending_access', "
                    + "price_paid NUMERIC(12,2) NOT NULL DEFAULT 0, currency VARCHAR(10) NOT NULL DEFAULT 'VND', purchase_transaction_id UUID, "
                    + "purchased_at TIMESTAMPTZ, access_email TEXT, drive_permission_id TEXT, access_granted_at TIMESTAMPTZ, "
                    + "last_access_email_sent_at TIMESTAMPTZ, progress_percent INTEGER NOT NULL DEFAULT 0, completed_at TIMESTAMPTZ, "
                    + "created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(course_id, student_id))");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_enrollments_student ON course_enrollments(student_id, status, created_at DESC)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_enrollments_course ON course_enrollments(course_id, status)");

            st.execute("CREATE TABLE IF NOT EXISTS course_access_grants ("
                    + "id UUID PRIMARY KEY DEFAULT gen_random_uuid(), enrollment_id UUID REFERENCES course_enrollments(id) ON DELETE CASCADE, "
                    + "course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                    + "student_email TEXT NOT NULL, drive_permission_id TEXT, status VARCHAR(20) NOT NULL DEFAULT 'pending', "
                    + "grant_requested_at TIMESTAMPTZ NOT NULL DEFAULT now(), granted_at TIMESTAMPTZ, revoked_at TIMESTAMPTZ, "
                    + "last_error TEXT, email_sent_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now())");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_access_grants_enrollment ON course_access_grants(enrollment_id, status)");
            st.execute("CREATE INDEX IF NOT EXISTS idx_course_access_grants_course_student ON course_access_grants(course_id, student_id, status)");
            schemaReady = true;
        } catch (SQLException e) {
            System.err.println("Error in CourseDao.ensureSchema: " + e.getMessage());
        }
        }
    }
}
