# [A5] Roster + compliance tools

**Linear:** [NEA-110](https://linear.app/neaa/issue/NEA-110/a5-roster-compliance-tools)
**Phase:** 9B — Coach & Admin AI Tools
**Repo:** `goruncoder/zice-agent`
**Priority:** Medium
**Estimated LOC:** ~650

## Scope

Roster and compliance query tools for the AI agent.

## Details

- `internal/tools/roster.go` — Roster tools
- `internal/tools/compliance.go` — Compliance tools
- `get_roster` — Full team roster with player details
- `get_player_compliance` — Compliance status for a specific player
- `get_expiring_certifications` — SafeSport/coaching certs expiring soon
- `get_missing_documents` — Documents still needed for a player
- zice-core client methods for roster and compliance endpoints
- PII redaction on tool results (emails, phones redacted before LLM context)
- Unit tests with mocked zice-core responses

## Dependencies

- A2 (tool registry)
