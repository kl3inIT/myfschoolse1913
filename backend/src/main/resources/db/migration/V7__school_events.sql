CREATE TABLE school_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years (id) ON DELETE CASCADE,
    class_id UUID REFERENCES school_classes (id) ON DELETE CASCADE,
    title VARCHAR(160) NOT NULL,
    description VARCHAR(500) NOT NULL,
    location VARCHAR(160) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    published BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (starts_at < ends_at)
);

CREATE INDEX idx_school_events_academic_year_start
    ON school_events (academic_year_id, starts_at);

CREATE INDEX idx_school_events_class_start
    ON school_events (class_id, starts_at);
