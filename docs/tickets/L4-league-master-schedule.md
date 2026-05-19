# L4: League Master Schedule — Schema + API

**Phase:** 7B — League Scheduling & Master Calendar
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1-L3, Phase 4A (game scheduling)

## Description

Enable league admins to create and manage a master game schedule for all member teams. Games created at league level automatically appear on both teams' calendars.

## Deliverables

- `league_games` view or extended `games` table: add `league_id`, `created_by_league BOOLEAN` columns to existing games table
- League schedule API:
  - `POST /leagues/:id/schedule/games` — create game between two member teams (home/away)
  - `GET /leagues/:id/schedule` — full league schedule with filters (division, team, date range)
  - `PUT /leagues/:id/schedule/games/:gameId` — reschedule/update game
  - `DELETE /leagues/:id/schedule/games/:gameId` — cancel game
- Schedule push: games created by league admin automatically visible on both teams' calendars
- Division-based schedule generation: `POST /leagues/:id/schedule/generate` — round-robin generator within division
- Reschedule notifications: changes propagate to both teams via notification system

## Acceptance Criteria

- [ ] League admin can create games between any two member teams
- [ ] Games appear on both teams' schedule views automatically
- [ ] Division-based round-robin generation creates correct matchups
- [ ] Teams cannot modify league-created games (read-only for team admins)
- [ ] Reschedule/cancel triggers notifications to affected teams
