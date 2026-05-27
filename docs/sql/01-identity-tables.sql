-- ============================================================
-- HIPZI - MVP Identity Tables
-- Database: PostgreSQL (Supabase)
-- File:     01-identity-tables.sql
-- Scope:    users, roles, user_roles
--
-- Business Rules Covered:
--   BR-ROLE-001: Every user must have at least one role.
--   BR-ROLE-004: Multiple roles require Admin assignment.
--   DEC-013:     Use relational database as primary database.
--   DEC-016:     Use session-based authentication for MVP.
-- ============================================================


-- ============================================================
-- BẢNG 1: roles
-- Lưu danh sách vai trò của nền tảng.
-- Dữ liệu cố định, được seeded thủ công.
-- Ghi chú: staff & admin chỉ được gán qua Supabase Dashboard.
-- ============================================================

CREATE TABLE IF NOT EXISTS roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index tra cứu theo tên role (dùng trong AuthService, RolePermissionService)
CREATE INDEX IF NOT EXISTS idx_roles_name ON roles (name);

-- Seed dữ liệu 5 vai trò chuẩn của HipZi
INSERT INTO roles (name, description) VALUES
    ('student',  'Học viên - truy cập tài liệu và luyện tập được duyệt'),
    ('parent',   'Phụ huynh - theo dõi tiến độ học tập của con'),
    ('teacher',  'Giảng viên - tải lên tài liệu và tạo nội dung AI sau khi được duyệt'),
    ('staff',    'Nhân viên kiểm duyệt - xét duyệt hồ sơ giảng viên và tài liệu'),
    ('admin',    'Quản trị viên - quản lý vai trò, quản trị nền tảng và kiểm tra audit')
ON CONFLICT (name) DO NOTHING;


-- ============================================================
-- BẢNG 2: users
-- Lưu thông tin tài khoản cốt lõi của người dùng.
--
-- Thiết kế quan trọng:
--   - Hỗ trợ cả 2 phương thức đăng nhập:
--       (1) Email + Password (đăng ký thủ công)
--       (2) OAuth 2.0 (Google, v.v.)
--   - password_hash có thể NULL nếu user đăng ký qua OAuth.
--   - oauth_provider + oauth_sub là cặp duy nhất định danh OAuth user.
--   - email UNIQUE để ngăn đăng ký trùng lặp.
--   - account_status kiểm soát quyền truy cập vào nền tảng.
--   - Soft delete qua deleted_at (không xoá vật lý).
-- ============================================================

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
    deleted_at      TIMESTAMPTZ                 -- Soft delete (NULL = chưa xoá)
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

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email         ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_account_status ON users (account_status);
CREATE INDEX IF NOT EXISTS idx_users_oauth          ON users (oauth_provider, oauth_sub);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at     ON users (deleted_at) WHERE deleted_at IS NULL;


-- ============================================================
-- BẢNG 3: user_roles
-- Bảng nối nhiều-nhiều giữa users và roles.
--
-- Thiết kế quan trọng:
--   - Mỗi user có thể giữ nhiều role (BR-ROLE-004).
--   - role phải được Admin gán thủ công (qua Supabase hoặc Admin panel).
--   - is_active = false khi role bị thu hồi (revoke), không xoá bản ghi
--     để đảm bảo auditability (DEC-017).
--   - assigned_by_user_id ghi lại Admin đã gán (hỗ trợ audit log).
--
-- Luồng đăng ký thông thường:
--   RegisterServlet → UserDao.insert() → UserRoleDao.insert(userId, roleId)
--   Trong đó roleId được lấy từ RoleDao.findByName("student" | "parent" | "teacher")
--   dựa trên tham số "role" người dùng chọn trên form.
-- ============================================================

CREATE TABLE IF NOT EXISTS user_roles (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id             UUID        NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    assigned_by_user_id UUID        REFERENCES users(id) ON DELETE SET NULL,
                                    -- NULL = hệ thống tự gán (đăng ký thông thường)
    is_active           BOOLEAN     NOT NULL DEFAULT true,
    assigned_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at          TIMESTAMPTZ             -- NULL = vẫn còn hiệu lực

    -- Mỗi user chỉ có thể giữ một instance của mỗi role tại một thời điểm
    -- (Dùng UNIQUE partial index bên dưới thay vì UNIQUE constraint
    --  để cho phép revoke rồi gán lại sau)
);

-- Partial UNIQUE index: một user không thể có 2 role giống nhau đang active cùng lúc
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_roles_active
    ON user_roles (user_id, role_id)
    WHERE is_active = true;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id  ON user_roles (user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id  ON user_roles (role_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_is_active ON user_roles (user_id, is_active);


-- ============================================================
-- TRIGGER: tự động cập nhật updated_at trên bảng users
-- ============================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();


-- ============================================================
-- GHI CHÚ TRIỂN KHAI
-- ============================================================
--
-- [LUỒNG 1] Đăng ký thông thường (email/password + chọn role trên form):
--
--   INSERT INTO users (email, password_hash, display_name, onboarding_completed)
--   VALUES (?, ?, ?, true)          ← true vì user đã chọn role trên form
--
--   INSERT INTO user_roles (user_id, role_id)
--   VALUES (userId, roleId)         ← roleId theo lựa chọn 'student'|'parent'|'teacher'
--
--   → Sau đăng ký: redirect /dashboard  (không cần onboarding)
--
-- ------------------------------------------------------------
-- [LUỒNG 2] Đăng ký / Đăng nhập qua Google OAuth (Giải pháp 2 - Onboarding Flow):
--
--   Bước 1 - Callback nhận thông tin từ Google:
--     SELECT id FROM users WHERE oauth_provider='google' AND oauth_sub=?
--
--   Bước 2a - User CHƯA tồn tại (đăng ký mới):
--     INSERT INTO users (email, display_name, avatar_url,
--                        oauth_provider, oauth_sub,
--                        onboarding_completed)
--     VALUES (?, ?, ?, 'google', ?, false)   ← false: chưa chọn role
--
--     INSERT INTO user_roles (user_id, role_id)
--     VALUES (userId, studentRoleId)          ← Gán tạm role mặc định 'student'
--
--     → redirect /onboarding.jsp
--
--   Bước 2b - User ĐÃ tồn tại (đăng nhập lại):
--     IF onboarding_completed = false → redirect /onboarding.jsp
--     IF onboarding_completed = true  → redirect /dashboard
--
--   Bước 3 - Tại /onboarding.jsp, user chọn role thật:
--     DELETE FROM user_roles WHERE user_id=? AND is_active=true  (xóa role tạm)
--     INSERT INTO user_roles (user_id, role_id) VALUES (?, selectedRoleId)
--     UPDATE users SET onboarding_completed=true WHERE id=?
--     → redirect /dashboard
--
-- ------------------------------------------------------------
-- [LUỒNG 3] Liên kết tài khoản email đã có với Google:
--   Nếu email đã tồn tại nhưng oauth_sub = NULL:
--   UPDATE users SET oauth_provider='google', oauth_sub=? WHERE email=?
--   → Không tạo user mới, không thay đổi role.
--
-- ------------------------------------------------------------
-- [QUAN TRỌNG] staff & admin KHÔNG được tạo qua bất kỳ form đăng ký nào.
--   Chỉ gán thủ công qua Supabase Dashboard hoặc trang Admin panel.
-- ============================================================

