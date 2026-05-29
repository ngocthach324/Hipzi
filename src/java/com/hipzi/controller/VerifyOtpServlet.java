package com.hipzi.controller;

import com.hipzi.dao.RoleDao;
import com.hipzi.dao.UserDao;
import com.hipzi.dao.UserRoleDao;
import com.hipzi.model.Role;
import com.hipzi.model.User;
import com.hipzi.service.OtpService;
import com.hipzi.service.OtpService.OtpValidationResult;
import com.hipzi.service.RememberMeService;
import com.hipzi.util.PasswordUtil;

import com.hipzi.service.StudentProfileService;
import com.hipzi.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet xử lý xác thực OTP đăng ký.
 *
 * Luồng thành công:
 *   1. Xác thực OTP hợp lệ.
 *   2. Tạo user mới từ pending data trong session.
 *   3. Gán role đã chọn.
 *   4. Đánh dấu email_verified = true.
 *   5. Tạo session loggedUser → redirect /dashboard.
 *
 * Route: GET /verify-otp?purpose=register  (hiển thị form)
 *        POST /verify-otp                  (xử lý submit)
 */
@WebServlet("/verify-otp")
public class VerifyOtpServlet extends HttpServlet {

    private final OtpService  otpService  = new OtpService();
    private final UserDao     userDao     = new UserDao();
    private final UserRoleDao userRoleDao = new UserRoleDao();
    private final RoleDao     roleDao     = new RoleDao();
    private final StudentProfileService studentProfileService = new StudentProfileService();
    private final com.hipzi.service.NotificationService notificationService = new com.hipzi.service.NotificationService();
    private final RememberMeService rememberMeService = new RememberMeService();

    // =========================================================================
    // GET: Hiển thị form nhập OTP
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String purpose = req.getParameter("purpose");
        if (purpose == null) purpose = "register";

        // Lấy email từ session để hiển thị (đã che)
        HttpSession session = req.getSession(false);
        String rawEmail = getEmailFromSession(session, purpose);
        if (rawEmail == null) {
            if ("login".equals(purpose) || "disable_2fa".equals(purpose)) {
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                resp.sendRedirect(req.getContextPath() + "/register.jsp?error=session_expired");
            }
            return;
        }

        req.setAttribute("purpose",     purpose);
        req.setAttribute("maskedEmail", com.hipzi.util.OtpUtil.maskEmail(rawEmail));
        req.setAttribute("otpError",    session != null ? session.getAttribute("otp_error") : null);

        if (session != null) session.removeAttribute("otp_error");

