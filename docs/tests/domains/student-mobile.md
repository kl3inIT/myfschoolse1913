# Student Mobile Test Coverage

Mirrors `docs/specs/domains/student-mobile.md`.

## Automated

- `test/student_bottom_navigation_test.dart` verifies student bottom navigation
  renders `Trang chủ`, `Lịch`, `Thông báo`, and `Tài khoản`.
- The same test verifies no `Tin nhắn` tab is present.
- The same test verifies tapping `Lịch` notifies the selected destination index.

## Build Checks

- `flutter analyze` passes.
- `flutter test` passes.
- `flutter build web --dart-define=API_BASE_URL=http://localhost:8080` passes.
- `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080`
  passes, with an Android NDK warning to resolve if it becomes noisy.

## Gaps

- Home shortcut navigation lacks widget tests.
- Grades, schedule, events, applications, clubs, and account screens lack
  focused widget tests.
- End-to-end login -> feature -> logout has not been recorded as passing.
- Runtime checks require backend and PostgreSQL to be running with demo data.
