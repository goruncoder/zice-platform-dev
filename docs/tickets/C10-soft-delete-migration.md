# C10: Soft-Delete Migration + RLS Updates

**Repo:** `zice-core`
**Type:** Backend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** C2 (Foundation schema), C3 (RLS policies)
**Blocks:** C13 (Admin CRUD API)

## Description

Add `deleted_at timestamptz` columns to all core tables and update RLS policies to exclude soft-deleted rows from normal queries. This is the foundation for the universal soft-delete policy.

## Acceptance Criteria

- [ ] `deleted_at` column added to: `organizations`, `players`, `memberships`, `rosters`, `games`
- [ ] `deleted_at` column added to `player_guardians` (in addition to existing `is_active`)
- [ ] Partial indexes created on all tables: `WHERE deleted_at IS NULL`
- [ ] All existing SELECT RLS policies updated to include `AND deleted_at IS NULL`
- [ ] Migration is idempotent (safe to run multiple times)
- [ ] Existing seed data unaffected (all `deleted_at` values default to NULL)
- [ ] Unit tests pass

## Technical Details

### Migration SQL

```sql
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.players ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.memberships ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.rosters ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.games ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.player_guardians ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_organizations_active ON public.organizations (id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_players_active ON public.players (id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_memberships_active ON public.memberships (user_id, org_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_rosters_active ON public.rosters (org_id, team_designation, season) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_games_active ON public.games (org_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_player_guardians_active ON public.player_guardians (player_id) WHERE deleted_at IS NULL AND is_active = true;
```

### RLS Policy Updates

All SELECT policies must add `AND {table}.deleted_at IS NULL` to their USING clause.

## Design Reference

See design doc Section 17: Universal Soft-Delete Policy
