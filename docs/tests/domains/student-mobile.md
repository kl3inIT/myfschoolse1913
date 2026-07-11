# Student Mobile Test Coverage

Mirrors `docs/specs/domains/student-mobile.md`.

## Automated

- `test/student_bottom_navigation_test.dart` verifies student bottom navigation
  renders `Trang chủ`, `Lịch`, `Thông báo`, and `Tài khoản`.
- The same test verifies no `Tin nhắn` tab is present.
- The same test verifies tapping `Lịch` notifies the selected destination index.
- `DemoStudentFixturesTests` pins the 36 unique identities, three classes with
  12 students each, and the documented demo-student login fixture.

## Build Checks

- `flutter analyze` passes (2026-07-11).
- `flutter test` passes, 4 tests (2026-07-11).
- `flutter build web --dart-define=API_BASE_URL=http://localhost:8080` passes.
- `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080`
  passes, with an Android NDK warning to resolve if it becomes noisy.

## Runtime Verification (2026-07-11)

- Fresh fixture login -> home rendered `Nguyễn Minh Anh`, class `10A1`, year
  `2026-2027`, and two current-day activity slots.
- Grades, schedule, events, applications, clubs, notifications, and account
  APIs all returned 200 against the recreated database.
- Flutter Web created an absence application (201); the admin web approved it;
  a fresh student API read returned `APPROVED`.
- The assistant streamed both a personal-grade answer and a seeded-document
  answer in the Flutter UI.

## Gaps

- Home shortcut navigation lacks widget tests.
- Grades, schedule, events, applications, clubs, and account screens lack
  focused widget tests.
- The verified browser walkthrough is manual, not a checked-in Playwright test.
- Runtime checks require backend and PostgreSQL to be running with demo data.
