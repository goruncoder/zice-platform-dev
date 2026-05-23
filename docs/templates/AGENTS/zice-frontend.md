# AGENTS.md — zice-frontend

> Next.js 14 frontend for the Zice multi-tenant sports management platform.

**Branching:** Target `main` for merges. Use `make check` before opening PRs.

## Platform documentation

Cross-repo context lives in [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev):

| Topic | Doc |
|---|---|
| System architecture (all repos) | [docs/ARCHITECTURE.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/ARCHITECTURE.md) |
| Auth flows | [docs/AUTH.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/AUTH.md) |
| Multi-tenant routing | [docs/MULTI-TENANT.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/MULTI-TENANT.md) |
| API reference (zice-core) | [docs/API.md](https://github.com/goruncoder/zice-platform-dev/blob/main/docs/API.md) |
| Implementation tickets (`F*` = this repo, `A*` = agent UI) | [docs/tickets/](https://github.com/goruncoder/zice-platform-dev/tree/main/docs/tickets) |

**Local full stack:** Clone [zice-platform-dev](https://github.com/goruncoder/zice-platform-dev), run `make clone`, then `make dev` (core on 8080 + frontend on 3000) or `make dev-all` (+ agent on 8081). Platform-dev runs the cloned `repos/` copies of each service (no extra symlink step).

## Quick Reference

| What | Command |
|---|---|
| Run tests | `npm test` or `npx vitest run` |
| Watch tests | `npm run test:watch` or `npx vitest` |
| Lint | `npm run lint` or `npx next lint` |
| Type check | `npx tsc --noEmit` |
| Pre-merge check | `make check` (lint + typecheck + test) |
| Dev server | `npm run dev` (port 3000) |
| Production build | `npm run build` |
| Smoke tests | `make smoke DEPLOY_URL=https://...` |

## Architecture

```
src/
  app/                          ← Next.js App Router pages
    (auth)/                     ← Auth pages (login, signup, verify, invite)
    (protected)/                ← Authenticated pages (dashboard, admin, settings)
      admin/                    ← Admin dashboard pages (players, guardians, staff, audit)
      dashboard/                ← User dashboard
      settings/security/        ← Password change + passkey management
    api/auth/                   ← API routes (Supabase auth callback, signout)
    tools/roster-auditor/       ← Roster Auditor tool page
  components/
    admin/                      ← Admin components (DataTable, SoftDeleteButton, RestoreButton)
    auth/                       ← Auth components (LoginForm, SignupForm, PasswordStrengthMeter, Passkey*)
    roster-auditor/             ← Roster Auditor components (FileDropZone, SummaryCards, etc.)
    ui/                         ← Shared UI components
  lib/
    api/client.ts               ← API client — typed fetch wrapper for zice-core endpoints
    config.ts                   ← Platform config (branding, URLs, Supabase keys)
    password.ts                 ← Password strength evaluation (5-point scoring)
    tenant.ts                   ← Subdomain parsing utility
    supabase/                   ← Supabase client (browser, server, middleware)
    roster-auditor/             ← CSV parsing, matching engine, validator
  middleware.ts                 ← Next.js middleware: auth + multi-tenant resolution
  test/                         ← Test setup (vitest)
```

## Key Patterns

### Multi-Tenant Middleware (`src/middleware.ts`)
Every request goes through middleware that:
1. Skips static assets (`/_next/`, `/favicon.ico`, etc.)
2. Refreshes Supabase auth session
3. Redirects unauthenticated users to `/login` (except public paths)
4. Resolves tenant from hostname:
   - Subdomain match → sets `x-org-slug` header
   - Custom domain → calls backend `GET /api/v1/tenants/resolve` → sets `x-org-slug`

### Configuration (`src/lib/config.ts`)
All branding and domain info is env-driven via `platformConfig`:
- `NEXT_PUBLIC_PLATFORM_NAME` — Display name (default: "Zice")
- `NEXT_PUBLIC_ROOT_DOMAIN` — Root domain (default: "zice.io")
- `NEXT_PUBLIC_API_URL` — Backend API URL (default: "http://localhost:8080")
- `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` — Supabase connection

### API Client (`src/lib/api/client.ts`)
Typed fetch wrapper for all backend endpoints. Usage:
```ts
import { api } from "@/lib/api/client";
const players = await api.listPlayers(token);
const result = await api.deletePlayer(token, playerId);
```
All methods accept a JWT token as the first argument. Returns typed response data.

### Auth Flow
- Supabase Auth handles signup, login, magic link, OAuth
- `@supabase/ssr` manages server-side session via cookies
- `src/lib/supabase/server.ts` — server component client
- `src/lib/supabase/client.ts` — browser client
- `src/lib/supabase/middleware.ts` — session refresh in middleware

### Password Policy
Enforced on signup and password change. `evaluatePassword()` in `src/lib/password.ts` returns a 0-5 score:
- At least 10 characters
- Contains uppercase letter
- Contains lowercase letter
- Contains a digit
- Contains a symbol

Score must be 5 (all checks pass) to proceed.

### Soft Deletes
Admin pages show active items by default. "Show archived" toggle reveals soft-deleted items with red background. `SoftDeleteButton` shows confirmation dialog; `RestoreButton` calls restore endpoint.

### Component Conventions
- **Tailwind CSS** for all styling (no CSS modules or styled-components)
- **React hooks** for state management (no Redux/Zustand)
- **Server Components** by default; `"use client"` only when needed (forms, interactivity)
- **Lucide React** for icons
- Test files colocated: `Component.test.tsx` next to `Component.tsx`

## Route Groups

### `(auth)` — Public auth pages
| Route | Page | Description |
|---|---|---|
| `/login` | LoginForm + OAuthButtons | Email/password + magic link + Google OAuth |
| `/signup` | SignupForm + PasswordStrengthMeter | Registration with password policy enforcement |
| `/verify` | Email verification | Post-signup email confirmation |
| `/invite/[token]` | Invite acceptance | Join org via invite link |

### `(protected)` — Authenticated pages
| Route | Page | Description |
|---|---|---|
| `/dashboard` | Dashboard | Home with links to Admin, Security, Roster Auditor |
| `/admin` | Admin overview | Cards linking to Players, Guardians, Staff, Audit Log |
| `/admin/players` | Players CRUD | Create, list, soft-delete, restore players |
| `/admin/guardians` | Guardians management | Guardian links with permissions |
| `/admin/staff` | Staff management | Admin/coach memberships with role badges |
| `/admin/audit` | Audit log viewer | Filterable timeline with expandable details, CSV export |
| `/settings/security` | Security settings | Change password + manage passkeys |

### Tools
| Route | Page | Description |
|---|---|---|
| `/tools/roster-auditor` | Roster Auditor | CSV upload, audit, export (client-side processing) |

## Roster Auditor (`src/lib/roster-auditor/`)

Entirely client-side CSV processing:
- `parser.ts` — PapaParse wrapper, auto-detects CSV format (USA Hockey, GameSheet, generic)
- `matcher.ts` — Fuzzy name matching (Levenshtein distance ≤ 2, normalization, suffix stripping)
- `validator.ts` — USA Hockey ID validation (14-char alphanumeric)
- `auditor.ts` — Orchestrates parse → match → validate → produce audit results
- `types.ts` — Shared TypeScript interfaces

## Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `NEXT_PUBLIC_PLATFORM_NAME` | Display name | `Zice` |
| `NEXT_PUBLIC_ROOT_DOMAIN` | Root domain | `zice.io` |
| `NEXT_PUBLIC_APP_URL` | App URL | `https://app.zice.io` |
| `NEXT_PUBLIC_SUPPORT_EMAIL` | Support email | `support@zice.io` |
| `NEXT_PUBLIC_API_URL` | Backend API URL | `http://localhost:8080` |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | — |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key | — |
| `NEXT_PUBLIC_LOGO_URL` | Logo path/URL | `/logo.svg` |
| `NEXT_PUBLIC_PRIMARY_COLOR` | Primary brand color | `#0F172A` |
| `NEXT_PUBLIC_ACCENT_COLOR` | Accent brand color | `#3B82F6` |

## Testing

Framework: **Vitest** + **React Testing Library** + **jsdom**

Config: `vitest.config.ts` (path aliases via `@/`)

Test structure:
- `src/lib/*.test.ts` — Unit tests for utilities
- `src/components/**/*.test.tsx` — Component tests
- `src/lib/roster-auditor/*.test.ts` — Roster auditor engine tests

101 tests across 13 test files. Run `npx vitest run` for all tests.

## Adding a New Page

1. Create page file in appropriate route group:
   - Auth page → `src/app/(auth)/new-page/page.tsx`
   - Protected page → `src/app/(protected)/new-page/page.tsx`
   - Admin page → `src/app/(protected)/admin/new-page/page.tsx`
2. Use Server Component by default; add `"use client"` only if interactive
3. For admin pages, reuse `DataTable`, `SoftDeleteButton`, `RestoreButton` from `src/components/admin/`
4. Add API methods to `src/lib/api/client.ts` if new backend calls needed
5. Add tests colocated with the component
6. Run `make check` before committing

## Adding a New API Endpoint Call

1. Add TypeScript interface in `src/lib/api/client.ts`
2. Add method to the `api` object using `apiRequest<T>()`
3. Use in components: `const data = await api.newMethod(token, ...params)`

## Hosting

- **Production**: Vercel
- **Auth**: Supabase Auth (email/password, magic link, Google OAuth, passkeys)
- **CI**: GitHub Actions (lint + typecheck + test on PR)
