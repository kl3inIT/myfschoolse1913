# Plan: AI Knowledge Base And Admin AI Management

All steps completed 2026-07-10.

1. Backend documents: V14 `school_documents` + V15 `vector_store`
   (extension + HNSW index); pgvector + Tika starters; upload/list/delete
   endpoints with ingestion. Fixed a `lower(bytea)` 500 on the list query
   (null String param → the repo-standard ''-sentinel search).
2. Backend settings: V16 `assistant_settings` (full Spring AI option set);
   GET/PUT admin endpoints with Vietnamese Bean Validation; per-turn
   application of model/sampling options, memory window, topK, similarity
   threshold, and extra instructions.
3. Assistant: `searchSchoolDocuments` tool + citation rule in the system
   prompt; settings snapshot through ToolContext.
4. Admin web: `Quản lý AI` page at `/ai` (config view first, knowledge
   base second), full-option settings form, document table + upload
   dialog; `authorizedForm` multipart helper.
5. Verification (real backend + OpenAI key): both uploads INDEXED; the
   regulation question answered 200.000đ/môn + deadline 25/07 citing the
   uploaded title; after saving topK 3 + a fixed closing sentence, the
   next student turn cited the Toán document and ended with the exact
   sentence. `gradlew test`, admin `tsc`/lint/build all green.

Known gaps: see `docs/tests/domains/assistant.md`.
