# Teacher And Parent School Work

Current behavior for teacher, parent, and related administrator workflows.

## Role Surfaces

- `TEACHER` uses the React staff portal only.
- `PARENT` uses Flutter and lands on `/parent`.
- `ADMIN` uses React for school-wide ownership.
- `STUDENT` keeps the existing Flutter experience.
- Flutter sends `ADMIN` and `TEACHER` to `/mobile-unsupported` instead of
  exposing partial mobile workflows.

## Access Model

Role alone is not a data grant:

- a teacher needs an active `TeachingAssignment` for one class, subject, and
  semester before reading its roster or writing attendance/assessments;
- a teacher needs an active `HomeroomAssignment` for class-wide applications
  and semester conduct;
- a parent needs an active verified `StudentGuardian` link for every selected
  child;
- an inactive, expired, unrelated, or guessed identifier is rejected by the
  service layer even when the caller has the correct high-level role.

## Administrator Workflow

The React page `/school-work` lets an administrator:

- create teacher and parent accounts;
- assign a teacher to class + subject + semester;
- assign the one active homeroom teacher for class + academic year;
- link a verified parent/guardian to a student and mark the primary contact;
- inspect current assignments and guardian links;
- correct a published assessment with a mandatory reason.

A published-score correction writes `assessment_correction_audits`, preserves
the result as published, records the administrator, and refreshes the legacy
`semester_subject_grades` aggregate used by existing student screens.

## Teacher React Workflow

The teacher root page lists only active assignments. For a selected subject
assignment the teacher can:

- view the assigned class roster;
- record lesson attendance (`PRESENT`, excused/unexcused absence, late, or
  early leave);
- enter multiple regular scores plus one midterm and one final score;
- save an assessment as draft or publish it;
- see the computed semester average.

Once a score is published, the teacher cannot change its score, title, comment,
or published state. An administrator must use the audited correction workflow.

For an assigned homeroom class the teacher can:

- approve/reject pending absence, late-arrival, or early-leave applications of
  at most three consecutive days;
- leave document requests and longer cases to an administrator;
- save or publish each student's semester conduct level and comment.

## Parent Flutter Workflow

The parent workspace lets an authenticated parent:

- switch among verified linked children;
- view the selected child's class/year summary;
- view published assessment components and semester average;
- view attendance, timetable, notifications, and application history;
- create absence, late-arrival, or early-leave applications for that child.

Unpublished scores and students without an active guardian link are never
returned. Meal accounting and document-request creation are not part of the
parent course-project flow.

## Academic Calculation

Assessment types are `REGULAR`, `MIDTERM`, and `FINAL`. A semester average is
available only when at least one regular score, a midterm, and a final exist:

`(sum(regular) + 2 * midterm + 3 * final) / (regular_count + 5)`

The result is rounded to one decimal using half-up rounding.

## Demo Accounts

All seeded accounts use `Password123`:

- Admin: `0900000000`
- Teacher: `0911000001` (Math + homeroom 10A1)
- Teacher: `0911000002` (Informatics 10A1)
- Parent: `0922000001` (two verified children)
- Parent: `0922000002` (one verified child)
- Student: `0900000001`

## Non-Goals

Teacher Flutter, tuition/payment, health, transport, meal accounting,
homework/LMS, digital signatures, realtime chat, and full HR management remain
out of scope.
