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

## Gaps

- No backend integration test for the chat endpoint (would need an LLM stub;
  candidate: mock `ChatClient` or a fake OpenAI server).
- Tool methods have no unit tests (date/status parsing, ToolContext user id).
- No Flutter widget test for `SchoolAssistantProvider` SSE parsing
  (`ApiClient.postEventStream` chunk-boundary handling is untested).
- Memory windowing (30 messages) and cross-restart persistence unverified.
- No rate limiting / spend cap on the endpoint; abuse would burn API credit.
