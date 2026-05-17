# F8: Admin Dashboard — Guardians + Staff CRUD

**Repo:** `zice-frontend`
**Type:** Frontend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** F7 (Admin Dashboard layout + players)
**Blocks:** None

## Description

Build guardian management and staff/member management pages within the admin dashboard. Both support soft-delete and restore operations.

## Acceptance Criteria

- [ ] Guardian list page: all guardians across org players
- [ ] Guardian detail page: permissions, linked players, audit history
- [ ] Guardian deactivate/reactivate with reason (uses existing `guardian_audit_log`)
- [ ] Guardian soft-delete (permanent archive via `deleted_at`)
- [ ] Staff/member list page: admins, coaches, parents, viewers
- [ ] Staff detail page: role, joined date, status
- [ ] Invite new member form (email, role selection)
- [ ] Role change functionality (e.g., promote parent → coach)
- [ ] Staff soft-delete and restore
- [ ] `AuditTrail` timeline component for guardian change history
- [ ] Unit tests for guardian and staff CRUD components

## Pages

```
/admin/guardians          → Guardian list
/admin/guardians/[id]     → Guardian detail (permissions, audit trail)
/admin/staff              → Staff/member list
/admin/staff/[id]         → Member detail (role, edit)
/admin/staff/invite       → Invite new member
```

## Design Reference

See design doc Section 19.2: CRUD Operations by Entity (Guardians, Staff)
