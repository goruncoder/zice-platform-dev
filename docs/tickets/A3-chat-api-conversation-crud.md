# [A3] Chat API + conversation CRUD + cost control

**Linear:** [NEA-108](https://linear.app/neaa/issue/NEA-108/a3-chat-api-conversation-crud-cost-control)
**Phase:** 9A — Foundation & Chat
**Repo:** `goruncoder/zice-agent`
**Priority:** High
**Estimated LOC:** ~700

## Scope

REST handlers, conversation list/get/delete, rate limiting, budget enforcement, usage tracking.

## Details

- `internal/api/handlers/chat.go` — POST /api/v1/chat/completions (SSE streaming)
- `internal/api/handlers/conversations.go` — GET/DELETE /api/v1/conversations
- `internal/api/handlers/usage.go` — GET /api/v1/usage
- `internal/api/handlers/admin.go` — Admin config endpoints (GET/PUT /api/v1/admin/config)
- `internal/api/middleware/ratelimit.go` — Sliding-window rate limiter (30 req/hr user, 200 req/hr org)
- `internal/api/middleware/costcontrol.go` — Budget enforcement middleware
- `internal/repository/conversations.go` — Conversation DB queries (sqlc)
- `internal/repository/messages.go` — Message DB queries
- `internal/repository/usage.go` — Usage tracking queries
- `internal/domain/conversation.go` — Conversation + Message domain types
- `internal/domain/usage.go` — Usage tracking types
- `internal/domain/config.go` — Org AI config types
- Abuse detection: injection attempt tracking, off-topic counting, temp bans
- GET /api/v1/suggestions?role={role} — Hardcoded example questions per role

## Dependencies

- A2 (agent engine)
