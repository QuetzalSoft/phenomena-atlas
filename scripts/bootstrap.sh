#!/usr/bin/env bash
# Clone every Phenomena Atlas component into this workspace, or update it if present.
# The layout this produces is assumed by CLAUDE.md and must be identical on every machine.
set -euo pipefail

ORG="git@github.com:QuetzalSoft"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# directory -> repository name. Add the mobile app here once its repository exists.
COMPONENTS=(
  "api:phenomena-atlas-api"
  "web:phenomena-atlas-web"
)

for entry in "${COMPONENTS[@]}"; do
  dir="${entry%%:*}"
  repo="${entry##*:}"
  target="$ROOT/$dir"

  if [ -d "$target/.git" ]; then
    echo "==> $dir: already cloned, fetching"
    git -C "$target" fetch --prune origin
  else
    echo "==> $dir: cloning $repo"
    git clone "$ORG/$repo.git" "$target"
  fi
done

echo
echo "Workspace ready at $ROOT"
