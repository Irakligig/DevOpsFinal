#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Running all tests"

echo "--- Express API tests ---"
(cd "$ROOT_DIR/api" && npm test)

echo "--- Flask app tests (via Docker) ---"
docker run --rm -v "$ROOT_DIR/app:/app" -w /app python:3.12-slim \
  bash -c "pip install -q -r requirements.txt && python -m pytest tests/ -v"

echo "✅ All tests passed"
