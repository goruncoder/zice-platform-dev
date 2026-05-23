# L15: League Revenue Sharing Configuration

**Phase:** 7E — League Billing & Pricing
**Repo:** zice-core
**Est. Size:** Small (~300 LOC)
**Dependency:** L13

## Description

Implement configurable revenue sharing between the platform and leagues. Platform takes a percentage of league subscription revenue; remainder goes to the league.

## Deliverables

- `league_revenue_config` table: `league_id`, `platform_fee_pct`, `effective_date`, `created_by`
- Platform admin API: `PUT /admin/leagues/:id/revenue-config` — set revenue share percentage
- Revenue report API: `GET /leagues/:id/billing/revenue?start=&end=` — revenue breakdown (gross, platform fee, net to league)
- Platform admin revenue dashboard data: `GET /admin/leagues/revenue` — aggregate platform revenue from all leagues
- Default platform fee configurable at platform level (e.g., 15%)

## Acceptance Criteria

- [ ] Platform fee percentage configurable per league
- [ ] Revenue report shows correct gross/fee/net breakdown
- [ ] Platform admin can view aggregate revenue across all leagues
- [ ] Default fee applies to new leagues automatically
