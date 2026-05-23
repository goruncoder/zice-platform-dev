# AGENTS.md templates

Canonical `AGENTS.md` files for each service repo. After `make clone`, run:

```bash
make sync-agent-docs
```

This copies templates into `repos/<service>/AGENTS.md` for local agent context.

**Upstream:** Commit changes in this directory, then open PRs in `zice-core`, `zice-frontend`, and `zice-agent` with the same `AGENTS.md` content (service repos are not tracked by `zice-platform-dev`).
