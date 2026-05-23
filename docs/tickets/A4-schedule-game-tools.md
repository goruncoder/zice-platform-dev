# [A4] Schedule + game tools

**Linear:** [NEA-109](https://linear.app/neaa/issue/NEA-109/a4-schedule-game-tools)
**Phase:** 9B — Coach & Admin AI Tools
**Repo:** `goruncoder/zice-agent`
**Priority:** Medium
**Estimated LOC:** ~650

## Scope

Schedule and game query tools for the AI agent.

## Details

- `internal/tools/schedule.go` — Schedule tools
- `internal/tools/games.go` — Game/standings tools
- `get_upcoming_games` — Next N games for the team
- `get_schedule_by_date` — Games/practices on a specific date
- `get_standings` — Current season standings
- `check_venue_availability` — Check if a venue is available at a given time
- `get_season_stats` — Team record (W-L-T) for the season
- zice-core client methods for each endpoint
- Unit tests with mocked zice-core responses

## Dependencies

- A2 (tool registry)
