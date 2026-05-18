# F6: Password Strength Meter + Passkey UI

**Repo:** `zice-frontend`
**Type:** Frontend
**Priority:** High
**Milestone:** M2
**Est. Size:** Medium (201-500 LOC)
**Blocked by:** F5 (Auth UI), C12 (Password validation)
**Blocks:** None

## Description

Add a real-time password strength meter to signup/password-change forms. Implement passkey (WebAuthn) UI for registration, login, and management via Supabase's native passkey API.

## Acceptance Criteria

- [ ] `PasswordStrengthMeter` component: visual bar (weak/fair/strong/very strong) + requirements checklist
- [ ] Signup form integrates strength meter; submit disabled until all requirements met
- [ ] `PasskeyLoginButton` on login page: "Sign in with Passkey"
- [ ] `PasskeyRegister` component: register new passkey from account settings
- [ ] `PasskeyList` component: list registered passkeys with rename/delete
- [ ] Security settings page at `/settings/security`: password change + passkey management
- [ ] Supabase client initialized with `{ auth: { experimental: { passkey: true } } }`
- [ ] Unit tests for PasswordStrengthMeter validation logic
- [ ] Responsive design for all components

## Design Reference

See design doc Section 18: Password Security & Passkey Authentication
