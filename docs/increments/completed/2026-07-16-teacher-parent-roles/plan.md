# Plan: Teacher And Parent Roles

## Status 2026-07-16

Completed and verified. Teacher is React-only, Parent is Flutter, and the
implementation stays focused on core school operations suitable for the course
project. Backend clean tests, React lint/build, Flutter analyze/tests/APK build,
role-boundary API checks, and browser walkthroughs all passed.

## 1. Foundation And Security

- Add Flyway schema for teacher/parent profiles, guardian links, teaching and
  homeroom assignments, attendance, assessment results, conduct, and audit
  metadata.
- Add entities/repositories and role-specific current-scope services.
- Gate all student, teacher, parent, and admin namespaces explicitly.
- Add integration tests proving assigned/linked and forbidden access.

## 2. Admin Ownership

- Add admin APIs for teacher accounts, assignments, and guardian links.
- Add React pages using the existing shell, query, form, and table patterns.
- Link timetable rows to real teacher assignments while retaining import
  compatibility.

## 3. Teacher React Workflow

- Allow teacher login and role-aware navigation.
- Implement teacher dashboard, assigned classes, roster, attendance, and
  subject gradebook.
- Implement homeroom-only short-leave review and conduct summary.
- Add service and UI tests for capability boundaries.

## 4. Parent Flutter Workflow

- Add parent domain models, API services, repositories, view models, and views
  using the existing MVVM/data-layer structure.
- Implement child selection and parent-scoped dashboard, schedule, grades,
  attendance, notifications, and applications.
- Keep the student router and repositories intact for student sessions.

## 5. Correct Existing Academic Gaps

- Replace single-formative-score assumptions with assessment definitions and
  multiple results.
- Compute averages with the Circular 22 formula.
- Preserve current admin import through a compatibility mapping and document
  its limits or extend its format when necessary.
- Add published/locked state and correction audit behavior.

## 6. Demo, Verification, And Consolidation

- Extend deterministic Vietnamese demo data with teacher/parent accounts and
  linked workflows.
- Run backend, admin, and Flutter automated gates.
- Walk admin assignment -> teacher attendance/grade -> parent read/application
  in a real browser.
- Update architecture, vision, specs, tests, roadmap, runbook, and Northstar.
- Move this increment to `completed/` only after all acceptance criteria pass.
