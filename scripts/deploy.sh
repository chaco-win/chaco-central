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
UID="$(id -u)" GID="$(id -g)" \
docker run --rm \
  -u "${UID}:${GID}" \
  -v "$PWD:/src" \
  -w /src \
  klakegg/hugo:ext-alpine \
  sh -lc "hugo mod get && hugo"
cd ..

echo "[3/3] Restarting web container..."
docker compose restart web

echo "Done. Visit your site to verify changes."

