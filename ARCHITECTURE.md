# MyFSchoolSE1913 Architecture

This is the source of truth for how the project is currently built. Planned
architecture that has not landed in code belongs in `docs/vision.md` or an
active increment.

## Stack

- Student/parent mobile client: Flutter, Dart, Material, `go_router`, `http`,
  `flutter_secure_storage`, `flutter_lints`.
- Admin/teacher web client: Vite + React + TypeScript in `admin-web/` (pnpm), Tailwind
  CSS, shadcn/ui, TanStack Router, TanStack Query, react-hook-form + zod,
  SheetJS (`xlsx`) for Excel import.
- Backend: Spring Boot 4.1, Java toolchain 25, Gradle Kotlin DSL, Spring Data
  JPA, Spring Security OAuth2 Resource Server/JWT, Flyway, PostgreSQL,
  Spring AI 2.0 (OpenAI chat + JDBC chat memory + pgvector RAG + Tika
  document reader).
- Auth: phone-number login, short-lived JWT access tokens, opaque refresh tokens
  stored as hashes.
- Database: PostgreSQL. Flyway owns schema migrations under
  `backend/src/main/resources/db/migration`.

## Repository Layout

```text
lib/vn/edu/fpt/       Flutter app source
  app/                bootstrap, routing, configuration, dependency composition
  core/               theme, network, result/failure types
  domain/             UI-facing clean models
  data/               DTOs, API services, repositories, token storage
  ui/core/            shared UI widgets
  ui/features/        feature views, widgets, view models, state

backend/              Spring Boot backend
  src/main/java/...   business modules under vn.edu.fpt.myfschoolse1913
  src/main/resources  application config and Flyway migrations

admin-web/            React admin web (Vite dev server on 5174, /api proxied
                      to localhost:8080)

android/ ios/ web/ windows/ linux/ macos/
                      Flutter platform targets
docs/                 repository system-of-record docs
test/                 Flutter widget tests
```

## Flutter Architecture

The Flutter app follows layered MVVM:

- `main.dart` calls `runApp`.
- `MyFSchoolApp` owns the app services and `GoRouter` lifetime.
- `AppDependencies` exposes service/repository objects through an
  `InheritedWidget`.
- `app_router.dart` owns route constants and protected-route redirects.
- Views render state and forward user actions.
- ViewModels own form controllers, validation, loading/error state, and
  commands.
- Repositories map external DTOs into domain models.
- Services are thin wrappers around HTTP or platform storage.

Current route surface:

- `/login`
- `/forgot-password`
- `/forgot-password/verify`
- `/forgot-password/reset`
- `/home`
- `/semester-grades`
- `/schedule`
- `/events`
- `/applications`
- `/applications/create`
- `/clubs`
- `/clubs/register`
- `/notifications`
- `/notifications/:notificationId`
- `/account`
- `/parent` (`PARENT` only)
- `/mobile-unsupported` (`ADMIN`/`TEACHER`; these roles use React)

## Backend Architecture

The backend is a Spring Boot modular monolith. Root packages are business
modules, not global technical layers:

```text
vn.edu.fpt.myfschoolse1913
  auth           login, refresh, logout, password reset
  user           app user and current-user endpoint
  student        student dashboard, grades, schedule, academic data
  application    student applications
  assistant      student AI assistant (Spring AI chat + tools + settings)
  document       school knowledge documents + pgvector ingestion/search
  club           clubs and club registration
  event          school events
  notification   notifications and read state
  schoolwork     teacher/parent profiles, assignments, guardian links,
                 attendance, assessment results, conduct, scoped workflows
  security       Spring Security and JWT infrastructure
  shared         cross-module API errors and common web support
  bootstrap      local/demo data seeders
```

JPA uses `ddl-auto: validate`; every mapped entity/column must match a Flyway
migration.

## API Surface

Public auth and health:

- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `POST /api/auth/password-reset/request`
- `POST /api/auth/password-reset/verify`
- `POST /api/auth/password-reset/confirm`
- `GET /api/health`

Authenticated student APIs:

- `GET /api/me`
- `GET /api/students/me/dashboard`
- `GET /api/students/me/semester-grades`
- `GET /api/students/me/schedule`
- `GET /api/students/me/events`
- `GET /api/students/me/applications`
- `POST /api/students/me/applications`
- `GET /api/students/me/clubs`
- `POST /api/students/me/clubs/{clubId}/registrations`
- `GET /api/students/me/notifications`
- `GET /api/students/me/notifications/{notificationId}`
- `POST /api/students/me/assistant/chat` (SSE stream; see
  `docs/specs/domains/assistant.md`)

Teacher APIs (require `ROLE_TEACHER` and an active assignment):

