# Zice Platform — Ticket Tracker

These tickets are stored as markdown for offline reference and future import into Linear (or another project management tool).

**Note:** Files in this directory are **specifications only** (not implementation). Code changes belong in the repo named on each ticket (for example `goruncoder/zice-agent` for Phase 9).

**AI agent context:** Platform architecture and per-repo guides live in [AGENTS.md](../../AGENTS.md) and [docs/templates/AGENTS/](../templates/AGENTS/). Sync into cloned repos with `make sync-agent-docs`.

## Completed (Phase 1 & 2)

| Ticket | Title | Repo | Status |
|---|---|---|---|
| C1 | Scaffold Go project + Makefile + Docker | zice-core | Done (PR #1) |
| C2 | Foundation schema — tables, indexes, triggers | zice-core | Done (PR #2) |
| C3 | RLS policies + helper functions | zice-core | Done (PR #3) |
| C4 | Core API handlers + OpenAPI spec | zice-core | Done (PR #6) |
| C5 | Auth + tenant middleware | zice-core | Done (PR #4) |
| C6 | Auth API endpoints + invite system | zice-core | Done (PR #5) |
| C7 | Dev seeder — test data | zice-core | Done (PR #10) |
| C8 | Admin RLS policies for import | zice-core | Done (PR #11) |
| C9 | Admin bulk import API endpoints | zice-core | Done (PR #12) |
| F1 | Scaffold Next.js app + Makefile + Tailwind | zice-frontend | Done (PR #1) |
| F2 | Multi-tenant middleware | zice-frontend | Done (PR #4) |
| F3 | Roster Auditor — CSV parsing + matching engine | zice-frontend | Done (PR #2) |
| F4 | Roster Auditor — UI components + page | zice-frontend | Done (PR #3) |
| F5 | Auth UI — login, signup, onboarding | zice-frontend | Done (PR #5) |
| X1 | CI/CD: PR + deploy Slack notifications | Both | Done (PR #7/#6) |
| X2 | Production smoke test scripts | Both | Done (PR #8/#7) |

## In Progress (Soft Deletes, Audit Log, Admin Dashboard, Auth Security)

| Ticket | Title | Repo | Status | Est. Size |
|---|---|---|---|---|
| [C10](C10-soft-delete-migration.md) | Soft-delete migration + RLS updates | zice-core | Pending | Medium |
| [C11](C11-user-audit-log.md) | User audit log — table, middleware, API | zice-core | Pending | Medium |
| [C12](C12-password-validation.md) | Password validation + passkey support | zice-core | Pending | Small |
| [C13](C13-admin-crud-api.md) | Admin CRUD API — soft-delete + restore | zice-core | Pending | Medium |
| [F6](F6-password-passkey-ui.md) | Password strength meter + passkey UI | zice-frontend | Pending | Medium |
| [F7](F7-admin-dashboard-players.md) | Admin Dashboard — layout + players CRUD | zice-frontend | Pending | Medium |
| [F8](F8-admin-guardians-staff.md) | Admin Dashboard — guardians + staff CRUD | zice-frontend | Pending | Medium |
| [F9](F9-admin-audit-log-viewer.md) | Admin Dashboard — audit log viewer | zice-frontend | Pending | Medium |

## Phase 9 — AI Agent (zice-agent + frontend)

Implementation: [zice-agent](https://github.com/goruncoder/zice-agent) (backend) and [zice-frontend](https://github.com/goruncoder/zice-frontend) (UI). Local stack: `make dev-all` in zice-platform-dev.

| Ticket | Title | Repo | Status |
|---|---|---|---|
| [A1](A1-scaffold-auth-db-schema.md) | Scaffold + auth + DB schema | zice-agent | Spec |
| [A2](A2-agent-engine-tool-framework.md) | Agent engine + tool framework | zice-agent | Spec |
| [A3](A3-chat-api-conversation-crud.md) | Chat API + conversation CRUD | zice-agent | Spec |
| [A4](A4-schedule-game-tools.md) | Schedule & game tools | zice-agent | Spec |
| [A5](A5-roster-compliance-tools.md) | Roster & compliance tools | zice-agent | Spec |
| [A6](A6-communication-admin-tools.md) | Communication + admin tools | zice-agent | Spec |
| [A7](A7-chat-widget-frontend.md) | Chat widget (frontend) | zice-frontend | Spec |
| [A8](A8-conversation-management-ui.md) | Conversation management UI | zice-frontend | Spec |
| [A9](A9-admin-ai-settings-ui.md) | Admin AI settings UI | zice-frontend | Spec |

```
A1 ──► A2 ──► A3 ──► A4 / A5 / A6
              └──► A7 ──► A8
A3 / A6 ──► A9
```

## Dependency Graph

```
C10 (soft-delete migration) ──► C13 (admin CRUD API) ──► F7 (admin players CRUD)
                                                      ──► F8 (admin guardians+staff)
C11 (audit log)             ──► F9 (audit log viewer)
C12 (password validation)   ──► F6 (password+passkey UI)
```
