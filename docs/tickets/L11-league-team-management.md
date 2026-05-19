# L11: League Team Management UI

**Phase:** 7D — League Admin Dashboard & Communications
**Repo:** zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L3, L10

## Description

Build the league team management interface — invite teams to join the league, approve/reject applications, suspend teams, assign to divisions, and view team details.

## Deliverables

- Team management page at `/league/:slug/teams`
- Team list with status badges (active, pending, suspended)
- Invite team flow: search by name or enter email → send invitation
- Application review: approve/reject pending team applications
- Division assignment: drag-drop or select to assign teams to divisions
- Team detail panel: roster preview, record, compliance status, payment status
- Suspend/remove team workflow with confirmation dialog
- League directory: public-facing page listing all member teams with logos and records

## Acceptance Criteria

- [ ] League admin can invite teams and approve/reject applications
- [ ] Teams can be assigned to divisions
- [ ] Suspend/remove workflow includes confirmation and notification to team admin
- [ ] Public league directory accessible without auth
- [ ] Responsive at mobile and desktop viewports
