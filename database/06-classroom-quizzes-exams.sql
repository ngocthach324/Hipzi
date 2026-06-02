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


-- Formal classroom exams shown both inside a classroom and in the class exam room.
CREATE TABLE IF NOT EXISTS classroom_exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    exam_code TEXT NOT NULL UNIQUE,
    exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice'
        CHECK (exam_type IN ('multiple_choice', 'essay', 'flashcard')),
    creation_mode VARCHAR(20) NOT NULL DEFAULT 'manual'
        CHECK (creation_mode IN ('manual', 'ai')),
    raw_source_text TEXT,
    source_material_id UUID REFERENCES classroom_materials(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('draft', 'open', 'closed')),
    duration_minutes INTEGER NOT NULL DEFAULT 45 CHECK (duration_minutes > 0),
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE classroom_exams
    ADD COLUMN IF NOT EXISTS exam_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice';

ALTER TABLE classroom_exams
    ADD COLUMN IF NOT EXISTS creation_mode VARCHAR(20) NOT NULL DEFAULT 'manual';

ALTER TABLE classroom_exams
    ADD COLUMN IF NOT EXISTS raw_source_text TEXT;

ALTER TABLE classroom_exams
    ADD COLUMN IF NOT EXISTS start_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS end_at TIMESTAMPTZ;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'classroom_exams_exam_type_check'
          AND conrelid = 'classroom_exams'::regclass
    ) THEN
        ALTER TABLE classroom_exams
            ADD CONSTRAINT classroom_exams_exam_type_check
            CHECK (exam_type IN ('multiple_choice', 'essay', 'flashcard'));
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'classroom_exams_creation_mode_check'
          AND conrelid = 'classroom_exams'::regclass
    ) THEN
        ALTER TABLE classroom_exams
            ADD CONSTRAINT classroom_exams_creation_mode_check
            CHECK (creation_mode IN ('manual', 'ai'));
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_classroom_exams_classroom
    ON classroom_exams(classroom_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_classroom_exams_code
    ON classroom_exams(exam_code);

ALTER TABLE classroom_exams
    DROP CONSTRAINT IF EXISTS classroom_exams_time_window_check;

ALTER TABLE classroom_exams
    ADD CONSTRAINT classroom_exams_time_window_check
    CHECK (start_at IS NULL OR end_at IS NULL OR end_at > start_at);

CREATE TABLE IF NOT EXISTS classroom_exam_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES classroom_exams(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    option_a TEXT,
    option_b TEXT,
    option_c TEXT,
    option_d TEXT,
    correct_option CHAR(1) CHECK (correct_option IN ('A', 'B', 'C', 'D')),
    reference_answer TEXT,
    points INTEGER NOT NULL DEFAULT 1 CHECK (points > 0),
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_exam_questions_exam
    ON classroom_exam_questions(exam_id, sort_order);
