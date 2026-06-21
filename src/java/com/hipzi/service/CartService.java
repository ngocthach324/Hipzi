package com.hipzi.service;

import com.hipzi.dao.CartDao;
import com.hipzi.dao.CourseDao;
import com.hipzi.model.CartItem;
import com.hipzi.model.Course;
import com.hipzi.model.Role;
import com.hipzi.model.User;

import java.math.BigDecimal;
import java.util.List;

public class CartService {
    private final CartDao cartDao;
    private final CourseDao courseDao;

    public CartService() {
        this.cartDao = new CartDao();
        this.courseDao = new CourseDao();
    }

    public String addToCart(User user, String courseId) {
        if (user == null || courseId == null || courseId.trim().isEmpty()) {
            return "Vui lòng đăng nhập để sử dụng giỏ hàng.";
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
            return "Chỉ học viên mới có thể thêm vào giỏ hàng.";
        }

        Course course = courseDao.findById(courseId, user.getId());
        if (course == null) {
            return "Không tìm thấy khóa học.";
        }

        if (!"approved".equals(course.getStatus()) || !"public".equals(course.getVisibility())) {
            return "Khóa học hiện không khả dụng.";
        }

        if (course.isFree()) {
            return "Khóa học miễn phí không thể thêm vào giỏ hàng.";
        }

        if (course.isViewerEnrolled()) {
            return "Bạn đã đăng ký khóa học này rồi.";
        }

        if (cartDao.isInCart(user.getId(), courseId)) {
            return "Khóa học đã có trong giỏ hàng.";
        }

        boolean success = cartDao.addItem(user.getId(), courseId);
        return success ? null : "Không thể thêm vào giỏ hàng. Vui lòng thử lại sau.";
    }

    public boolean removeFromCart(String studentId, String courseId) {
        if (studentId == null || courseId == null) return false;
        return cartDao.removeItem(studentId, courseId);
    }

    public boolean clearCart(String studentId) {
        if (studentId == null) return false;
        return cartDao.clearCart(studentId);
    }

    public List<CartItem> getCartItems(String studentId) {
        if (studentId == null) return java.util.Collections.emptyList();
        return cartDao.findByStudent(studentId);
    }

    public int getCartCount(String studentId) {
        if (studentId == null) return 0;
        return cartDao.countByStudent(studentId);
    }

    public BigDecimal getTotalPrice(String studentId) {
        List<CartItem> items = getCartItems(studentId);
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            if (item.getPriceAmount() != null) {
                total = total.add(item.getPriceAmount());
            }
        }
        return total;
    }
}
