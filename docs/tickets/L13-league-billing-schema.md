# L13: League Billing Schema + Stripe Integration

**Phase:** 7E — League Billing & Pricing
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1, Phase 3A (Stripe payments), Phase 8 (Productization)

## Description

Implement separate billing for leagues and league-affiliated teams. Supports both league-funded (league pays for all teams) and team-funded (teams pay individually with optional league discount) models.

## Deliverables

- `league_subscriptions` table: `id`, `league_id`, `stripe_subscription_id`, `tier` (free/pro/enterprise), `max_teams`, `billing_model` (league_funded/team_funded), `team_discount_pct`, `created_at`
- `league_invoices` table: `id`, `league_id`, `target_org_id` (nullable), `amount_cents`, `description`, `status`, `stripe_invoice_id`, `due_date`
- League subscription tiers: Free (up to 4 teams), Pro (up to 16 teams), Enterprise (unlimited)
- Stripe integration:
  - `POST /leagues/:id/billing/subscribe` — create/update league subscription
  - `GET /leagues/:id/billing` — billing dashboard data (subscription, invoices, team payment status)
  - `POST /leagues/:id/billing/invoices` — generate invoice for team dues
- Team-within-league pricing: discounted team subscription when `billing_model = team_funded`
- League-funded model: league subscription covers all member teams
- Webhook handler for league subscription lifecycle events

## Acceptance Criteria

- [ ] League can subscribe to Free/Pro/Enterprise tier
- [ ] Team count enforced per tier (4/16/unlimited)
- [ ] League-funded model: teams don't need individual subscriptions
- [ ] Team-funded model: teams get configurable discount
- [ ] Invoices can be generated for team dues
- [ ] Billing dashboard shows subscription and payment status
