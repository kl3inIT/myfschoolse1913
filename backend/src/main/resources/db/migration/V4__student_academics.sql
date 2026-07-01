CREATE TABLE academic_years (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(40) NOT NULL UNIQUE,
    starts_on DATE,
    ends_on DATE,
    current_year BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE school_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years (id) ON DELETE RESTRICT,
    name VARCHAR(40) NOT NULL,
    UNIQUE (academic_year_id, name)
);

CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES app_users (id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES school_classes (id) ON DELETE RESTRICT,
    student_code VARCHAR(40) NOT NULL UNIQUE,
    status VARCHAR(40) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE semesters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years (id) ON DELETE RESTRICT,
    name VARCHAR(40) NOT NULL,
    display_order INTEGER NOT NULL,
    starts_on DATE,
    ends_on DATE,
    current_semester BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (academic_year_id, name)
);

CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL
);

CREATE TABLE semester_subject_grades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    semester_id UUID NOT NULL REFERENCES semesters (id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects (id) ON DELETE RESTRICT,
    average_score NUMERIC(4, 1) NOT NULL CHECK (average_score >= 0 AND average_score <= 10),
    detail VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, semester_id, subject_id)
);

CREATE INDEX idx_school_classes_academic_year ON school_classes (academic_year_id);
CREATE INDEX idx_students_user_id ON students (user_id);
CREATE INDEX idx_students_class_id ON students (class_id);
CREATE INDEX idx_semesters_academic_year ON semesters (academic_year_id);
CREATE INDEX idx_semester_subject_grades_student_semester ON semester_subject_grades (student_id, semester_id);
