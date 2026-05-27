package com.hipzi.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class PasswordUtil {
    
    /**
     * Tạm thời sử dụng SHA-256 cơ bản để mã hoá mật khẩu, 
     * dễ dàng tích hợp mà không cần thêm file .jar ngay lập tức.
     * Trong tương lai nên chuyển sang BCrypt hoặc PBKDF2.
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Could not hash password", e);
        }
    }

    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        // Hỗ trợ mượt mà các tài khoản test được seed bằng mật khẩu dạng plain text trong CSDL cục bộ
        if (plainPassword.equals(hashedPassword)) {
            return true;
        }
        String newHash = hashPassword(plainPassword);
        return newHash.equals(hashedPassword);
    }
}
