-- ==========================================
-- HỆ THỐNG KHÓA HỌC (COURSES) & SỐ DƯ (WALLET)
-- ==========================================

-- 1. Bổ sung cột Số dư (Wallet Balance) cho tất cả User
-- Nếu chưa có cột wallet_balance, thêm vào bảng users
ALTER TABLE users ADD COLUMN IF NOT EXISTS wallet_balance NUMERIC(12, 2) NOT NULL DEFAULT 0;

-- 2. Bảng Khóa học (Courses)
-- Khóa học chỉ có thể đăng bởi Staff hoặc Teacher
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    price NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Giá bằng 0 là miễn phí
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_courses_filters
    ON courses(status, price, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_courses_teacher
    ON courses(teacher_id);

-- 3. Bảng Bài học (Course Lessons)
-- Các bài học thuộc về một khóa học
CREATE TABLE IF NOT EXISTS course_lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    video_url TEXT,
    content TEXT,
    is_preview BOOLEAN NOT NULL DEFAULT false, -- Cho phép xem thử miễn phí
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_course_lessons_course
    ON course_lessons(course_id, sort_order);

-- 4. Bảng Ghi danh (Course Enrollments)
-- Học sinh mua/tham gia khóa học
CREATE TABLE IF NOT EXISTS course_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(course_id, student_id) -- Mỗi học sinh chỉ tham gia 1 khóa 1 lần
);

CREATE INDEX IF NOT EXISTS idx_course_enrollments_student
    ON course_enrollments(student_id, enrolled_at DESC);

-- 5. Bảng Giao dịch ví (Wallet Transactions) (Bổ sung để tracking lịch sử mua/bán)
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL, -- Giá trị giao dịch (+ là nạp/nhận, - là trừ/mua)
    transaction_type VARCHAR(50) NOT NULL
        CHECK (transaction_type IN ('deposit', 'withdraw', 'buy_course', 'course_revenue')),
    reference_id UUID, -- Ví dụ: Course ID nếu là mua khóa học
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user
    ON wallet_transactions(user_id, created_at DESC);
