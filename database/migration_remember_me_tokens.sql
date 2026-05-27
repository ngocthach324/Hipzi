CREATE TABLE IF NOT EXISTS remember_me_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    selector VARCHAR(64) UNIQUE NOT NULL,
    validator_hash VARCHAR(128) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_selector
    ON remember_me_tokens(selector)
    WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_remember_me_tokens_user_id
    ON remember_me_tokens(user_id);
