CREATE TABLE assessment_correction_audits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_result_id UUID NOT NULL REFERENCES assessment_results (id) ON DELETE RESTRICT,
    previous_score NUMERIC(4, 1),
    new_score NUMERIC(4, 1) NOT NULL CHECK (new_score >= 0 AND new_score <= 10),
    previous_comment VARCHAR(255),
    new_comment VARCHAR(255),
    reason VARCHAR(500) NOT NULL,
    corrected_by UUID NOT NULL REFERENCES app_users (id) ON DELETE RESTRICT,
    corrected_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_assessment_corrections_result_time
    ON assessment_correction_audits (assessment_result_id, corrected_at DESC);
