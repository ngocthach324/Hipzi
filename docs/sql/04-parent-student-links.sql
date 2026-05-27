-- ============================================================
-- HIPZI - Parent to student linking schema
-- Database: PostgreSQL / Supabase
-- Scope: parent_student_links
-- ============================================================

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS parent_student_links (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    student_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'linked'
                CHECK (status IN ('pending', 'linked', 'rejected', 'revoked')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_parent_student_links_parent_student UNIQUE (parent_id, student_id),
    CONSTRAINT chk_parent_student_links_distinct CHECK (parent_id <> student_id)
);

ALTER TABLE parent_student_links
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'linked';

ALTER TABLE parent_student_links
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();

ALTER TABLE parent_student_links
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

UPDATE parent_student_links
SET status = 'linked'
WHERE status IS NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'uq_parent_student_links_parent_student'
    ) THEN
        ALTER TABLE parent_student_links
            ADD CONSTRAINT uq_parent_student_links_parent_student
            UNIQUE (parent_id, student_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_parent_student_links_distinct'
    ) THEN
        ALTER TABLE parent_student_links
            ADD CONSTRAINT chk_parent_student_links_distinct
            CHECK (parent_id <> student_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_parent_student_links_parent_id
    ON parent_student_links (parent_id);

CREATE INDEX IF NOT EXISTS idx_parent_student_links_student_id
    ON parent_student_links (student_id);

CREATE INDEX IF NOT EXISTS idx_parent_student_links_status
    ON parent_student_links (status);

DROP TRIGGER IF EXISTS trg_parent_student_links_updated_at ON parent_student_links;
CREATE TRIGGER trg_parent_student_links_updated_at
    BEFORE UPDATE ON parent_student_links
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();
