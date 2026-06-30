#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT_DIR/logs/healthcheck.log"
LIVE_FILE="$ROOT_DIR/data/live-slot"
SLOT=$(cat "$LIVE_FILE" 2>/dev/null || echo "default")

if [[ "$SLOT" == "blue" ]]; then PORT=3001
elif [[ "$SLOT" == "green" ]]; then PORT=3002
else PORT=3000; fi

RESPONSE=$(curl -sf --max-time 5 "http://localhost:$PORT/health" 2>/dev/null || echo "UNREACHABLE")

if echo "$RESPONSE" | grep -q '"ok"'; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$SLOT:$PORT] UP" | tee -a "$LOG"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$SLOT:$PORT] DOWN" | tee -a "$LOG"
  exit 1
fi

# Also check Flask app
FLASK=$(curl -sf --max-time 5 "http://localhost:5000/health" 2>/dev/null || echo "UNREACHABLE")
if echo "$FLASK" | grep -q '"ok"'; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [flask:5000] UP" | tee -a "$LOG"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') [flask:5000] DOWN" | tee -a "$LOG"
  exit 1
fi
