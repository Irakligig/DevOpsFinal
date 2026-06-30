#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-3000}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT_DIR/logs/post-deploy.log"

echo "==> Post-deployment verification (port $PORT)"

checks=0
passed=0

run_check() {
  local name="$1"
  local url="$2"
  checks=$((checks + 1))
  if curl -sf --max-time 10 "$url" >/dev/null 2>&1; then
    echo "  ✅ $name"
    passed=$((passed + 1))
  else
    echo "  ❌ $name"
  fi
}

run_check "Health endpoint"  "http://localhost:$PORT/health"
run_check "Hello endpoint"   "http://localhost:$PORT/hello/test"
run_check "Echo endpoint"    "http://localhost:$PORT/echo"  # POST needed but GET will fail - skip

# Echo requires POST
checks=$((checks + 1))
if curl -sf --max-time 10 -X POST -H "Content-Type: application/json" \
     -d '{"test":true}' "http://localhost:$PORT/echo" >/dev/null 2>&1; then
  echo "  ✅ Echo endpoint (POST)"
  passed=$((passed + 1))
else
  echo "  ❌ Echo endpoint (POST)"
fi

echo "$(date -Iseconds) post-deploy port=$PORT passed=$passed/$checks" >> "$LOG"

if [[ $passed -lt $checks ]]; then
  echo "❌ Post-deployment checks failed ($passed/$checks)"
  exit 1
fi

echo "✅ Post-deployment checks passed ($passed/$checks)"
