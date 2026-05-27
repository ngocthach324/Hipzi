package com.hipzi.service;

import com.hipzi.dao.StudentProfileDao;
import com.hipzi.model.StudentProfile;

public class StudentProfileService {

    private final StudentProfileDao studentProfileDao = new StudentProfileDao();

    public StudentProfile getProfileByUserId(String userId) {
        if (userId == null || userId.trim().isEmpty()) {
            return new StudentProfile();
        }
        StudentProfile profile = studentProfileDao.findProfileByUserId(userId);
        if (profile == null) {
            // Seed a fresh default instance if row isn't initialized yet
            // Lazily create in database so it exists for future visits/caching
            createDefaultProfile(userId);
            profile = studentProfileDao.findProfileByUserId(userId);
            
            // If still null (e.g. insert failed), return a transient object
            if (profile == null) {
                profile = new StudentProfile();
                profile.setUserId(userId);
            }
        }
        return profile;
    }

    public boolean createDefaultProfile(String userId) {
        if (userId == null || userId.trim().isEmpty()) return false;
        
        StudentProfile profile = new StudentProfile();
        profile.setUserId(userId);
        // Default values like gradeLevel and schoolName can be empty for now
        
        return studentProfileDao.createProfile(profile);
    }
}
