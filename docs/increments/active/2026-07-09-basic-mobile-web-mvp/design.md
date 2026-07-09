# Basic Mobile And Flutter Web MVP

## Goal

Finish a basic student-facing MyFSchoolSE1913 demo by the weekend for teacher
review.

## Scope

The MVP is one student experience delivered through Flutter mobile and Flutter
Web:

- login and forgot-password flow;
- home dashboard;
- semester grades;
- schedule;
- events;
- applications and create application;
- clubs and registration;
- notifications and notification detail;
- account and logout.

Backend scope is the Spring Boot API and PostgreSQL schema needed to support the
student demo.

## Non-Goals

- React admin UI.
- Parent app.
- Teacher/admin mobile flows.
- Production deployment.
- Public registration.

## Current Risks

- Backend local database setup is not repeatable enough.
- Backend context tests fail without a reachable PostgreSQL database.
- Notification detail/read-state is in progress and lacks focused tests.
- Android debug build passes but emits an NDK version warning.

## Definition Of Done

- Flutter analyze and tests pass.
- Flutter Web build passes.
- Android debug APK build passes.
- Backend tests pass against the configured database.
- A real demo flow is verified with demo credentials and seeded data.
- README documents the exact commands needed to run the demo.
