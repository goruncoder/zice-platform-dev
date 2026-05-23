# L16: League Public Pages — Subdomain + Standings + Schedule

**Phase:** 7F — League Public Pages & Branding
**Repo:** zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1, L7, Phase 6B (website builder patterns)

## Description

Create public-facing league pages accessible via league subdomain (e.g., `metroyhl.zice.io`). No auth required. Shows standings, schedule, and team directory.

## Deliverables

- League subdomain routing: `{slug}.zice.io` resolves to league public pages
- Public league landing page: hero with league branding, quick links to standings/schedule/teams
- Public standings page: full league standings and division standings tables
- Public schedule page: filterable by division, team, date range — upcoming and past games
- Public team directory: card grid with team logo, name, record, division, link to team public page
- SEO meta tags: title, description, OpenGraph for social sharing
- 404 page for invalid league slugs

## Acceptance Criteria

- [ ] League subdomain resolves correctly
- [ ] Standings page shows correct W-L-T-OTL records
- [ ] Schedule page filters work (division, team, date)
- [ ] Team directory shows all active member teams
- [ ] Pages are accessible without authentication
- [ ] SEO meta tags render correctly
