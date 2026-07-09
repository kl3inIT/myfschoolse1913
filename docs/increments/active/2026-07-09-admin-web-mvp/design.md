# Admin Web MVP Design

## Product Shape

The admin web is an operations tool, not a marketing surface. It should be dense,
quiet, and optimized for repeated school-office tasks.

Do not add broad school-office modules by guesswork. New admin screens should be
chosen from the evidence-backed backlog in `research.md`.

## Import Student Flow

- The user logs in with an admin account.
- The first screen focuses on importing student accounts from CSV.
- Required CSV columns:
  - `studentCode`
  - `fullName`
  - `phoneNumber`
- Optional CSV columns:
  - `className`
  - `academicYearName`
  - `password`
  - `status`

## Account Rule

Students do not register themselves. Import creates the `AppUser` with role
`STUDENT`, then creates the linked `Student` record.
