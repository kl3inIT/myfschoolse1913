# Backend VPS Deployment Plan

- [x] Audit the VPS, shared PostgreSQL, Docker networks, Nginx Proxy Manager,
  repository state, and DNS.
- [x] Add a production Spring profile, persistent JWT keys, configurable CORS,
  and independently controlled knowledge seeding.
- [x] Add non-root Docker images and production Compose definitions for the
  React Admin/Teacher portal and Spring Boot API.
- [x] Run backend tests and build the API image locally.
- [x] Commit, push, merge, and deploy the exact API revision.
- [x] Create isolated Docker networks, database role/database, pgvector
  extension, server-local secrets, and the application directory.
- [ ] Build, publish, and deploy the React Admin/Teacher image.
- [ ] Create the DNS record and Nginx Proxy Manager host with `/` routed to web,
  `/api` routed to API, and TLS enabled.
- [x] Run Flyway and the one-time demo seed, disable the seed flag, and restart.
- [ ] Verify health, login, role-scoped data, restart persistence, and logs.
- [ ] Consolidate architecture/runbook docs and update Northstar.
