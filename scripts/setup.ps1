$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RootDir

Write-Host "==> DevOps Final — Environment Setup (Windows)"
Write-Host "    Project root: $RootDir"

# Create runtime directories
New-Item -ItemType Directory -Force -Path logs, data\blue, data\green | Out-Null

# Copy env template if .env does not exist
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "    Created .env from .env.example"
}

# Install Node.js API dependencies
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "==> Installing Node.js API dependencies..."
    Push-Location api
    npm ci
    Pop-Location
}

# Install Python dependencies
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Host "==> Installing Python app dependencies..."
    pip install -r app/requirements-dev.txt --quiet
}

# Build and start Docker Compose stack
Write-Host "==> Building and starting Docker Compose stack..."
docker compose up --build -d

Write-Host "==> Waiting for services to become healthy..."
Start-Sleep -Seconds 15

# Run validation
& "$RootDir\scripts\validate-env.ps1"

Write-Host ""
Write-Host "Environment ready!" -ForegroundColor Green
Write-Host ""
Write-Host "  Flask App:    http://localhost:5000"
Write-Host "  Express API:  http://localhost:3000"
Write-Host "  Prometheus:   http://localhost:9090"
Write-Host "  Grafana:      http://localhost:3001  (admin / admin)"
Write-Host "  Alertmanager: http://localhost:9093"
Write-Host "  Loki:         http://localhost:3100"
Write-Host ""
