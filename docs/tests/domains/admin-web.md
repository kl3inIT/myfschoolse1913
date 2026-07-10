# Admin Web Test Coverage

Mirrors `docs/specs/domains/admin-web.md`.

## Automated

- No focused tests for the admin APIs or the React admin UI exist yet. The
  backend suite only covers the modulith architecture rules
  (`ModulithArchitectureTests`) and Spring context load, both of which the
  admin modules pass.
- `npx tsc -b --noEmit` and `npm run lint` gate the frontend and are clean.

## Runtime Verification (manual, per slice)

Each slice was verified end-to-end against the running backend + Postgres
with browser flows before its docs/commit:

- Login (ADMIN role check) and immediate redirect to `/login` on 401/403.
- Student CSV/Excel import, list search/paging, detail, in-place edit
  (including 409 phone/code conflicts and password reset), stats cards.
- Academic year/class creation (409 duplicates, current-year switch).
- Grade import (weighted average, per-row CREATED/UPDATED/SKIPPED reasons,
  409-free upsert) and grade list search — cross-checked against the
  student semester-grades API.
- Timetable import (upsert on class/semester/day/lesson, time and slot-type
  validation, skip reasons), list search, per-class weekly grid —
  cross-checked against the student schedule API.
- Notification publish/recall — cross-checked against the student
  notifications API.
- Application review (approve/reject with note, 409 on double review,
  status filter, stats) — cross-checked against the student applications
  API.
- Dashboard stats and panels after the `/` → `/students` route move.

## Gaps

- Add backend integration tests (Testcontainers or a test database) for the
  admin endpoints: search/paging clamps, 404/409 conflict paths, import
  row-level skip reasons, review state transitions, and `ROLE_ADMIN`
  authorization on `/api/admin/**`.
- Add frontend component tests for the shared `DataTable`, CSV parsers
  (`lib/csv.ts`, `lib/grades.ts`, `lib/timetable.ts`,
  `lib/student-import.ts`), and the review/import dialogs.
- Script the manual Playwright flows above into repeatable e2e checks for
  the demo path.
