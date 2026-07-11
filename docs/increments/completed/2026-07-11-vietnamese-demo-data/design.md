# Design: Vietnamese Demo Data And Teacher Walkthrough

## Goal

Replace the thin, accumulated local demo database with one deterministic,
credible Vietnamese high-school fixture that supports both the student app and
the admin web during the teacher review.

## Dataset Shape

- One admin account and 36 synthetic student accounts.
- Three populated classes in academic year `2026-2027`.
- A curriculum-shaped subject catalog including compulsory subjects, the
  current elective pool, and FPT-style enrichment subjects.
- Eight numerical semester grades per student with varied but deterministic
  score profiles.
- A weekly timetable for every class, including weekend activity slots so the
  demo dashboard is never empty on the review weekend.
- Events, notifications, applications, clubs, and registrations with enough
  state variety to exercise admin filters and student tabs.
- Six school knowledge documents ingested through the real embedding pipeline.

All people, phone numbers, student codes, and operational rules are synthetic.
Knowledge documents carry a demo disclaimer and do not claim to replace an
official school policy.

## Runtime Model

- `SEED_DEMO_USER=true` enables all demo seeders.
- Flyway remains the only schema owner.
- A fresh database is the supported reset path. The seeders are still
  idempotent enough for an accidental same-day restart, but the flag must be
  disabled after the fixture has been created so demo mutations persist.
- Knowledge documents use the same `SchoolDocumentIngestionService` as admin
  uploads, so successful startup proves text extraction, OpenAI embeddings,
  and pgvector writes.

## Acceptance Criteria

- Fresh database migrates through the latest Flyway version and backend starts.
- Admin dashboard shows 36 students, three populated classes, varied
  applications, and current notifications.
- Demo student `0900000001 / Password123` sees grades, a non-empty current-day
  schedule, events, applications, clubs, and notifications.
- Knowledge documents are `INDEXED` and the assistant answers a document-only
  question with a source title.
- One cross-surface mutation chain is verified: student creates an application,
  admin approves it, and the student reads the approved state.
