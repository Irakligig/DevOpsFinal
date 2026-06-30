# Reliability & SLO Documentation

## Architecture Reliability Features

### Health Checks

Every service includes layered health monitoring:

| Layer | Mechanism | Frequency |
|-------|-----------|-----------|
| Docker | Built-in HEALTHCHECK in Dockerfiles | 30s |
| Compose | `healthcheck` in docker-compose.yml | 30s |
| Application | `/health` endpoints on Flask and Express | On demand |
| External | `scripts/healthcheck.sh` cron-compatible script | Configurable |
| CI/CD | Post-deployment validation in pipeline | Every deploy |

### Automatic Recovery

- All Docker services use `restart: unless-stopped`
- Failed health checks trigger container restart via Docker
- Blue-Green deployment ensures zero-downtime deploys with instant rollback

### Alerting Strategy

Prometheus evaluates alert rules every 5 seconds:

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| FlaskAppDown | `up{job="flask-app"} == 0` for 1m | Critical | Immediate investigation |
| HighErrorRate | `rate(app_errors_total[5m]) > 0.1` for 2m | Warning | Check logs, consider rollback |
| HighRequestRate | `rate(app_requests_total[1m]) > 10` for 5m | Info | Monitor for traffic spike |

Alerts route through Alertmanager with severity-based receivers.

### Deployment Strategy

**Blue-Green Deployment** (from CI/CD assignment):

1. Deploy to idle slot (blue:3001 or green:3002)
2. Run health check on new slot
3. Switch live traffic marker
4. Previous slot remains available for instant rollback

**Rollback**: Single command — `bash scripts/rollback.sh`

### Failure Recovery Automation

| Scenario | Automated Response |
|----------|-------------------|
| Container crash | Docker restart policy |
| Failed deploy | Pipeline stops, previous version stays live |
| Unhealthy slot | Deploy script exits before switching traffic |
| Post-deploy failure | `post-deploy-check.sh` fails the deploy job |

## Service Level Objectives

### Availability SLO: 99.5%

- **Measurement**: Prometheus `up` metric for flask-app job
- **Window**: Rolling 30 days
- **Error budget**: 3.6 hours/month of downtime

### Latency SLO (informational)

- Health endpoint response < 500ms
- Measured via post-deployment checks

### Monitoring Dashboard

Grafana dashboard "DevOps Final - App Metrics" shows:
- Total request count
- Error rate (1m window)
- Service availability (`up` metric)

## Branching Strategy

| Branch | Purpose | CI Trigger |
|--------|---------|------------|
| `main` | Production-ready code | Full pipeline + deploy |
| `dev` | Development integration | Lint, test, security scans |
| Feature branches | Individual work | PR checks against `dev` or `main` |

## Commit Convention

| Prefix | Meaning |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `chore:` | Maintenance |
| `docs:` | Documentation |
| `security:` | Security improvements |
