CREATE TABLE IF NOT EXISTS roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_roles_name ON roles (name);

INSERT INTO roles (name, description) VALUES
    ('student',  'Học viên - truy cập tài liệu và luyện tập được duyệt'),
    ('parent',   'Phụ huynh - theo dõi tiến độ học tập của con'),
    ('teacher',  'Giảng viên - tải lên tài liệu và tạo nội dung AI sau khi được duyệt'),
    ('staff',    'Nhân viên kiểm duyệt - xét duyệt hồ sơ giảng viên và tài liệu'),
    ('admin',    'Quản trị viên - quản lý vai trò, quản trị nền tảng và kiểm tra audit')
ON CONFLICT (name) DO NOTHING;

CREATE TABLE IF NOT EXISTS users (
    -- Định danh
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Thông tin tài khoản
    email           TEXT        NOT NULL UNIQUE,
    password_hash   TEXT,                       -- NULL nếu đăng ký qua OAuth
    display_name    TEXT        NOT NULL,
    avatar_url      TEXT,

    -- OAuth (Google / bên thứ 3)
    -- Cặp (oauth_provider, oauth_sub) phải là duy nhất
    oauth_provider  TEXT,                       -- ví dụ: 'google', 'facebook'
    oauth_sub       TEXT,                       -- Subject ID từ OAuth provider

    -- Trạng thái tài khoản
    -- 'active'    : tài khoản hoạt động bình thường
    -- 'suspended' : bị tạm khóa bởi Admin (BR-TCH-007)
    -- 'disabled'  : bị vô hiệu hóa vĩnh viễn
    account_status          TEXT        NOT NULL DEFAULT 'active'
                            CHECK (account_status IN ('active', 'suspended', 'disabled')),

    -- Onboarding Flow (Giải pháp 2 - Default Role + Chuyển hướng)
    -- false : user chưa hoàn thành chọn role → redirect /onboarding.jsp
    -- true  : user đã xác nhận role → vào /dashboard bình thường
    --
    -- Áp dụng cho:
    --   (1) Đăng ký qua Google OAuth (role mặc định là student, chờ xác nhận)
    --   (2) Đăng ký email thông thường → true ngay vì đã chọn role trên form
    onboarding_completed    BOOLEAN     NOT NULL DEFAULT false,

    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ,                 -- Soft delete (NULL = chưa xoá)

    -- Cờ email đã xác minh
    email_verified BOOLEAN NOT NULL DEFAULT false,

    -- Cờ bật/tắt 2FA
    two_factor_enabled BOOLEAN NOT NULL DEFAULT false
);

-- Ràng buộc: mỗi OAuth account là duy nhất
ALTER TABLE users
    ADD CONSTRAINT uq_users_oauth_provider_sub
    UNIQUE (oauth_provider, oauth_sub);

-- Ràng buộc logic: user phải có ít nhất 1 trong 2 phương thức xác thực
-- (Nếu không có password_hash thì phải có oauth_provider)
ALTER TABLE users
    ADD CONSTRAINT chk_users_auth_method
    CHECK (
        password_hash IS NOT NULL
        OR (oauth_provider IS NOT NULL AND oauth_sub IS NOT NULL)
    );

CREATE INDEX IF NOT EXISTS idx_users_email         ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_account_status ON users (account_status);
CREATE INDEX IF NOT EXISTS idx_users_oauth          ON users (oauth_provider, oauth_sub);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at     ON users (deleted_at) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS user_roles (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id             UUID        NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    assigned_by_user_id UUID        REFERENCES users(id) ON DELETE SET NULL,
                                    -- NULL = hệ thống tự gán (đăng ký thông thường)
    is_active           BOOLEAN     NOT NULL DEFAULT true,
    assigned_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at          TIMESTAMPTZ             -- NULL = vẫn còn hiệu lực
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_user_roles_active
    ON user_roles (user_id, role_id)
    WHERE is_active = true;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id  ON user_roles (user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id  ON user_roles (role_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_is_active ON user_roles (user_id, is_active);

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

CREATE TABLE IF NOT EXISTS remember_me_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    selector VARCHAR(64) UNIQUE NOT NULL,
    validator_hash VARCHAR(128) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_selector
    ON remember_me_tokens(selector)
    WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_user_id
    ON remember_me_tokens(user_id);