        req.getRequestDispatcher("/verify-otp.jsp").forward(req, resp);
    }

    // =========================================================================
    // POST: Xử lý mã OTP người dùng nhập
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String purpose  = req.getParameter("purpose");
        String inputOtp = req.getParameter("otp");

        if (purpose == null || inputOtp == null || session == null) {
            resp.sendRedirect(req.getContextPath() + "/register.jsp?error=invalid_request");
            return;
        }

        String email = getEmailFromSession(session, purpose);
        if (email == null) {
            resp.sendRedirect(req.getContextPath() + "/register.jsp?error=session_expired");
            return;
        }

        // --- Xác thực OTP ---
        OtpValidationResult result = otpService.validate(email, inputOtp, purpose);

        if (result != OtpValidationResult.SUCCESS) {
            session.setAttribute("otp_error", OtpService.getErrorMessage(result));
            resp.sendRedirect(req.getContextPath() + "/verify-otp?purpose=" + purpose);
            return;
        }

        // --- Xử lý theo mục đích ---
        switch (purpose) {
            case "register":
                handleRegisterSuccess(req, resp, session, email);
                break;
            case "login":
                handleLoginSuccess(req, resp, session);
                break;
            case "disable_2fa":
                handleDisable2faSuccess(req, resp, session);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    // =========================================================================
    // Luồng đăng ký: Tạo user + gán role + đăng nhập
    // =========================================================================
    private void handleRegisterSuccess(HttpServletRequest req, HttpServletResponse resp,
                                       HttpSession session, String email) throws IOException {

        String passwordHash = (String) session.getAttribute("pending_register_hash");
        String displayName  = (String) session.getAttribute("pending_register_name");
        String roleName     = (String) session.getAttribute("pending_register_role");

        // Tạo user mới
        User newUser = new User();
        newUser.setEmail(email);
        newUser.setPasswordHash(passwordHash);
        newUser.setDisplayName(displayName);
        newUser.setOnboardingCompleted(true);

        if (!userDao.createUser(newUser)) {
            session.setAttribute("otp_error", "Không thể tạo tài khoản. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/verify-otp?purpose=register");
            return;
        }

        // Gán role
        Role role = roleDao.findRoleByName(roleName != null ? roleName : "student");
        if (role != null) {
            userRoleDao.assignRole(newUser.getId(), role.getId());
            
            // Khởi tạo profile học sinh nếu role là student
            if ("student".equalsIgnoreCase(role.getName())) {
                studentProfileService.createDefaultProfile(newUser.getId());
                
                // Tạo thông báo chào mừng
                notificationService.sendToUser(
                    newUser.getId(), 
                    "Chào mừng tân học viên gia nhập HIPZI!", 
                    "Tài khoản của bạn đã được khởi tạo thành công. Hãy bổ sung đầy đủ thông tin cá nhân để nhận các đề xuất tài liệu phù hợp nhất nhé.",
                    "success"
                );
            }
        }

        // Đánh dấu email đã xác minh
        userDao.setEmailVerified(newUser.getId());

        // Dọn dẹp pending data
        session.removeAttribute("pending_register_email");
        session.removeAttribute("pending_register_name");
        session.removeAttribute("pending_register_hash");
        session.removeAttribute("pending_register_role");

        // Load đầy đủ roles rồi đăng nhập
        List<com.hipzi.model.Role> roles = userRoleDao.getRolesByUserId(newUser.getId());
        newUser.setRoles(roles);
        session.setAttribute("loggedUser", newUser);

        String targetUrl = "student-profile";
        if (roleName != null) {
            switch (roleName.toLowerCase()) {
                case "parent":  targetUrl = "parent-profile"; break;
                case "teacher": targetUrl = "teacher-profile"; break;
                case "staff":   targetUrl = "staff-profile"; break;
                case "admin":   targetUrl = "admin-profile"; break;
                default:        targetUrl = "student-profile"; break;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/" + targetUrl + "?welcome=true");
    }

    // =========================================================================
    // Luồng đăng nhập 2FA: Kích hoạt session
    // =========================================================================
    private void handleLoginSuccess(HttpServletRequest req, HttpServletResponse resp,
                                    HttpSession session) throws IOException {

        String pendingUserId = (String) session.getAttribute("pending_2fa_user_id");
        if (pendingUserId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=session_expired");
            return;
        }

        User user = userDao.findById(pendingUserId);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=user_not_found");
            return;
        }

        List<com.hipzi.model.Role> roles = userRoleDao.getRolesByUserId(user.getId());
        user.setRoles(roles);
        session.setAttribute("loggedUser", user);
        if (Boolean.TRUE.equals(session.getAttribute("pending_remember_me"))) {
            rememberMeService.issueRememberCookie(user, req, resp);
        } else {
            rememberMeService.clearRememberCookie(req, resp);
        }
        session.removeAttribute("pending_2fa_user_id");
        session.removeAttribute("pending_remember_me");

        if (!user.isOnboardingCompleted()) {
            resp.sendRedirect(req.getContextPath() + "/onboarding");
            return;
        }

        String targetUrl = "student-profile";
        if (roles != null) {
            boolean hasParent = false, hasTeacher = false, hasStaff = false, hasAdmin = false;
            for (com.hipzi.model.Role r : roles) {
                String rn = r.getName().toLowerCase();
                if ("parent".equals(rn)) hasParent = true;
                if ("teacher".equals(rn)) hasTeacher = true;
                if ("staff".equals(rn)) hasStaff = true;
                if ("admin".equals(rn)) hasAdmin = true;
            }
            if (hasAdmin) targetUrl = "admin-profile";
            else if (hasStaff) targetUrl = "staff-profile";
            else if (hasTeacher) targetUrl = "teacher-profile";
            else if (hasParent) targetUrl = "parent-profile";
        }

        resp.sendRedirect(req.getContextPath() + "/" + targetUrl);
    }

    // =========================================================================
    // Luồng tắt 2FA: Cập nhật cờ trong DB
    // =========================================================================
    private void handleDisable2faSuccess(HttpServletRequest req, HttpServletResponse resp,
                                         HttpSession session) throws IOException {

        User loggedUser = (User) session.getAttribute("loggedUser");
        if (loggedUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        otpService.disableTwoFactor(loggedUser.getId());

        // Cập nhật session
        loggedUser.setTwoFactorEnabled(false);
        session.setAttribute("loggedUser", loggedUser);

        resp.sendRedirect(req.getContextPath() + "/profile?success=2fa_disabled");
    }

    // =========================================================================
    // Helper: Lấy email từ session theo purpose
    // =========================================================================
    private String getEmailFromSession(HttpSession session, String purpose) {
        if (session == null) return null;
        switch (purpose) {
            case "register":   return (String) session.getAttribute("pending_register_email");
            case "login":
                String uid = (String) session.getAttribute("pending_2fa_user_id");
                if (uid == null) return null;
                User u = new UserDao().findById(uid);
                return u != null ? u.getEmail() : null;
            case "disable_2fa":
                User lu = (User) session.getAttribute("loggedUser");
                return lu != null ? lu.getEmail() : null;
            default: return null;
        }
    }
}
