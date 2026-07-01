CREATE TABLE password_reset_otps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_users (id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    otp_hash VARCHAR(64) NOT NULL,
    reset_token_hash VARCHAR(64) UNIQUE,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    reset_token_expires_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_password_reset_otps_user_id ON password_reset_otps (user_id);
CREATE INDEX idx_password_reset_otps_phone_created_at ON password_reset_otps (phone_number, created_at);
CREATE INDEX idx_password_reset_otps_expires_at ON password_reset_otps (expires_at);
CREATE INDEX idx_password_reset_otps_reset_token_hash ON password_reset_otps (reset_token_hash);
