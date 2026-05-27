-- ============================================================
-- HIPZI - Student Profiles & Statistics Schema
-- Database: PostgreSQL (Supabase)
-- File:     03-student-statistics-tables.sql
-- Scope:    student_profiles
--
-- Tóm tắt nghiệp vụ (Giải pháp 1 - Caching / Pre-calculated fields):
--   Lưu trữ thông tin hồ sơ mở rộng của học viên kèm theo các
--   chỉ số thống kê tổng quan (Level, XP, Streak, Quizzes, Classes)
--   để phục vụ tải giao diện Student Dashboard với tốc độ cao
--   mà không cần thực hiện các lệnh truy vấn gom nhóm (COUNT/AVG) nặng.
-- ============================================================

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

-- Index tối ưu tra cứu theo user_id
CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles (user_id);

-- ============================================================
-- TRIGGER: Tự động cập nhật mốc thời gian updated_at
-- ============================================================
CREATE TRIGGER trg_student_profiles_updated_at
    BEFORE UPDATE ON student_profiles
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
-- GHI CHÚ TÍCH HỢP CHO BACKEND (SERVICE LAYER)
-- ============================================================
-- 1. Khi học viên nộp bài Quiz thành công (PracticeService):
--    - Tăng completed_quizzes_count += 1.
--    - Tính toán lại average_accuracy dựa trên kết quả mới nộp.
--    - Cộng điểm XP tương ứng vào current_xp, nếu vượt mốc thì tăng current_level.
--    - Cập nhật last_activity_date = CURRENT_DATE. Nếu ngày liền trước đã học thì tăng current_streak.
--
-- 2. Khi học viên được phê duyệt tham gia lớp học mới:
--    - Tăng active_classes_count += 1.
--
-- 3. Khi học viên rời lớp hoặc lớp bị đóng:
--    - Giảm active_classes_count -= 1.
-- ============================================================

-- 1. Thêm cột student_code vào bảng users
ALTER TABLE users ADD COLUMN IF NOT EXISTS student_code VARCHAR(20) UNIQUE;

-- 2. Cập nhật mã code cho các người dùng hiện có (dựa trên 5 ký tự đầu của ID)
UPDATE users 
SET student_code = 'HZ-' || UPPER(SUBSTRING(id::text, 1, 5))
WHERE student_code IS NULL;

-- 3. Đảm bảo các user mới sau này luôn có mã (nếu bạn muốn ràng buộc chặt chẽ hơn)
-- ALTER TABLE users ALTER COLUMN student_code SET NOT NULL;
