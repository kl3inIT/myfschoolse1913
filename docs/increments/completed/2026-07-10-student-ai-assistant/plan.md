# Plan: Student AI Assistant

All steps completed 2026-07-10.

1. Backend: Spring AI BOM 2.0.0 + OpenAI + chat-memory-JDBC starters;
   V13 migration; `assistant` module (config, tools, SSE controller);
   `ASSISTANT` dashboard shortcut. `gradlew test` green (Modulith verify
   accepts the new module; context loads with a blank key).
2. Flutter: `flutter_ai_toolkit`; `postEventStream` on
   `ApiClient`/`AuthenticatedApiClient`; `AssistantApiService`;
   `SchoolAssistantProvider`; `/assistant` page + route + home shortcut
   mapping. `flutter analyze` + `flutter test` green.
3. Verification (real backend, real OpenAI key, demo student):
   - curl SSE smoke test: streamed Vietnamese deltas; resolved
     "tomorrow" to Thứ bảy 11/07/2026 and correctly reported an empty
     Saturday (matches the schedule API).
   - Grades cross-check: assistant said Toán 8.5, average 8.4, Giỏi —
     exact match with `/api/students/me/semester-grades`.
   - Browser (built web bundle + Playwright): login → `Trợ lý AI`
     shortcut → welcome + suggestion chips → chip answer streamed →
     context-dependent follow-up ("môn nào điểm cao nhất?") answered
     Tiếng Anh 8.7 / Tin học 8.6 / Toán 8.5 — multi-turn memory works.
4. Docs: `docs/specs/domains/assistant.md`,
   `docs/tests/domains/assistant.md`, ARCHITECTURE, README, roadmap.

Known gaps (backlog): rate limiting/spend cap, LLM-stubbed integration
tests, provider/SSE unit tests, `/history` rehydration.
