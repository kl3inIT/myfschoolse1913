# MyFSchoolSE1913 Architecture

This is the source of truth for how the project is currently built. Planned
architecture that has not landed in code belongs in `docs/vision.md` or an
active increment.

## Stack

- Mobile/web demo client: Flutter, Dart, Material, `go_router`, `http`,
  `flutter_secure_storage`, `flutter_lints`.
- Backend: Spring Boot 4.1, Java toolchain 25, Gradle Kotlin DSL, Spring Data
  JPA, Spring Security OAuth2 Resource Server/JWT, Flyway, PostgreSQL.
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

## Backend Architecture

The backend is a Spring Boot modular monolith. Root packages are business
modules, not global technical layers:

```text
vn.edu.fpt.myfschoolse1913
  auth           login, refresh, logout, password reset
  user           app user and current-user endpoint
  student        student dashboard, grades, schedule, academic data
  application    student applications
  club           clubs and club registration
  event          school events
  notification   notifications and read state
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

## Runtime Configuration

Backend defaults:

- `DB_URL=jdbc:postgresql://localhost:5433/myfschoolse1913`
- `DB_USERNAME=postgres`
- `DB_PASSWORD=admin123`
- `SERVER_PORT=8080`
- `SEED_DEMO_USER=false`

Flutter reads `API_BASE_URL` from `--dart-define`, defaulting to
`http://localhost:8080`.

Use `http://localhost:8080` for Flutter Web and `http://10.0.2.2:8080` for an
Android emulator that talks to a backend running on the host machine.

## Commands

```powershell
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8080
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080

cd backend
.\gradlew.bat test --rerun-tasks
.\gradlew.bat bootRun
```

Do not use `bootRun` as a terminating verification gate. It is for running the
app.
