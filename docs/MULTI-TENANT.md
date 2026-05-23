# Multi-Tenant Routing

## Overview

Zice supports multiple independent sports organizations (tenants) on a single platform. Each organization is identified by a unique `slug` and can be accessed via subdomain or custom domain.

## Routing Strategies

### 1. Subdomain-Based (Default)

Organizations are accessed via subdomains of the platform root domain:

```
https://joliet-jaguars.zice.io  →  org slug: joliet-jaguars
https://canlan-huskies.zice.io  →  org slug: canlan-huskies
```

**DNS Setup**: A single wildcard DNS record (`*.zice.io`) routes all subdomains to Vercel.

**Excluded subdomains** (treated as platform root, not tenants):
- `www.zice.io`
- `app.zice.io`

### 2. BYOD Custom Domain

Organizations can use their own domain:

```
https://jolietjaguars.org  →  CNAME to zice.io  →  org slug: joliet-jaguars
```

**Setup Process**:
1. Org admin adds their custom domain in settings
2. Backend stores the domain → org mapping
3. Admin adds a CNAME record pointing to `zice.io`
4. Cloudflare for SaaS auto-provisions SSL
5. Next.js middleware resolves the domain on each request

## Resolution Flow

```
                    ┌─────────────────┐
                    │  Incoming Request │
                    │  Host: ???       │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Is static path? │
                    │ /_next, /api,   │
                    │ /favicon.ico    │
                    └──┬──────────┬───┘
                       │ Yes      │ No
                       ▼          ▼
                    Skip    ┌─────────────┐
                            │Parse hostname│
                            └──────┬──────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │ Is subdomain of root domain? │
                    │ e.g., foo.zice.io            │
                    └──┬─────────────────────┬────┘
                       │ Yes                 │ No
                       ▼                     ▼
              ┌────────────────┐   ┌──────────────────┐
              │ Use subdomain  │   │ Is root domain?  │
              │ as org slug    │   │ e.g., zice.io    │
              │                │   └──┬───────────┬───┘
              │ x-org-slug:    │      │ Yes       │ No
              │   foo          │      ▼           ▼
              │ x-tenant-      │   No tenant  ┌──────────────┐
              │   source:      │              │ Custom domain │
              │   subdomain    │              │ resolution    │
              └────────────────┘              └──────┬───────┘
                                                     │
                                              ┌──────▼───────┐
                                              │ GET /api/v1/ │
                                              │ tenants/     │
                                              │ resolve?     │
                                              │ domain=...   │
                                              └──────┬───────┘
                                                     │
                                              ┌──────▼───────┐
                                              │ Found?       │
                                              └──┬───────┬───┘
                                                 │ Yes   │ No
                                                 ▼       ▼
                                           ┌─────────┐  No
                                           │x-org-   │  tenant
                                           │slug: xyz│
                                           │x-tenant-│
                                           │source:  │
                                           │custom-  │
                                           │domain   │
                                           └─────────┘
```

## Implementation

### Frontend Middleware (`src/middleware.ts`)

The Next.js middleware runs on every request and:

1. Skips static paths (`/_next/`, `/favicon.ico`, `/images/`, `/logo.svg`, `/api/`)
2. Refreshes the Supabase auth session
3. Redirects unauthenticated users to `/login` (except public paths)
4. Parses the hostname for tenant context
5. Injects `x-org-slug` and `x-tenant-source` headers

### Tenant Context Headers

| Header | Value | Description |
|--------|-------|-------------|
| `x-org-slug` | Organization slug (e.g., `joliet-jaguars`) | Identifies the tenant |
| `x-tenant-source` | `subdomain` or `custom-domain` | How the tenant was resolved |

### Backend Tenant Resolution API

```
GET /api/v1/tenants/resolve?domain=jolietjaguars.org

Response:
{
  "data": {
    "slug": "joliet-jaguars",
    "name": "Joliet Jaguars"
  }
}
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_ROOT_DOMAIN` | Platform root domain | `zice.io` |
| `NEXT_PUBLIC_API_URL` | Backend API URL | `http://localhost:8080` |

## Local Development

For local development, tenant resolution works with:

```
# Subdomain testing (add to /etc/hosts)
127.0.0.1  test-org.localhost

# Then access:
http://test-org.localhost:3000
```

The middleware treats `localhost` as the root domain in development, so `test-org.localhost` resolves to org slug `test-org`.
