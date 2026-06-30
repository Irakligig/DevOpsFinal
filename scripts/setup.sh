#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> DevOps Final — Environment Setup"
echo "    Project root: $ROOT_DIR"

# Create runtime directories
mkdir -p logs data/blue data/green

# Copy env template if .env does not exist
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "    Created .env from .env.example"
fi

# Make scripts executable
chmod +x scripts/*.sh

# Install Node.js API dependencies (for local testing outside Docker)
if command -v npm &>/dev/null; then
  echo "==> Installing Node.js API dependencies..."
  (cd api && npm ci)
fi

# Install Python dependencies (for local testing outside Docker)
if command -v pip &>/dev/null; then
  echo "==> Installing Python app dependencies..."
  pip install -r app/requirements.txt --quiet
fi

# Build and start all Docker services
echo "==> Building and starting Docker Compose stack..."
docker compose up --build -d

echo "==> Waiting for services to become healthy..."
sleep 15

# Run post-start validation
bash scripts/validate-env.sh

echo ""
echo "✅ Environment ready!"
echo ""
echo "  Flask App:    http://localhost:5000"
echo "  Express API:  http://localhost:3000"
echo "  Prometheus:   http://localhost:9090"
echo "  Grafana:      http://localhost:3001  (admin / admin)"
echo "  Alertmanager: http://localhost:9093"
echo "  Loki:         http://localhost:3100"
echo ""
