#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_FILE="$ROOT_DIR/data/live-slot"
CURRENT=$(cat "$LIVE_FILE" 2>/dev/null || echo "none")

if [[ "$CURRENT" == "blue" ]]; then
  TARGET="green"
  PORT=3002
else
  TARGET="blue"
  PORT=3001
fi

echo "==> Blue-Green Deploy: deploying to $TARGET slot (port $PORT)"

# Stop existing slot container if running
docker compose -f "$ROOT_DIR/docker-compose.yml" stop "api-$TARGET" 2>/dev/null || true

# Start the target slot
PORT=$PORT docker compose -f "$ROOT_DIR/docker-compose.bluegreen.yml" up -d "api-$TARGET"

sleep 5

STATUS=$(curl -sf "http://localhost:$PORT/health" | grep -o '"ok"' || true)
if [[ "$STATUS" != '"ok"' ]]; then
  echo "❌ Health check failed on $TARGET slot"
  exit 1
fi

echo "$TARGET" > "$LIVE_FILE"
echo "✅ Live slot: $TARGET → http://localhost:$PORT"
echo "$(date -Iseconds) DEPLOY slot=$TARGET port=$PORT" >> "$ROOT_DIR/logs/deploy.log"

bash "$ROOT_DIR/scripts/post-deploy-check.sh" "$PORT"
