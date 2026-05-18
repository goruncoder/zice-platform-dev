# Zice Platform — Local Development Environment

Full-stack local development environment for the Zice multi-tenant sports management platform.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Browser (localhost)                  │
│   :3000 (Frontend)     :8080 (API)     :54323 (DB)  │
└──────┬──────────────────┬──────────────────┬────────┘
       │                  │                  │
┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
│ zice-frontend│   │  zice-core  │   │  Supabase   │
│  (Next.js)  │   │   (Go API)  │   │ (Postgres)  │
│  Port 3000  │   │  Port 8080  │   │ Port 54322  │
└─────────────┘   └──────┬──────┘   └─────────────┘
                         │
                  ┌──────▼──────┐
                  │  PostgreSQL  │
                  │  Port 54322  │
                  │  + RLS + Auth│
                  └─────────────┘
```

## Repositories

| Repo | Purpose | URL |
|------|---------|-----|
| `zice-core` | Go REST API backend | https://github.com/goruncoder/zice-core |
| `zice-frontend` | Next.js frontend | https://github.com/goruncoder/zice-frontend |
| `zice-platform-dev` | This repo — dev environment orchestration | https://github.com/goruncoder/zice-platform-dev |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2+
- [Go](https://go.dev/dl/) 1.23+
- [Node.js](https://nodejs.org/) 22+
- [Make](https://www.gnu.org/software/make/)

## Quick Start

```bash
# 1. Clone this repo and all service repos
make clone

# 2. Copy environment template
cp .env.example .env
# Edit .env with your Supabase credentials (see Configuration below)

# 3. Start everything
make dev

# 4. Verify
make status
```

The following services will be available:

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend API | http://localhost:8080 |
| API Health | http://localhost:8080/api/v1/health |
| Database | localhost:54322 (PostgreSQL) |

## Configuration

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### Required Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SUPABASE_URL` | Supabase project URL | `http://localhost:54322` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | (from local Supabase) |
| `SUPABASE_SERVICE_KEY` | Supabase service role key | (from local Supabase) |
| `JWT_SECRET` | JWT signing secret | (from local Supabase) |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:postgres@localhost:54322/postgres` |

### Optional Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PLATFORM_NAME` | Platform display name | `Zice` |
| `ROOT_DOMAIN` | Root domain for multi-tenant routing | `zice.io` |
| `API_URL` | Backend API URL (frontend uses this) | `http://localhost:8080` |
| `FRONTEND_URL` | Frontend URL | `http://localhost:3000` |
| `CORS_ORIGINS` | Comma-separated allowed CORS origins | `http://localhost:3000` |

## Makefile Commands

### Development

| Command | Description |
|---------|-------------|
| `make dev` | Start all services (frontend + backend + database) |
| `make dev-frontend` | Start only the frontend |
| `make dev-backend` | Start only the backend |
| `make stop` | Stop all running services |
| `make restart` | Restart all services |
| `make status` | Show status of all services |
| `make logs` | Tail logs from all services |
| `make logs-frontend` | Tail frontend logs only |
| `make logs-backend` | Tail backend logs only |

### Code Quality

| Command | Description |
|---------|-------------|
| `make test` | Run all tests (frontend + backend) |
| `make test-frontend` | Run frontend tests only |
| `make test-backend` | Run backend tests only |
| `make lint` | Run linters on all repos |
| `make lint-frontend` | Run frontend linter only |
| `make lint-backend` | Run backend linter only |
| `make check` | Run lint + test (prepare for merge) |

### Setup & Maintenance

| Command | Description |
|---------|-------------|
| `make clone` | Clone all service repos into `./repos/` |
| `make install` | Install dependencies for all repos |
| `make clean` | Remove build artifacts and dependencies |
| `make smoke` | Run smoke tests against local services |

### Database

| Command | Description |
|---------|-------------|
| `make db-migrate` | Run pending database migrations |
| `make db-reset` | Reset database and re-run all migrations |

## Project Structure

```
zice-platform-dev/
├── .env.example          # Environment variable template
├── .gitignore            # Git ignore rules
├── Makefile              # Orchestration commands
├── README.md             # This file
├── docker-compose.yml    # Docker services (database)
├── docs/
│   ├── ARCHITECTURE.md   # System architecture overview
│   ├── API.md            # API endpoint reference
│   ├── AUTH.md           # Authentication flow documentation
│   └── MULTI-TENANT.md  # Multi-tenant routing documentation
└── repos/                # Service repos (cloned via `make clone`)
    ├── zice-core/        # Go API backend
    └── zice-frontend/    # Next.js frontend
```

