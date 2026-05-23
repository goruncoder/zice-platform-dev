# L6: League Calendar Export (iCal/Google Calendar)

**Phase:** 7B — League Scheduling & Master Calendar
**Repo:** zice-core
**Est. Size:** Small (~300 LOC)
**Dependency:** L4

## Description

Extend existing calendar export (Phase 4A C32) to support league-level schedule exports — full league, per-division, or per-team within league.

## Deliverables

- `GET /leagues/:id/schedule/ical` — full league schedule as iCal feed
- `GET /leagues/:id/schedule/ical?division=:divId` — division-filtered iCal feed
- `GET /leagues/:id/schedule/ical?team=:orgId` — single team's league games as iCal feed
- `GET /leagues/:id/schedule/export.json` — JSON export for Google Calendar import
- Google Calendar subscription URL generation for league schedules
- Feed includes venue, home/away teams, division info in event descriptions

## Acceptance Criteria

- [ ] iCal feed validates against RFC 5545
- [ ] Division and team filters work correctly
- [ ] Google Calendar can subscribe to the league feed URL
- [ ] Events include venue, teams, and division in description
