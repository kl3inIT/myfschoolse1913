# Student Assistant Spec

Current behavior of the AI assistant available to students, across the Spring
Boot backend, the Flutter app, and the admin web's AI management page.

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

- Model: OpenAI via `spring-ai-starter-model-openai`; key from
  `OPENAI_API_KEY`. The model name and sampling options are runtime settings
  (see Admin AI Management); `ASSISTANT_CHAT_MODEL` (default `gpt-5.5`) is
  only the fallback until an admin saves settings.
- The system prompt injects the student's name, class, academic year, today's
  date, and the admin's extra instructions (if any), and instructs Vietnamese
  answers scoped to school topics.
- Answers are grounded through read-only tools (`StudentAssistantTools`):
  - `getWeeklySchedule(date?)` — weekly timetable;
  - `getSemesterGrades()` — current semester grades;
  - `getNotifications()` — published notifications;
  - `getMyApplications(status?)` — the student's applications;
  - `searchSchoolDocuments(query)` — semantic search over the admin-managed
    knowledge base; the model must cite the source document titles.
- The controller places the authenticated `userId` and the settings snapshot
  in the ToolContext; tools only ever read that student's data. The model
  cannot choose whose data it reads.

### Knowledge Base (RAG)

- Admins upload school documents (regulations, school info, subject learning
  materials) on the admin web; module `document` stores the file bytes in
  `school_documents` (V14) and immediately ingests them: Tika text extraction
  (PDF/Word/RTF; text/Markdown read directly), token splitting, OpenAI
  `text-embedding-3-large` shortened to 1536 dims, chunks in the pgvector
  `vector_store` table (V15) with `{documentId, title, category,
  subjectName}` metadata.
- Per-row ingest status is INDEXED/FAILED (+ chunk count); unreadable files
  are rejected with a Vietnamese 400. Deleting a document removes its
  vectors, then the row.
- The assistant's `searchSchoolDocuments` runs a similarity search (topK and
  optional similarity threshold from settings) and returns excerpts with the
  source title/category/subject.

### Admin AI Management

Admin web page `Quản lý AI` (`/ai`), config view first, knowledge base view
second:

- `GET/PUT /api/admin/assistant/settings` — single-row runtime settings,
  applied to the next turn without restart: chat model, temperature, topP,
  maxTokens, frequency/presence penalty (all optional → provider defaults),
  document topK (1..20), similarity threshold (0..1), memory window
  (2..100 messages), and extra system-prompt instructions (max 2000 chars).
- `POST /api/admin/documents` (multipart file + title + category +
  subjectName?), `GET /api/admin/documents?search=&category=&page=&size=`,
  `DELETE /api/admin/documents/{id}`. Categories: REGULATION, SCHOOL_INFO,
  SUBJECT_MATERIAL, OTHER. Upload limit 25MB.

### Conversation Memory

- JDBC-backed (`spring_ai_chat_memory`, Flyway `V13`), conversation id =
  student user id, so each student has one private conversation that survives
  backend restarts.
- The model sees a window of the most recent messages (admin-tunable, default
  30, `MessageWindowChatMemory` attached per turn); older rows are trimmed by
  Spring AI.
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
