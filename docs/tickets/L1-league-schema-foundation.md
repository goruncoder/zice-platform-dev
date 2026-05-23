# L1: League Foundation Schema

**Phase:** 7A — League Foundation
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** Phase 1 (multi-tenant schema)

## Description

Create the core league data model tables, indexes, and triggers.

## Deliverables

- `leagues` table: `id`, `name`, `slug`, `sport`, `logo_url`, `settings JSONB`, `billing_tier`, `stripe_customer_id`, `created_at`, `updated_at`, `deleted_at`
- `league_memberships` table: user-to-league role mapping (`league_admin`, `league_official`, `league_viewer`)
- `league_teams` table: league-to-team association with `join_date`, `status` (active/suspended/pending), `division_id`
- `league_divisions` table: optional grouping within leagues (e.g., "U14 Division A", "U16 Conference East")
- Updated `organizations` table: add `league_id` FK (nullable — null = standalone team), `league_join_status`
- Indexes on all FK columns and common query patterns
- `updated_at` triggers on all new tables
- Migration file: `00010_league_foundation.sql`

## Acceptance Criteria

- [ ] All tables created with proper constraints and indexes
- [ ] `league_id` on organizations is nullable (standalone teams have NULL)
- [ ] League slugs are unique
- [ ] Migration runs cleanly on fresh and existing databases
- [ ] `league_teams.status` enforces valid enum values
