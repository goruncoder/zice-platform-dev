# [A6] Communication + admin tools

**Linear:** [NEA-111](https://linear.app/neaa/issue/NEA-111/a6-communication-admin-tools)
**Phase:** 9B — Coach & Admin AI Tools
**Repo:** `goruncoder/zice-agent`
**Priority:** Medium
**Estimated LOC:** ~550

## Scope

Communication tools and admin configuration endpoints for the AI agent.

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
