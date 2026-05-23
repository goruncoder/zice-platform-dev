# L17: League Branding + Theme Customization

**Phase:** 7F — League Public Pages & Branding
**Repo:** zice-core + zice-frontend
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1, L16

## Description

Enable league-level branding customization — custom colors, logo, banner image applied to all league pages. Extend existing org branding patterns to league entities.

## Deliverables

### Backend (zice-core)
- League settings JSONB schema: `branding.primary_color`, `branding.logo_url`, `branding.banner_url`, `branding.favicon_url`
- `PUT /leagues/:id/branding` — update league branding settings
- `GET /leagues/:id/branding` — get league branding (public, no auth)
- Logo/banner upload via existing media upload endpoints scoped to league

### Frontend (zice-frontend)
- League branding settings page at `/league/:slug/settings/branding`
- Color picker for primary/secondary colors
- Logo and banner image upload with preview
- Live preview of branding changes on public pages
- CSS variable injection: league branding applied via CSS custom properties on league pages

## Acceptance Criteria

- [ ] League admin can set custom colors, logo, and banner
- [ ] Public league pages reflect branding changes
- [ ] Default branding applies if no custom branding is set
- [ ] Logo/banner uploads work with existing media pipeline
- [ ] Responsive branding renders correctly on mobile
