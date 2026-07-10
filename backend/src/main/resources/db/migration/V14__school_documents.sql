-- Admin-managed school knowledge documents (regulations, school info, subject
-- learning materials). File bytes live in-row; derived embedding chunks live
-- in vector_store (V15) keyed by metadata documentId.
CREATE TABLE school_documents (
	id UUID PRIMARY KEY,
	title VARCHAR(200) NOT NULL,
	category VARCHAR(40) NOT NULL,
	subject_name VARCHAR(120),
	file_name VARCHAR(255) NOT NULL,
	mime_type VARCHAR(120) NOT NULL,
	size_bytes BIGINT NOT NULL,
	content BYTEA NOT NULL,
	ingest_status VARCHAR(20) NOT NULL,
	ingest_error VARCHAR(500),
	chunk_count INT,
	created_at TIMESTAMP WITH TIME ZONE NOT NULL,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_school_documents_updated ON school_documents(updated_at DESC);
