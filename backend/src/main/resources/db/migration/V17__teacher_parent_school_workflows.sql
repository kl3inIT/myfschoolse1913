CREATE TABLE teacher_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES app_users (id) ON DELETE CASCADE,
    employee_code VARCHAR(40) NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE parent_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES app_users (id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE student_guardians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES parent_profiles (id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    relationship VARCHAR(30) NOT NULL,
    primary_contact BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (parent_id, student_id)
);

CREATE TABLE teaching_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES teacher_profiles (id) ON DELETE RESTRICT,
    class_id UUID NOT NULL REFERENCES school_classes (id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects (id) ON DELETE RESTRICT,
    semester_id UUID NOT NULL REFERENCES semesters (id) ON DELETE CASCADE,
    assignment_type VARCHAR(30) NOT NULL DEFAULT 'PRIMARY',
    starts_on DATE,
    ends_on DATE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (teacher_id, class_id, subject_id, semester_id, assignment_type)
);

CREATE TABLE homeroom_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES teacher_profiles (id) ON DELETE RESTRICT,
    class_id UUID NOT NULL REFERENCES school_classes (id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES academic_years (id) ON DELETE CASCADE,
    starts_on DATE,
    ends_on DATE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (teacher_id, class_id, academic_year_id)
);

ALTER TABLE class_timetable_slots
    ADD COLUMN teaching_assignment_id UUID REFERENCES teaching_assignments (id) ON DELETE SET NULL;

CREATE TABLE attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teaching_assignment_id UUID NOT NULL REFERENCES teaching_assignments (id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    lesson_number INTEGER NOT NULL CHECK (lesson_number > 0),
    status VARCHAR(30) NOT NULL,
    note VARCHAR(255),
    recorded_by UUID NOT NULL REFERENCES app_users (id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (teaching_assignment_id, student_id, attendance_date, lesson_number)
);

CREATE TABLE assessment_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teaching_assignment_id UUID NOT NULL REFERENCES teaching_assignments (id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    assessment_type VARCHAR(30) NOT NULL,
    sequence_number INTEGER NOT NULL DEFAULT 1 CHECK (sequence_number > 0),
    title VARCHAR(120) NOT NULL,
    score NUMERIC(4, 1) CHECK (score >= 0 AND score <= 10),
    comment VARCHAR(255),
    published BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMPTZ,
    recorded_by UUID NOT NULL REFERENCES app_users (id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (teaching_assignment_id, student_id, assessment_type, sequence_number)
);

CREATE TABLE student_conduct_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    homeroom_assignment_id UUID NOT NULL REFERENCES homeroom_assignments (id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    semester_id UUID NOT NULL REFERENCES semesters (id) ON DELETE CASCADE,
    conduct_level VARCHAR(30) NOT NULL,
    comment VARCHAR(500),
    published BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_by UUID NOT NULL REFERENCES app_users (id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, semester_id)
);

ALTER TABLE student_applications
    ADD COLUMN end_date DATE,
    ADD COLUMN created_by_user_id UUID REFERENCES app_users (id) ON DELETE SET NULL,
    ADD COLUMN reviewed_by_user_id UUID REFERENCES app_users (id) ON DELETE SET NULL;

UPDATE student_applications SET end_date = target_date WHERE end_date IS NULL;

UPDATE student_applications application
SET created_by_user_id = student.user_id
FROM students student
WHERE application.student_id = student.id
  AND application.created_by_user_id IS NULL;

ALTER TABLE student_applications
    ADD CONSTRAINT chk_student_application_dates CHECK (end_date >= target_date);

CREATE INDEX idx_guardians_parent_active ON student_guardians (parent_id, active);
CREATE INDEX idx_guardians_student_active ON student_guardians (student_id, active);
CREATE INDEX idx_teaching_assignments_teacher_active ON teaching_assignments (teacher_id, active);
CREATE INDEX idx_teaching_assignments_scope ON teaching_assignments (class_id, subject_id, semester_id, active);
CREATE INDEX idx_homeroom_assignments_teacher_active ON homeroom_assignments (teacher_id, active);
CREATE INDEX idx_attendance_student_date ON attendance_records (student_id, attendance_date DESC);
CREATE INDEX idx_assessment_student_published ON assessment_results (student_id, published);
