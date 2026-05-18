# C13: Admin CRUD API — Soft-Delete + Restore Endpoints

**Repo:** `zice-core`
**Type:** Backend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** C10 (Soft-delete migration), C4 (Core API handlers)
**Blocks:** F7 (Admin Dashboard — players CRUD), F8 (Admin Dashboard — guardians + staff CRUD)

## Description

Add soft-delete (DELETE) and restore (PUT) endpoints for all entities. Update existing GET endpoints to support `?include_deleted=true` query parameter for admin archive views. Implement cascading soft-delete for organizations.

## Acceptance Criteria

- [ ] DELETE endpoints for: players, guardians, memberships, rosters, games — all set `deleted_at = now()`
- [ ] Restore endpoints: `PUT /api/v1/admin/{entity}/{id}/restore` sets `deleted_at = NULL`
- [ ] GET list endpoints support `?include_deleted=true` for admin archive views
- [ ] Cascading soft-delete: deleting an org also soft-deletes its memberships and rosters
- [ ] Only org admins can soft-delete and restore (enforced via RLS + middleware)
- [ ] Soft-delete of player_guardians sets `deleted_at` (distinct from `is_active=false` deactivation)
- [ ] All mutations logged to audit_log (if C11 is merged)
- [ ] Unit tests for all delete, restore, and archive query endpoints

## API Endpoints

```
# Soft-delete (admin only)
DELETE /api/v1/players/:id
DELETE /api/v1/guardians/:id
DELETE /api/v1/memberships/:id
DELETE /api/v1/rosters/:id
DELETE /api/v1/games/:id

# Restore (admin only)
PUT /api/v1/admin/players/:id/restore
PUT /api/v1/admin/guardians/:id/restore
PUT /api/v1/admin/memberships/:id/restore
PUT /api/v1/admin/rosters/:id/restore
PUT /api/v1/admin/games/:id/restore

# Archive view (admin only, query param)
GET /api/v1/players?include_deleted=true
GET /api/v1/memberships?include_deleted=true
GET /api/v1/rosters?include_deleted=true
GET /api/v1/games?include_deleted=true
```

## Design Reference

See design doc Section 17.4 (API Behavior) and Section 19.2 (CRUD Operations by Entity)
