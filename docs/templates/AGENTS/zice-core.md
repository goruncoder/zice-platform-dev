# AGENTS.md — zice-core

> Go REST API backend for the Zice multi-tenant sports management platform.

## Platform documentation

Cross-repo context lives in [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev):

| Topic | Doc |
|---|---|
| System architecture (all repos) | [docs/ARCHITECTURE.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/ARCHITECTURE.md) |
| Auth flows | [docs/AUTH.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/AUTH.md) |
| Multi-tenant routing | [docs/MULTI-TENANT.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/MULTI-TENANT.md) |
| API reference | [docs/API.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/API.md) |
| Implementation tickets (`C*` = this repo) | [docs/tickets/](https://github.com/goruncoder/zice-platform-dev/tree/main/docs/tickets) |

**Local full stack:** Clone [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev). From that repository, run `make clone`, then `make dev` to start the stack or `make check` to lint/test core + frontend + agent together.

## Quick Reference

| What | Command |
|---|---|
| Run tests | `make test` or `go test -race -count=1 ./...` |
| Lint | `make lint` or `golangci-lint run ./...` |
| Pre-merge check | `make check` (lint + test) |
| Build binary | `make build` → `bin/zice-core` |
| Start dev server | `make dev` (Docker) or `go run ./cmd/server` |
| Apply migrations | `make migrate` (requires Supabase CLI) |
| Generate OpenAPI | `make generate` (swag) |
| Smoke tests | `make smoke DEPLOY_URL=https://...` |
| Clean | `make clean` |

## Architecture

```
cmd/server/main.go          ← Entry point. Starts HTTP server on $PORT (default 8080).
internal/
  api/
    router.go               ← All route registration. Three middleware tiers:
                               1. Public (no auth)
                               2. Protected (auth required)
                               3. Tenant-scoped (auth + org context)
    handlers/                ← HTTP handlers (one file per domain entity)
    middleware/              ← Auth, tenant, CORS, request ID, logger, audit log
    response/               ← Standard {data, error, meta} envelope helper
  domain/                   ← Domain models and business logic (no HTTP dependency)
  supabase/                 ← Supabase client wrapper
supabase/migrations/        ← SQL migration files (applied via Supabase CLI)
api/                        ← OpenAPI/Swagger spec
scripts/                    ← Smoke test and utility scripts
docs/                       ← Generated API docs
```

## Key Patterns

### Response Envelope
All endpoints return: `{"data": ..., "error": null, "meta": {"timestamp": "..."}}`.
Use `response.JSON()`, `response.Error()`, `response.Created()` from `internal/api/response/`.

### In-Memory Handlers
Handlers use `sync.RWMutex`-protected in-memory maps for data storage. This is scaffolding — will be replaced with real Supabase queries when connected to a live database. Each handler struct has its own mutex and data slice/map.

### Middleware Chain
Routes are organized in three tiers in `router.go`:
1. **Public** (`mux`): health, signup, login, magic-link, refresh, tenant resolve
2. **Protected** (`protectedMux`): requires JWT auth via `middleware.Auth()`
3. **Tenant-scoped** (`tenantMux`): requires auth + org context via `middleware.Tenant()`

Audit logging middleware (`middleware.AuditLog`) wraps protected and tenant routes.

### Soft Deletes
All entities support soft-delete via `deleted_at` field. Default list endpoints exclude soft-deleted items. Admin endpoints (`/api/v1/admin/...`) support `?include_deleted=true` and restore operations.

### Audit Log
All mutations on protected/tenant routes are automatically logged by the audit middleware. Sensitive fields (passwords, tokens) are redacted. Admin can query via `GET /api/v1/admin/audit`.

## Domain Models

Located in `internal/domain/`. Each file defines the struct and validation logic:

| File | Entity | Key Fields |
|---|---|---|
| `player.go` | Player | id, first_name, last_name, dob, usa_hockey_id, deleted_at |
| `organization.go` | Organization | id, name, slug, custom_domain, deleted_at |
| `membership.go` | Membership | id, user_id, org_id, role (admin/coach/parent/player), deleted_at |
| `roster.go` | Roster | id, player_id, team_name, season, jersey_number, deleted_at |
| `guardian.go` | Guardian | id, player_id, guardian_user_id, relationship, permissions |
| `audit.go` | AuditEntry | id, user_id, org_id, action, resource_type, old_data, new_data |
| `password.go` | PasswordPolicy | min 10 chars, uppercase, lowercase, digit, symbol |

## Database

PostgreSQL via Supabase. Migrations in `supabase/migrations/`:

| Migration | Purpose |
|---|---|
| `20260516000001_foundation_schema.sql` | Core tables: organizations, players, memberships, rosters, player_guardians, games |
| `20260516000002_rls_policies.sql` | Row Level Security policies for all tables |
| `20260516000005_soft_delete.sql` | Adds `deleted_at` columns + partial indexes |
| `20260516000006_audit_log.sql` | Audit log table + indexes |

RLS enforces multi-tenant isolation. Users can only access data within orgs they belong to (via `memberships` table).

## API Routes

### Public
- `GET /api/v1/health` — Health check
- `POST /api/v1/auth/signup` — Register (validates password policy)
- `POST /api/v1/auth/login` — Login (returns JWT)
- `POST /api/v1/auth/magic-link` — Send magic link email
- `POST /api/v1/auth/refresh` — Refresh JWT
- `GET /api/v1/invites/{token}` — Validate invite token
- `GET /api/v1/organizations/{slug}` — Get org by slug
- `GET /api/v1/tenants/resolve` — Resolve tenant from domain/subdomain

### Protected (auth required)
- `POST /api/v1/auth/logout` — Logout
- `GET /api/v1/auth/me` — Get current user
- `PUT /api/v1/auth/me` — Update current user
- `PUT /api/v1/auth/password` — Change password (validates policy)
- CRUD for players, memberships, rosters
- `DELETE` on players/memberships = soft-delete

### Admin (auth + admin role)
- `GET /api/v1/admin/players` — List all players (including soft-deleted)
- `PUT /api/v1/admin/players/{id}/restore` — Restore soft-deleted player
- `PUT /api/v1/admin/memberships/{id}/restore` — Restore membership
- `PUT /api/v1/admin/rosters/{id}/restore` — Restore roster
- `GET /api/v1/admin/audit` — Query audit log (filterable)
- `GET /api/v1/admin/audit/{id}` — Get single audit entry

### Tenant-scoped (auth + org context)
- Invite creation, org updates, membership creation, roster CRUD

## Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `PORT` | Server listen port | `8080` |
| `SUPABASE_URL` | Supabase project URL | — |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | — |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | — |
| `SUPABASE_JWT_SECRET` | JWT verification secret | — |

## Testing

Tests are colocated with source files (`*_test.go`). Run `make test` to execute all.

Key test files:
- `internal/api/handlers/*_test.go` — Handler tests (HTTP request/response)
- `internal/api/middleware/*_test.go` — Middleware tests (auth, tenant, audit)
- `internal/domain/*_test.go` — Domain logic tests (password validation, audit)

## Adding a New Entity

1. Create domain model in `internal/domain/new_entity.go`
2. Create handler in `internal/api/handlers/new_entity.go` with `NewXxxHandler()`
3. Register routes in `internal/api/router.go` (choose public/protected/tenant tier)
4. Add migration in `supabase/migrations/` with next sequence number
5. Add RLS policies in the migration
6. Add tests for handler and domain logic
7. Run `make check` before committing

## Multi-Tenant Model

- Organizations identified by `slug` (subdomain) or `custom_domain`
- Users belong to orgs via `memberships` (role: admin, coach, parent, player)
- RLS policies enforce isolation: `org_id IN (SELECT org_id FROM memberships WHERE user_id = auth.uid())`
- Tenant middleware resolves org from request hostname and sets `x-org-slug` header

## Hosting

- **Production**: Railway
- **Database**: Supabase (PostgreSQL + Auth)
- **CI**: GitHub Actions (lint + test on PR, deploy notifications to Slack)
