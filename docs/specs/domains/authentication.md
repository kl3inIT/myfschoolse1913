# Authentication Spec

Current behavior for login, session, and password reset.

## Mobile/Web Client

- The app starts at `/login`.
- Login uses phone number and password.
- There is no public register screen.
- Authenticated users are redirected away from `/login` to `/home`.
- Protected routes redirect unauthenticated users to `/login`.
- Access and refresh tokens are stored through `TokenStorage`.
- Widgets do not read/write tokens directly.
- Forgot-password flow uses request -> verify OTP -> reset password.

## Backend

- `POST /api/auth/login` returns an auth session.
- `POST /api/auth/refresh` rotates/returns a refreshed session.
- `POST /api/auth/logout` revokes the refresh token and returns no content.
- `POST /api/auth/password-reset/request` creates an OTP request.
- `POST /api/auth/password-reset/verify` verifies OTP and returns a reset token.
- `POST /api/auth/password-reset/confirm` changes the password.
- Access tokens are JWTs.
- Refresh tokens are opaque random tokens stored as hashes.

## Current Constraints

- Login is phone-number based.
- Primary mobile role is `STUDENT`.
- Parent, teacher, and admin mobile auth flows are out of scope.
