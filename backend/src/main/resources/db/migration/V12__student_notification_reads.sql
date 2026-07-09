CREATE TABLE student_notification_reads (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	student_id UUID NOT NULL REFERENCES students (id) ON DELETE CASCADE,
	notification_id UUID NOT NULL REFERENCES school_notifications (id) ON DELETE CASCADE,
	read_at TIMESTAMPTZ NOT NULL DEFAULT now(),
	CONSTRAINT uk_student_notification_read UNIQUE (student_id, notification_id)
);

CREATE INDEX idx_student_notification_reads_student
	ON student_notification_reads(student_id);
