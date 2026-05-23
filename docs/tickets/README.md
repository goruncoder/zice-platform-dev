# Zice Platform — Ticket Tracker

These tickets are stored as markdown for offline reference and future import into Linear (or another project management tool).

**Note:** Files in this directory are **specifications only** (not implementation). Code changes belong in the repo named on each ticket (for example `goruncoder/zice-agent` for Phase 9).

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

## Dependency Graph

```
C10 (soft-delete migration) ──► C13 (admin CRUD API) ──► F7 (admin players CRUD)
                                                      ──► F8 (admin guardians+staff)
C11 (audit log)             ──► F9 (audit log viewer)
C12 (password validation)   ──► F6 (password+passkey UI)
```
