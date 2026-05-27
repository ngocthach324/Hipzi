package com.hipzi.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * Tiện ích sinh và hash mã OTP 6 chữ số.
 *
 * Bảo mật:
 *   - Dùng SecureRandom (không phải Random) để đảm bảo ngẫu nhiên an toàn.
 *   - Mã OTP được hash SHA-256 trước khi lưu DB (không lưu plaintext).
 *   - Khi validate: hash input rồi so sánh với hash trong DB.
 */
public class OtpUtil {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final int OTP_LENGTH = 6;

    /**
     * Sinh mã OTP 6 chữ số ngẫu nhiên (an toàn mã hóa).
     * Ví dụ: "047382", "913200"
     */
    public static String generateOtp() {
        int bound = (int) Math.pow(10, OTP_LENGTH); // 1_000_000
        int otp   = SECURE_RANDOM.nextInt(bound);
        // Zero-pad để đảm bảo đúng 6 chữ số
        return String.format("%0" + OTP_LENGTH + "d", otp);
    }

    /**
     * Hash mã OTP bằng SHA-256.
     * Kết quả là chuỗi hex 64 ký tự.
     *
     * @param otpPlaintext Mã OTP 6 chữ số gốc
     * @return Chuỗi hex SHA-256
     */
    public static String hashOtp(String otpPlaintext) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(otpPlaintext.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Không thể hash OTP: SHA-256 không khả dụng", e);
        }
    }

    /**
     * Kiểm tra mã OTP người dùng nhập có khớp với hash trong DB hay không.
     *
     * @param inputOtp   Mã người dùng nhập (plaintext)
     * @param storedHash Hash SHA-256 đang lưu trong DB
     * @return true nếu hợp lệ
     */
    public static boolean verifyOtp(String inputOtp, String storedHash) {
        if (inputOtp == null || storedHash == null) return false;
        String inputHash = hashOtp(inputOtp.trim());
        return inputHash.equals(storedHash);
    }

    /**
     * Ẩn bớt địa chỉ email để hiển thị an toàn trên UI.
     * Ví dụ: "hoanganh@gmail.com" → "h*******@gmail.com"
     *
     * @param email Địa chỉ email đầy đủ
     * @return Email đã che
     */
    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "***";
        String[] parts   = email.split("@", 2);
        String   local   = parts[0];
        String   domain  = parts[1];
        if (local.length() <= 2) {
            return local.charAt(0) + "*@" + domain;
        }
        String masked = local.charAt(0) + "****" + local.charAt(local.length() - 1);
        return masked + "@" + domain;
    }
}
