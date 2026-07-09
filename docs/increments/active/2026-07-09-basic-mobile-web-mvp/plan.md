# Plan: Basic Mobile And Flutter Web MVP

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
