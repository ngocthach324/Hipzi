package com.hipzi.model;

import java.sql.Timestamp;

/**
 * Model ánh xạ bảng otp_codes.
 *
 * Thiết kế:
 *   - codeHash lưu SHA-256 của mã OTP 6 số (KHÔNG lưu plaintext).
 *   - userId có thể NULL trong giai đoạn đăng ký chưa hoàn tất.
 *   - purpose phân loại mục đích: register | login | disable_2fa.
 *   - usedAt NULL = chưa dùng; NOT NULL = đã vô hiệu hóa.
 *   - attemptCount đếm số lần thử sai (tối đa 5 lần).
 */
public class OtpCode {

    private String    id;
    private String    userId;        // NULL khi đăng ký chưa tạo user
    private String    email;         // Email nhận OTP
    private String    codeHash;      // SHA-256 của mã OTP plaintext
    private String    purpose;       // 'register' | 'login' | 'disable_2fa'
    private Timestamp expiresAt;     // Thời điểm hết hạn
    private Timestamp usedAt;        // NULL = chưa dùng
    private int       attemptCount;  // Số lần thử sai
    private Timestamp createdAt;

    public OtpCode() {}

    // -------------------------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------------------------

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getCodeHash() { return codeHash; }
    public void setCodeHash(String codeHash) { this.codeHash = codeHash; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }

    public Timestamp getUsedAt() { return usedAt; }
    public void setUsedAt(Timestamp usedAt) { this.usedAt = usedAt; }

    public int getAttemptCount() { return attemptCount; }
    public void setAttemptCount(int attemptCount) { this.attemptCount = attemptCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // -------------------------------------------------------------------------
    // Helper methods
    // -------------------------------------------------------------------------

    /** Kiểm tra OTP đã hết hạn hay chưa. */
    public boolean isExpired() {
        return expiresAt != null && expiresAt.before(new Timestamp(System.currentTimeMillis()));
    }

    /** Kiểm tra OTP đã được dùng hay chưa. */
    public boolean isUsed() {
        return usedAt != null;
    }

    /** Kiểm tra OTP còn hiệu lực (chưa dùng, chưa hết hạn, chưa quá giới hạn thử). */
    public boolean isValid() {
        return !isUsed() && !isExpired() && attemptCount < 5;
    }
}
