# Backend Architecture Pointer

Backend architecture is documented at the repository level to avoid parallel
sources of truth:

- [../ARCHITECTURE.md](../ARCHITECTURE.md) - current backend stack, module
  layout, API surface, runtime config, and commands.
- [../docs/conventions.md](../docs/conventions.md) - backend coding and schema
  conventions.
- [../docs/specs/domains/](../docs/specs/domains/) - current behavior specs.
- [../docs/tests/domains/](../docs/tests/domains/) - backend and end-to-end test
  coverage/gaps.

Do not add long-lived backend facts here unless this backend becomes a separate
subproject-level documentation root.
