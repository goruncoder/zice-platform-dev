#!/usr/bin/env bash
# Copy canonical AGENTS.md templates into cloned service repos.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$ROOT/docs/templates/AGENTS"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Error: missing $TEMPLATE_DIR" >&2
  exit 1
fi

for repo in zice-core zice-frontend zice-agent; do
  src="$TEMPLATE_DIR/${repo}.md"
  dest="$ROOT/repos/${repo}/AGENTS.md"
  if [[ ! -f "$src" ]]; then
    echo "Warning: no template for $repo ($src)" >&2
    continue
  fi
  if [[ ! -d "$ROOT/repos/${repo}" ]]; then
    echo "Skipping $repo (not cloned — run 'make clone')" >&2
    continue
  fi
  cp "$src" "$dest"
  echo "Synced AGENTS.md → repos/${repo}/"
done

echo "Done. Commit AGENTS.md in each service repo when changing templates."
