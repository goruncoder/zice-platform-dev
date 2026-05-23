# L2: League RLS Policies

**Phase:** 7A — League Foundation
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1

## Description

Create row-level security policies for all league tables and update existing team-level policies to support league admin access.

## Deliverables

- RLS policies on `leagues`: league members can read; league admins can write
- RLS policies on `league_memberships`: league admins can manage; members can read own
- RLS policies on `league_teams`: league admins can manage; team admins can read own team's association
- RLS policies on `league_divisions`: league admins can write; league members can read
- Updated RLS on `organizations`: league admins can read member team org data
- Updated RLS on `players`/`rosters`: league admins can read AND write member team rosters (add/remove players)
- Updated RLS on `games`/`game_attendance`: league admins can read member team game data
- Helper functions: `is_league_admin(league_id)`, `is_league_member(league_id)`, `get_league_for_org(org_id)`
- Migration file: `00011_league_rls_policies.sql`

## Acceptance Criteria

- [ ] League admins can read all member team data (rosters, schedules, compliance)
- [ ] League admins can write to member team rosters (add/remove players)
- [ ] Team admins cannot see other teams' data within the league
- [ ] Standalone teams (no league) are unaffected by league RLS
- [ ] League viewers have read-only access to league-level data
- [ ] No cross-league data leakage
