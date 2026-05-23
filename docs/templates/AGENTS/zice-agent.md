# AGENTS.md — zice-agent

> AI chat and tool-calling service for the Zice sports management platform.

## Platform documentation

Cross-repo context lives in [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev):

| Topic | Doc |
|---|---|
| System architecture (all repos) | [docs/ARCHITECTURE.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/ARCHITECTURE.md) |
| Auth flows | [docs/AUTH.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/AUTH.md) |
| API reference (zice-core, tool targets) | [docs/API.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/API.md) |
| Implementation tickets (`A*` = this repo + frontend widget) | [docs/tickets/](https://github.com/goruncoder/zice-platform-dev/tree/main/docs/tickets) |

**Local full stack:** Clone [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev), run `make clone`, `make db-migrate`, then `make dev-all` (ports 3000 / 8080 / 8081).

## Quick Reference

| What | Command |
|---|---|
| Run server | `make dev` or `go run ./cmd/server` |
| Run tests | `make test` or `go test -race -count=1 ./...` |
| Lint | `make lint` or `golangci-lint run ./...` |
| Pre-merge check | `make check` (lint + test) |
| Build binary | `make build` → `bin/zice-agent` |
| Apply migrations (local) | From platform-dev: `make db-migrate-agent` |
| Clean | `make clean` |

## Role in the platform

- **Standalone Go service** on port **8081** — not embedded in zice-core
- **Platform data:** Read/write only via **zice-core REST** (`ZICE_CORE_URL`, `ZICE_CORE_SERVICE_KEY`); do not query org/player/roster tables directly
- **Agent data:** Own tables (`ai_conversations`, `ai_messages`, `ai_usage_logs`, `ai_org_config`) in shared PostgreSQL; migrations in `sql/migrations/`
- **Frontend:** Chat widget in zice-frontend calls this service; streams responses via **SSE**

## Architecture

```text
cmd/server/main.go              ← Entry point, graceful shutdown
internal/
  api/
    router.go                   ← Chi routes, middleware chain
    handlers/                   ← health, chat (SSE), conversations, suggestions, usage
    middleware/                 ← Auth (Supabase JWT), CORS, logger, rate limits, RequireOrg
    response/                   ← JSON envelope helpers (match zice-core style)
  agent/                        ← LLM engine, tool loop
  client/                       ← OpenAI + zice-core HTTP clients
  config/                       ← envconfig-loaded settings
  domain/                       ← Conversation, message, usage, LLM interface
  repository/postgres/          ← sqlc/pgx data access for ai_* tables
  tools/                        ← Tool registry; schedule/roster/comms tools call core API
sql/
  migrations/                   ← Agent schema (applied with platform `make db-migrate`)
  queries/                      ← sqlc query definitions (if present)
```

## Key patterns

- **Conventions** mirror zice-core: Chi router, handler structs, middleware tiers, standard response envelope
- **`LLMClient` interface** (`internal/domain/llm.go`) — swap LLM providers without changing handlers
- **Tool registry** — tools register by role; implementations use `ZiceCoreClient`
- **Security** — input/output validators (prompt injection, off-topic, PII); per-user and per-org rate limits
- **Suggestions** — `GET /api/v1/suggestions?role={role}` returns hardcoded prompts (not LLM-generated)

## API surface (summary)

| Route | Auth | Purpose |
|---|---|---|
| `GET /api/v1/health` | Public | Health + DB ping |
| `GET /api/v1/suggestions` | JWT | Role-based prompt suggestions |
| `POST /api/v1/chat` | JWT + org | SSE chat stream |
| `GET /api/v1/conversations` | JWT + org | List conversations |
| `GET /api/v1/conversations/{id}/messages` | JWT + org | Conversation messages |
| `DELETE /api/v1/conversations/{id}` | JWT + org | Delete conversation |
| `GET /api/v1/usage` | JWT + org | Org usage stats |

Org context: `middleware.RequireOrg` validates membership via zice-core before tenant-scoped handlers run.

## Environment variables

See `.env.example`. Critical vars:

| Variable | Purpose |
|---|---|
| `PORT` | Listen port (default `8081`) |
| `DATABASE_URL` | PostgreSQL for ai_* tables — use port `54322` with [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev) Docker Postgres (see `.env.example`) |
| `SUPABASE_URL` / `SUPABASE_JWT_SECRET` | JWT validation (same auth as frontend/core) |
| `OPENAI_API_KEY` / `OPENAI_MODEL` | LLM provider |
| `ZICE_CORE_URL` / `ZICE_CORE_SERVICE_KEY` | Service-to-service core API |
| `CORS_ALLOWED_ORIGINS` | Typically `http://localhost:3000` in dev |

## Testing & verification

- **This repo:** `make check`
- **Full stack:** From zice-platform-dev after `make clone`: `make check`, `make integration`, `make smoke`
- **Health:** `curl http://localhost:8081/api/v1/health`

## Related repos

| Repo | Role |
|---|---|
| [zice-core](https://github.com/goruncoder/zice-core) | Platform REST API (tool data source) |
| [zice-frontend](https://github.com/goruncoder/zice-frontend) | Next.js UI + chat widget |
| [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev) | Local orchestration, architecture docs, tickets |

## Hosting

- **Production:** Railway (port 8081)
- **Database:** Supabase PostgreSQL (shared instance; agent migrations separate from core)
- **CI:** GitHub Actions (lint + test on PR)
