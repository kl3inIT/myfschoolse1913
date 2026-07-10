# MyFSchoolSE1913 Roadmap

This is a lightweight delivery tracker, not an issue tracker. Increment
descriptions live in `docs/vision.md` or the increment's own design.

## Active

| Increment | Status | Target |
| --- | --- | --- |
| Basic mobile and Flutter Web MVP | In progress | 2026-07-12 |

See `docs/increments/active/2026-07-09-basic-mobile-web-mvp/plan.md`.

Admin web MVP completed 2026-07-10 — history in
`docs/increments/completed/2026-07-09-admin-web-mvp/`.

## Recently Built

- Student AI assistant (2026-07-10): Spring AI 2.0 `assistant` backend module
  (OpenAI chat, JDBC conversation memory, read-only data tools) streaming SSE
  to a `flutter_ai_toolkit` chat screen at `/assistant`
  (`docs/specs/domains/assistant.md`).
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

- Make local backend/database quickstart repeatable.
- Add backend integration tests for the student-facing and admin API
  surfaces (see `docs/tests/domains/admin-web.md` for the admin gap list).
- Add end-to-end browser checks for the demo flow.
- Add docs/screenshots for the teacher review demo path.
- Fix Android NDK version warning if Android rebuilds become noisy.
- Assistant hardening: rate limiting/spend cap, integration tests with an LLM
  stub, provider/SSE-parsing unit tests (see `docs/tests/domains/assistant.md`).
