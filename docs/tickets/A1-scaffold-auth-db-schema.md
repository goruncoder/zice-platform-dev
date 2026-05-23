# [A1] Scaffold + auth + DB schema

**Linear:** [NEA-106](https://linear.app/neaa/issue/NEA-106/a1-scaffold-auth-db-schema)
**Phase:** 9A — Foundation & Chat
**Repo:** `goruncoder/zice-agent`
**Priority:** High
**Estimated LOC:** ~900

## Scope

Go project scaffold for `zice-agent` repo with Chi router, JWT middleware, sqlc models, migration, Dockerfile, Makefile, CI.

## Details

- `cmd/server/main.go` — entry point, graceful shutdown
- `internal/api/router.go` — Chi router setup, middleware chain
- `internal/api/middleware/auth.go` — JWT validation using `golang-jwt/jwt/v5` + Supabase JWKS
- `internal/config/config.go` — env config loading via `kelseyhightower/envconfig`
- `sql/migrations/001_ai_schema.sql` — conversations, messages, usage_logs, ai_org_config tables
- `sql/queries/*.sql` — sqlc query definitions
- `go.mod` with chi, pgx, zerolog, envconfig, go-openai, golang-jwt
- `Dockerfile` — multi-stage Go build
- `Makefile` — build, run, test, lint, migrate, sqlc, docker targets
- `.github/workflows/ci.yml` — lint + test on PR
- `AGENTS.md` — agent context doc

## Dependencies

None (first PR)
