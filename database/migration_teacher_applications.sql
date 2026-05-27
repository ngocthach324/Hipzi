-- Migration: Store teacher teaching-registration applications
CREATE TABLE IF NOT EXISTS teacher_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    teacher_type VARCHAR(40) NOT NULL CHECK (teacher_type IN ('student_tutor', 'certified_pedagogy', 'degree_specialist')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'needs_more_info')),
    institution_name TEXT NOT NULL,
    specialization TEXT NOT NULL,
    current_study_year VARCHAR(40),
    teaching_subjects TEXT NOT NULL,
    teaching_experience TEXT,
    workplace TEXT,
    credentials_summary TEXT,
    teacher_bio TEXT NOT NULL,
    evidence_summary TEXT,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    review_note TEXT,
    reviewed_at TIMESTAMP,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_applications_status
    ON teacher_applications(status);

CREATE INDEX IF NOT EXISTS idx_teacher_applications_submitted_at
    ON teacher_applications(submitted_at DESC);
