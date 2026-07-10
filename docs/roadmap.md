# MyFSchoolSE1913 Roadmap

This is a lightweight delivery tracker, not an issue tracker. Increment
descriptions live in `docs/vision.md` or the increment's own design.

## Active

| Increment | Status | Target |
| --- | --- | --- |
| Basic mobile and Flutter Web MVP | In progress | 2026-07-12 |
| Admin web MVP | In progress | - |

See
`docs/increments/active/2026-07-09-basic-mobile-web-mvp/plan.md` and
`docs/increments/active/2026-07-09-admin-web-mvp/plan.md`.

## Recently Built

- Layered Flutter MVVM app shell.
- Phone login and forgot-password flow.
- Student dashboard.
- Semester grades, schedule, events, applications, clubs, notifications, and
  account screens.
- Spring Boot backend modules and Flyway schema for the student-facing APIs.
- Notification detail/read-state feature.
- Admin web: login, student CSV/Excel import, student list with
  search/paging/stat cards, student detail page with in-place edit,
  notification publishing with recall, academic year/class master data,
  semester grade list + CSV/Excel import, a shared list/toolbar/dialog
  pattern (`docs/guidelines/admin-web-patterns.md`) with FPT branding, and
  immediate redirect to login on expired sessions.

## Backlog

- Make local backend/database quickstart repeatable.
- Add a minimal React admin UI after the student MVP is stable.
- Add backend integration tests for the student-facing API surface.
- Add end-to-end browser checks for the demo flow.
- Add docs/screenshots for the teacher review demo path.
- Fix Android NDK version warning if Android rebuilds become noisy.
