# Incident Response Runbook

## Overview

This document describes the incident response procedure for the DevOps Final project stack.

## Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| P1 — Critical | Service completely down | Immediate | Flask app unreachable, all health checks failing |
| P2 — High | Degraded performance or partial outage | 15 minutes | High error rate alert firing |
| P3 — Medium | Non-critical issue | 1 hour | Elevated request rate, log shipping delay |
| P4 — Low | Informational | Next business day | Info-level alerts |

## Service Availability Objectives (SLOs)

| Service | Target Availability | Error Budget (monthly) |
|---------|--------------------|-----------------------|
| Flask App | 99.5% | ~3.6 hours downtime |
| Express API | 99.5% | ~3.6 hours downtime |
| Prometheus | 99.0% | ~7.2 hours downtime |
| Grafana | 99.0% | ~7.2 hours downtime |

## Alert Response Procedures

### FlaskAppDown (Critical)

1. Check container status: `docker compose ps app`
2. View logs: `docker compose logs app --tail 50`
3. Restart: `docker compose restart app`
4. Verify: `curl http://localhost:5000/health`
5. If still failing, rollback: `bash scripts/rollback.sh`

### HighErrorRate (Warning)

1. Open Grafana → Error Rate panel
2. Check recent traffic: `curl http://localhost:5000/error` (test endpoint)
3. Review logs in Grafana Explore: `{job="flask-app"}`
4. If caused by bad deploy, run rollback

### Service Unreachable (General)

1. Run health check: `bash scripts/healthcheck.sh`
2. Run full validation: `bash scripts/validate-env.sh`
3. Check Docker: `docker compose ps`
4. Full restart: `docker compose down && docker compose up -d`

## Rollback Procedure

```bash
# Instant rollback to previous blue/green slot
bash scripts/rollback.sh

# Verify rollback
bash scripts/healthcheck.sh
curl http://localhost:3001/health  # or 3002
```

## Escalation

1. On-call engineer investigates (you)
2. If unresolved in 30 minutes → check Docker/host resources
3. If data loss suspected → stop writes, preserve logs in `logs/`

## Post-Incident

1. Document timeline in `logs/incidents/`
2. Update alerting thresholds if needed in `prometheus/alerts.yml`
3. Add regression test if applicable

## Useful Commands

```bash
# Full environment status
docker compose ps

# All service logs
docker compose logs --tail 100

# Prometheus targets
curl http://localhost:9090/api/v1/targets

# Active alerts
curl http://localhost:9090/api/v1/alerts

# Generate test traffic
for i in $(seq 1 20); do curl -s http://localhost:5000/ > /dev/null; done
```
