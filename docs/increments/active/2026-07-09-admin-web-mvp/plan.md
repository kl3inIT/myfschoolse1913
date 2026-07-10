# Admin Web MVP Plan

## Goal

Build the first React admin web surface for school staff to provision student
accounts because students do not self-register in the mobile app.

## Stack

- Vite 8 React TypeScript scaffold from `create-vite@latest`.
- TypeScript 7.
- Tailwind CSS 4 through the Vite plugin.
- TanStack Router and TanStack Query, matching the Northstar frontend pattern.
- Admin web lives in `admin-web/`; Flutter keeps the existing `web/` target.

## First Vertical Slice (built)

1. Admin login with an `ADMIN` role check.
2. Student CSV import.
3. Backend admin endpoint that creates or updates `STUDENT` users and `students`
   records.
4. Summary of created, updated, and skipped rows.

## Second Slice (built)

1. `GET /api/admin/students` with search and paging.
2. Student list table with debounced search, prev/next paging; import results
   moved into the import sheet.

## Third Slice (built)

1. Stat cards on the list page backed by `GET /api/admin/students/stats`.
2. Dedicated student detail route `/students/:studentId` backed by
   `GET /api/admin/students/{id}`; replaced the inline detail panel.
3. Login page rebuilt on the official shadcn `login-01` block.

## Fourth Slice (built)

1. Notification publishing at `/notifications`: publish form, paged list of
   published notifications, and soft recall (thu hồi).
2. Backend `POST/GET /api/admin/notifications` and
   `DELETE /api/admin/notifications/{id}` on the existing
   `SchoolNotification` model; recalled notifications disappear from the
   student API.
3. Sidebar items are now real route links with active state.

## Fifth Slice (built)

1. Academic year and class master data at `/classes`: year cards with class
   tables and student counts, create year (with current-year switch), and
   inline create class per year.
2. Backend `GET/POST /api/admin/academic-years` and
   `POST /api/admin/academic-years/{yearId}/classes` with 409 conflicts on
   duplicate names.

## Sixth Slice (built)

1. Semester grade CSV import at `/grades`: client-side preview, weighted
   average auto-computation, per-row result.
2. Backend `POST /api/admin/grades/import` upserting
   `SemesterSubjectGrade` rows, auto-creating missing semesters and subjects.

## Seventh Slice (built)

1. Excel (`.xlsx`/`.xls`) accepted in both import dropzones via SheetJS,
   converted to CSV client-side.
2. Student edit: `PUT /api/admin/students/{id}` plus Jmix-style in-place edit
   mode on the student detail page (profile, class, account, password reset,
   lock/unlock).

## Eighth Slice (built)

1. Consistency pass across all pages following
   `docs/guidelines/admin-web-patterns.md`: shared TanStack `DataTable` with
   per-resource `columns.tsx`, one toolbar row (search + actions) below the
   stat cards, centered create dialogs, inline row icon actions, pagination
   fixed at the bottom, FPT orange branding shared with the mobile app.

## Ninth Slice (built)

1. `GET /api/admin/grades` (search + paging, newest updates first); `/grades`
   became a list-first page on the shared `DataTable`, with the import result
   moved into the sheet like student import.
2. Notifications table converted to the shared `DataTable` + `columns.tsx`.
3. 401/403 now clears the session and immediately redirects to `/login`.

## Tenth Slice (built)

1. Timetable at `/timetable`: list of class timetable slots (search + paging,
   sorted class/day/lesson) plus CSV/Excel import with per-row upsert on
   (class, semester, day, lesson) — reusing the existing
   `ClassTimetableSlot` model the student schedule reads from.
2. Backend `GET /api/admin/timetable` and `POST /api/admin/timetable/import`
   with auto-created semesters/classes/subjects and Vietnamese skip reasons.

## Eleventh Slice (built)

1. Application review at `/applications`: stat cards, status filter
   (defaults to pending), and inline approve/reject actions with a confirm
   dialog and optional reviewer note — completing the last sidebar
   placeholder besides "Tổng quan".
2. Backend `GET /api/admin/applications` (+`/stats`) and
   `PUT /api/admin/applications/{id}` reviewing PENDING applications on the
   existing `StudentApplication` model (409 when already reviewed).

Current behavior is documented in `docs/specs/domains/admin-web.md`.

## Deferred

- Candidate modules from `research.md`, not committed requirements yet:
  - class and academic-year management;
  - timetable import/management;
  - notification/news publishing;
  - grade/result import;
  - attendance import/reporting;
  - teacher/homeroom assignment;
  - parent/guardian contact linking;
  - rewards, discipline, clubs, and leave/applications.
- Do not build payments, meals, pickup authorization, health, dormitory,
  transport, chat, or admissions until the requirement is explicitly selected.
- OpenAPI client generation after the backend contract is stabilized.
