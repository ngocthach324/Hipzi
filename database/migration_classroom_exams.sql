-- Formal classroom exams shown both inside a classroom and in the class exam room.
CREATE TABLE IF NOT EXISTS classroom_exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    exam_code TEXT NOT NULL UNIQUE,
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

CREATE INDEX IF NOT EXISTS idx_classroom_exams_classroom
    ON classroom_exams(classroom_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_classroom_exams_code
    ON classroom_exams(exam_code);
