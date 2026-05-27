package com.hipzi.service;

import com.hipzi.dao.OtpDao;
import com.hipzi.dao.UserDao;
import com.hipzi.model.OtpCode;
import com.hipzi.model.User;
import com.hipzi.util.EmailService;
import com.hipzi.util.OtpUtil;

import java.sql.Timestamp;

/**
 * Service xử lý toàn bộ business logic của OTP và 2FA.
 *
 * Business Rules:
 *   - BR-SEC-001: Mã OTP hết hạn sau 5 phút.
 *   - BR-SEC-002: Tối đa 5 lần thử sai, sau đó OTP bị vô hiệu.
 *   - BR-SEC-003: Rate limit: không gửi OTP mới trong vòng 60 giây.
 *   - BR-SEC-004: OTP cũ bị vô hiệu ngay khi sinh OTP mới.
 *   - BR-SEC-005: OTP được hash SHA-256, không lưu plaintext.
 */
public class OtpService {

    private static final int OTP_EXPIRY_MINUTES = 5;

    private final OtpDao  otpDao  = new OtpDao();
    private final UserDao userDao = new UserDao();

    // =========================================================================
    // SINH VÀ GỬI OTP
    // =========================================================================

    /**
     * Sinh OTP, lưu vào DB và gửi email cho người dùng.
     *
     * @param email       Email nhận OTP
     * @param userId      ID user (null nếu chưa đăng ký xong)
     * @param displayName Tên hiển thị trong email
     * @param purpose     'register' | 'login' | 'disable_2fa'
     * @throws IllegalStateException nếu đang trong rate limit (60 giây)
     * @throws RuntimeException      nếu gửi email thất bại
     */
    public void generateAndSend(String email, String userId, String displayName, String purpose) {
        // --- BR-SEC-003: Kiểm tra rate limit ---
        if (otpDao.hasRecentOtp(email, purpose)) {
            throw new IllegalStateException("Vui lòng chờ ít nhất 60 giây trước khi gửi lại mã OTP.");
        }

        // --- BR-SEC-004: Vô hiệu hóa các OTP cũ cùng purpose ---
        otpDao.invalidateOldOtps(email, purpose);

        // --- Sinh mã OTP ---
        String otp     = OtpUtil.generateOtp();
        String otpHash = OtpUtil.hashOtp(otp);

        // --- Tạo bản ghi trong DB ---
        OtpCode otpCode = new OtpCode();
        otpCode.setUserId(userId);
        otpCode.setEmail(email);
        otpCode.setCodeHash(otpHash);
        otpCode.setPurpose(purpose);
        otpCode.setExpiresAt(new Timestamp(System.currentTimeMillis() + OTP_EXPIRY_MINUTES * 60 * 1000L));

        if (!otpDao.insert(otpCode)) {
            throw new RuntimeException("Không thể tạo mã OTP. Vui lòng thử lại.");
        }

        // --- Gửi email theo mục đích ---
        switch (purpose) {
            case "register":
                EmailService.sendRegisterOtp(email, displayName, otp);
                break;
            case "login":
                EmailService.sendLoginOtp(email, displayName, otp);
                break;
            case "disable_2fa":
                EmailService.sendDisable2faOtp(email, displayName, otp);
                break;
            default:
                throw new IllegalArgumentException("Purpose không hợp lệ: " + purpose);
        }
    }

    // =========================================================================
    // XÁC THỰC OTP
    // =========================================================================

    /**
     * Kết quả xác thực OTP.
     */
    public enum OtpValidationResult {
        SUCCESS,         // OTP hợp lệ
        NOT_FOUND,       // Không tìm thấy OTP active cho email + purpose
        EXPIRED,         // OTP đã hết hạn
        ALREADY_USED,    // OTP đã được dùng trước đó
        MAX_ATTEMPTS,    // Đã thử quá 5 lần sai
        WRONG_CODE       // Mã nhập sai (attempt_count tăng)
    }

    /**
     * Xác thực OTP người dùng nhập vào.
     *
     * Nếu SUCCESS: đánh dấu OTP đã dùng (used_at = NOW()).
     * Nếu WRONG_CODE: tăng attempt_count lên 1.
     *
     * @param email     Email của user
     * @param inputCode Mã OTP người dùng nhập (plaintext)
     * @param purpose   'register' | 'login' | 'disable_2fa'
     * @return OtpValidationResult enum
     */
    public OtpValidationResult validate(String email, String inputCode, String purpose) {
        OtpCode otpCode = otpDao.findActiveByEmailAndPurpose(email, purpose);

        if (otpCode == null) {
            return OtpValidationResult.NOT_FOUND;
        }
        if (otpCode.isUsed()) {
            return OtpValidationResult.ALREADY_USED;
        }
        if (otpCode.isExpired()) {
            return OtpValidationResult.EXPIRED;
        }
        if (otpCode.getAttemptCount() >= 5) {
            return OtpValidationResult.MAX_ATTEMPTS;
        }

        // --- Kiểm tra mã nhập ---
        if (!OtpUtil.verifyOtp(inputCode, otpCode.getCodeHash())) {
            otpDao.incrementAttempt(otpCode.getId());
            return OtpValidationResult.WRONG_CODE;
        }

        // --- Thành công: đánh dấu đã dùng ---
        otpDao.markUsed(otpCode.getId());
        return OtpValidationResult.SUCCESS;
    }

    // =========================================================================
    // BẬT / TẮT 2FA
    // =========================================================================

    /**
     * Bật 2FA cho user. Yêu cầu email đã được xác minh.
     *
     * @param userId ID của user
     * @return true nếu thành công
     */
    public boolean enableTwoFactor(String userId) {
        return userDao.setTwoFactorEnabled(userId, true);
    }

    /**
     * Tắt 2FA cho user (sau khi OTP 'disable_2fa' đã validate thành công).
     *
     * @param userId ID của user
     * @return true nếu thành công
     */
    public boolean disableTwoFactor(String userId) {
        return userDao.setTwoFactorEnabled(userId, false);
    }

    // =========================================================================
    // HELPER: Thông báo lỗi thân thiện từ OtpValidationResult
    // =========================================================================

    /**
     * Chuyển đổi OtpValidationResult thành thông báo tiếng Việt.
     */
    public static String getErrorMessage(OtpValidationResult result) {
        switch (result) {
            case NOT_FOUND:    return "Mã OTP không tồn tại hoặc đã hết hiệu lực. Vui lòng yêu cầu gửi lại.";
            case EXPIRED:      return "Mã OTP đã hết hạn (sau 5 phút). Vui lòng yêu cầu gửi lại mã mới.";
            case ALREADY_USED: return "Mã OTP này đã được sử dụng. Vui lòng yêu cầu gửi lại.";
            case MAX_ATTEMPTS: return "Bạn đã thử quá 5 lần. Mã OTP đã bị vô hiệu. Vui lòng yêu cầu gửi lại.";
            case WRONG_CODE:   return "Mã OTP không đúng. Vui lòng kiểm tra lại email của bạn.";
            default:           return "Có lỗi xảy ra. Vui lòng thử lại.";
        }
    }
}
