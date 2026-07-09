# MyFSchoolSE1913

MyFSchoolSE1913 is a Flutter learning project and real prototype for an FPT
Schools-style student app.

The current product is a student-facing mobile app backed by a Spring Boot
modular monolith. Flutter Web is used as an acceptable web/demo target for the
same student experience. A React admin UI is planned later and is not currently
implemented.

## Status

This repo is an active PRM393 project. The immediate target is a basic mobile
and web-demo MVP by the weekend so the user can review progress with the
teacher.

Current implemented scope includes:

- phone-number login and refresh-token auth;
- forgot-password request, OTP verify, and reset;
- student home dashboard;
- semester grades;
- schedule;
- events;
- applications and create-application flow;
- clubs and registration flow;
- notifications, with notification detail/read-state in progress;
- account and logout.

## Quickstart

Requirements:

- Flutter SDK matching `pubspec.yaml`;
- Java/Gradle for the Spring Boot backend;
- PostgreSQL with the `myfschoolse1913` database;
- Android SDK when building Android APKs.

Backend default config:

```powershell
cd backend
.\gradlew.bat bootRun
```

The backend reads:

- `DB_URL`, default `jdbc:postgresql://localhost:5433/myfschoolse1913`
- `DB_USERNAME`, default `postgres`
- `DB_PASSWORD`, default `admin123`
- `SERVER_PORT`, default `8080`
- `SEED_DEMO_USER`, default `false`

Flutter web:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Android emulator:

```powershell
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Common verification:

```powershell
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8080
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080
cd backend
.\gradlew.bat test --rerun-tasks
```

Backend tests require a reachable PostgreSQL database matching the backend
configuration.

## Documentation

The repository is the system of record. Start here, then follow focused docs
instead of relying on chat history.

| Path | Purpose |
| --- | --- |
| [harness.md](./harness.md) | Repository operating model for AI-assisted development |
| [AGENTS.md](./AGENTS.md) / [CLAUDE.md](./CLAUDE.md) | Thin agent map and workflow rules |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Current built stack, layout, runtime config, commands |
| [docs/vision.md](./docs/vision.md) | Product intent, MVP scope, and future scope |
| [docs/roadmap.md](./docs/roadmap.md) | Delivery tracker and backlog |
| [docs/conventions.md](./docs/conventions.md) | Code, Flutter, backend, docs, and commit conventions |
| [docs/guidelines/](./docs/guidelines/) | Learning, Penpot, testing, safety, and Flutter mechanics |
| [docs/specs/domains/](./docs/specs/domains/) | Current behavior by domain |
| [docs/tests/domains/](./docs/tests/domains/) | Coverage and gaps mirroring the specs |
| [docs/decisions/](./docs/decisions/) | Append-only rationale for significant decisions |
| [docs/increments/](./docs/increments/) | Active and completed increment design/plan history |
| [LEARNING.md](./LEARNING.md) | User learning progress through the Flutter codebase |

Old monolithic prompt-style docs have been retired into this map. Current facts
belong in `ARCHITECTURE.md` and the durable specs/tests.
