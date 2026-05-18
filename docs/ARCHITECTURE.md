# System Architecture

## Overview

Zice is a multi-tenant sports management platform built with a "Family-First Universal Passport" identity model. The architecture separates concerns across two main services with Supabase providing managed authentication and database.

## Service Map

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloudflare DNS                           │
│   *.zice.io (wildcard)  │  custom domains (BYOD)               │
└────────────┬────────────┴───────────────┬───────────────────────┘
             │                            │
     ┌───────▼────────┐          ┌───────▼────────┐
     │    Vercel       │          │    Railway      │
     │  zice-frontend  │────API──▶│   zice-core     │
     │  (Next.js 15)   │          │   (Go 1.23)     │
     │  Port 3000      │          │   Port 8080     │
     └───────┬─────────┘          └───────┬─────────┘
             │                            │
             │        ┌───────────────────┘
             │        │
     ┌───────▼────────▼──┐
     │     Supabase       │
     │  PostgreSQL + Auth  │
     │  + RLS Policies     │
     └────────────────────┘
```

## Service Responsibilities

### zice-frontend (Next.js)

- **Multi-tenant middleware**: Parses subdomain or resolves custom domain to inject `x-org-slug` header
- **Auth UI**: Login, signup, email verification, invite acceptance, onboarding wizard
- **Roster Auditor**: 100% client-side CSV parsing and fuzzy matching (no data leaves the browser)
- **Dashboard**: Authenticated landing page after login
- **Supabase SSR**: Server-side session management via `@supabase/ssr`

### zice-core (Go API)

- **REST API**: OpenAPI-documented endpoints for organizations, players, memberships, rosters
- **Auth middleware**: JWT validation with Supabase, audience claim checking
- **Tenant middleware**: X-Org-ID extraction and validation
- **Auth endpoints**: Signup, login, magic link, invite system
- **Tenant resolution**: Custom domain → org slug mapping

### Supabase

- **PostgreSQL**: All persistent data with Row Level Security (RLS)
- **Auth**: User signup, login, JWT issuance, magic links, OAuth
- **RLS Policies**: 22 policies across 6 tables ensuring data isolation

## Database Schema

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│organizations │     │   memberships    │     │   players    │
├──────────────┤     ├──────────────────┤     ├──────────────┤
│ id (PK)      │◄────│ org_id (FK)      │     │ id (PK)      │
│ name         │     │ user_id (FK)     │──┐  │ first_name   │
│ slug (unique)│     │ role (enum)      │  │  │ last_name    │
│ domain       │     │ status (enum)    │  │  │ dob          │
│ settings     │     └──────────────────┘  │  │ player_user  │
│ stripe_id    │                           │  │ _id (FK)     │
└──────┬───────┘                           │  └──────┬───────┘
       │                                   │         │
       │     ┌──────────────────┐          │  ┌──────▼───────────┐
       │     │     rosters      │          │  │player_guardians  │
       │     ├──────────────────┤          │  ├──────────────────┤
       └────▶│ org_id (FK)      │          └──│ guardian_id (FK) │
             │ player_id (FK)   │◄────────────│ player_id (FK)   │
             │ team             │             │ relationship     │
             │ jersey_number    │             │ permissions      │
             │ status (enum)    │             └──────────────────┘
             └──────────────────┘

                              ┌──────────────────────┐
                              │ guardian_audit_log    │
                              ├──────────────────────┤
                              │ id (PK)              │
                              │ player_guardian_id    │
                              │ action               │
                              │ performed_by         │
                              │ reason               │
                              │ previous_state       │
                              └──────────────────────┘
```

## Identity Model: "Family-First Universal Passport"

```
                    ┌─────────────┐
                    │  auth.users  │
                    │  (Supabase)  │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼──────┐    │     ┌──────▼──────┐
       │ Membership  │    │     │ Membership  │
       │ Org A:admin │    │     │ Org B:parent│
       └─────────────┘    │     └─────────────┘
                          │
                 ┌────────▼────────┐
                 │player_guardians │
                 │ (bridge table)  │
                 └────────┬────────┘
                          │
              ┌───────────┼───────────┐
              │           │           │
       ┌──────▼──┐  ┌────▼─────┐  ┌──▼───────┐
       │Player 1 │  │ Player 2 │  │ Player 3 │
       │(child)  │  │ (child)  │  │ (child)  │
       └─────────┘  └──────────┘  └──────────┘
```

Key principles:
- One parent account manages multiple players across multiple orgs
- Multiple guardians per player (handles divorce, grandparents, carpooling)
- Granular permissions per guardian: `financial`, `medical`, `legal_signer`, `schedule_view`, `pickup`, `messaging`
- Age-based autonomy: 13+ gets own account, 18+ becomes legal signer

## Request Flow

### Authenticated API Request

```
1. Browser → Next.js middleware
   │  Parse Host header for tenant context
   │  Refresh Supabase session (cookie-based)
   │  Inject x-org-slug header
   ▼
2. Next.js → zice-core API
   │  Authorization: Bearer <jwt>
   │  x-org-slug: joliet-jaguars
   ▼
3. zice-core auth middleware
   │  Validate JWT signature + expiry
   │  Check audience claim = "authenticated"
   │  Extract user_id from JWT sub claim
   ▼
4. zice-core tenant middleware
   │  Read x-org-slug header
   │  Validate org exists
   │  Set org context for RLS
   ▼
5. Handler → PostgreSQL (via Supabase)
   │  RLS policies enforce:
   │  - Parents see only their children
   │  - Admins see all org members
   │  - Coaches see roster players
   ▼
6. Response → Browser
```

## Future Service Extraction

The monolith (`zice-core`) is structured for future extraction:

| Future Service | Repo | Extraction Trigger |
|---|---|---|
| Communications | `zice-comms` | Messaging volume justifies independent scaling |
| Payments | `zice-payments` | PCI compliance isolation needed |
| Compliance | `zice-compliance` | Async processing for background jobs |
| Marketplace | `zice-marketplace` | Distinct bounded context |

Inter-service communication will use async events (NATS/Redis Streams).
