#!/usr/bin/env bash
set -euo pipefail

# Deploy Chaco Central
# - Pull latest source
# - Build Hugo site via container (modules + content)
# - Restart web to pick up changes

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/3] Pulling latest from Git..."
git pull --rebase --autostash

echo "[2/3] Building site with Hugo (modules + content)..."
cd site
# Resolve user/group IDs robustly (fallback to 1000 if unavailable)
uid_val="$(id -u 2>/dev/null || echo 1000)"
gid_val="$(id -g 2>/dev/null || echo 1000)"
docker run --rm \
  -u "${uid_val}:${gid_val}" \
  -v "$PWD:/src" \
  -w /src \
  klakegg/hugo:ext-alpine \
  sh -lc "hugo mod get && hugo"
cd ..

echo "[3/3] Restarting web container..."
docker compose restart web

echo "Done. Visit your site to verify changes."
