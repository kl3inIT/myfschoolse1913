# Plan: Vietnamese Demo Data And Teacher Walkthrough

## Status 2026-07-11

Completed. The dedicated database was recreated, Flyway applied all 16
migrations, the full fixture and six RAG documents were seeded, build/test
gates passed, and the cross-surface browser walkthrough met every acceptance
criterion. Durable instructions and evidence were consolidated into
`ARCHITECTURE.md`, the domain test docs, `docs/roadmap.md`, and
`docs/guidelines/teacher-demo-runbook.md`.

## 1. Build The Fixture

- Centralize synthetic student identities shared by user and school seeders.
- Populate classes, subjects, grades, timetables, events, notifications,
  applications, clubs, and registrations.
- Add classpath knowledge documents and ingest them through the production RAG
  pipeline.

## 2. Verify Before Destructive Reset

- Compile and test the backend against the current database.
- Review the diff and confirm only the dedicated `myfschoolse1913` database is
  in reset scope.

## 3. Rebuild Demo State

- Stop project services.
- Drop and recreate only `myfschoolse1913` in `northstar-postgres-1`.
- Start the backend once with `SEED_DEMO_USER=true` and a valid OpenAI key.
- Verify table counts, Flyway version, document indexing, and demo credentials.

## 4. Walk The Real Flow

- Run admin web and Flutter web.
- Verify admin and student read paths.
- Execute notification/application cross-surface behavior.
- Ask the assistant one personal-data question and one knowledge-base question.

## 5. Consolidate

- Update architecture, specs, tests, roadmap, and quickstart with the durable
  demo-fixture behavior and verification evidence.
- Move this increment to `completed/`.
- Close the three Northstar tasks only after all acceptance criteria pass.
