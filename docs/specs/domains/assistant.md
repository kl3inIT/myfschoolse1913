# Student Assistant Spec

Current behavior of the AI assistant available to students, across the Spring
Boot backend and the Flutter app.

## Scope

- Student-only. The endpoint sits under `/api/students/me/**` and resolves the
  student from the JWT; non-student or disabled sessions are rejected before
  any LLM call.
- Read-only: the assistant can look at the student's own data but cannot
  create or change anything.

## Backend

Module `assistant` (Spring Modulith) built on Spring AI 2.0.0.

### Endpoint

- `POST /api/students/me/assistant/chat` with body `{ "message": string }`
  (1..4000 chars). Responds with `text/event-stream`; each SSE event's data is
  a JSON object:
  - `{"text": "<delta>"}` — a streamed chunk of the answer;
  - `{"error": "<Vietnamese message>"}` — the turn failed; the stream ends.
- One POST = one turn. The turn times out after 120s.

### Model And Grounding

- Model: OpenAI via `spring-ai-starter-model-openai`; model name from
  `ASSISTANT_CHAT_MODEL` (default `gpt-5.5`), key from `OPENAI_API_KEY`.
- The system prompt injects the student's name, class, academic year, and
  today's date, and instructs Vietnamese answers scoped to school topics.
- Answers are grounded through read-only tools (`StudentAssistantTools`)
  that reuse the same services behind the student REST API:
  - `getWeeklySchedule(date?)` — weekly timetable;
  - `getSemesterGrades()` — current semester grades;
  - `getNotifications()` — published notifications;
  - `getMyApplications(status?)` — the student's applications.
- The controller places the authenticated `userId` in the ToolContext; tools
  only ever read that student's data. The model cannot choose whose data it
  reads.

### Conversation Memory

- JDBC-backed (`spring_ai_chat_memory`, Flyway `V13`), conversation id =
  student user id, so each student has one private conversation that survives
  backend restarts.
- The model sees a window of the 30 most recent messages
  (`MessageWindowChatMemory`); older rows are trimmed by Spring AI.
- The repository schema initializer is off (`initialize-schema: never`);
  Flyway owns the schema.

## Flutter App

- Route `/assistant`, protected like other student routes; opened via the
  `Trợ lý AI` home shortcut (backend `ASSISTANT` shortcut code).
- UI is `LlmChatView` from `flutter_ai_toolkit` (attachments and voice notes
  disabled), with a Vietnamese welcome message and suggestion chips.
- `SchoolAssistantProvider` implements the toolkit's `LlmProvider`: it POSTs
  the message through `AuthenticatedApiClient.postEventStream` (JWT attached,
  single 401 refresh-and-retry before the first event) and relays SSE
  `text` deltas into the chat; an `error` event surfaces as the toolkit's
  failure dialog.
- The on-screen transcript lives in the provider for the app session; the
  durable memory is server-side.

## Failure Behavior

- Missing/expired token: 401 before the stream starts; the client refreshes
  once, then surfaces the standard session-expired message.
- LLM/tool failure mid-turn: the server logs the cause and emits a single
  `{"error": "Trợ lý đang gặp sự cố. Vui lòng thử lại sau."}` event.
- Blank message or > 4000 chars: Bean Validation 400.
