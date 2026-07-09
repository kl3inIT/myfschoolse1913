# Notifications Test Coverage

Mirrors `docs/specs/domains/notifications.md`.

## Automated

- No focused notification list/detail tests are recorded yet.

## Build Checks

- Current Flutter analyze/test/build checks pass with the notification working
  tree present.
- Backend Java compilation reaches test execution, but full context-load testing
  depends on a reachable PostgreSQL database.

## Gaps

- Add Flutter widget tests for notification cards, read/unread indicator, and
  detail navigation.
- Add backend tests for:
  - list includes read state;
  - detail marks a notification as read;
  - unknown notification returns 404;
  - access is scoped to the current student.
- Add runtime verification for list -> detail -> back -> read state refresh.
