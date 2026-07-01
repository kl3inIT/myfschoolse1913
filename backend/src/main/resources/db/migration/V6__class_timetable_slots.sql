CREATE TABLE class_timetable_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES school_classes (id) ON DELETE CASCADE,
    semester_id UUID NOT NULL REFERENCES semesters (id) ON DELETE CASCADE,
    day_index SMALLINT NOT NULL CHECK (day_index >= 1 AND day_index <= 7),
    lesson_number INTEGER NOT NULL CHECK (lesson_number > 0),
    slot_type VARCHAR(30) NOT NULL,
    title VARCHAR(120) NOT NULL,
    subject_id UUID REFERENCES subjects (id) ON DELETE SET NULL,
    room_name VARCHAR(80),
    teacher_name VARCHAR(120),
    starts_at TIME NOT NULL,
    ends_at TIME NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (class_id, semester_id, day_index, lesson_number),
    CHECK (starts_at < ends_at)
);

CREATE INDEX idx_class_timetable_slots_class_semester
    ON class_timetable_slots (class_id, semester_id);

CREATE INDEX idx_class_timetable_slots_day
    ON class_timetable_slots (class_id, semester_id, day_index, lesson_number);
