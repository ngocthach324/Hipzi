-- ============================================================
-- HIPZI - OTP / 2FA Migration
-- Database: PostgreSQL (Supabase)
-- File:     02-otp-2fa-tables.sql
-- Scope:    Thêm cột 2FA vào bảng users, tạo bảng otp_codes
--
-- Business Rules Covered:
--   BR-SEC-001: Email phải được xác minh trước khi kích hoạt tài khoản.
--   BR-SEC-002: 2FA bằng OTP là tùy chọn, user tự bật/tắt trong phần Bảo mật.
--   BR-SEC-003: Mã OTP hết hạn sau 5 phút và chỉ được dùng 1 lần.
--   BR-SEC-004: Cho phép tối đa 5 lần thử sai, sau đó OTP bị vô hiệu.
-- ============================================================


-- ============================================================
-- BƯỚC 1: Thêm cột vào bảng users
-- ============================================================

-- Cờ email đã xác minh (email_verified)
-- false: user vừa đăng ký, chưa nhập OTP xác thực
-- true : user đã xác thực email lần đầu thành công
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT false;

-- Cờ bật/tắt 2FA khi đăng nhập
-- false: đăng nhập bình thường (mặc định)
-- true : sau khi nhập mật khẩu đúng, yêu cầu thêm OTP
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN NOT NULL DEFAULT false;


-- ============================================================
-- BẢNG: otp_codes
-- Lưu mã OTP tạm thời cho các mục đích khác nhau:
--   'register'   : xác minh email khi đăng ký lần đầu
--   'login'      : xác thực bước 2 khi đăng nhập (nếu 2FA bật)
--   'disable_2fa': xác nhận danh tính trước khi tắt 2FA
--
-- Thiết kế quan trọng:
--   - code lưu dưới dạng SHA-256 hash (KHÔNG lưu plaintext).
--   - user_id có thể NULL khi đăng ký (chưa tạo user xong).
--   - email bắt buộc để tra cứu khi user_id chưa có.
--   - expires_at được kiểm tra trước khi validate.
--   - used_at NULL = chưa dùng; NOT NULL = đã dùng (vô hiệu hóa).
--   - attempt_count giới hạn số lần thử sai (tối đa 5).
-- ============================================================

CREATE TABLE IF NOT EXISTS otp_codes (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Liên kết với user (NULL trong giai đoạn đăng ký chưa hoàn tất)
    user_id         UUID        REFERENCES users(id) ON DELETE CASCADE,

    -- Email đích nhận OTP (bắt buộc, dùng để tra cứu khi user_id NULL)
    email           TEXT        NOT NULL,

    -- Mã OTP đã hash SHA-256 (KHÔNG lưu plaintext)
    code_hash       TEXT        NOT NULL,

    -- Mục đích sử dụng OTP
    purpose         TEXT        NOT NULL
                    CHECK (purpose IN ('register', 'login', 'disable_2fa')),

    -- Thời điểm hết hạn (= created_at + 5 phút)
    expires_at      TIMESTAMPTZ NOT NULL,

    -- Đánh dấu đã dùng (NULL = chưa dùng)
    used_at         TIMESTAMPTZ,

    -- Đếm số lần thử sai (tối đa 5, sau đó coi như hết hạn)
    attempt_count   INTEGER     NOT NULL DEFAULT 0,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index tra cứu OTP theo email + mục đích (dùng nhiều nhất)
CREATE INDEX IF NOT EXISTS idx_otp_codes_email_purpose
    ON otp_codes (email, purpose)
    WHERE used_at IS NULL;

-- Index tra cứu OTP theo user_id (dùng cho login 2FA)
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_id
    ON otp_codes (user_id)
    WHERE used_at IS NULL AND user_id IS NOT NULL;

-- Index dọn dẹp OTP hết hạn (job định kỳ)
CREATE INDEX IF NOT EXISTS idx_otp_codes_expires_at
    ON otp_codes (expires_at);


-- ============================================================
-- DỌN DẸP ĐỊNH KỲ (Tuỳ chọn - chạy bằng pg_cron hoặc job)
-- Xoá các OTP đã hết hạn hoặc đã dùng quá 24 giờ
-- ============================================================
-- DELETE FROM otp_codes
-- WHERE expires_at < NOW() - INTERVAL '24 hours'
--    OR used_at    < NOW() - INTERVAL '24 hours';


-- ============================================================
-- GHI CHÚ TRIỂN KHAI
-- ============================================================
--
-- [LUỒNG ĐĂNG KÝ]
--   1. User điền form → RegisterServlet nhận request.
--   2. Kiểm tra email chưa tồn tại trong bảng users.
--   3. Gọi OtpService.generateAndSend(email, 'register') →
--        INSERT INTO otp_codes (email, code_hash, purpose, expires_at)
--   4. Redirect sang /verify-otp?purpose=register&email=...
--   5. User nhập OTP → VerifyRegisterOtpServlet:
--        Gọi OtpService.validate(email, inputCode, 'register')
--        Nếu hợp lệ:
--          - INSERT INTO users → INSERT INTO user_roles
--          - UPDATE otp_codes SET used_at = NOW()
--          - UPDATE users SET email_verified = true
--          - Tạo session loggedUser → redirect /dashboard
--
-- [LUỒNG ĐĂNG NHẬP 2FA]
--   1. LoginServlet xác thực email + password thành công.
--   2. Nếu user.two_factor_enabled = true:
--        Gọi OtpService.generateAndSend(email, 'login')
--        Lưu session: pending_2fa_user_id = user.getId()
--        Redirect /verify-otp?purpose=login
--   3. Nếu two_factor_enabled = false: tạo session ngay → /dashboard
--   4. VerifyLoginOtpServlet xác thực OTP → tạo session loggedUser
--
-- [LUỒNG TẮT 2FA]
--   1. User nhấn "Tắt bảo mật 2 lớp" tại trang Profile.
--   2. Gọi OtpService.generateAndSend(email, 'disable_2fa')
--   3. User nhập OTP xác nhận → TwoFactorSettingsServlet:
--        UPDATE users SET two_factor_enabled = false
--
-- ============================================================
