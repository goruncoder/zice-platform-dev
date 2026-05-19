# L9: League Official/Referee Management

**Phase:** 7C — League Standings, Stats & Officials
**Repo:** zice-core
**Est. Size:** Medium (~400 LOC)
**Dependency:** L4

## Description

Enable leagues to maintain a pool of referees/officials and assign them to games. Includes score submission verification and dispute workflow.

## Deliverables

- `league_officials` table: `id`, `league_id`, `user_id` (nullable), `name`, `email`, `phone`, `certification_level`, `status`
- `game_official_assignments` table: `game_id`, `official_id`, `role` (referee, linesman, scorekeeper)
- Officials API:
  - `POST /leagues/:id/officials` — add official to league pool
  - `GET /leagues/:id/officials` — list officials
  - `PUT /leagues/:id/officials/:officialId` — update official
  - `DELETE /leagues/:id/officials/:officialId` — remove official
  - `POST /leagues/:id/games/:gameId/officials` — assign official to game
  - `GET /leagues/:id/games/:gameId/officials` — list assigned officials
- Game result submission: team admins submit scores via `POST /leagues/:id/games/:gameId/result`
- League admin score verification: `PUT /leagues/:id/games/:gameId/result/verify`
- Score dispute: `POST /leagues/:id/games/:gameId/result/dispute` — team flags result for review

## Acceptance Criteria

- [ ] Officials can be added to league pool and assigned to games
- [ ] Team admins can submit game results
- [ ] League admin can verify or override submitted scores
- [ ] Dispute workflow notifies league admin and locks result until resolved
- [ ] Official assignments visible on game detail
