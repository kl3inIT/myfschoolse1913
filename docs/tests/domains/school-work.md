# Teacher And Parent School Work Test Coverage

Mirrors `docs/specs/domains/school-work.md`.

## Automated

- `VietnameseGradeCalculatorTests` covers the weighted Circular 22 semester
  calculation, regular-score averaging, rounding, and incomplete components.
- `RoleScopeServiceTests` covers teacher assignment and parent guardian-link
  service boundaries.
- `parent_workspace_dto_test.dart` verifies linked-child and published school
  data mapping into the Flutter domain model.
- The Spring context test runs Flyway through version 18 and validates the JPA
  mappings against PostgreSQL.

## Build Gates (2026-07-16)

- `backend/gradlew.bat clean test`: passed.
- `admin-web/pnpm lint`: passed.
- `admin-web/pnpm build`: passed (only the existing bundle-size warning).
- `flutter analyze`: no issues.
- `flutter test`: 5 tests passed.
- `flutter build apk --debug`: passed.

## Runtime And Browser Verification (2026-07-16)

- Flyway version 18 was active on `myfschoolse1913`.
- Admin overview returned two teachers, two teaching assignments, and three
  guardian links.
- Assigned teacher saw the 10A1 roster; an unrelated assignment was rejected.
- Linked parent saw two children; an unrelated student id was rejected.
- Teacher attendance and a published regular score were visible in the parent
  workspace.
- Parent-created short leave was approved by the assigned homeroom teacher and
  returned as approved to the parent.
- Admin corrected a published score from 7.5 to 7.6; one audit row was created,
  the overview reflected 7.6, and the teacher's attempted re-edit returned 409.
- Real-browser checks rendered the Admin correction form, the scoped Teacher
  React workspace, and the Parent Flutter workspace with linked-child grades
  and attendance. Browser consoles had no errors.

## Gaps

- The verified multi-role browser walkthrough is not yet checked in as a
  permanent Playwright test.
- Controller-level integration tests could cover more malformed request and
  transaction rollback cases.
- Production notification delivery and identity verification remain outside
  this course-project fixture.
