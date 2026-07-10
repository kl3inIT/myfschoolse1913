-- Embedding storage for school documents. The table is Spring AI's
-- PgVectorStore layout, NOT a domain table: Flyway owns the DDL
-- (initialize-schema: false) and the columns must match
-- PgVectorStore#initializeSchema exactly. Chunks carry metadata
-- {documentId, title, category, subjectName}; rows are derived and
-- disposable, so there is deliberately no FK to school_documents —
-- deletion is the ingestion service's job.
--
-- 1536 dims = text-embedding-3-large shortened via the `dimensions`
-- request option (Matryoshka); full 3072 would exceed pgvector's
-- 2000-dim index cap.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE vector_store (
    id        uuid PRIMARY KEY,
    content   text,
    metadata  json,
    embedding vector(1536)
);

CREATE INDEX spring_ai_vector_index ON vector_store USING hnsw (embedding vector_cosine_ops);
