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

## First Vertical Slice

1. Admin login with an `ADMIN` role check.
2. Student CSV import.
3. Backend admin endpoint that creates or updates `STUDENT` users and `students`
   records.
4. Summary of created, updated, and skipped rows.

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
