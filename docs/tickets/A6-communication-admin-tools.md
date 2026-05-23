# [A6] Communication + admin tools

**Linear:** [NEA-111](https://linear.app/neaa/issue/NEA-111/a6-communication-admin-tools)
**Phase:** 9B — Coach & Admin AI Tools
**Repo:** `goruncoder/zice-agent`
**Priority:** Medium
**Estimated LOC:** ~550

## Scope

Communication tools and admin configuration endpoints for the AI agent.

## API scope (vs A3 chat)

Chat streaming and conversation CRUD live in **A3** (`handlers/chat.go`, `handlers/conversations.go`). This ticket owns **tools** plus **admin/audit HTTP** below.

| Method | Path | Auth | Request / response |
|---|---|---|---|
| GET | `/api/v1/admin/config` | Org admin | Returns `{ enabled, monthly_budget_cents, model, retention_days }`. |
| PUT | `/api/v1/admin/config` | Org admin | Body: same shape; updates org AI settings. |
| GET | `/api/v1/admin/usage` | Org admin | Query: `?period=month`; returns token/cost aggregates and top users. |
| GET | `/api/v1/admin/conversations` | Org admin | Query: `?user_id=&from=&to=`; paginated audit list (no message bodies in list). |
| GET | `/api/v1/platform/ai/usage` | Platform admin | Cross-org usage summary (platform_admin role only). |

Suggested prompts (`GET /api/v1/suggestions?role=coach`) are implemented in **A2** (`suggestions.go`), not here.

## Details

- `internal/tools/communication.go` — Communication tools
- `internal/tools/meta.go` — Meta tools (user info, org info)
- `draft_announcement` — Generate announcement draft text (read-only, does NOT send)
- `get_user_info` — Current user's profile and role info
- `get_org_info` — Organization details and settings
- Admin endpoints:
  - GET/PUT /api/v1/admin/config — Enable/disable AI per org, set budget
  - GET /api/v1/admin/usage — Usage dashboard data (tokens, costs, top users)
  - GET /api/v1/admin/conversations — Conversation audit log
- Platform admin endpoints for cross-org management
- Unit tests

## Dependencies

- A2 (tool registry)
- A3 (admin handlers)
