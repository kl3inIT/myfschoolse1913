# Plan: Basic Mobile And Flutter Web MVP

## Status 2026-07-10

All five steps verified against the running backend + northstar Postgres:

1. Docs/runbook: README quickstart updated (DB defaults now the
   `northstar-postgres-1` container, admin-web quickstart added).
2. Backend runtime: DB decided (5432/northstar), Flyway current,
   `gradlew test` green.
3. Notification detail/read-state: shipped earlier; recalled notifications
   verified hidden from the student list.
4. Flutter targets: `flutter analyze` clean, `flutter test` 4/4,
   `flutter build web` and `flutter build apk --debug` both pass (NDK
   version warning remains, non-blocking).
5. Demo walkthrough on the built web bundle (served statically, real
   backend): login → home (today schedule) → semester grades (shows
   admin-imported scores) → weekly schedule (shows admin-imported Saturday
   slots) → notifications + detail → applications (pending/approved/
   rejected tabs reflect admin review) → events → clubs → account → logout.

Remaining before closing the increment: the actual teacher demo.

## 1. Stabilize Docs And Runbook

- Apply repository-as-system-of-record harness.
- Make README quickstart accurate.
- Keep `AGENTS.md` and `CLAUDE.md` thin and synchronized.

## 2. Stabilize Backend Runtime

- Decide the local PostgreSQL port/user/password for this repo.
- Ensure Flyway migrations run through the latest migration.
- Enable demo data when needed with `SEED_DEMO_USER=true`.
- Re-run `.\gradlew.bat test --rerun-tasks` against the configured DB.

## 3. Finish Notification Detail

- Review working tree changes for notification detail/read-state.
- Add focused tests where practical.
- Verify list -> detail -> back refresh behavior.

## 4. Verify Flutter Targets

- Run `flutter analyze`.
- Run `flutter test`.
- Run Flutter Web build.
- Run Android debug APK build.
- Fix NDK warning if it becomes a blocker for local demo builds.

## 5. Demo Walkthrough

- Start backend and database.
- Run Flutter Web or Android.
- Verify login with demo credentials.
- Walk through home, grades, schedule, events, applications, clubs,
  notifications, account, and logout.
- Record skipped checks and known gaps.
