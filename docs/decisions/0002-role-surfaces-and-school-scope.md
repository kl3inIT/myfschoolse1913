# 0002 - Role Surfaces And School Scope

Status: accepted

## Context

The prototype originally treated Flutter as student-only and React as
admin-only. Adding teacher and parent roles without assignments or verified
relationships would expose school data too broadly and produce an unrealistic
demo. Implementing every commercial school feature would exceed the course
scope.

## Decision

- Teacher uses React only; Parent uses Flutter.
- Teacher access is derived from active subject/class/semester and homeroom
  assignments, not from the `TEACHER` enum alone.
- Parent access is derived from active verified guardian links.
- Grades use multiple regular components, one midterm, and one final with the
  Vietnamese weighted semester formula.
- Published grades are locked for teachers; administrator correction requires a
  reason and creates an audit row.
- The increment covers academic, attendance, conduct, applications, timetable,
  notifications, and essential account/assignment administration only.

## Consequences

The demo has credible four-role data boundaries while reusing one backend and
the existing two clients. Teacher Flutter and commercial modules such as
payments, health, transport, meals, LMS, signatures, realtime chat, and full HR
remain explicit non-goals.
