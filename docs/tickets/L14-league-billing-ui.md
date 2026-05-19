# L14: League Billing Dashboard UI

**Phase:** 7E — League Billing & Pricing
**Repo:** zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L13, L10

## Description

Build the league billing dashboard — subscription management, team payment status, invoice generation, and revenue overview.

## Deliverables

- League billing page at `/league/:slug/billing`
- Subscription card: current tier, max teams, renewal date, upgrade/downgrade CTA
- Billing model toggle: league-funded vs team-funded with discount configuration
- Team payment status table: team name, subscription status, last payment date, amount
- Invoice generator: create invoices for team dues with custom amount and due date
- Invoice list: status (paid/pending/overdue), amount, team, date
- Revenue summary: total revenue, outstanding balance, projected renewal cost
- Stripe customer portal link for payment method management

## Acceptance Criteria

- [ ] League admin can view and manage subscription
- [ ] Billing model toggle switches between league-funded and team-funded
- [ ] Invoice generation sends notification to target team admin
- [ ] Payment status table accurately reflects Stripe subscription data
- [ ] Responsive at mobile and desktop viewports
