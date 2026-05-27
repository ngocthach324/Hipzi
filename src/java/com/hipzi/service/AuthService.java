package com.hipzi.service;

import com.hipzi.dao.RoleDao;
import com.hipzi.dao.UserDao;
import com.hipzi.dao.UserRoleDao;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.util.PasswordUtil;

import java.util.List;

public class AuthService {

    private final UserDao userDao = new UserDao();
    private final RoleDao roleDao = new RoleDao();
    private final UserRoleDao userRoleDao = new UserRoleDao();
    private final StudentProfileService studentProfileService = new StudentProfileService();

    // -------------------------------------------------------------------------
    // Đăng ký bằng email/password + role do user chọn trên form
    // BR-ROLE-001: Mỗi user phải có ít nhất 1 role
    // -------------------------------------------------------------------------
    public String register(String email, String password, String displayName, String roleName) {
        // Validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return "Email và mật khẩu không được để trống.";
        }
        if (displayName == null || displayName.trim().isEmpty()) {
            return "Họ và tên không được để trống.";
        }
        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }

        // Chỉ cho phép 3 role được đăng ký tự do (BR-ROLE-004)
        if (roleName == null || (!roleName.equals("student") && !roleName.equals("parent") && !roleName.equals("teacher"))) {
            roleName = "student"; // Fallback an toàn
        }

        // Kiểm tra email đã tồn tại
        if (userDao.findByEmail(email) != null) {
            return "Email này đã được sử dụng.";
        }

        // Tạo user mới (onboarding_completed = true vì đã chọn role trên form)
        User newUser = new User();
        newUser.setEmail(email.trim());
        newUser.setDisplayName(displayName.trim());
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));

        if (!userDao.createUser(newUser)) {
            return "Có lỗi xảy ra khi tạo tài khoản. Vui lòng thử lại.";
        }

        // Gán role đã chọn
        Role role = roleDao.findRoleByName(roleName);
        if (role != null) {
            userRoleDao.assignRole(newUser.getId(), role.getId());
            
            // Khởi tạo profile học sinh nếu role là student
            if ("student".equalsIgnoreCase(roleName)) {
                studentProfileService.createDefaultProfile(newUser.getId());
            }
        }

        return null; // null = thành công
    }

    // -------------------------------------------------------------------------
    // Đăng nhập bằng email/password
    // -------------------------------------------------------------------------
    public User login(String email, String password) throws Exception {
        User user = userDao.findByEmail(email);
        if (user == null) {
            throw new Exception("Email hoặc mật khẩu không chính xác.");
        }

        // User đăng ký qua OAuth không có password_hash
        if (user.getPasswordHash() == null) {
            throw new Exception("Tài khoản này đăng ký qua Google. Vui lòng đăng nhập bằng Google.");
        }

        if (!PasswordUtil.checkPassword(password, user.getPasswordHash())) {
            throw new Exception("Email hoặc mật khẩu không chính xác.");
        }

        if (!"active".equalsIgnoreCase(user.getAccountStatus())) {
            throw new Exception("Tài khoản của bạn đã bị vô hiệu hoá.");
        }

        // Gắn danh sách role vào user object
        List<Role> roles = userRoleDao.getRolesByUserId(user.getId());
        user.setRoles(roles);

        return user;
    }

    // -------------------------------------------------------------------------
    // Xử lý Google OAuth Callback (Onboarding Flow - Giải pháp 2)
    //
    // Trả về User (đã có id, roles, onboardingCompleted).
    // Controller kiểm tra user.isOnboardingCompleted():
    //   false → redirect /onboarding.jsp
    //   true  → redirect /dashboard
    // -------------------------------------------------------------------------
    public User loginOrRegisterWithOAuth(String provider, String sub,
                                         String email, String displayName, String avatarUrl) throws Exception {
        // Bước 1: Tìm user đã tồn tại theo OAuth sub
        User user = userDao.findByOAuth(provider, sub);

        if (user == null) {
            // Bước 2a: Chưa có → Tạo mới với onboarding_completed = false
            user = new User();
            user.setEmail(email);
            user.setDisplayName(displayName);
            user.setAvatarUrl(avatarUrl);
            user.setOauthProvider(provider);
            user.setOauthSub(sub);

            if (!userDao.createUserFromOAuth(user)) {
                throw new Exception("Không thể tạo tài khoản. Vui lòng thử lại.");
            }

            // Gán tạm role mặc định 'student' (sẽ được cập nhật tại /onboarding.jsp)
            Role studentRole = roleDao.findRoleByName("student");
            if (studentRole != null) {
                userRoleDao.assignRole(user.getId(), studentRole.getId());
                // Mặc định OAuth mới là student, khởi tạo profile
                studentProfileService.createDefaultProfile(user.getId());
            }
        }

        // Bước 2b / 3: User đã tồn tại → kiểm tra account_status
        if (!"active".equalsIgnoreCase(user.getAccountStatus())) {
            throw new Exception("Tài khoản của bạn đã bị vô hiệu hoá.");
        }

        // Gắn roles
        List<Role> roles = userRoleDao.getRolesByUserId(user.getId());
        user.setRoles(roles);

        return user;
        // Controller sẽ xử lý redirect dựa vào user.isOnboardingCompleted()
    }

    // -------------------------------------------------------------------------
    // Cập nhật hồ sơ cá nhân (Họ và tên, ảnh đại diện)
    // -------------------------------------------------------------------------
    public boolean updateProfile(User user) {
        if (user == null || user.getId() == null) return false;
        return userDao.updateUser(user);
    }

    // -------------------------------------------------------------------------
    // Đổi mật khẩu đăng nhập
    // -------------------------------------------------------------------------
    public void changePassword(String userId, String currentPassword, String newPassword) throws Exception {
        User user = userDao.findById(userId);
        if (user == null) {
            throw new Exception("Tài khoản không tồn tại.");
        }
        // Nếu tài khoản đã có mật khẩu, kiểm tra khớp mật khẩu cũ.
        // Nếu tài khoản Google OAuth chưa có mật khẩu, cho phép thiết lập mật khẩu mới trực tiếp.
        if (user.getPasswordHash() != null && !user.getPasswordHash().trim().isEmpty()) {
            if (!PasswordUtil.checkPassword(currentPassword, user.getPasswordHash())) {
                throw new Exception("Mật khẩu hiện tại không chính xác.");
            }
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new Exception("Mật khẩu mới phải có ít nhất 6 ký tự.");
        }
        if (!newPassword.matches(".*[a-zA-Z].*") || !newPassword.matches(".*\\d.*")) {
            throw new Exception("Mật khẩu phải bao gồm cả chữ cái và chữ số để đảm bảo an toàn.");
        }
        
        String newHash = PasswordUtil.hashPassword(newPassword);
        if (!userDao.updatePassword(userId, newHash)) {
            throw new Exception("Không thể cập nhật mật khẩu mới vào cơ sở dữ liệu.");
        }
    }
}
