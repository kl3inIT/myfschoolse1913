# Design: AI Knowledge Base And Admin AI Management

Date: 2026-07-10 (same-day follow-up to the student assistant increment).
Status: completed same day.

## Goal

Let the school control what the assistant knows and how it behaves:

1. Admins upload school documents (regulations, school info, subject
   learning materials à la FPT Education Learning Materials) that the
   assistant can cite when answering.
2. A single admin "Quản lý AI" page also exposes the full set of Spring AI
   runtime options (model, sampling, RAG, memory window, extra
   instructions) — config view first, knowledge base view second.

## Approach

- `document` module: `school_documents` (V14, bytes in-row) + immediate
  ingestion — Tika extraction, token splitting, `text-embedding-3-large`
  @1536 dims, chunks into the pgvector `vector_store` (V15, HNSW+cosine,
  same layout/pins as Northstar). Metadata `{documentId, title, category,
  subjectName}`; delete-by-filter keeps vectors disposable, no FK.
- The Postgres container already runs pgvector/pgvector:pg18, so
  `CREATE EXTENSION vector` needed no infra change.
- `assistant` gains tool #5 `searchSchoolDocuments(query)` (via
  `SchoolDocumentSearchService`, public module API) and a prompt rule to
  cite source titles.
- `assistant_settings` (V16, single row): chat model, temperature, topP,
  maxTokens, frequency/presence penalty (nullable → provider defaults;
  gpt-5.5 rejects non-default temperature so null is the safe default),
  topK, similarity threshold, memory window, extra instructions. Applied
  per turn — options via `ChatOptions.builder()`, memory advisor built per
  request so the window change is immediate, settings snapshot rides the
  ToolContext into the search tool.
- Admin web `/ai`: toolbar-toggle page (pattern from the timetable
  multi-view), full-width settings card + document DataTable with
  multipart upload dialog (`authorizedForm` helper added to the api lib).

## Key Decisions

- Bytes in Postgres, not a file system/S3 — one fewer moving part at this
  scale; ingestion re-reads from the row.
- Synchronous ingestion on upload: documents are small; the admin sees
  INDEXED/FAILED immediately. Embedding-backend failures keep the row as
  FAILED (delete + re-upload heals) instead of failing the upload.
- Settings are one DB row read per turn, not cached — trivially cheap next
  to an LLM call, and edits apply instantly.
