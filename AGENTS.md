# AGENTS.md — zice-platform-dev

> Development environment orchestrator for the Zice platform. Coordinates zice-core (Go backend), zice-frontend (Next.js), and zice-agent (AI assistant) for local development and testing.

## Read this first

| If you are… | Start here |
|---|---|
| New to the platform | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — services, ports, request flows |
| Implementing auth / JWT | [docs/AUTH.md](docs/AUTH.md) |
| Working on subdomains / custom domains | [docs/MULTI-TENANT.md](docs/MULTI-TENANT.md) |
| Calling or changing APIs | [docs/API.md](docs/API.md) |
| Picking up a ticket | [docs/tickets/](docs/tickets/) (`C*` core, `F*` frontend, `A*` agent, `L*` league) |
| Editing a service repo | Run `make sync-agent-docs` after clone; see `repos/<service>/AGENTS.md` |
| Full product / schema design | [docs/design-doc-zice-phase1-phase2.md](docs/design-doc-zice-phase1-phase2.md) |

**Agent context in service repos:** Canonical files live in [docs/templates/AGENTS/](docs/templates/AGENTS/). Sync into clones with `make sync-agent-docs` (commit the same content in each service repo when templates change).

**Cursor rules:** [.cursor/rules/](.cursor/rules/) — platform invariants, tenant/auth, and per-repo conventions when `repos/` is cloned.

## Quick Reference

| What | Command |
|---|---|
| Start everything | `make dev-all` (DB + backend + frontend + agent) |
| Start without agent | `make dev` |
| Start frontend only | `make dev-frontend` |
| Start backend only | `make dev-backend` |
| Start agent only | `make dev-agent` |
| Sync repos to configured branches | `make sync-repos` (core: `main`, frontend: `main`) |
| Stop all services | `make stop` |
| Check service status | `make status` |
| Run all tests | `make test` |
| Run all linters | `make lint` |
| Pre-merge gate | `make check` (lint + test across all repos) |
| Clone repos | `make clone` |
| Sync AGENTS.md into clones | `make sync-agent-docs` |
| Install deps | `make install` |
| Apply DB migrations | `make db-migrate` |
| Reset DB | `make db-reset` |
| Smoke tests | `make smoke` |
| Show all commands | `make help` |

## Architecture

This repo does NOT contain application code. It orchestrates the service repos:

```
zice-platform-dev/
  docker-compose.yml        ← PostgreSQL 16 (port 54322) for local dev
  Makefile                  ← Orchestration commands across all repos
  docs/
    API.md                  ← API documentation
    ARCHITECTURE.md         ← Architecture overview
    AUTH.md                 ← Authentication flow documentation
    MULTI-TENANT.md         ← Multi-tenant routing documentation
    design-doc-zice-phase1-phase2.md  ← Full design document
    tickets/                ← Ticket markdown files for Linear import
  repos/                    ← Cloned service repos (gitignored)
    zice-core/              ← Go backend (`main`, port 8080)
    zice-frontend/          ← Next.js frontend (`main`, port 3000)
    zice-agent/             ← AI assistant service (`main`, port 8081)
```

## Local Development Setup

```bash
# 1. Clone this repo and service repos
make clone

# 2. Install dependencies
make install

# 3. Start everything (PostgreSQL + backend + frontend)
make dev

# Services:
#   Frontend:  http://localhost:3000
#   Backend:   http://localhost:8080
#   Database:  localhost:54322 (user: postgres, password: postgres)
```

## Service Repos

| Repo | Language | Purpose | Port |
|---|---|---|---|
| [zice-core](https://github.com/goruncoder/zice-core) | Go 1.23 | REST API backend | 8080 |
| [zice-frontend](https://github.com/goruncoder/zice-frontend) | TypeScript/Next.js 14 | Web frontend | 3000 |
| [zice-agent](https://github.com/goruncoder/zice-agent) | Go 1.25 | AI chat / tool-calling service | 8081 |

Each service repo has its own `AGENTS.md` (maintained from `docs/templates/AGENTS/`). After `make clone`, run `make sync-agent-docs` so local copies match the platform templates.

`make db-migrate` applies SQL from both `zice-core/supabase/migrations/` and `zice-agent/sql/migrations/`.

## Database

Local PostgreSQL runs via Docker Compose:
- **Host**: `localhost`
- **Port**: `54322`
- **User**: `postgres`
- **Password**: `postgres`
- **Database**: `postgres`

Migrations live in `zice-core/supabase/migrations/`. Apply with `make db-migrate`.

In production, Supabase manages PostgreSQL with Row Level Security (RLS).

## Ticket Documentation

Ticket markdown files in `docs/tickets/` are formatted for future Linear import:

| Ticket | Description |
|---|---|
| C10 | Soft-delete migration + RLS updates |
| C11 | User audit log — table, middleware, API |
| C12 | Password validation + passkey support |
| C13 | Admin CRUD API — soft-delete + restore endpoints |
| C14 | Team Blog — schema, RLS, API endpoints |
| F6 | Password strength meter + passkey UI |
| F7 | Admin Dashboard — layout + players CRUD |
| F8 | Admin Dashboard — guardians + staff CRUD |
| F9 | Admin Dashboard — audit log viewer |
| F10 | Team Blog — feed + post viewer |
| F11 | Team Blog — editor + admin management |

## Design Document

The full design doc is at `docs/design-doc-zice-phase1-phase2.md`. It covers:
- Multi-tenant architecture with subdomain + BYOD custom domain routing
- "Family-First Universal Passport" identity model
- Database schema with RLS policies
- API-first architecture (OpenAPI spec)
- Authentication & onboarding flows
- Roster Auditor (client-side CSV processing)
- Admin import & bulk operations
- Soft-delete policy, password security, passkey authentication
- User audit log
- Team blog & content publishing
- PR breakdown strategy

Also stored on Linear: [Design Document](https://linear.app/neaa/document/phase-1-and-phase-2-technical-design-document-63388cde24b9)

## Infrastructure

| Service | Platform | Purpose |
|---|---|---|
| Frontend | Vercel | Next.js hosting with wildcard subdomains |
| Backend | Railway | Go API deployment |
| Database/Auth | Supabase | PostgreSQL + Auth + Storage |
| DNS | Cloudflare | DNS management, SSL for SaaS (custom domains) |
| CI | GitHub Actions | Lint, test, deploy notifications |

## Slack Channels

| Channel | Purpose |
|---|---|
| `#dice-platform-prs` | PR lifecycle notifications |
| `#dice-platform-deployment` | Deploy events + smoke test results |

## Project Tracking

- **Linear Project**: [Sports Management Platform](https://linear.app/neaa/project/sports-management-platform-279cb93ef2ca/overview)
- **Ticket naming**: `C*` = zice-core, `F*` = zice-frontend, `X*` = cross-repo

## Test Data

The dev seeder (zice-core PR #10) creates:
- **Org**: Joliet Jaguars (`joliet-jaguars`)
- **Team**: 14U Gold, 2025-26 season
- **Players**: 15 players (ages 12-14) with USA Hockey IDs and jersey numbers
- **Games**: 10-game schedule (Oct 2025 - Feb 2026)
- **Users**: 3 accounts (admin, coach, parent)
