# MyFSchoolSE1913 Vision

MyFSchoolSE1913 is a learning-first Flutter project that still aims to become a
credible FPT Schools-style prototype.

## Problem Thesis

Students and parents need a simple mobile view of verified school information.
Teachers need a focused workspace for only their assigned classes and subjects;
administrators own school-wide configuration and sensitive corrections.

The project also has a second purpose: helping the user learn Flutter deeply
through a real codebase instead of isolated examples.

## Product Intent

The experience should feel close to common Vietnamese school-management apps,
but remain tight enough for a course-project demo.

The app should:

- use phone-number login;
- support `STUDENT` and `PARENT` in Flutter;
- support `ADMIN` and `TEACHER` in React;
- keep user-facing copy in Vietnamese;
- scope teacher data by active subject/class assignments;
- scope parent data by verified guardian links;
- keep teacher/admin mobile flows out of scope;
- use Flutter Web as a demo target for the same student experience;
- keep React admin UI as future scope.

## Current MVP Shape

The current MVP is a four-role workflow:

- Auth: login, refresh session, logout, forgot password.
- Home: student summary, feature shortcuts, today schedule.
- Academic: semester grades and schedule.
- School life: events, applications, clubs, notifications.
- Account: current user profile and logout.
- Parent: linked-child switching, published academic data, attendance,
  notifications, and school requests.
- Teacher: assigned roster, attendance, assessment components, homeroom
  applications, and conduct on React.
- Admin: teacher/parent accounts, subject and homeroom assignments, guardian
  links, and audited correction of published scores.

The immediate deadline is a basic mobile and Flutter Web demo by the weekend.

## Future Scope

Future scope, not current fact:

- Richer backend administration for events, notifications, grades, clubs, and
  applications.
- Production-grade deployment, CI, and seeded demo environments.
- More automated end-to-end coverage.

## Out Of Scope Unless Reopened

- Public registration screen.
- Tuition/payment, health, transport, meal accounting, homework/LMS, digital
  signatures, or realtime parent-teacher chat.
- Student mobile chat/messages.
- Teacher Flutter screens and full HR/teacher qualification management.
- Teacher/admin mobile workflows.

Architecture facts move to `ARCHITECTURE.md` only after the code actually lands.
