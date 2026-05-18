# API Reference

Base URL: `http://localhost:8080` (local) or `https://zice-core.railway.app` (production)

All endpoints return responses in the standard envelope:

```json
{
  "data": { ... },
  "error": null,
  "meta": { "page": 1, "per_page": 20, "total": 100 }
}
```

## Authentication

All API requests (except health and auth endpoints) require a valid JWT:

```
Authorization: Bearer <supabase-jwt>
```

Multi-tenant context is provided via header:

```
x-org-slug: joliet-jaguars
```

## Endpoints

### Health

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/health` | No | Health check |

### Auth

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/signup` | No | Register new user (proxies to Supabase) |
| POST | `/api/v1/auth/login` | No | Login (proxies to Supabase) |
| POST | `/api/v1/auth/magic-link` | No | Send magic link email |
| POST | `/api/v1/auth/refresh` | No | Refresh access token |
| POST | `/api/v1/auth/logout` | Yes | Logout (revoke session) |
| GET | `/api/v1/auth/me` | Yes | Get current user profile |
| PUT | `/api/v1/auth/me` | Yes | Update current user profile |

### Invites

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/invites` | Yes (admin) | Create an invitation |
| GET | `/api/v1/invites/validate` | No | Validate invite token (`?token=...`) |
| POST | `/api/v1/invites/accept` | Yes | Accept an invitation |

### Organizations

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/organizations` | Yes | List user's organizations |
| GET | `/api/v1/organizations/:slug` | Yes | Get organization by slug |
| PUT | `/api/v1/organizations/:slug` | Yes (admin) | Update organization |

### Players

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/players` | Yes | List players (filtered by org + role) |
| POST | `/api/v1/players` | Yes | Create a player |
| GET | `/api/v1/players/:id` | Yes | Get player details |
| PUT | `/api/v1/players/:id` | Yes | Update player |

### Memberships

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/memberships` | Yes | List memberships for current org |
| POST | `/api/v1/memberships` | Yes (admin) | Create a membership |
| PUT | `/api/v1/memberships/:id` | Yes (admin) | Update membership role/status |

### Rosters

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/rosters` | Yes | List rosters for current org |
| POST | `/api/v1/rosters` | Yes (admin/coach) | Add player to roster |
| PUT | `/api/v1/rosters/:id` | Yes (admin/coach) | Update roster entry |

### Tenant Resolution

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/tenants/resolve` | No | Resolve custom domain to org slug (`?domain=...`) |

### Documentation

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/docs/openapi.yaml` | No | OpenAPI 3.0.3 specification |

## Error Responses

```json
{
  "data": null,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required"
  }
}
```

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `BAD_REQUEST` | Invalid request body or parameters |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `CONFLICT` | Duplicate resource |
| 500 | `INTERNAL_ERROR` | Server error |

## Rate Limiting

Not yet implemented. Planned for future milestones.
