# Authentication Flow

## Overview

Zice uses Supabase Auth for all authentication. The Go backend validates JWTs issued by Supabase — it does not manage sessions or passwords directly.

## Supported Auth Methods

| Method | Description |
|--------|-------------|
| Email + Password | Standard signup with email verification |
| Magic Link | Passwordless email login |
| Google OAuth | Social login via Google |

## Signup Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────┐     ┌──────────┐
│  User    │     │  Frontend    │     │ Supabase │     │ zice-core│
│ (Browser)│     │  (Next.js)   │     │  Auth    │     │  (Go)    │
└────┬─────┘     └──────┬───────┘     └────┬─────┘     └────┬─────┘
     │                  │                  │                 │
     │  Fill signup form│                  │                 │
     ├─────────────────▶│                  │                 │
     │                  │  signUp()        │                 │
     │                  ├─────────────────▶│                 │
     │                  │                  │ Create user     │
     │                  │                  │ Send verify email│
     │                  │  { user, session }│                │
     │                  │◀─────────────────┤                 │
     │  Redirect /verify│                  │                 │
     │◀─────────────────┤                  │                 │
     │                  │                  │                 │
     │  Click email link│                  │                 │
     ├──────────────────┼─────────────────▶│                 │
     │                  │                  │ Verify email    │
     │  Redirect /auth/ │callback          │                 │
     │◀─────────────────┼──────────────────┤                 │
     │                  │                  │                 │
     │                  │  Exchange code   │                 │
     │                  ├─────────────────▶│                 │
     │                  │  { session }     │                 │
     │                  │◀─────────────────┤                 │
     │  Redirect        │                  │                 │
     │  /onboarding     │                  │                 │
     │◀─────────────────┤                  │                 │
```

## Login Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│  User    │     │  Frontend    │     │ Supabase │
└────┬─────┘     └──────┬───────┘     └────┬─────┘
     │  Fill login form │                  │
     ├─────────────────▶│                  │
     │                  │  signInWith      │
     │                  │  Password()      │
     │                  ├─────────────────▶│
     │                  │  { session }     │
     │                  │◀─────────────────┤
     │                  │  Set cookies     │
     │  Redirect        │  via @supabase/  │
     │  /dashboard      │  ssr             │
     │◀─────────────────┤                  │
```

## Invite Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────┐     ┌──────────┐
│  Admin   │     │  Frontend    │     │ zice-core│     │ Supabase │
└────┬─────┘     └──────┬───────┘     └────┬─────┘     └────┬─────┘
     │  Create invite   │                  │                 │
     ├─────────────────▶│                  │                 │
     │                  │ POST /invites    │                 │
     │                  ├─────────────────▶│                 │
     │                  │  { token, url }  │                 │
     │                  │◀─────────────────┤                 │
     │  Share invite URL│                  │                 │
     │◀─────────────────┤                  │                 │
     │                  │                  │                 │
┌────┴─────┐            │                  │                 │
│ Invitee  │            │                  │                 │
└────┬─────┘            │                  │                 │
     │  Open invite URL │                  │                 │
     ├─────────────────▶│                  │                 │
     │                  │ GET /invites/    │                 │
     │                  │ validate?token=  │                 │
     │                  ├─────────────────▶│                 │
     │                  │ { org, role }    │                 │
     │                  │◀─────────────────┤                 │
     │  Show invite page│                  │                 │
     │◀─────────────────┤                  │                 │
     │                  │                  │                 │
     │  Accept invite   │                  │                 │
     ├─────────────────▶│                  │                 │
     │                  │ POST /invites/   │                 │
     │                  │ accept           │                 │
     │                  ├─────────────────▶│                 │
     │                  │  Create          │                 │
     │                  │  membership      │                 │
     │                  │  { membership }  │                 │
     │                  │◀─────────────────┤                 │
     │  Redirect        │                  │                 │
     │  /dashboard      │                  │                 │
     │◀─────────────────┤                  │                 │
```

## JWT Structure

Supabase JWTs contain:

```json
{
  "sub": "user-uuid",
  "aud": "authenticated",
  "exp": 1234567890,
  "iat": 1234567890,
  "email": "user@example.com",
  "role": "authenticated",
  "app_metadata": {},
  "user_metadata": {}
}
```

The backend validates:
- Signature (using `JWT_SECRET`)
- Expiration (`exp` claim)
- Audience (`aud` must be `"authenticated"`)

## Middleware Chain

```
Request → Auth Middleware → Tenant Middleware → Handler
              │                   │
              │ Validate JWT      │ Read x-org-slug
              │ Extract user_id   │ Validate org exists
              │ Set auth context  │ Set tenant context
              ▼                   ▼
         401 if invalid     403 if no access
```

## Session Management

- Sessions are stored as HTTP-only cookies via `@supabase/ssr`
- The Next.js middleware refreshes the session on every request
- The `getUser()` method (not `getSession()`) is used for auth checks — this calls the Supabase API to verify the JWT, preventing use of expired tokens
- Signout hits `/api/auth/signout` which clears cookies server-side

## Protected Routes

| Route Pattern | Access |
|--------------|--------|
| `/login`, `/signup`, `/verify`, `/invite/*` | Public (redirects to `/dashboard` if authenticated) |
| `/dashboard` | Authenticated users only |
| `/tools/roster-auditor` | Authenticated users only |
| `/onboarding` | Authenticated users only |
| `/_next/*`, `/favicon.ico`, `/api/*` | Static/API (bypasses auth) |