## Development Flow

### Adding a New Feature

1. Create a Linear ticket in the [Sports Management Platform](https://linear.app/neaa/project/sports-management-platform-279cb93ef2ca) project
2. Create a feature branch: `git checkout -b devin/<ticket-id>-<timestamp>`
3. Implement changes in the appropriate repo(s)
4. Run `make check` to verify lint + tests pass
5. Create a PR (Small-Medium size: 26-500 LOC)
6. PR notifications auto-post to `#dice-platform-prs` Slack channel
7. After merge and deploy, smoke tests run automatically

### PR Size Guidelines

| Size | LOC Changed |
|------|-------------|
| Tiny | 1-25 |
| Small | 26-200 |
| Medium | 201-500 |
| Large | 501-1000 |
| Extra Large | >1000 (avoid) |

### Branch Naming Convention

```
devin/<ticket-id>-<timestamp>    # When working on a Linear ticket
devin/<timestamp>-<description>  # General feature branches
```

## Authentication Flow

```
User → Frontend (Next.js) → Supabase Auth → JWT issued
                                              ↓
User → Frontend → Backend API (Go) → JWT validated → Response
                   ↕ (headers)
          x-org-slug: tenant context
          Authorization: Bearer <jwt>
```

1. User signs up/logs in via Supabase Auth (email, magic link, or OAuth)
2. Supabase issues a JWT with the user's ID and `authenticated` audience
3. Frontend stores the session via `@supabase/ssr` cookies
4. Frontend sends API requests with `Authorization: Bearer <jwt>` header
5. Backend validates the JWT, extracts user ID, applies RLS context
6. Multi-tenant context is injected via `x-org-slug` header (from subdomain or custom domain)

## Multi-Tenant Routing

### Subdomain-Based (Default)

```
https://joliet-jaguars.zice.io  →  x-org-slug: joliet-jaguars
https://canlan-huskies.zice.io  →  x-org-slug: canlan-huskies
https://zice.io                 →  No tenant (platform root)
```

### BYOD Custom Domain

```
https://jolietjaguars.org  →  DNS CNAME → zice.io
                           →  Middleware resolves via API
                           →  x-org-slug: joliet-jaguars
```

Resolution flow:
1. Next.js middleware extracts hostname
2. If subdomain of root domain → use subdomain as org slug
3. If custom domain → call `GET /api/v1/tenants/resolve?domain=<hostname>`
4. Backend returns org slug for the custom domain
5. Middleware injects `x-org-slug` and `x-tenant-source` headers

## Smoke Tests

After deployment, run smoke tests to validate:

```bash
# Backend smoke tests
./repos/zice-core/scripts/smoke-test.sh https://your-backend-url.railway.app

# Frontend smoke tests
./repos/zice-frontend/scripts/smoke-test.sh https://your-frontend-url.vercel.app
```

### Backend Tests
1. Health check (`GET /api/v1/health` → 200)
2. API versioning (`GET /api/v1/` → 200 or 404)
3. Tenant resolution (unknown domain → 404)
4. Auth required (no token → 401)
5. OpenAPI spec accessible (200)
6. CORS headers present

### Frontend Tests
1. Homepage loads (200)
2. Login page loads (200, contains "sign in")
3. Auth redirect (roster-auditor → 302 to /login)
4. 404 handling (not 500)
5. Subdomain handling (no crash)

## Hosting

| Service | Platform | URL Pattern |
|---------|----------|-------------|
| Frontend | Vercel | `*.zice.io` |
| Backend API | Railway | `zice-core.railway.app` |
| Database | Supabase | Managed PostgreSQL |
| DNS | Cloudflare | Custom domains + SSL |

## Links

- [Design Document](https://linear.app/neaa/document/phase-1-and-phase-2-technical-design-document-63388cde24b9)
- [Linear Project Board](https://linear.app/neaa/project/sports-management-platform-279cb93ef2ca)
- [zice-core PRs](https://github.com/goruncoder/zice-core/pulls)
- [zice-frontend PRs](https://github.com/goruncoder/zice-frontend/pulls)
