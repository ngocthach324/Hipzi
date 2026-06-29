package com.hipzi.dao;

import com.hipzi.model.Classroom;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class ClassroomDao {

    public ClassroomDao() {
        ensureSchema();
    }

    public List<Classroom> findByTeacherId(String teacherId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM classrooms c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN teacher_applications ta ON ta.user_id = c.teacher_id "
                + "WHERE c.teacher_id = ?::uuid "
                + "ORDER BY c.updated_at DESC";

        List<Classroom> classrooms = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    classrooms.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.findByTeacherId: " + e.getMessage());
        }
        return classrooms;
    }

    public Classroom findById(String classId) {
        String sql = "SELECT c.*, u.display_name AS teacher_name, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM classrooms c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN teacher_applications ta ON ta.user_id = c.teacher_id "
                + "WHERE c.id::text = ? "
                + "LIMIT 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.findById: " + e.getMessage());
        }
        return null;
    }


    public List<Classroom> listPublic(String subjectFilter, String gradeFilter, String searchQuery) {
        long startedAt = System.nanoTime();
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.class_code, c.teacher_id, c.title, c.subject, c.grade_level, c.description, "
                + "c.student_count, c.status, c.schedule_days, c.start_time, c.end_time, c.online_room_url, c.tuition_fee, c.tuition_due_date, "
                + "c.created_at, c.updated_at, "
                + "u.display_name AS teacher_name, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM classrooms c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN LATERAL ("
                + "SELECT institution_name, workplace "
                + "FROM teacher_applications "
                + "WHERE user_id = c.teacher_id "
                + "ORDER BY submitted_at DESC "
                + "LIMIT 1"
                + ") ta ON true "
                + "WHERE c.status IN ('open', 'upcoming') ");

        List<Object> params = new ArrayList<>();
        if (subjectFilter != null && !subjectFilter.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(subjectFilter.trim())) {
            sql.append("AND c.subject = ? ");
            params.add(subjectFilter.trim());
        }
        if (gradeFilter != null && !gradeFilter.trim().isEmpty() && !"Tất cả".equalsIgnoreCase(gradeFilter.trim())) {
            sql.append("AND c.grade_level = ? ");
            params.add(gradeFilter.trim());
        }
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (c.title ILIKE ? OR u.display_name ILIKE ?) ");
            String keyword = "%" + searchQuery.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }
        sql.append("ORDER BY c.created_at DESC");

        List<Classroom> classrooms = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    classrooms.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.listPublic: " + e.getMessage());
            logPerf("ClassroomDao.listPublic FAILED params=" + params.size(), startedAt);
            return null;
        }
        logPerf("ClassroomDao.listPublic rows=" + classrooms.size() + " params=" + params.size(), startedAt);
        return classrooms;
    }

    public List<Classroom> listForStaff(String titleFilter, String subjectFilter, String statusFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, u.display_name AS teacher_name, u.avatar_url AS teacher_avatar_url, "
                + "COALESCE(ta.institution_name, ta.workplace, '') AS teacher_school "
                + "FROM classrooms c "
                + "JOIN users u ON u.id = c.teacher_id "
                + "LEFT JOIN teacher_applications ta ON ta.user_id = c.teacher_id "
                + "WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        if (titleFilter != null && !titleFilter.trim().isEmpty()) {
            sql.append("AND c.title ILIKE ? ");
            params.add("%" + titleFilter.trim() + "%");
        }
        if (subjectFilter != null && !subjectFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(subjectFilter.trim())) {
            sql.append("AND c.subject = ? ");
            params.add(subjectFilter.trim());
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND c.status = ? ");
            params.add(statusFilter.trim());
        }
        sql.append("ORDER BY c.updated_at DESC");

        List<Classroom> classrooms = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    classrooms.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.listForStaff: " + e.getMessage());
        }
        return classrooms;
    }

    public List<String> listSubjects() {
        String sql = "SELECT DISTINCT subject FROM classrooms WHERE subject IS NOT NULL AND TRIM(subject) <> '' ORDER BY subject";
        List<String> subjects = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                subjects.add(rs.getString("subject"));
            }
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.listSubjects: " + e.getMessage());
        }
        return subjects;
    }

    public int countActiveClassrooms() {
        String sql = "SELECT COUNT(*) FROM classrooms WHERE status IN ('open', 'upcoming')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.countActiveClassrooms: " + e.getMessage());
        }
        return 0;
    }

    public boolean create(Classroom classroom) {
        if (classroom.getId() == null || classroom.getId().isEmpty()) {
            classroom.setId(UUID.randomUUID().toString());
        }
        if (classroom.getClassCode() == null || classroom.getClassCode().trim().isEmpty()) {
            classroom.setClassCode("HPZ-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase(Locale.ROOT));
        }
        String sql = "INSERT INTO classrooms "
                + "(id, teacher_id, class_code, title, subject, grade_level, description, schedule_days, start_time, end_time, status, online_room_url, tuition_fee, tuition_due_date) "
                + "VALUES (?::uuid, ?::uuid, ?, ?, ?, ?, ?, ?, ?::time, ?::time, ?, ?, ?, ?::date)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classroom.getId());
            ps.setString(2, classroom.getTeacherId());
            ps.setString(3, classroom.getClassCode());
            bindEditableFields(ps, classroom, 4, false);
            ps.setString(12, classroom.getOnlineRoomUrl());
            ps.setBigDecimal(13, classroom.getTuitionFee());
            ps.setString(14, classroom.getTuitionDueDate() != null ? classroom.getTuitionDueDate().toString() : null);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.create: " + e.getMessage());
        }
        return false;
    }

    public boolean updateForTeacher(Classroom classroom) {
        String sql = "UPDATE classrooms SET "
                + "title = ?, subject = ?, grade_level = ?, description = ?, schedule_days = ?, "
                + "start_time = ?::time, end_time = ?::time, status = ?, online_room_url = ?, tuition_fee = ?, tuition_due_date = ?::date, updated_at = NOW() "
                + "WHERE id = ?::uuid AND teacher_id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindEditableFields(ps, classroom, 1, false);
            ps.setString(9, classroom.getOnlineRoomUrl());
            ps.setBigDecimal(10, classroom.getTuitionFee());
            ps.setString(11, classroom.getTuitionDueDate() != null ? classroom.getTuitionDueDate().toString() : null);
            ps.setString(12, classroom.getId());
            ps.setString(13, classroom.getTeacherId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.updateForTeacher: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteForTeacher(String classId, String teacherId) {
        String sql = "DELETE FROM classrooms WHERE id = ?::uuid AND teacher_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classId);
            ps.setString(2, teacherId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.deleteForTeacher: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteById(String classId) {
        String sql = "DELETE FROM classrooms WHERE id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.deleteById: " + e.getMessage());
        }
        return false;
    }

    private void bindEditableFields(PreparedStatement ps, Classroom classroom, int startIndex, boolean includeTeacherId)
            throws SQLException {
        int i = startIndex;
        if (includeTeacherId) {
            ps.setString(i++, classroom.getTeacherId());
        }
        ps.setString(i++, classroom.getTitle());
        ps.setString(i++, classroom.getSubject());
        ps.setString(i++, classroom.getGrade());
        ps.setString(i++, classroom.getDescription());
        ps.setString(i++, classroom.getScheduleDays());
        ps.setString(i++, classroom.getStartTime() != null ? classroom.getStartTime().toString() : null);
        ps.setString(i++, classroom.getEndTime() != null ? classroom.getEndTime().toString() : null);
        ps.setString(i, classroom.getStatus());
    }

    private Classroom mapRow(ResultSet rs) throws SQLException {
        Classroom classroom = new Classroom();
        classroom.setId(rs.getString("id"));
        classroom.setClassCode(readOptionalString(rs, "class_code"));
        classroom.setTeacherId(rs.getString("teacher_id"));
        classroom.setTitle(rs.getString("title"));
        classroom.setSubject(rs.getString("subject"));
        classroom.setGrade(rs.getString("grade_level"));
        classroom.setDescription(rs.getString("description"));
        classroom.setStudentCount(rs.getInt("student_count"));
        classroom.setStatus(rs.getString("status"));
        classroom.setScheduleDays(rs.getString("schedule_days"));
        classroom.setStartTime(rs.getTime("start_time"));
        classroom.setEndTime(rs.getTime("end_time"));
        classroom.setTeacherName(readOptionalString(rs, "teacher_name"));
        classroom.setTeacherSchool(readOptionalString(rs, "teacher_school"));
        classroom.setTeacherAvatarUrl(readOptionalString(rs, "teacher_avatar_url"));
        String onlineRoomUrl = readOptionalString(rs, "online_room_url");
        classroom.setOnlineRoomUrl(onlineRoomUrl != null ? onlineRoomUrl.trim() : "");
        classroom.setTuitionFee(rs.getBigDecimal("tuition_fee"));
        java.sql.Date tuitionDueDate = rs.getDate("tuition_due_date");
        classroom.setTuitionDueDate(tuitionDueDate != null ? tuitionDueDate.toLocalDate() : null);
        classroom.setSchedule(formatSchedule(classroom.getScheduleDays(), classroom.getStartTime(), classroom.getEndTime()));
        classroom.setCreatedAt(rs.getTimestamp("created_at"));
        classroom.setUpdatedAt(rs.getTimestamp("updated_at"));
        return classroom;
    }

    private String readOptionalString(ResultSet rs, String columnName) {
        try {
            return rs.getString(columnName);
        } catch (SQLException ignored) {
            return "";
        }
    }

    private String formatSchedule(String scheduleDays, Time startTime, Time endTime) {
        String days = scheduleDays == null || scheduleDays.trim().isEmpty() ? "Chưa cập nhật ngày học" : scheduleDays.trim();
        String start = startTime != null ? startTime.toLocalTime().toString().substring(0, 5) : "--:--";
        String end = endTime != null ? endTime.toLocalTime().toString().substring(0, 5) : "--:--";
        return days + " (" + start + " - " + end + ")";
    }

    private void logPerf(String label, long startedAt) {
        long elapsedMs = (System.nanoTime() - startedAt) / 1_000_000L;
        System.err.println("[PERF] " + label + " " + elapsedMs + "ms");
    }

    private void ensureSchema() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS class_code VARCHAR(20)");
            st.execute("UPDATE classrooms "
                    + "SET class_code = 'HPZ-' || upper(substring(id::text from 1 for 6)) "
                    + "WHERE class_code IS NULL OR trim(class_code) = ''");
            st.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_classrooms_class_code_unique ON classrooms(class_code)");
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS online_room_url TEXT");
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS tuition_fee NUMERIC(12,2) NOT NULL DEFAULT 0");
            st.execute("ALTER TABLE classrooms ADD COLUMN IF NOT EXISTS tuition_due_date DATE");
        } catch (SQLException e) {
            System.err.println("Error in ClassroomDao.ensureSchema: " + e.getMessage());
        }
    }
}
