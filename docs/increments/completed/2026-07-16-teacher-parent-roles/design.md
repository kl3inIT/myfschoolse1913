# Design: Teacher And Parent Roles

## Goal

Extend MyFSchool from the current student/admin prototype into a credible
four-role school workflow while staying inside a course-project scope:

- `ADMIN` manages master data, teacher assignments, guardian links, imports,
  approvals, and audit-sensitive operations;
- `TEACHER` uses the React web only for assigned classes and subjects;
- `PARENT` uses Flutter to follow verified children and submit school requests;
- `STUDENT` keeps the current Flutter self-service experience.

The increment must implement real data scoping. Adding enum values without
teacher assignments and guardian links does not meet the goal.

## Scope

### Foundation

- Teacher and parent profiles backed by existing `app_users` accounts.
- Subject/class/semester teaching assignments plus class/year homeroom
  assignments.
- Verified parent-to-student relationships with relationship and primary
  contact metadata.
- Role-specific API namespaces and backend row-level authorization.
- Demo accounts and deterministic relationships/assignments.

### Teacher React Web

- Login accepts `ADMIN` and `TEACHER` and renders role-specific navigation.
- Teacher dashboard lists today's timetable and assigned classes/subjects.
- Assigned roster is read-only outside permitted teacher actions.
- Attendance is recorded per timetable session with explicit status and audit
  metadata.
- Gradebook supports the Vietnamese secondary-school shape: multiple regular
  assessments, one midterm, one final, computed semester average, draft and
  published state.
- Homeroom teachers can review short leave requests for their class and record
  semester conduct summaries.

### Parent Flutter

- A parent selects one of the children linked to the account.
- The selected child drives dashboard, schedule, published grades, attendance,
  notifications, and applications.
- A parent can create and track absence/late-arrival/early-leave requests for
  the selected child.
- Student screens and behavior remain unchanged for `STUDENT` accounts.

### Admin React Web

- Manage teacher accounts/profiles.
- Assign a teacher to class + subject + semester and assign one homeroom
  teacher to a class + academic year.
- Manage verified parent-child links.
- Retain admin ownership of school-wide master data, bulk imports, final grade
  correction approval, and school-wide notifications.

## Explicit Non-Goals

- Teacher Flutter screens.
- Tuition/payment, health, transport, meal accounting, homework/LMS, digital
  signatures, realtime chat, or production push notifications.
- A full HR system or teacher qualification/certification workflow.
- Replacing the existing student AI assistant with teacher or parent analytics.

## Assignment Model

`TeachingAssignment` is the source of truth for teacher access to one class,
subject, and semester. It supports primary, co-teacher, and time-bounded
substitute assignments. `HomeroomAssignment` grants class-wide homeroom
capabilities for an academic year.

The current timetable `teacher_name` string becomes display-only compatibility
data. New and updated slots reference a real teacher/assignment so the system
can derive permissions instead of trusting a name.

Rules:

- one teacher may have many assignments;
- one class has many subject teachers but one active primary homeroom teacher;
- expired/revoked assignments lose write access immediately;
- historical attendance and grade authorship is immutable;
- role `TEACHER` alone grants no student access.

## Academic Model

The current single `formative_score` column is insufficient. Each
class/subject/semester has assessment definitions (`REGULAR`, `MIDTERM`,
`FINAL`) and each student has an assessment result. Subjects may use two,
three, or four regular results based on the configured annual lesson count.

Semester average follows Circular 22/2021:

`(sum(regular) + 2 * midterm + 3 * final) / (regular_count + 5)`.

Published results are visible to students and parents. Editing a published
result requires a reason and creates an audit record; final correction approval
remains an admin capability in this course scope.

Conduct is recorded as `GOOD`, `FAIR`, `PASS`, or `NOT_PASS`. Subject teachers
contribute comments; the homeroom teacher owns the semester summary.

## Application Workflow

- Student or verified parent creates an application for the student.
- A homeroom teacher may approve/reject a justified absence of no more than
  three consecutive days for the assigned class.
- Other application types and longer leave remain admin-reviewed.
- Every review records reviewer identity, note, and timestamp.

## Security And Privacy

- `/api/teachers/**` requires `ROLE_TEACHER`; service queries also verify an
  active assignment.
- `/api/parents/**` requires `ROLE_PARENT`; every child id is verified through
  an active guardian link.
- `/api/students/**` requires `ROLE_STUDENT`; `/api/admin/**` remains admin-only.
- Parent responses never expose another student's data or class contact list.
- Teacher roster responses expose only fields needed for class work.
- Attendance, scores, conduct, assignment changes, and application reviews are
  auditable.

## Acceptance Criteria

- A clean database migrates and seeds one admin, teachers, parents, students,
  assignments, guardian links, assessment results, and attendance.
- A teacher can log into React, see only assigned classes, take attendance, and
  enter/publish grades for an assigned subject.
- The same teacher receives `403` for an unassigned class/subject.
- A homeroom teacher can review an eligible short leave request but a subject
  teacher cannot.
- A parent can log into Flutter, switch verified children, view only published
  school data, and create an application for the selected child.
- A parent receives `404` or `403` for a student without an active link.
- Existing student and admin demo flows still pass.
- Backend tests, admin build/lint, Flutter analyze/tests, and a real browser
  walkthrough are green.
