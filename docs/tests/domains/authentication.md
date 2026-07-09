# Authentication Test Coverage

Mirrors `docs/specs/domains/authentication.md`.

## Automated

- Flutter widget test verifies the app starts on the login screen.
- Flutter widget test verifies navigation from login to forgot password.

## Verified By Build/Compile

- `flutter analyze` currently passes.
- `flutter test` currently passes.
- Backend compile passes as part of Gradle test execution before DB connection.

## Gaps

- Backend auth integration tests are not yet documented as passing in this
  repo.
- Password reset request/verify/confirm flow lacks focused Flutter widget tests.
- Token refresh/session-expired behavior lacks end-to-end coverage.
- Backend context test currently requires a correctly running PostgreSQL
  database.
