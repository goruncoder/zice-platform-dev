# F9: Admin Dashboard — Audit Log Viewer

**Repo:** `zice-frontend`
**Type:** Frontend
**Priority:** Medium
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** C11 (User audit log API), F7 (Admin Dashboard layout)
**Blocks:** None

## Description

Build an audit log viewer within the admin dashboard. Displays a chronological timeline of all data changes with old/new diff views, filters, and CSV export.

## Acceptance Criteria

- [ ] Audit log page at `/admin/audit` with timeline view
- [ ] Chronological list of events with user avatars and timestamps
- [ ] Diff view: side-by-side old/new data comparison for updates
- [ ] Filters: by user, entity type, action, date range
- [ ] Search: full-text on path and metadata
- [ ] Pagination (server-side, 50 per page)
- [ ] CSV export of filtered audit entries
- [ ] Password change events show "Password changed" with no data diff
- [ ] Responsive design
- [ ] Unit tests for filter logic and diff rendering

## Pages

```
/admin/audit              → Audit log timeline
/admin/audit/[id]         → Single audit entry detail with full diff
```

## Design Reference

See design doc Section 20.7: Audit Log UI
