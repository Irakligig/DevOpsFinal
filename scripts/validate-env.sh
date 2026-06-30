#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

check() {
  local name="$1"
  local url="$2"
  local expected="${3:-}"

  if response=$(curl -sf --max-time 10 "$url" 2>/dev/null); then
    if [[ -n "$expected" && ! "$response" =~ $expected ]]; then
      echo "  ❌ $name — unexpected response"
      FAIL=$((FAIL + 1))
    else
      echo "  ✅ $name"
      PASS=$((PASS + 1))
    fi
  else
    echo "  ❌ $name — unreachable at $url"
    FAIL=$((FAIL + 1))
  fi
}

echo "==> Environment Validation"
check "Flask App"      "http://localhost:5000/health" "ok"
check "Express API"    "http://localhost:3000/health" "ok"
check "Prometheus"     "http://localhost:9090/-/healthy"
check "Grafana"        "http://localhost:3001/api/health"
check "Alertmanager"   "http://localhost:9093/-/healthy"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  echo "❌ Environment validation failed"
  exit 1
fi

echo "✅ All services validated"
