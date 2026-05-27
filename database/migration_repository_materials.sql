-- Public material repository uploaded by teachers.
CREATE TABLE IF NOT EXISTS repository_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    subject TEXT NOT NULL,
    grade TEXT NOT NULL,
    material_type TEXT NOT NULL,
    file_path TEXT NOT NULL,
    original_file_name TEXT NOT NULL,
    file_type TEXT,
    file_size BIGINT NOT NULL DEFAULT 0,
    uploaded_by TEXT,
    view_count INTEGER NOT NULL DEFAULT 0 CHECK (view_count >= 0),
    rating_average NUMERIC(3,2) NOT NULL DEFAULT 0 CHECK (rating_average >= 0 AND rating_average <= 5),
    rating_count INTEGER NOT NULL DEFAULT 0 CHECK (rating_count >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'APPROVED'
        CHECK (status IN ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED')),
    visibility VARCHAR(20) NOT NULL DEFAULT 'VISIBLE'
        CHECK (visibility IN ('VISIBLE', 'HIDDEN')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_repository_materials_filters
    ON repository_materials(subject, grade, material_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_repository_materials_uploaded_by
    ON repository_materials(uploaded_by, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_repository_materials_status_visible
    ON repository_materials(status, visibility, created_at DESC);
