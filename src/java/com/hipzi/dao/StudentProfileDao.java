package com.hipzi.dao;

import com.hipzi.model.StudentProfile;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StudentProfileDao {

    public StudentProfile findProfileByUserId(String userId) {
        String sql = "SELECT * FROM student_profiles WHERE user_id = ?::uuid";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StudentProfile profile = new StudentProfile();
                    profile.setId(rs.getString("id"));
                    profile.setUserId(rs.getString("user_id"));
                    profile.setGradeLevel(rs.getString("grade_level"));
                    profile.setSchoolName(rs.getString("school_name"));
                    profile.setCurrentLevel(rs.getInt("current_level"));
                    profile.setCurrentXp(rs.getInt("current_xp"));
                    profile.setCurrentStreak(rs.getInt("current_streak"));
                    profile.setLastActivityDate(rs.getDate("last_activity_date"));
                    profile.setCompletedQuizzesCount(rs.getInt("completed_quizzes_count"));
                    profile.setAverageAccuracy(rs.getDouble("average_accuracy"));
                    profile.setActiveClassesCount(rs.getInt("active_classes_count"));
                    profile.setCreatedAt(rs.getTimestamp("created_at"));
                    profile.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return profile;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in StudentProfileDao.findProfileByUserId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean createProfile(StudentProfile profile) {
        String sql = "INSERT INTO student_profiles (user_id, grade_level, school_name) "
                + "VALUES (?::uuid, ?, ?) ON CONFLICT (user_id) DO NOTHING";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, profile.getUserId());
            ps.setString(2, profile.getGradeLevel());
            ps.setString(3, profile.getSchoolName());
            
            System.out.println("Executing SQL: " + sql + " with userId=" + profile.getUserId());
            int rows = ps.executeUpdate();
            System.out.println("StudentProfileDao.createProfile: inserted " + rows + " rows.");
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error in StudentProfileDao.createProfile for userId " + profile.getUserId() + ": " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
