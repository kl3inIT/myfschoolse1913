# Student Assistant Test Coverage

Mirrors `docs/specs/domains/assistant.md`.

## Automated Coverage

- None specific to the assistant. `ModulithArchitectureTests` verifies the new
  `assistant` module respects module boundaries; the context-load test proves
  the Spring AI wiring starts with a blank `OPENAI_API_KEY`.

## Manual Verification (2026-07-10)

Against the running backend (gpt-5.5, real OpenAI key) and the northstar
Postgres, as demo student `0900000001`:

- SSE stream: `POST /api/students/me/assistant/chat` returned `{"text": ...}`
  deltas and closed cleanly.
- Grounding via tools: "Điểm trung bình môn Toán..." answered 8.5 (Toán),
  8.4 overall, "Giỏi" — exactly matching `/api/students/me/semester-grades`.
- Date resolution: "tomorrow" resolved to Thứ bảy 11/07/2026; the empty
  Saturday answer matched `/api/students/me/schedule` (0 items that day).
- Vietnamese-only replies with student's name; UTF-8 body handled (a 400 seen
  from curl was the shell sending cp1252, not an app defect).
- Flutter web: home shortcut `Trợ lý AI` → `/assistant`, welcome message +
  suggestion chips render, streamed answer appears incrementally.
- Knowledge base: uploaded a REGULATION markdown via curl and a
  SUBJECT_MATERIAL file via the admin upload dialog; both INDEXED with chunk
  counts. "Lệ phí thi lại...?" answered 200.000đ/môn + hạn 25/07 citing
  "Quy chế thi lại và học lại" — content that exists only in the upload.
- Settings: saved topK 3 + extra instruction (fixed closing sentence) on the
  admin page; the next student turn cited the Toán document AND ended with
  the exact configured sentence — settings flow into prompt + retrieval.
- The documents list initially 500'd (`lower(bytea)` — null String param
  binds as bytea on PostgreSQL); fixed by the repo-standard ''-sentinel
  search parameter and re-verified.

## Fresh-Fixture Verification (2026-07-11)

- Six classpath Markdown documents were ingested during demo startup; every
  `school_documents` row was `INDEXED` and had a matching pgvector row.
- Flutter Web question `Điểm trung bình môn Toán của mình là bao nhiêu?`
  streamed `8.5` plus TX/GK/CK detail from the student's own grade tool.
- Flutter Web question about self-directed phone use returned the seeded rule
  and cited `Nội quy học sinh - Bản demo 2026-2027`.
- Both assistant requests completed with HTTP 200 against the real OpenAI
  model and the freshly recreated PostgreSQL database.

## Gaps

- No backend integration test for the chat endpoint (would need an LLM stub;
  candidate: mock `ChatClient` or a fake OpenAI server).
- Tool methods have no unit tests (date/status parsing, ToolContext user id).
- No Flutter widget test for `SchoolAssistantProvider` SSE parsing
  (`ApiClient.postEventStream` chunk-boundary handling is untested).
- Memory windowing and cross-restart persistence unverified.
- No rate limiting / spend cap on the endpoint; abuse would burn API credit.
- Ingestion untested for real PDF/Word files (only text/Markdown exercised).
- Settings validation ranges rely on Bean Validation; no test pins them.
