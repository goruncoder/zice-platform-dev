# Contributing to Zice

The [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev) repo orchestrates local development; application code lives in service repos under `repos/` after `make clone`.

## Repositories

| Repo | Purpose |
|---|---|
| [zice-core](https://github.com/goruncoder/zice-core) | Go REST API |
| [zice-frontend](https://github.com/goruncoder/zice-frontend) | Next.js web app |
| [zice-agent](https://github.com/goruncoder/zice-agent) | AI chat service |
| **zice-platform-dev** (this repo) | Docker DB, Makefile, architecture docs, tickets |

## Local setup

```bash
make clone      # clone service repos into repos/
make install    # install dependencies
make db-migrate # apply core + agent SQL migrations
make dev-all    # DB + core + frontend + agent
```

## Before opening a PR

1. Run **`make check`** in the repo you changed (or from platform-dev for full-stack work).
2. Follow the PR template checklist (documentation section).
3. Use ticket prefixes from `docs/tickets/` (`C*`, `F*`, `A*`, `L*`, `X*`).

## Keeping AI agent context accurate

When your change affects **how agents should work** (not just implementation detail), update:

| Change type | Update |
|---|---|
| New service, port, or migration location | `docs/ARCHITECTURE.md` |
| Auth or tenant behavior | `docs/AUTH.md` and/or `docs/MULTI-TENANT.md` |
| API contract | `docs/API.md` |
| Repo layout, commands, conventions | `docs/templates/AGENTS/<repo>.md` then `make sync-agent-docs` and commit `AGENTS.md` in that service repo |

Cursor-specific rules live in `.cursor/rules/` in this repo.

## Architecture reference

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [AGENTS.md](AGENTS.md) — orchestration quick reference
