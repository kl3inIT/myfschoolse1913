# Operating Model: Repository As System Of Record

This repo uses the same lightweight documentation harness as `D:\northstar`.
Durable project knowledge belongs in versioned docs, not in chat history or one
large agent prompt.

## Principles

- The repo is the system of record.
- Entry files are maps, not encyclopedias.
- Follow progressive disclosure: start small, open deeper docs only when needed.
- Do not duplicate facts. Link to the source of truth.
- Current-fact docs record what is already built, not what is merely planned.
- Intent and future scope live in `docs/vision.md` and `docs/roadmap.md`.
- Rationale lives in append-only decision records.

## Document Roles

- `AGENTS.md` and `CLAUDE.md` are thin maps plus durable workflow rules.
- `ARCHITECTURE.md` records current built facts: stack, repo layout, runtime
  configuration, deployables, and commands.
- `docs/vision.md` records product intent, MVP scope, and future scope.
- `docs/roadmap.md` records delivery status and backlog.
- `docs/conventions.md` records how code and docs are written.
- `docs/guidelines/` records reusable mechanics such as testing, Penpot, and
  Learning Mode.
- `docs/specs/<axis>/` records current behavior of durable units.
- `docs/tests/<axis>/` mirrors specs and records coverage plus gaps.
- `docs/decisions/` records why significant choices were made.
- `docs/increments/` records active/completed design and plan pairs.

## Increment Flow

For a meaningful increment:

1. Capture intent and constraints.
2. Write `docs/increments/active/<YYYY-MM-DD-slug>/design.md`.
3. Write `plan.md` beside it.
4. Execute.
5. Consolidate durable facts into `ARCHITECTURE.md`, specs, tests, guidelines,
   and decisions.
6. Move the increment directory to `docs/increments/completed/`.

Small fixes and chores can skip design/plan, but not consolidation when durable
behavior changes.

## Hygiene Rules

- Completed increment docs are history, not current state.
- Specs say what a unit does. Guidelines say how a framework/tooling mechanic
  works.
- Test docs say what is covered and what is not. The reusable test method lives
  in `docs/guidelines/testing-harness.md`.
- Decisions are not edited to match the present. Supersede them with a new
  decision when reality changes.
