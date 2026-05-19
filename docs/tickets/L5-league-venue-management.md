# L5: League Venue Management + Conflict Detection

**Phase:** 7B — League Scheduling & Master Calendar
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L4, Phase 4A (venue management)

## Description

Enable leagues to manage a shared pool of venues across member teams, with conflict detection to prevent double-booking teams or venues.

## Deliverables

- `league_venues` table: league-level venue pool (references existing `venues` table with `league_id` scope)
- League venue API:
  - `POST /leagues/:id/venues` — add venue to league pool
  - `GET /leagues/:id/venues` — list league venues with availability
  - `PUT /leagues/:id/venues/:venueId` — update venue details
  - `DELETE /leagues/:id/venues/:venueId` — remove venue from pool
- Conflict detection: when scheduling a game, check for:
  - Venue already booked at that time
  - Either team already has a game at that time
- `GET /leagues/:id/venues/:venueId/availability?date=YYYY-MM-DD` — venue availability for a given date
- Venue utilization report: `GET /leagues/:id/venues/utilization?start=&end=` — usage stats per venue

## Acceptance Criteria

- [ ] League admin can manage a shared venue pool
- [ ] Conflict detection prevents double-booking venues and teams
- [ ] Venue availability API returns correct open slots
- [ ] Utilization report shows games per venue over a date range
