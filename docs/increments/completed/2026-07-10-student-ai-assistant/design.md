# Design: Student AI Assistant

Date: 2026-07-10. Status: completed same day.

## Goal

Let a logged-in student ask natural Vietnamese questions about their own
school data ("mai học gì?", "điểm Toán bao nhiêu?") and get streamed,
grounded answers inside the Flutter app.

## Approach

Mirror the proven Northstar assistant architecture (same machine, same
Spring Boot 4.1 + Spring AI 2.0.0 GA stack), scaled down for an MVP:

- Backend `assistant` module: one memory-carrying `ChatClient`
  (OpenAI `gpt-5.5`, key reused from the machine's `OPENAI_API_KEY`),
  JDBC chat memory (`spring_ai_chat_memory`, V13), and four read-only
  `@Tool` methods that reuse the exact services behind the student REST
  API. The controller puts the JWT's userId into the ToolContext, so the
  model can only ever read the current student's data.
- `POST /api/students/me/assistant/chat` streams SSE `{"text": delta}`
  events from `ChatClient.stream()` via `SseEmitter` (Spring MVC, no
  WebFlux migration).
- Flutter: `flutter_ai_toolkit`'s `LlmChatView` (the Flutter team's AI
  chat widget) with a custom `SchoolAssistantProvider` that consumes the
  SSE stream through the existing `AuthenticatedApiClient` (JWT +
  401-refresh). Entry via a new `Trợ lý AI` dashboard shortcut.

## Dropped From Northstar (deliberately, for the MVP)

Tool-search advisor, tool-trace UI events, attachments, conversation
titling/listing, /history rehydration, Vercel UI Message Stream protocol.

## Key Decisions

- Provider-agnostic UI: `LlmProvider` is an interface; the API key never
  ships in the app.
- One conversation per student (conversation id = user id) instead of
  conversation management — simplest thing that demos well.
- `MessageWindowChatMemory` (30 messages) is acceptable because there is
  no history endpoint yet; if /history is added, switch to a
  keep-everything memory like Northstar's `WindowedChatMemory`.
