# Backend Architecture

This backend is a Spring Boot modular monolith.

## Package Shape

Business modules live as direct sub-packages of `vn.edu.fpt.myfschoolse1913`:

```text
vn.edu.fpt.myfschoolse1913
  auth        login, refresh token, logout
  user        user entity, role, repository
  security    Spring Security and JWT infrastructure
  shared      cross-module API errors and common web support
  bootstrap   local/demo bootstrap code
```

Future modules should follow the same shape:

```text
grades
schedule
events
applications
clubs
notifications
account
```

## Rules

- Keep code organized by feature/domain, not by global layers.
- Prefer `auth/AuthController.java`, `auth/AuthService.java`, `auth/RefreshTokenRepository.java`.
- Avoid global packages such as `controller`, `service`, `repository` at the app root.
- A module may depend on `shared`.
- `shared` must not depend on business modules.
- Cross-module calls should go through public module APIs, not random internal classes.
- Keep database migrations in `src/main/resources/db/migration`.

## Auth Strategy

- Access token: short-lived JWT.
- Refresh token: opaque random token.
- Store only refresh token hashes in PostgreSQL.
- Rotate refresh tokens on refresh.
- Revoke refresh tokens on logout.
