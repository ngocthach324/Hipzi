CREATE TABLE IF NOT EXISTS mock_exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice'
        CHECK (exam_type IN ('multiple_choice', 'flashcard', 'essay')),
    subject TEXT NOT NULL,
    grade_level TEXT NOT NULL,
    duration_minutes INTEGER, -- Thời gian thi (phút). NULL nếu là Flashcard
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published', 'archived')),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Admin hoặc Staff tạo
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mock_exams_filters
    ON mock_exams(exam_type, subject, grade_level, status, created_at DESC);

-- 2. Dạng 1: Trắc nghiệm (Multiple Choice)
CREATE TABLE IF NOT EXISTS mock_exam_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_option CHAR(1) CHECK (correct_option IN ('A', 'B', 'C', 'D')),
    explanation TEXT,
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_questions_exam_id
    ON mock_exam_questions(mock_exam_id, sort_order);

-- 3. Dạng 2: Flashcard
CREATE TABLE IF NOT EXISTS mock_exam_flashcards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,
    front_text TEXT NOT NULL,
    back_text TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_flashcards_exam_id
    ON mock_exam_flashcards(mock_exam_id, sort_order);

-- 4. Dạng 3: Tự luận (Essay)
CREATE TABLE IF NOT EXISTS mock_exam_essays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,
    prompt_text TEXT NOT NULL,         -- Đề bài
    reference_answer TEXT,             -- Hướng dẫn/Đáp án tham khảo
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_essays_exam_id
    ON mock_exam_essays(mock_exam_id, sort_order);

-- 5. Lịch sử / Tiến độ làm bài (Chỉ cần thiết cho Trắc nghiệm và Tự luận)
CREATE TABLE IF NOT EXISTS mock_exam_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mock_exam_id UUID NOT NULL REFERENCES mock_exams(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER CHECK (score >= 0),           -- Điểm (Null nếu tự luận giáo viên chưa chấm, hoặc flashcard)
    total_questions INTEGER CHECK (total_questions >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress'
        CHECK (status IN ('in_progress', 'completed')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    submitted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_attempts_student
    ON mock_exam_attempts(student_id, mock_exam_id, started_at DESC);

-- Chi tiết đáp án học viên chọn (Cho Trắc nghiệm)
CREATE TABLE IF NOT EXISTS mock_exam_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES mock_exam_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES mock_exam_questions(id) ON DELETE CASCADE,
    selected_option CHAR(1) CHECK (selected_option IN ('A', 'B', 'C', 'D')),
    is_correct BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_answers_attempt
    ON mock_exam_answers(attempt_id);

-- Bài làm Tự luận của học viên
CREATE TABLE IF NOT EXISTS mock_exam_essay_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES mock_exam_attempts(id) ON DELETE CASCADE,
    essay_id UUID NOT NULL REFERENCES mock_exam_essays(id) ON DELETE CASCADE,
    student_response TEXT NOT NULL,     -- Bài làm của học sinh
    teacher_feedback TEXT,              -- Nhận xét của giáo viên (nếu có)
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mock_exam_essay_submissions_attempt
    ON mock_exam_essay_submissions(attempt_id);
