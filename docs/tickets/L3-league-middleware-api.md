# L3: League Multi-Tenant Middleware + Core API

**Phase:** 7A — League Foundation
**Repo:** zice-core
**Est. Size:** Medium (~500 LOC)
**Dependency:** L1, L2

## Description

Update multi-tenant middleware to support `X-League-ID` header alongside existing `X-Org-ID`. Create core CRUD API endpoints for leagues, memberships, divisions, and team associations.

## Deliverables

- Middleware update: extract and validate `X-League-ID` header, inject into request context
- `POST /leagues` — create a new league
- `GET /leagues/:id` — get league details
- `PUT /leagues/:id` — update league settings/branding
- `DELETE /leagues/:id` — soft-delete league
- `POST /leagues/:id/members` — add member (invite user to league role)
- `GET /leagues/:id/members` — list league members
- `DELETE /leagues/:id/members/:userId` — remove league member
- `POST /leagues/:id/divisions` — create division
- `GET /leagues/:id/divisions` — list divisions
- `PUT /leagues/:id/divisions/:divId` — update division
- `POST /leagues/:id/teams` — associate team with league (invite/accept)
- `GET /leagues/:id/teams` — list league teams with division and status
- `PUT /leagues/:id/teams/:orgId` — update team status/division
- `DELETE /leagues/:id/teams/:orgId` — remove team from league
- OpenAPI spec updates for all new endpoints

## Acceptance Criteria

- [ ] `X-League-ID` header is validated and injected into context
- [ ] All CRUD endpoints return proper HTTP status codes
- [ ] League slug is auto-generated from name, unique enforced
- [ ] Team association supports pending → active workflow
- [ ] OpenAPI spec documents all new endpoints
