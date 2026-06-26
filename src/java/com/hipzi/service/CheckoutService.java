package com.hipzi.service;

import com.hipzi.dao.CourseDao;
import com.hipzi.dao.CourseOrderDao;
import com.hipzi.model.CartItem;
import com.hipzi.model.Course;
import com.hipzi.model.CourseOrder;
import com.hipzi.model.CourseOrderItem;
import com.hipzi.model.Role;
import com.hipzi.model.User;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class CheckoutService {
    private static final int ORDER_EXPIRES_MINUTES = 30;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final CartService cartService;
    private final CourseDao courseDao;
    private final CourseOrderDao courseOrderDao;

    public CheckoutService() {
        this.cartService = new CartService();
        this.courseDao = new CourseDao();
        this.courseOrderDao = new CourseOrderDao();
    }

    public CheckoutResult createOrderFromCart(User user) {
        return createOrderFromCart(user, null);
    }

    public CheckoutResult createOrderFromCart(User user, List<String> selectedCourseIds) {
        if (user == null) {
            return CheckoutResult.error("Vui lòng đăng nhập để thanh toán.");
        }
        if (!hasStudentRole(user)) {
            return CheckoutResult.error("Chỉ học viên mới có thể thanh toán khóa học.");
        }

        List<CartItem> cartItems = cartService.getCartItems(user.getId());
        if (cartItems == null || cartItems.isEmpty()) {
            return CheckoutResult.error("Giỏ hàng đang trống.");
        }

        Set<String> selectedSet = normalizeSelectedCourseIds(selectedCourseIds);
        if (selectedCourseIds != null && selectedSet.isEmpty()) {
            return CheckoutResult.error("Vui lòng chọn ít nhất 1 khóa học để thanh toán.");
        }

        List<CourseOrderItem> orderItems = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;
        int matchedSelectedItems = 0;

        for (CartItem cartItem : cartItems) {
            if (selectedSet != null && !selectedSet.contains(cartItem.getCourseId())) {
                continue;
            }
            matchedSelectedItems++;

            Course course = courseDao.findById(cartItem.getCourseId(), user.getId());
            String validationError = validateCourseForCheckout(course);
            if (validationError != null) {
                return CheckoutResult.error(validationError);
            }

            CourseOrderItem item = new CourseOrderItem();
            item.setCourseId(course.getId());
            item.setTeacherId(course.getTeacherId());
            item.setCourseTitle(course.getTitle());
            item.setPriceAmount(course.getPriceAmount());
            item.setCurrency(valueOrDefault(course.getCurrency(), "VND"));
            orderItems.add(item);
            total = total.add(course.getPriceAmount());
        }

        if (selectedSet != null && matchedSelectedItems != selectedSet.size()) {
            return CheckoutResult.error("Có khóa học đã chọn không còn nằm trong giỏ hàng.");
        }

        if (orderItems.isEmpty() || total.compareTo(BigDecimal.ZERO) <= 0) {
            return CheckoutResult.error("Không có khóa học có phí hợp lệ để thanh toán.");
        }

        CourseOrder order = new CourseOrder();
        order.setStudentId(user.getId());
        order.setTotalAmount(total);
        order.setCurrency("VND");
        order.setStatus("pending");
        order.setPaymentProvider("sepay");
        order.setExpiresAt(new Timestamp(System.currentTimeMillis() + ORDER_EXPIRES_MINUTES * 60L * 1000L));
        order.setItems(orderItems);

        for (int attempt = 0; attempt < 3; attempt++) {
            String orderCode = generateOrderCode();
            order.setOrderCode(orderCode);
            order.setPaymentContent("HIPZI " + orderCode);

            CourseOrder created = courseOrderDao.createPendingOrder(order);
            if (created != null) {
                return CheckoutResult.success(created);
            }
        }

        return CheckoutResult.error("Không thể tạo đơn thanh toán. Vui lòng thử lại sau.");
    }

    public CourseOrder findOrderForUser(User user, String orderId) {
        if (user == null || orderId == null || orderId.trim().isEmpty()) {
            return null;
        }
        return courseOrderDao.findById(orderId, user.getId());
    }

    private String validateCourseForCheckout(Course course) {
        if (course == null) {
            return "Có khóa học trong giỏ không còn tồn tại.";
        }
        if (!"approved".equals(course.getStatus()) || !"public".equals(course.getVisibility())) {
            return "Khóa học \"" + course.getTitle() + "\" hiện không khả dụng.";
        }
        if (course.isViewerEnrolled()) {
            return "Bạn đã đăng ký khóa học \"" + course.getTitle() + "\" rồi.";
        }
        if (course.isFree()) {
            return "Khóa học miễn phí \"" + course.getTitle() + "\" không cần thanh toán.";
        }
        if (!"VND".equalsIgnoreCase(valueOrDefault(course.getCurrency(), "VND"))) {
            return "Khóa học \"" + course.getTitle() + "\" đang dùng đơn vị tiền tệ chưa được hỗ trợ.";
        }
        return null;
    }

    private boolean hasStudentRole(User user) {
        if (user.getRoles() == null) {
            return false;
        }
        for (Role role : user.getRoles()) {
            if (role != null && "student".equalsIgnoreCase(role.getName())) {
                return true;
            }
        }
        return false;
    }

    private String generateOrderCode() {
        String timePart = new SimpleDateFormat("yyMMddHHmmss", Locale.US).format(new Date());
        int randomPart = 1000 + RANDOM.nextInt(9000);
        return "HZ" + timePart + randomPart;
    }

    private Set<String> normalizeSelectedCourseIds(List<String> selectedCourseIds) {
        if (selectedCourseIds == null) {
            return null;
        }
        Set<String> selected = new HashSet<>();
        for (String courseId : selectedCourseIds) {
            if (courseId != null && !courseId.trim().isEmpty()) {
                selected.add(courseId.trim());
            }
        }
        return selected;
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    public static class CheckoutResult {
        private final CourseOrder order;
        private final String error;

        private CheckoutResult(CourseOrder order, String error) {
            this.order = order;
            this.error = error;
        }

        public static CheckoutResult success(CourseOrder order) {
            return new CheckoutResult(order, null);
        }

        public static CheckoutResult error(String error) {
            return new CheckoutResult(null, error);
        }

        public CourseOrder getOrder() { return order; }
        public String getError() { return error; }
        public boolean isSuccess() { return order != null && error == null; }
    }
}
