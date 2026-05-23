# [A9] Admin AI settings UI (frontend)

**Linear:** [NEA-114](https://linear.app/neaa/issue/NEA-114/a9-admin-ai-settings-ui-frontend)
**Phase:** 9C — Frontend Integration
**Repo:** `goruncoder/zice-frontend`
**Priority:** Medium
**Estimated LOC:** ~500

## Scope

Admin interface for managing AI agent settings per org.

## Details

- Enable/disable AI per org toggle
- Monthly token budget configuration
- Usage charts (recharts) — tokens used, cost, requests over time
- Top users by usage
- Conversation audit log — searchable, filterable
- Abuse detection alerts display
- Platform admin: cross-org AI usage overview

## Dependencies

- A6 (admin API endpoints)
- A8 (conversation management)
