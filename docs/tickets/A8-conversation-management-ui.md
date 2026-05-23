# [A8] Conversation management UI (frontend)

**Linear:** [NEA-113](https://linear.app/neaa/issue/NEA-113/a8-conversation-management-ui-frontend)
**Phase:** 9C — Frontend Integration
**Repo:** `goruncoder/zice-frontend`
**Priority:** Medium
**Estimated LOC:** ~600

## Scope

Conversation list, search, context injection, suggested prompts per role.

## Details

- Conversation list sidebar within chat panel
- Search conversations by keyword
- Delete conversations
- Context injection display (shows what page/team context is active)
- Suggested prompts per role (from GET /api/v1/suggestions?role={role})
- Conversation auto-close after 100 messages with prompt to start new
- Timestamp display and grouping
- Empty state for no conversations

## Dependencies

- A7 (chat widget)
