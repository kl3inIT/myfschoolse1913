# Backend VPS Deployment Plan

- [x] Audit the VPS, shared PostgreSQL, Docker networks, Nginx Proxy Manager,
  repository state, and DNS.
- [x] Add a production Spring profile, persistent JWT keys, configurable CORS,
  and independently controlled knowledge seeding.
- [x] Add a non-root Docker image and production Compose definition.
- [ ] Run backend tests and build the image locally.
- [ ] Commit, push, merge, and deploy the exact merged revision.
- [ ] Create isolated Docker networks, database role/database, pgvector
  extension, server-local secrets, and the application directory.
- [ ] Create the DNS record and Nginx Proxy Manager host with TLS.
- [ ] Run Flyway and the one-time demo seed, disable the seed flag, and restart.
- [ ] Verify health, login, role-scoped data, restart persistence, and logs.
- [ ] Consolidate architecture/runbook docs and update Northstar.
