# Screenshots folder

Save PNG files here using **exactly** these names (linked from README.md):

| Filename | In README | What to capture |
|----------|-----------|-----------------|
| `ci-pipeline.png` | Yes | GitHub Actions → CI/CD Pipeline → all jobs green |
| `docker-services.png` | Yes | Terminal: `docker compose ps` |
| `env-validation.png` | Yes | Terminal: `.\scripts\validate-env.ps1` |
| `prometheus-targets.png` | Yes | http://localhost:9090/targets — flask-app UP |
| `grafana-dashboard.png` | Yes | http://localhost:3001 — DevOps Final dashboard |
| `grafana-logs.png` | Yes | Grafana Explore → Loki → `{job="flask-app"}` |
| `healthcheck.png` | Yes | Terminal: health check output |
| `prometheus-metrics.png` | Optional | http://localhost:9090/graph — `app_requests_total` |
| `blue-green-deploy.png` | Optional | Terminal: `bash scripts/deploy.sh` output |
| `rollback.png` | Optional | Terminal: `bash scripts/rollback.sh` output |

Path on your machine:
```
C:\Users\darkb\Desktop\Computer Science\Semester 6\DevOps\Final\screenshots\
```
