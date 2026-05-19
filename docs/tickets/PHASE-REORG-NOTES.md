# Phase Reorganization Notes

**Date:** 2026-05-19
**Status:** Pending Linear sync (token expired)

## Changes

### Phase 7: Native Mobile Apps → League Support
- **Old Phase 7:** Native Mobile Apps (App Store + Play Store releases, biometric auth, offline mode)
- **New Phase 7:** League Support (league tier between platform and teams, scheduling, standings, billing)
- **Reason:** League Support is a critical organizational tier that sits between the platform and individual teams. It introduces a new business model layer (league billing + team billing) and is higher priority than native mobile apps.

### Phase 13: Native Mobile Apps (NEW — last phase)
- Native Mobile Apps content moved unchanged from Phase 7 to Phase 13
- Sub-phases: 13A (iOS), 13B (Android), 13C (Cross-Platform Polish)
- PRs: N1–N9 (unchanged)
- Dependency on Phase 5B (mobile codebase) remains

### Phase 6E: Cross-Club & League Syncing → Superseded
- Phase 6E scope is now fully covered by Phase 7A–7F
- Marked as superseded in design doc with strikethrough

## Linear Tickets to Create (when token available)

### Phase 7 tickets (L1–L18):
- L1: League Foundation Schema (zice-core)
- L2: League RLS Policies (zice-core)
- L3: League Multi-Tenant Middleware + Core API (zice-core)
- L4: League Master Schedule — Schema + API (zice-core)
- L5: League Venue Management + Conflict Detection (zice-core)
- L6: League Calendar Export (zice-core)
- L7: League Standings — Auto-Calculation + Tiebreakers (zice-core)
- L8: League Stats Leaders (zice-core)
- L9: League Official/Referee Management (zice-core)
- L10: League Admin Dashboard (zice-frontend)
- L11: League Team Management UI (zice-frontend)
- L12: League Communications (zice-core + zice-frontend)
- L13: League Billing Schema + Stripe Integration (zice-core)
- L14: League Billing Dashboard UI (zice-frontend)
- L15: League Revenue Sharing Configuration (zice-core)
- L16: League Public Pages (zice-frontend)
- L17: League Branding + Theme Customization (zice-core + zice-frontend)
- L18: League Embeddable Widgets + Stats Pages (zice-frontend)

### Phase 13 tickets (N1–N9):
- N1–N3: iOS App Store Release
- N4–N6: Android Play Store Release
- N7–N9: Cross-Platform Polish

### Existing tickets to update:
- Phase 6E tickets (C54–C56, F39–F40): Mark as superseded by Phase 7
- Any references to "Phase 7: Native Mobile Apps" in existing tickets: Update to Phase 13

## Design Doc Decisions
- League admins can edit team rosters (add/remove players), but most roster management stays at team level
- Standalone teams work independently — no league required
- League + team billing are separate: league-funded and team-funded models supported
