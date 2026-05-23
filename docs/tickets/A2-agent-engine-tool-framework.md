# [A2] Agent engine + tool framework

**Linear:** [NEA-107](https://linear.app/neaa/issue/NEA-107/a2-agent-engine-tool-framework)
**Phase:** 9A — Foundation & Chat
**Repo:** `goruncoder/zice-agent`
**Priority:** High
**Estimated LOC:** ~1,100

## Scope

Core agent loop with go-openai streaming, tool registry/interface, SSE writer, context builder.

## Details

- `internal/agent/engine.go` — Core agent loop: prompt -> LLM -> tools -> stream
- `internal/agent/context.go` — Context injection (user, org, page, role)
- `internal/agent/prompt.go` — System prompt template rendering with security rules, scope restrictions
- `internal/agent/suggestions.go` — Role-based suggested prompts (example questions)
- `internal/tools/registry.go` — Tool interface + registration, role-based filtering
- `internal/client/openai.go` — go-openai wrapper: streaming, retry, timeout
- `internal/client/zicecore.go` — HTTP client for zice-core API with circuit breaker
- SSE writer helper with event types (token, tool_call, tool_result, done, error)
- Input validation (prompt injection detection, fuzzy matching, length limits)
- Output validation (PII redaction, off-topic detection, system prompt leak detection)
- Tool call limits (max 5 per request, max 3 sequential loops)
- Network isolation (egress firewall in HTTP transport, metadata IP blocking)

## Acceptance criteria (security)

| Area | Rule |
|---|---|
| Prompt injection | Reject user input over 4,000 characters; block messages matching a maintained injection pattern list (role override, ignore instructions, exfiltration prompts). Return HTTP 400 with a generic error. |
| PII redaction | Before streaming to the client, redact US SSN (`###-##-####`), credit-card runs (13–19 digits), and email addresses in assistant text (replace with `[redacted]`). |
| Off-topic | If the model output does not reference allowed domains (org, team, schedule, roster, announcements), append a short scope reminder and do not execute tools. |
| System prompt leak | If assistant output contains verbatim system-prompt markers or internal tool JSON schemas, replace the chunk with a safe fallback message. |
| Tool limits | Enforce max 5 tool calls per user turn and max 3 agent↔tool loops per request; return error event on SSE when exceeded. |
| Egress | HTTP transport allowlist: OpenAI API host(s), configured `ZICE_CORE_URL` only; deny private/metadata IP ranges (10/8, 172.16/12, 192.168/16, 169.254/16, localhost). |

## Dependencies

- A1 (scaffold)
