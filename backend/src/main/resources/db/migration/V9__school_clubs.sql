CREATE TABLE school_clubs (
	id UUID PRIMARY KEY,
	name VARCHAR(120) NOT NULL UNIQUE,
	description VARCHAR(500) NOT NULL,
	schedule_text VARCHAR(160) NOT NULL,
	location VARCHAR(120) NOT NULL,
	active BOOLEAN NOT NULL
);

CREATE TABLE club_registrations (
	id UUID PRIMARY KEY,
	student_id UUID NOT NULL REFERENCES students(id),
	club_id UUID NOT NULL REFERENCES school_clubs(id),
	status VARCHAR(30) NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
	reviewed_at TIMESTAMP WITH TIME ZONE,
	CONSTRAINT uk_club_registration_student_club UNIQUE(student_id, club_id)
);

CREATE INDEX idx_club_registrations_student
	ON club_registrations(student_id);
