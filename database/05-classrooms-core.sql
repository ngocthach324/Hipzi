CREATE TABLE IF NOT EXISTS classrooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subject TEXT NOT NULL,
    grade_level TEXT,
    description TEXT,
    schedule_days TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    student_count INTEGER NOT NULL DEFAULT 0 CHECK (student_count >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'upcoming', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_classrooms_teacher_id
    ON classrooms(teacher_id);

CREATE INDEX IF NOT EXISTS idx_classrooms_subject_grade
    ON classrooms(subject, grade_level);

CREATE INDEX IF NOT EXISTS idx_classrooms_status
    ON classrooms(status);

CREATE INDEX IF NOT EXISTS idx_classrooms_created_at
    ON classrooms(created_at DESC);

CREATE TABLE IF NOT EXISTS classroom_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    module_type VARCHAR(30) NOT NULL DEFAULT 'learning_content'
        CHECK (module_type IN ('learning_content', 'entry_requirement')),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_modules_classroom_id
    ON classroom_modules(classroom_id, module_type, sort_order);

CREATE TABLE IF NOT EXISTS classroom_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'accepted', 'rejected')),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(classroom_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_classroom_enrollments_class_status
    ON classroom_enrollments(classroom_id, status);

CREATE INDEX IF NOT EXISTS idx_classroom_enrollments_student
    ON classroom_enrollments(student_id, status);

-- Internal classroom content areas. CRUD screens can be connected to these tables later.
CREATE TABLE IF NOT EXISTS classroom_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    material_url TEXT,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    -- Additional fields added later
    file_path TEXT,
    original_file_name TEXT,
    file_type TEXT,
    file_size BIGINT NOT NULL DEFAULT 0,
    category VARCHAR(30) NOT NULL DEFAULT 'document',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_materials_classroom_id
    ON classroom_materials(classroom_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_classroom_materials_category
    ON classroom_materials(classroom_id, category, created_at DESC);

CREATE TABLE IF NOT EXISTS classroom_homework (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    due_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_homework_classroom_id
    ON classroom_homework(classroom_id, created_at DESC);

CREATE TABLE IF NOT EXISTS classroom_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    rule_text TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 1 CHECK (sort_order > 0),
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_classroom_rules_classroom_id
    ON classroom_rules(classroom_id, sort_order);
