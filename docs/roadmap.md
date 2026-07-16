# MyFSchoolSE1913 Roadmap

This is a lightweight delivery tracker, not an issue tracker. Increment
descriptions live in `docs/vision.md` or the increment's own design.

## Active

| Increment | Status | Target |
| --- | --- | --- |
No implementation increment is currently active. Completed design/plan history
lives under `docs/increments/completed/`.

## Recently Built

- Teacher + Parent roles (2026-07-16): real teaching/homeroom assignments,
  verified guardian links, Teacher React workspace, Parent Flutter workspace,
  attendance, multi-component grades using the Circular 22 formula, conduct,
  short-leave homeroom review, and audited admin correction of published grades
  (`docs/specs/domains/school-work.md`).

- Repeatable Vietnamese teacher-demo fixture (2026-07-11): 36 synthetic
  students/three classes, curriculum-shaped subjects and grades, seven-day
  timetable, varied school-life data, six seeded RAG documents, and a verified
  student-create -> admin-approve -> student-read walkthrough.
- Student AI assistant (2026-07-10): Spring AI 2.0 `assistant` backend module
  (OpenAI chat, JDBC conversation memory, read-only data tools) streaming SSE
  to a `flutter_ai_toolkit` chat screen at `/assistant`
  (`docs/specs/domains/assistant.md`).
- AI knowledge base + admin AI management (2026-07-10): `document` module
  (upload → Tika → embeddings → pgvector), `searchSchoolDocuments` RAG tool
  with source citations, and the admin `Quản lý AI` page (runtime model/
  sampling/RAG/memory settings + document upload/list/delete).
- Layered Flutter MVVM app shell.
- Phone login and forgot-password flow.
- Student dashboard.
- Semester grades, schedule, events, applications, clubs, notifications, and
  account screens.
- Spring Boot backend modules and Flyway schema for the student-facing APIs.
- Notification detail/read-state feature.
- Admin web: login, overview dashboard, student CSV/Excel import, student
  list with
  search/paging/stat cards, student detail page with in-place edit,
  notification publishing with recall, academic year/class master data,
  semester grade list + CSV/Excel import, timetable list + CSV/Excel
  import with a per-class weekly grid, application review
  (approve/reject with notes), a shared list/toolbar/dialog
  pattern (`docs/guidelines/admin-web-patterns.md`) with FPT branding, and
  immediate redirect to login on expired sessions.

## Backlog

- Add backend integration tests for the student-facing and admin API
  surfaces (see `docs/tests/domains/admin-web.md` for the admin gap list).
- Turn the verified manual teacher-review walkthrough into an automated
  Playwright check.
- Assistant hardening: rate limiting/spend cap, integration tests with an LLM
  stub, provider/SSE-parsing unit tests (see `docs/tests/domains/assistant.md`).
