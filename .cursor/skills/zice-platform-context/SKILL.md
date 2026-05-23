---
name: zice-platform-context
description: >-
  Onboard to the Zice multi-repo platform (zice-platform-dev, zice-core,
  zice-frontend, zice-agent). Use when building, reviewing, or testing features
  that span services, need architecture or auth/tenant context, or when the
  user mentions Zice local dev, make check, or cross-repo PRs.
---

# Zice platform context

## 1. Pick the right repo

| Work | Repo | Entry doc |
|------|------|-----------|
| Orchestration, DB, integration tests | `zice-platform-dev` | `AGENTS.md` |
| REST API, migrations, RLS | `zice-core` | `repos/zice-core/AGENTS.md` (after `make clone`) |
| Next.js UI, tenant middleware | `zice-frontend` | `repos/zice-frontend/AGENTS.md` |
| AI chat, tools, SSE | `zice-agent` | `repos/zice-agent/AGENTS.md` |

Platform topic docs: `docs/ARCHITECTURE.md`, `docs/AUTH.md`, `docs/MULTI-TENANT.md`, `docs/API.md`.

## 2. Local stack (from zice-platform-dev)

```bash
make clone      # clones repos + sync-agent-docs
make install
cp .env.example .env
make dev-all    # 3000 frontend, 8080 core, 8081 agent, 54322 Postgres
make seed       # first-time DB (auth stub + migrations + Joliet Jaguars data)
```

Test a service PR: `make checkout-pr REPO=zice-core PR=15` (also `zice-frontend`, `zice-agent`).

## 3. Verify before merge

| Scope | Command |
|-------|---------|
| Single repo | `make check` inside that repo |
| Full platform | `make check` from zice-platform-dev |
| Stack smoke | `make integration-all` (with `make dev-all` + `make seed`) |
| CI-style bootstrap | `make integration-ci` |

## 4. Invariants

- API: `Authorization: Bearer <jwt>` and `x-org-slug` for tenant routes.
- Agent reads platform data only via zice-core REST (not direct SQL on core tables).
- Schema changes need migrations + RLS in zice-core; agent tables in `zice-agent/sql/migrations/`.
- Ticket prefixes in `docs/tickets/`: `C*` core, `F*` frontend, `A*` agent, `L*` league.

## 5. Doc updates

If boundaries change (ports, env vars, flows), update `docs/ARCHITECTURE.md` and `docs/templates/AGENTS/<repo>.md`, then `make sync-agent-docs` and commit `AGENTS.md` in the service repo. See `CONTRIBUTING.md`.
