# L8: League Stats Leaders

**Phase:** 7C — League Standings, Stats & Officials
**Repo:** zice-core
**Est. Size:** Medium (~400 LOC)
**Dependency:** L7, Phase 4A (scoring)

## Description

Aggregate individual player stats across all league teams into league-wide stat leader boards — top scorers, top goalies, penalty minutes, etc.

## Deliverables

- `league_player_stats` materialized view: aggregates player stats across all league teams
- Stats leader API:
  - `GET /leagues/:id/stats/leaders?category=goals` — top scorers
  - `GET /leagues/:id/stats/leaders?category=assists` — top assists
  - `GET /leagues/:id/stats/leaders?category=points` — top points (G+A)
  - `GET /leagues/:id/stats/leaders?category=gaa` — goalie GAA leaders
  - `GET /leagues/:id/stats/leaders?category=pim` — penalty minute leaders
  - `GET /leagues/:id/stats/leaders?category=save_pct` — save percentage leaders
- Configurable stat categories per league (different sports track different stats)
- Player stats link back to team and player profile
- Auto-refresh on game result submission

## Acceptance Criteria

- [ ] Stat leaders aggregate correctly across all league teams
- [ ] Category filter returns correct leaderboard
- [ ] Stats update when game results are submitted
- [ ] Players are linked to their team and profile
