CREATE TABLE student_applications (
	id UUID PRIMARY KEY,
	student_id UUID NOT NULL REFERENCES students(id),
	application_type VARCHAR(40) NOT NULL,
	status VARCHAR(30) NOT NULL,
	target_date DATE NOT NULL,
	requested_time TIME,
	reason VARCHAR(200) NOT NULL,
	details VARCHAR(1000),
	reviewer_note VARCHAR(500),
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
	reviewed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_student_applications_student_status_created
	ON student_applications(student_id, status, created_at DESC);
