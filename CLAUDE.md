# MyFSchoolSE1913 Agent Map

This file is a thin map for agents. It points to the repository system of
record; do not turn it back into an encyclopedia.

`AGENTS.md` and `CLAUDE.md` must stay synchronized.

## Documentation Map

- [README.md](./README.md) - project overview, quickstart, and doc index.
- [harness.md](./harness.md) - repository operating model for AI-assisted work.
- [ARCHITECTURE.md](./ARCHITECTURE.md) - current built facts: stack, layout,
  deployables, runtime config, and commands.
- [docs/vision.md](./docs/vision.md) - product intent, scope, MVP, and future
  direction.
- [docs/roadmap.md](./docs/roadmap.md) - delivery status and backlog.
- [docs/conventions.md](./docs/conventions.md) - code, Flutter, backend, commit,
  and documentation conventions.
- [docs/guidelines/](./docs/guidelines/) - reusable mechanics: learning mode,
  Penpot, testing, agent safety, and Flutter architecture notes.
- [docs/specs/domains/](./docs/specs/domains/) - current behavior by durable
  domain.
- [docs/tests/domains/](./docs/tests/domains/) - test coverage and gaps,
  mirroring the specs.
- [docs/decisions/](./docs/decisions/) - append-only rationale for significant
  decisions.
- [docs/increments/](./docs/increments/) - active/completed increment design and
  plan history.
- [LEARNING.md](./LEARNING.md) - Flutter learning progress; update only when the
  user demonstrates understanding.

## Workflow

- Read the existing files before changing code.
- Default to Learning Mode unless the user says `code mode`, `just build it`, or
  `tắt learning`.
- Keep explanations to the user in Vietnamese unless they ask otherwise.
- Work from current repo evidence, tests, logs, and local services before
  concluding.
- For every meaningful increment: design -> plan -> execute -> consolidate docs.
- For smaller changes, skip ceremony but still update specs/tests/decisions when
  durable behavior changes.

## Documentation Hygiene

- Keep this file thin. Product intent lives in `docs/vision.md`; current facts
  live in `ARCHITECTURE.md`; conventions live in `docs/conventions.md`.
- A spec records what a unit does now. Reusable mechanics live in
  `docs/guidelines/`.
- A test doc records what is covered and what remains untested. The reusable
  testing method lives in `docs/guidelines/testing-harness.md`.
- Completed increment docs are history, not current state.

## Safety

- Do not delete Gradle caches broadly.
- Do not run destructive git commands unless explicitly requested.
- Do not overwrite user changes without checking the diff.
- Do not add dependencies unless they solve a concrete need in this project.
