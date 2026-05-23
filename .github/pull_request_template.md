## Summary

<!-- What changed and why (1–3 sentences) -->

## Test plan

- [ ] `make check` (or repo-specific `make check` for single-repo PRs)
- [ ] Manual verification described below
- [ ] Integration/smoke (if touching auth, tenancy, or cross-service flows): `make integration` / `make smoke`

## Documentation (check if applicable)

- [ ] **Not needed** — no boundary or agent-context changes
- [ ] Updated **zice-platform-dev** `docs/ARCHITECTURE.md` (new service, port, migration path, or cross-repo flow)
- [ ] Updated **zice-platform-dev** `docs/templates/AGENTS/<repo>.md` and ran `make sync-agent-docs` (or updated `AGENTS.md` directly in the service repo)
- [ ] Updated topic docs (`docs/AUTH.md`, `docs/MULTI-TENANT.md`, `docs/API.md`) if behavior changed

## Cross-repo impact

<!-- List other repos that need coordinated PRs, or "None" -->
