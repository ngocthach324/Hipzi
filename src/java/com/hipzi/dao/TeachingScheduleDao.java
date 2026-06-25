package com.hipzi.dao;

import com.hipzi.model.TeachingSchedule;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TeachingScheduleDao {

    public TeachingScheduleDao() {}

    public boolean createBatch(List<TeachingSchedule> schedules) {
        if (schedules == null || schedules.isEmpty()) return true;

        String sql = "INSERT INTO teaching_schedules " +
                "(classroom_id, teacher_id, title, description, session_date, start_time, end_time, source, meet_link, location, session_type) " +
                "VALUES (?::uuid, ?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false);

            for (TeachingSchedule s : schedules) {
                if (s.getClassroomId() != null && !s.getClassroomId().isEmpty()) {
                    ps.setString(1, s.getClassroomId());
                } else {
                    ps.setNull(1, java.sql.Types.OTHER);
                }
                ps.setString(2, s.getTeacherId());
                ps.setString(3, s.getTitle());
                ps.setString(4, s.getDescription());
                ps.setDate(5, s.getSessionDate());
                ps.setTime(6, s.getStartTime());
                ps.setTime(7, s.getEndTime());
                ps.setString(8, s.getSource() != null ? s.getSource() : "auto");
                ps.setString(9, s.getMeetLink());
                ps.setString(10, s.getLocation());
                ps.setString(11, s.getSessionType() != null ? s.getSessionType() : "online");

                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            conn.commit();
            conn.setAutoCommit(true);
            return results.length == schedules.size();

        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.createBatch: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean create(TeachingSchedule s) {
        String sql = "INSERT INTO teaching_schedules " +
                "(classroom_id, teacher_id, title, description, session_date, start_time, end_time, source, meet_link, location, session_type) " +
                "VALUES (?::uuid, ?::uuid, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (s.getClassroomId() != null && !s.getClassroomId().isEmpty()) {
                ps.setString(1, s.getClassroomId());
            } else {
                ps.setNull(1, java.sql.Types.OTHER);
            }
            ps.setString(2, s.getTeacherId());
            ps.setString(3, s.getTitle());
            ps.setString(4, s.getDescription());
            ps.setDate(5, s.getSessionDate());
            ps.setTime(6, s.getStartTime());
            ps.setTime(7, s.getEndTime());
            ps.setString(8, s.getSource() != null ? s.getSource() : "manual");
            ps.setString(9, s.getMeetLink());
            ps.setString(10, s.getLocation());
            ps.setString(11, s.getSessionType() != null ? s.getSessionType() : "online");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.create: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<TeachingSchedule> findByTeacherId(String teacherId) {
        String sql = "SELECT ts.*, c.title AS classroom_title " +
                     "FROM teaching_schedules ts " +
                     "LEFT JOIN classrooms c ON ts.classroom_id = c.id " +
                     "WHERE ts.teacher_id = ?::uuid " +
                     "ORDER BY ts.session_date ASC, ts.start_time ASC";
                     
        List<TeachingSchedule> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.findByTeacherId: " + e.getMessage());
        }
        return list;
    }

    public List<TeachingSchedule> findByStudentId(String studentId) {
        String sql = "SELECT ts.*, c.title AS classroom_title, u.display_name AS teacher_name " +
                     "FROM teaching_schedules ts " +
                     "JOIN classrooms c ON ts.classroom_id = c.id " +
                     "JOIN users u ON ts.teacher_id = u.id " +
                     "JOIN classroom_enrollments ce ON ce.classroom_id = c.id " +
                     "WHERE ce.student_id = ?::uuid AND ce.status = 'accepted' " +
                     "ORDER BY ts.session_date ASC, ts.start_time ASC";

        List<TeachingSchedule> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeachingSchedule ts = mapRow(rs);
                    ts.setTeacherName(rs.getString("teacher_name"));
                    list.add(ts);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.findByStudentId: " + e.getMessage());
        }
        return list;
    }

    public boolean update(TeachingSchedule s) {
        String sql = "UPDATE teaching_schedules SET " +
                "title = ?, description = ?, session_date = ?, start_time = ?, end_time = ?, " +
                "meet_link = ?, location = ?, session_type = ?, status = ?, updated_at = NOW() " +
                "WHERE id = ?::uuid AND teacher_id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, s.getTitle());
            ps.setString(2, s.getDescription());
            ps.setDate(3, s.getSessionDate());
            ps.setTime(4, s.getStartTime());
            ps.setTime(5, s.getEndTime());
            ps.setString(6, s.getMeetLink());
            ps.setString(7, s.getLocation());
            ps.setString(8, s.getSessionType());
            ps.setString(9, s.getStatus());
            ps.setString(10, s.getId());
            ps.setString(11, s.getTeacherId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.update: " + e.getMessage());
        }
        return false;
    }

    public boolean cancel(String id, String teacherId, String reason) {
        String sql = "UPDATE teaching_schedules SET status = 'cancelled', cancelled_reason = ?, updated_at = NOW() " +
                     "WHERE id = ?::uuid AND teacher_id = ?::uuid";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reason);
            ps.setString(2, id);
            ps.setString(3, teacherId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.cancel: " + e.getMessage());
        }
        return false;
    }

    public boolean deleteAutoFuture(String classroomId) {
        String sql = "DELETE FROM teaching_schedules " +
                     "WHERE classroom_id = ?::uuid AND source = 'auto' AND session_date >= CURRENT_DATE";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, classroomId);
            return ps.executeUpdate() >= 0; // >= 0 in case there are no records to delete
        } catch (SQLException e) {
            System.err.println("Error in TeachingScheduleDao.deleteAutoFuture: " + e.getMessage());
        }
        return false;
    }

    private TeachingSchedule mapRow(ResultSet rs) throws SQLException {
        TeachingSchedule s = new TeachingSchedule();
        s.setId(rs.getString("id"));
        s.setClassroomId(rs.getString("classroom_id"));
        s.setTeacherId(rs.getString("teacher_id"));
        s.setTitle(rs.getString("title"));
        s.setDescription(rs.getString("description"));
        s.setSessionDate(rs.getDate("session_date"));
        s.setStartTime(rs.getTime("start_time"));
        s.setEndTime(rs.getTime("end_time"));
        s.setSource(rs.getString("source"));
        s.setMeetLink(rs.getString("meet_link"));
        s.setLocation(rs.getString("location"));
        s.setSessionType(rs.getString("session_type"));
        s.setStatus(rs.getString("status"));
        s.setCancelledReason(rs.getString("cancelled_reason"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            s.setClassroomTitle(rs.getString("classroom_title"));
        } catch (SQLException e) {
            // column might not exist
        }

        return s;
    }
}
