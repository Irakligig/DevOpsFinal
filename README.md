# DevOps Final Project

> Unified DevOps solution combining observability, CI/CD, blue-green deployment, security automation, and production-ready reliability — all runnable locally with Docker Compose.

Built on previous semester assignments:
- [observability-lab](https://github.com/Irakligig/observability-lab) — Monitoring, logging, metrics
- [my-cicd-project](https://github.com/Irakligig/my-cicd-project) — CI/CD, blue-green deployment, IaC
- [devops-assignment](https://github.com/Irakligig/devops-assignment) — Automated testing & deployment pipeline

---

## Architecture

```
                         ┌─────────────────────────────────────────────┐
                         │              GitHub Actions CI/CD            │
                         │  Gitleaks │ Tests │ npm audit │ Trivy │ Deploy│
                         └──────────────────────┬──────────────────────┘
                                                │
    ┌───────────────┐  /metrics   ┌─────────────▼──┐    alerts   ┌──────────────┐
    │  Flask App    │────────────▶│   Prometheus   │────────────▶│ Alertmanager │
    │  :5000        │             │   :9090        │             │  :9093       │
    └───────┬───────┘             └───────┬────────┘             └──────────────┘
            │ logs                        │ queries
            ▼                             ▼
    ┌───────────────┐             ┌──────────────┐
    │   Promtail    │──push──────▶│   Grafana    │
    └───────┬───────┘             │   :3001      │
            │                     └──────────────┘
            ▼
    ┌───────────────┐
    │     Loki      │
    │   :3100       │
    └───────────────┘

    ┌───────────────┐  Blue-Green
    │  Express API  │  slots :3001 / :3002
    │  :3000        │  + rollback via scripts/
    └───────────────┘
```

---

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Flask App | 5000 | Main app — metrics, logs, health checks |
| Express API | 3000 | REST API — blue-green deploy target |
| Prometheus | 9090 | Metrics collection & alerting |
| Grafana | 3001 | Dashboards (admin / admin) |
| Loki | 3100 | Log aggregation |
| Promtail | — | Log shipper |
| Alertmanager | 9093 | Alert routing |

---

## Quick Start — One Command Setup

### Linux / macOS / WSL

```bash
git clone <your-repo-url>
cd devops-final
bash scripts/setup.sh
```

### Windows (PowerShell)

```powershell
git clone <your-repo-url>
cd devops-final
.\scripts\setup.ps1
```

This single command will:
1. Create runtime directories and `.env` file
2. Install local dependencies (Node.js + Python)
3. Build and start all Docker services
4. Run automated environment validation

### Alternative: Ansible IaC

```bash
ansible-playbook ansible/provision.yml
```

---

## Environment Setup (Manual)

If you prefer step-by-step setup:

```bash
# 1. Copy environment config
cp .env.example .env

# 2. Install dependencies
cd api && npm ci && cd ..
pip install -r app/requirements.txt

# 3. Start the stack
docker compose up --build -d

# 4. Validate everything is running
bash scripts/validate-env.sh
```

---

## Endpoints

### Flask App (port 5000)

| Route | Description |
|-------|-------------|
| `/` | Home — increments request counter |
| `/health` | Health check endpoint |
| `/error` | Simulates error (increments error counter) |
| `/testlog` | Writes a test log entry |
| `/metrics` | Prometheus metrics scrape endpoint |

### Express API (port 3000)

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/health` | Health check |
| GET | `/hello/:name` | Dynamic greeting |
| POST | `/echo` | Echo request body |

---

## Deployment Workflow

### CI/CD Pipeline (GitHub Actions)

Triggered on push/PR to `main` or `dev`:

```
Push/PR → Secrets Scan (Gitleaks)
              ↓
         Lint & Test (Flask + Express)
              ↓
         Dependency Scan (npm audit + pip-audit)
              ↓
         Config Scan (Trivy + Hadolint)
              ↓
         Build & Scan Images (Trivy)
              ↓
         Deploy + Validate (main branch only)
```

### Blue-Green Deployment

```bash
bash scripts/deploy.sh      # Deploy to idle slot, health check, switch traffic
bash scripts/rollback.sh    # Instant rollback to previous slot
bash scripts/healthcheck.sh # Monitor live slot health
```

### Branching Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production — triggers full pipeline + deploy |
| `dev` | Integration — runs tests and security scans |
| Feature branches | PR checks before merge |

---

## Security Implementation

| Check | Tool | Where |
|-------|------|-------|
| Secrets scanning | Gitleaks | CI pipeline |
| Node.js dependency audit | npm audit | CI pipeline |
| Python dependency audit | pip-audit | CI pipeline |
| Container image scanning | Trivy | CI pipeline |
| Dockerfile linting | Hadolint | CI pipeline |
| IaC/config scanning | Trivy (config mode) | CI pipeline |
| Non-root containers | Dockerfile USER directive | App & API images |
| Secrets management | `.env.example` template, `.env` gitignored | Local config |

---

## Monitoring & Logging

### Metrics (Prometheus)

| Query | Description |
|-------|-------------|
| `app_requests_total` | Total request count |
| `rate(app_requests_total[1m])` | Request rate per second |
| `app_errors_total` | Total errors |
| `rate(app_errors_total[1m])` | Error rate per second |
| `up{job="flask-app"}` | Service availability |

### Logs (Grafana + Loki)

1. Open Grafana → http://localhost:3001
2. Go to **Explore** → select **Loki** datasource
3. Query: `{job="flask-app"}`

### Dashboards

Grafana auto-provisions a dashboard **"DevOps Final - App Metrics"** with request count, error rate, and availability panels.

### Alerting

Prometheus alert rules (see `prometheus/alerts.yml`):

| Alert | Trigger | Severity |
|-------|---------|----------|
| FlaskAppDown | Target unreachable for 1m | Critical |
| HighErrorRate | Error rate > 0.1/s for 2m | Warning |
| HighRequestRate | Request rate > 10/s for 5m | Info |

---

## Reliability Improvements

| Feature | Implementation |
|---------|---------------|
| Health checks | Docker HEALTHCHECK + `/health` endpoints + validation scripts |
| Rollback | `scripts/rollback.sh` — instant blue-green switch |
| Failure recovery | Docker `restart: unless-stopped` on all services |
| Post-deploy checks | `scripts/post-deploy-check.sh` in deploy flow |
| SLOs | 99.5% availability target — see `docs/reliability.md` |
| Incident response | Runbook in `docs/incident-response.md` |
| Alerting strategy | Prometheus rules → Alertmanager routing |

See [docs/reliability.md](docs/reliability.md) and [docs/incident-response.md](docs/incident-response.md) for full details.

---

## Running Tests Locally

```bash
# Express API tests
cd api && npm test

# Flask app tests
cd app && python -m pytest tests/ -v

# Lint API
cd api && npm run lint

# Health check all services
bash scripts/healthcheck.sh

# Full environment validation
bash scripts/validate-env.sh
```

---

## Generating Traffic (for dashboards)

```bash
# Normal traffic
for i in $(seq 1 50); do curl -s http://localhost:5000/ > /dev/null; done

# Error traffic
for i in $(seq 1 20); do curl -s http://localhost:5000/error > /dev/null; done

# Test logs
curl http://localhost:5000/testlog
```

---

## Project Structure

```
devops-final/
├── app/                          # Flask observability app
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── tests/
├── api/                          # Express REST API
│   ├── app.js
│   ├── Dockerfile
│   └── app.test.js
├── prometheus/                   # Metrics & alert rules
├── grafana/provisioning/         # Auto-configured dashboards
├── alertmanager/                 # Alert routing
├── promtail/                     # Log shipping
├── ansible/provision.yml         # IaC provisioning
├── scripts/                      # Automation scripts
│   ├── setup.sh / setup.ps1      # One-command environment setup
│   ├── validate-env.sh           # Environment validation
│   ├── deploy.sh                 # Blue-green deployment
│   ├── rollback.sh               # Rollback procedure
│   ├── healthcheck.sh            # Health monitoring
│   └── post-deploy-check.sh      # Post-deployment verification
├── docs/                         # Reliability & incident docs
├── .github/workflows/ci-cd.yml   # Full CI/CD pipeline
├── docker-compose.yml            # Main stack
├── docker-compose.bluegreen.yml  # Blue-green slots
├── .env.example
└── README.md
```

---

## Screenshots

Add screenshots to the `screenshots/` folder demonstrating:

- CI/CD pipeline with all security stages passing
- Grafana dashboard with live metrics
- Prometheus targets showing UP status
- Docker Compose services running
- Blue-green deployment and rollback
- Health check and validation output

See [screenshots/README.md](screenshots/README.md) for the full list.

---

## Troubleshooting

**Services not starting?**
```bash
docker compose logs <service-name>
docker compose ps
```

**Prometheus not scraping?**
- Check http://localhost:9090/targets — Flask target should show UP

**Logs not in Grafana?**
- Verify Promtail: `docker compose logs promtail`
- Try LogQL: `{job=~".+"}`

**Validation failing?**
```bash
bash scripts/validate-env.sh
# Wait a few seconds after startup — services need time to become healthy
```

**Full reset:**
```bash
docker compose down -v
bash scripts/setup.sh
```

---

## Previous Assignments

This project extends functionality from:

| Assignment | Features Preserved |
|------------|-------------------|
| observability-lab | Flask metrics, Prometheus, Grafana, Loki, Promtail |
| my-cicd-project | Express API, blue-green deploy, rollback, health checks, Ansible IaC |
| devops-assignment | CI/CD pipeline, automated testing, deployment blocking on failure |

All previously implemented functionality remains fully operational.
