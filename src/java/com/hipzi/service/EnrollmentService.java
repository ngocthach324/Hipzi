package com.hipzi.service;

import com.hipzi.dao.CourseDao;
import com.hipzi.dao.CourseEnrollmentDao;
import com.hipzi.model.Course;
import com.hipzi.model.Role;
import com.hipzi.model.User;

public class EnrollmentService {
    
    private final CourseDao courseDao;
    private final CourseEnrollmentDao enrollmentDao;

    public EnrollmentService() {
        this.courseDao = new CourseDao();
        this.enrollmentDao = new CourseEnrollmentDao();
    }

    public String enrollFree(User user, String courseId) {
        if (user == null || courseId == null || courseId.trim().isEmpty()) {
            return "Vui lòng đăng nhập để đăng ký khóa học.";
        }
        
        boolean isStudent = false;
        if (user.getRoles() != null) {
            for (Role r : user.getRoles()) {
                if ("student".equalsIgnoreCase(r.getName())) {
                    isStudent = true;
                    break;
                }
            }
        }
        
        if (!isStudent) {
            return "Chỉ học viên mới có thể đăng ký khóa học.";
        }

        Course course = courseDao.findById(courseId, user.getId());
        if (course == null) {
            return "Không tìm thấy khóa học.";
        }

        if (!"approved".equals(course.getStatus()) || !"public".equals(course.getVisibility())) {
            return "Khóa học hiện không khả dụng.";
        }

        if (!course.isFree()) {
            return "Khóa học này có phí. Vui lòng thanh toán để đăng ký.";
        }

        if (course.isViewerEnrolled()) {
            return "Bạn đã đăng ký khóa học này rồi.";
        }

        boolean success = enrollmentDao.enrollFreeCourse(user.getId(), courseId);
        if (success) {
            return null; // Success
        } else {
            return "Đăng ký không thành công. Vui lòng thử lại sau.";
        }
    }
}
