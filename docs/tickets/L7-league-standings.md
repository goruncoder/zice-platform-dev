# L7: League Standings — Auto-Calculation + Tiebreakers

**Phase:** 7C — League Standings, Stats & Officials
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L4, Phase 4A (scoring/standings)

## Description

Auto-calculate league-wide standings from game results across all member teams, with configurable tiebreaker rules and division-scoped standings.

## Deliverables

- `league_standings` materialized view or computed table: W-L-T-OTL, points, GF, GA, goal differential, streak, last 10
- `league_tiebreaker_rules` table: configurable per league (head-to-head, goal differential, goals for, etc.)
- Division standings: standings scoped to division/conference groups
- Standings API:
  - `GET /leagues/:id/standings` — full league standings
  - `GET /leagues/:id/standings?division=:divId` — division standings
  - `PUT /leagues/:id/standings/tiebreakers` — configure tiebreaker order
- Auto-recalculation trigger: standings update when game results are submitted
- Points system configuration: wins = 2pts, OTL = 1pt, etc. (configurable per league)

## Acceptance Criteria

- [ ] Standings auto-calculate from game results
- [ ] Division standings filter correctly
- [ ] Tiebreaker rules resolve ties in correct order
- [ ] Points system is configurable per league
- [ ] Standings recalculate within seconds of score submission
