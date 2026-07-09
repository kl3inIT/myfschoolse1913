# 0001 - Repository As System Of Record

Status: accepted

## Context

This project has accumulated product direction, Flutter learning rules, backend
conventions, Penpot guidance, verification rules, and session context inside
large agent prompt files. That makes future sessions read too much and risks
contradictions as the project grows.

`D:\northstar` already uses a lightweight repository harness that keeps
`AGENTS.md`/`CLAUDE.md` thin and moves durable facts into focused docs.

## Decision

Apply the same repository-as-system-of-record model here:

- `AGENTS.md` and `CLAUDE.md` stay thin maps plus workflow rules.
- `ARCHITECTURE.md` records current built facts.
- `docs/vision.md` records product intent and future scope.
- `docs/roadmap.md` records delivery status and backlog.
- `docs/conventions.md` records coding/documentation conventions.
- `docs/guidelines/` records reusable mechanics.
- `docs/specs/` records current behavior.
- `docs/tests/` records coverage and gaps.
- `docs/increments/` records active/completed increment design and plans.

## Consequences

Agents should start from the thin map, open only relevant docs, and update the
durable docs when behavior changes. Completed increment docs are history, not
current state.
