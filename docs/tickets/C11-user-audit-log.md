# C11: User Audit Log — Table, Middleware, API

**Repo:** `zice-core`
**Type:** Backend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** C1 (Scaffold), C5 (Auth middleware)
**Blocks:** F9 (Audit log viewer)

## Description

Implement a comprehensive user audit log that captures all API requests and data mutations. Logs old/new state for creates, updates, and deletes. Password changes are logged as events only — no old/new password data is ever stored.

## Acceptance Criteria

- [ ] `audit_log` table created with RLS (append-only: INSERT only, no UPDATE/DELETE)
- [ ] Go HTTP middleware captures all mutation requests (POST/PUT/DELETE)
- [ ] `old_data` and `new_data` stored as JSONB for creates/updates/deletes
- [ ] Auth events logged: login, logout, signup, password_change, passkey_register
- [ ] Sensitive fields redacted: password, password_hash, refresh_token, access_token, current_password, new_password
- [ ] Password change events: `old_data=null`, `new_data=null`, only metadata recorded
- [ ] Request context captured: IP address, user agent, request ID
- [ ] Admin API endpoints: `GET /api/v1/admin/audit` (filterable), `GET /api/v1/admin/audit/:id`
- [ ] Query filters: user_id, resource_type, resource_id, action, date range, pagination
- [ ] RLS: org admins can SELECT their org's audit logs
- [ ] Indexes on: user_id, org_id, resource_type+resource_id, created_at DESC, action
- [ ] Unit tests for middleware, redaction, and API endpoints

## Technical Details

### Audit Log Table

See design doc Section 20.3 for full CREATE TABLE SQL.

### Middleware Pattern

```go
func AuditLog() func(http.Handler) http.Handler
```

Wraps all handlers. For mutations:
1. Capture pre-handler state (old_data)
2. Run handler with response recorder
3. Capture post-handler state (new_data)
4. Redact sensitive fields
5. Async INSERT into audit_log

### Redacted Fields

```go
var redactedFields = map[string]bool{
    "password": true, "password_hash": true,
    "refresh_token": true, "access_token": true,
    "current_password": true, "new_password": true,
}
```

## Design Reference

See design doc Section 20: User Audit Log
