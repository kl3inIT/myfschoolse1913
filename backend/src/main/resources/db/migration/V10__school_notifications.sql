CREATE TABLE school_notifications (
	id UUID PRIMARY KEY,
	title VARCHAR(160) NOT NULL,
	body VARCHAR(1000) NOT NULL,
	category VARCHAR(40) NOT NULL,
	audience VARCHAR(40) NOT NULL,
	published_at TIMESTAMP WITH TIME ZONE NOT NULL,
	pinned BOOLEAN NOT NULL,
	active BOOLEAN NOT NULL
);

CREATE INDEX idx_school_notifications_active_published
	ON school_notifications(active, published_at DESC);
