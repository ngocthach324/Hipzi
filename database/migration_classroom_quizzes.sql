-- Classroom multiple-choice practice created from scanned/uploaded exam images.
CREATE TABLE IF NOT EXISTS classroom_quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    source_image_path TEXT,
    source_file_name TEXT,
    raw_scan_text TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published')),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_quizzes_classroom_status
    ON classroom_quizzes(classroom_id, status, created_at DESC);

CREATE TABLE IF NOT EXISTS classroom_quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES classroom_quizzes(id) ON DELETE CASCADE,
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

CREATE INDEX IF NOT EXISTS idx_classroom_quiz_questions_quiz
    ON classroom_quiz_questions(quiz_id, sort_order);

CREATE TABLE IF NOT EXISTS classroom_quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES classroom_quizzes(id) ON DELETE CASCADE,
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
    total_questions INTEGER NOT NULL DEFAULT 0 CHECK (total_questions >= 0),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_quiz_attempts_student
    ON classroom_quiz_attempts(classroom_id, student_id, submitted_at DESC);

CREATE INDEX IF NOT EXISTS idx_classroom_quiz_attempts_quiz
    ON classroom_quiz_attempts(quiz_id, score DESC, submitted_at DESC);

CREATE TABLE IF NOT EXISTS classroom_quiz_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES classroom_quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES classroom_quiz_questions(id) ON DELETE CASCADE,
    selected_option CHAR(1) CHECK (selected_option IN ('A', 'B', 'C', 'D')),
    is_correct BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_classroom_quiz_answers_attempt
    ON classroom_quiz_answers(attempt_id);
