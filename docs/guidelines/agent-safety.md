# Agent Safety

This repo is a learning project and an active school prototype. Preserve both:
do not make broad cleanup changes just because they look tidy.

## Working Rules

- Read existing files before changing code.
- Prefer current repo evidence, logs, tests, and local services over guesses.
- In a dirty worktree, do not revert unrelated user changes.
- Keep edits scoped to the requested behavior.
- Do not run `git reset --hard` or `git checkout --` unless explicitly asked.
- Do not delete Gradle caches broadly.
- Do not add dependencies without a concrete project need.

## Local Environment Traps

- Flutter Web can be used as a local verification target when no emulator/device
  is connected.
- Android/Gradle work on this machine should use a compatible JDK for the
  project. Do not assume a newer JDK is automatically compatible.
- Backend tests require a reachable PostgreSQL database matching
  `application.yml`.
- `bootRun` is not a terminating test gate.
- Runtime logs are generated artifacts and should not become source-of-truth
  docs.

## Current Documentation

- Use local repo files first.
- Use current official documentation for library/framework/API questions when
  local source does not answer the question.
- Update durable docs when a durable fact changes.
