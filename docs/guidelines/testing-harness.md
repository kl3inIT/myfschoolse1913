# Testing Harness

Code compiling is not enough. Use targeted checks that match the blast radius of
the change.

## Flutter Gates

Run after Flutter code changes when practical:

```powershell
flutter analyze
flutter test
```

For web/demo confidence:

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:8080
```

For Android compile confidence:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Backend Gates

Run from `backend/`:

```powershell
.\gradlew.bat test --rerun-tasks
```

This requires PostgreSQL to be reachable using the configured `DB_URL`,
`DB_USERNAME`, and `DB_PASSWORD`.

Use `bootRun` to run the backend, not to prove a terminating verification gate.

## Runtime Flow Checks

For user-facing behavior:

- Start the backend and database.
- Run Flutter Web or Android.
- Verify the real flow: login -> home -> target feature -> error/session/logout
  behavior where relevant.
- Shut down background services you started unless the user asks to keep them.

## Completion Evidence

When reporting completion, include:

- commands run and outcomes;
- any skipped gate and why;
- whether checks were compile-only, widget tests, backend context tests, or real
  runtime/browser checks.
