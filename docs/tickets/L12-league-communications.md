# L12: League Communications — Announcements & Notifications

**Phase:** 7D — League Admin Dashboard & Communications
**Repo:** zice-core + zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L3, Phase 4C (messaging), Phase 3C (notifications)

## Description

Enable league-wide announcements and notification preferences for league admins. League admins can push messages to all teams or specific divisions.

## Deliverables

### Backend (zice-core)
- `league_announcements` table: `id`, `league_id`, `author_id`, `title`, `body`, `target` (all/division/team), `target_ids[]`, `created_at`
- `POST /leagues/:id/announcements` — create league-wide announcement
- `GET /leagues/:id/announcements` — list announcements
- Announcement delivery: push to all member team channels or create notification per team admin
- League compliance overview: `GET /leagues/:id/compliance` — which teams have outstanding requirements

### Frontend (zice-frontend)
- Announcement composer in league admin dashboard
- Target selector: all teams, specific division, specific teams (multi-select)
- Announcement feed on league dashboard
- League compliance overview page: table of teams with compliance status badges

## Acceptance Criteria

- [ ] League admin can send announcements to all teams or filtered groups
- [ ] Announcements appear in target team messaging channels
- [ ] Compliance overview shows per-team status accurately
- [ ] Notification preferences configurable per league admin
