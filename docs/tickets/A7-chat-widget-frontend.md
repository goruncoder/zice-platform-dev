# [A7] Chat widget component (frontend)

**Linear:** [NEA-112](https://linear.app/neaa/issue/NEA-112/a7-chat-widget-component-frontend)
**Phase:** 9C — Frontend Integration
**Repo:** `goruncoder/zice-frontend`
**Priority:** Medium
**Estimated LOC:** ~800

## Scope

Floating chat widget accessible from all authenticated pages in zice-frontend.

## Details

- Floating action button (bottom-right corner)
- Slide-out panel (right side, 400px wide)
- Welcome screen with role-based example questions (clickable chips)
- EventSource SSE client for real-time token streaming
- Message rendering with markdown support
- Loading indicators during tool calls ("Looking up schedules...")
- "New conversation" button
- Context badge showing current page/team
- Error handling for rate limits, budget exceeded, auth failures
- Responsive design (collapses on mobile)

## Dependencies

- A3 (chat API must exist)
