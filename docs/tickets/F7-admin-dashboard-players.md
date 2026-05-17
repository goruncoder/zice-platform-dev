# F7: Admin Dashboard — Layout + Players CRUD

**Repo:** `zice-frontend`
**Type:** Frontend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** F5 (Auth UI), C13 (Admin CRUD API)
**Blocks:** F8 (Guardians + staff CRUD)

## Description

Build the admin dashboard layout (sidebar, role-gating) and full CRUD pages for player management with soft-delete support.

## Acceptance Criteria

- [ ] `AdminLayout` with sidebar navigation (role-gated, redirects non-admins)
- [ ] Admin overview page at `/admin` with stats summary
- [ ] Player list page: sortable, filterable, paginated `DataTable`
- [ ] Player create page: form with validation (name, DOB, USA Hockey ID, jersey)
- [ ] Player edit page: pre-populated form
- [ ] `SoftDeleteButton` with confirmation dialog
- [ ] `RestoreButton` for admin recovery of soft-deleted players
- [ ] Archive view toggle (`?include_deleted=true`)
- [ ] Shared `DataTable` component (reusable across all entity pages)
- [ ] Unit tests for DataTable, SoftDeleteButton, forms

## Pages

```
/admin                    → Overview / stats
/admin/players            → Player list (DataTable)
/admin/players/new        → Create player form
/admin/players/[id]       → Player detail / edit
```

## Design Reference

See design doc Section 19: Admin Dashboard — Full CRUD
