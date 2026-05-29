-- database/09-hipzi-exams.sql

-- Kỳ thi HIPZI (Sự kiện thi chung)
-- Chỉ Staff và Admin có quyền tạo. Tổ chức theo tuần/tháng với cơ chế giám sát và phần thưởng (cộng XP).

CREATE TABLE IF NOT EXISTS hipzi_exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Lịch trình thi
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    
    -- Cấu hình
    duration_minutes INT NOT NULL DEFAULT 60,
    max_attempts INT DEFAULT 1, -- Thường chỉ được thi 1 lần
    is_proctored BOOLEAN DEFAULT TRUE, -- Yêu cầu giám sát chặt chẽ
    
    -- Phần thưởng
    reward_xp INT DEFAULT 0, -- Điểm kinh nghiệm cộng thêm cho học sinh hoàn thành
    
    -- Trạng thái và Người tạo
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'completed', 'cancelled')),
    created_by UUID NOT NULL REFERENCES users(id), -- Staff / Admin ID
    
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Bảng câu hỏi của kỳ thi HIPZI
CREATE TABLE IF NOT EXISTS hipzi_exam_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES hipzi_exams(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'essay')),
    points INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Lựa chọn cho câu hỏi trắc nghiệm
CREATE TABLE IF NOT EXISTS hipzi_exam_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES hipzi_exam_questions(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE
);

-- Lịch sử làm bài (Attempts)
CREATE TABLE IF NOT EXISTS hipzi_exam_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES hipzi_exams(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    start_time TIMESTAMPTZ DEFAULT now(),
    end_time TIMESTAMPTZ,
    
    -- Kết quả
    total_score INT DEFAULT 0,
    is_passed BOOLEAN DEFAULT FALSE,
    reward_claimed BOOLEAN DEFAULT FALSE, -- Cờ đánh dấu đã cộng XP vào student_profiles chưa
    
    -- Thông tin giám sát (Future)
    proctoring_log TEXT,
    is_flagged BOOLEAN DEFAULT FALSE, -- Bị đánh dấu vi phạm
    
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Lưu câu trả lời của học sinh
CREATE TABLE IF NOT EXISTS hipzi_exam_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES hipzi_exam_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES hipzi_exam_questions(id) ON DELETE CASCADE,
    selected_option_id UUID REFERENCES hipzi_exam_options(id), -- Trắc nghiệm
    essay_text TEXT, -- Tự luận
    is_correct BOOLEAN,
    points_awarded INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Bảng xếp hạng tạm thời (Tùy chọn cho việc truy vấn nhanh Leaderboard)
CREATE TABLE IF NOT EXISTS hipzi_exam_leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES hipzi_exams(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rank_position INT NOT NULL,
    total_score INT NOT NULL,
    completion_time_seconds INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (exam_id, student_id)
);
