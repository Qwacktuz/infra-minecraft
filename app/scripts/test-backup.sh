#!/bin/bash
set -euo pipefail

APP_DIR="$HOME/app"

if [ -z "${DOCKER_HOST:-}" ] && [ -S "/run/user/$(id -u)/docker.sock" ]; then
  export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
fi

cd "$APP_DIR" || exit 1

if [ ! -f ".env" ]; then
  echo "❌ Missing $APP_DIR/.env. Run deploy to generate it."
  exit 1
fi

set -a
# shellcheck disable=SC1090
source ".env"
set +a

echo "🔎 Running restic integrity check..."
docker compose run --rm --no-deps --entrypoint restic backup check

echo ""
echo "📸 Listing available snapshots..."
docker compose run --rm --no-deps --entrypoint restic backup snapshots

echo ""
echo "📊 Snapshot stats (latest)..."
docker compose run --rm --no-deps --entrypoint restic backup stats latest

echo ""
echo "✅ Backup test complete!"