- `GET /api/teachers/me/workspace`
- `GET /api/teachers/me/assignments/{assignmentId}/classroom`
- `PUT /api/teachers/me/assignments/{assignmentId}/attendance`
- `PUT /api/teachers/me/assignments/{assignmentId}/grades`
- `GET /api/teachers/me/homeroom/{classId}/applications`
- `PUT /api/teachers/me/homeroom/{classId}/applications/{applicationId}`
- `PUT /api/teachers/me/homeroom/{classId}/conduct`

Parent APIs (require `ROLE_PARENT` and an active guardian link):

- `GET /api/parents/me/workspace?studentId=`
- `POST /api/parents/me/children/{studentId}/applications`

Admin APIs (require `ROLE_ADMIN`):

- `POST /api/admin/students/import`
- `GET /api/admin/students?search=&page=&size=`
- `GET /api/admin/students/stats`
- `GET /api/admin/students/{id}`
- `PUT /api/admin/students/{id}`
- `POST /api/admin/notifications`
- `GET /api/admin/notifications?page=&size=`
- `DELETE /api/admin/notifications/{id}` (soft deactivate)
- `GET /api/admin/academic-years`
- `POST /api/admin/academic-years`
- `POST /api/admin/academic-years/{yearId}/classes`
- `GET /api/admin/grades?search=&page=&size=`
- `POST /api/admin/grades/import`
- `GET /api/admin/timetable?search=&page=&size=`
- `POST /api/admin/timetable/import`
- `GET /api/admin/applications?search=&status=&page=&size=`
- `GET /api/admin/applications/stats`
- `PUT /api/admin/applications/{id}` (review: approve/reject)
- `POST /api/admin/documents` (multipart upload + vector ingestion)
- `GET /api/admin/documents?search=&category=&page=&size=`
- `DELETE /api/admin/documents/{documentId}`
- `GET /api/admin/assistant/settings`
- `PUT /api/admin/assistant/settings`
- `GET /api/admin/school-work`
- `POST /api/admin/school-work/teachers`
- `POST /api/admin/school-work/parents`
- `POST /api/admin/school-work/teaching-assignments`
- `POST /api/admin/school-work/homeroom-assignments`
- `POST /api/admin/school-work/guardian-links`
- `POST /api/admin/school-work/assessment-results/{resultId}/correction`

## Runtime Configuration

Backend defaults:

- `DB_URL=jdbc:postgresql://localhost:5432/myfschoolse1913`
- `DB_USERNAME=northstar`
- `DB_PASSWORD=northstar`

The local database is the `myfschoolse1913` database inside the
`northstar-postgres-1` Docker container (pgvector/pgvector:pg18, host port
5432).
- `SERVER_PORT=8080`
- `SEED_DEMO_USER=false`
- `OPENAI_API_KEY` (no default; required for the student assistant)
- `ASSISTANT_CHAT_MODEL=gpt-5.5`

Flutter reads `API_BASE_URL` from `--dart-define`, defaulting to the production
origin `https://myfschool.kl3in.tech`. Nginx Proxy Manager routes the app's
relative `/api` requests to `myfschool-api` on the shared proxy network.

Use `http://localhost:8080` for Flutter Web and `http://10.0.2.2:8080` for an
Android emulator that talks to a backend running on the host machine.

## Demo Fixture

The conditional seeders under `bootstrap/` and `document/` run when
`SEED_DEMO_USER=true`:

- `DemoUserSeeder` creates one admin, two teachers, two parents, and 36
  synthetic student accounts;
- `DemoSchoolDataSeeder` creates academic year `2026-2027`, three populated
  classes, 18 subjects, eight grades per student, a seven-day timetable, five
  events, six notifications, 17 initial applications, eight clubs, and five
  registrations;
- `DemoKnowledgeBaseSeeder` reads six Markdown files from
  `src/main/resources/demo/knowledge/` and sends them through the production
  embedding/pgvector ingestion path.
- `DemoSchoolWorkSeeder` creates subject/homeroom assignments, three verified
  guardian links, published assessment components, attendance, and conduct.

The seed flag is for creating/resetting a disposable demo environment. Leave it
off during normal demo runs because the school-data seeder deliberately resets
grades, timetables, applications, events, notifications, and registrations.
The local reset procedure and walkthrough live in
`docs/guidelines/teacher-demo-runbook.md`.

## Commands

```powershell
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8080
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter build apk --release

cd backend
.\gradlew.bat test --rerun-tasks
.\gradlew.bat bootRun

cd admin-web
pnpm dev
pnpm lint
pnpm build
```

Do not use `bootRun` as a terminating verification gate. It is for running the
app.
