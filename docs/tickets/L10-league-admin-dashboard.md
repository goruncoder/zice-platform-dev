# L10: League Admin Dashboard

**Phase:** 7D — League Admin Dashboard & Communications
**Repo:** zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1-L3

## Description

Build the league admin dashboard — a centralized view for league administrators to see member team health, upcoming games, standings snapshot, compliance status, and action items.

## Deliverables

- League admin dashboard page at `/league/:slug/dashboard`
- Member team overview: card grid showing each team's logo, record, next game, compliance status
- Upcoming games widget: next 5-10 league games with teams, venue, date/time
- Standings snapshot: top of each division
- Compliance status: teams with outstanding requirements flagged
- Action items: pending team applications, unverified scores, disputes
- Quick actions: create game, send announcement, manage officials

## Acceptance Criteria

- [ ] Dashboard loads with real-time data from league API
- [ ] Member team cards show correct record and compliance status
- [ ] Action items badge shows count of pending items
- [ ] Dashboard is accessible only to league admins
- [ ] Responsive at mobile (375px) and desktop (1440px)
