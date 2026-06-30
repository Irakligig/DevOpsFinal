#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE_FILE="$ROOT_DIR/data/live-slot"
CURRENT=$(cat "$LIVE_FILE" 2>/dev/null || echo "blue")

if [[ "$CURRENT" == "blue" ]]; then
  ROLLBACK="green"
  PORT=3002
else
  ROLLBACK="blue"
  PORT=3001
fi

echo "==> Rollback: switching from $CURRENT to $ROLLBACK (port $PORT)"

STATUS=$(curl -sf "http://localhost:$PORT/health" | grep -o '"ok"' || true)
if [[ "$STATUS" != '"ok"' ]]; then
  echo "❌ Rollback slot $ROLLBACK is not healthy — cannot rollback"
  exit 1
fi

echo "$ROLLBACK" > "$LIVE_FILE"
echo "✅ Rolled back to $ROLLBACK → http://localhost:$PORT"
echo "$(date -Iseconds) ROLLBACK from=$CURRENT to=$ROLLBACK" >> "$ROOT_DIR/logs/deploy.log"
