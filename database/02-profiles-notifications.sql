CREATE TABLE IF NOT EXISTS student_profiles (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Thông tin hồ sơ cơ bản
    grade_level             TEXT,       -- Cấp/Lớp học viên (VD: 'Lớp 10', 'Đại học')
    school_name             TEXT,       -- Tên trường học
    
    -- Các chỉ số tiến trình học tập (Dashboard Statistics Caching - Giải pháp 1)
    current_level           INT         NOT NULL DEFAULT 1,             -- Cấp độ học viên (VD: 3)
    current_xp              INT         NOT NULL DEFAULT 0,             -- Điểm số XP tích lũy (VD: 650)
    current_streak          INT         NOT NULL DEFAULT 0,             -- Chuỗi ngày học liên tục (VD: 5)
    last_activity_date      DATE,                                       -- Ngày học tập/truy cập gần nhất để tính Streak
    completed_quizzes_count INT         NOT NULL DEFAULT 0,             -- Tổng số bài Quiz đã hoàn thành
    average_accuracy        NUMERIC(5,2) NOT NULL DEFAULT 0.00,         -- Tỷ lệ làm bài đúng trung bình (%)
    active_classes_count    INT         NOT NULL DEFAULT 0,             -- Số lượng lớp học đang tham gia
    
    -- Timestamps
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles (user_id);


CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info', -- 'info', 'success', 'warning', 'error'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- 1. Thêm cột student_code vào bảng users
ALTER TABLE users ADD COLUMN IF NOT EXISTS student_code VARCHAR(20) UNIQUE;

-- 2. Cập nhật mã code cho các người dùng hiện có (dựa trên 5 ký tự đầu của ID)
UPDATE users 
SET student_code = 'HZ-' || UPPER(SUBSTRING(id::text, 1, 5))
WHERE student_code IS NULL;

-- Tạo bảng liên kết Phụ huynh - Học sinh
CREATE TABLE IF NOT EXISTS parent_student_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES users(id),
    student_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, linked, rejected
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_id, student_id) -- Tránh kết nối trùng lặp
);
