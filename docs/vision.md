# MyFSchoolSE1913 Vision

MyFSchoolSE1913 is a learning-first Flutter project that still aims to become a
credible FPT Schools-style prototype.

## Problem Thesis

Students need a simple school app that gives them the information they check
often: login, personal school identity, schedule, semester grades, events,
applications, clubs, notifications, and account actions.

The project also has a second purpose: helping the user learn Flutter deeply
through a real codebase instead of isolated examples.

## Product Intent

The student mobile experience should feel close to FPT Schools and the student
side of EnetViet, but scoped tightly enough for a school project demo.

The app should:

- use phone-number login;
- focus on the `STUDENT` role;
- keep user-facing copy in Vietnamese;
- avoid parent-only flows unless parent scope is explicitly added;
- avoid teacher/admin mobile flows unless explicitly requested;
- use Flutter Web as a demo target for the same student experience;
- keep React admin UI as future scope.

## Current MVP Shape

The current MVP is a student self-service app:

- Auth: login, refresh session, logout, forgot password.
- Home: student summary, feature shortcuts, today schedule.
- Academic: semester grades and schedule.
- School life: events, applications, clubs, notifications.
- Account: current user profile and logout.

The immediate deadline is a basic mobile and Flutter Web demo by the weekend.

## Future Scope

Future scope, not current fact:

- React admin UI for teacher/admin operations.
- Parent experience as a separate role and information architecture.
- Richer backend administration for events, notifications, grades, clubs, and
  applications.
- Production-grade deployment, CI, and seeded demo environments.
- More automated end-to-end coverage.

## Out Of Scope Unless Reopened

- Public registration screen.
- Parent child-selection, tuition, approvals, or parent-teacher communication.
- Student mobile chat/messages.
- Attendance, reward, or discipline screens.
- Teacher/admin mobile workflows.

Architecture facts move to `ARCHITECTURE.md` only after the code actually lands.
