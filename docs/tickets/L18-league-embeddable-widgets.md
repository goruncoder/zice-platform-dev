# L18: League Embeddable Widgets + Stats Pages

**Phase:** 7F — League Public Pages & Branding
**Repo:** zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L7, L8, L16

## Description

Create embeddable widgets (standings table, upcoming schedule) that teams and leagues can embed on external sites. Also build public stats leader pages with historical season data.

## Deliverables

- Embeddable standings widget: `<iframe>` or `<script>` embed for league standings table
  - `GET /leagues/:id/embed/standings` — returns standalone HTML/JS widget
  - Configurable: division filter, theme (light/dark), max rows
- Embeddable schedule widget: upcoming games embed
  - `GET /leagues/:id/embed/schedule` — returns standalone HTML/JS widget
  - Configurable: division/team filter, date range, theme
- Public stats leader pages:
  - `/league/:slug/stats` — stat leaders with category tabs (goals, assists, points, GAA, save%, PIM)
  - `/league/:slug/stats/teams` — team comparison page (sortable by any stat)
  - `/league/:slug/stats/history` — historical season selector with past standings/leaders
- Embed code generator in league admin settings: copy-paste snippet for external sites
- Widget styling respects league branding (colors, logo)

## Acceptance Criteria

- [ ] Standings widget renders correctly when embedded on external site
- [ ] Schedule widget renders correctly when embedded on external site
- [ ] Widgets respect league branding colors
- [ ] Stats leader pages show correct aggregated data
- [ ] Historical season data accessible via season selector
- [ ] Embed code generator produces working snippets
