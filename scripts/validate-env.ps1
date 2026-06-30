$ErrorActionPreference = "Continue"
$Pass = 0
$Fail = 0

function Test-Service {
    param([string]$Name, [string]$Url, [string]$Expected = "")
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 10 -UseBasicParsing
        if ($Expected -and $response.Content -notmatch $Expected) {
            Write-Host "  FAIL $Name - unexpected response" -ForegroundColor Red
            $script:Fail++
        } else {
            Write-Host "  OK   $Name" -ForegroundColor Green
            $script:Pass++
        }
    } catch {
        Write-Host "  FAIL $Name - unreachable at $Url" -ForegroundColor Red
        $script:Fail++
    }
}

Write-Host "==> Environment Validation"
Test-Service "Flask App"    "http://localhost:5000/health" "ok"
Test-Service "Express API"  "http://localhost:3000/health" "ok"
Test-Service "Prometheus"   "http://localhost:9090/-/healthy"
Test-Service "Grafana"      "http://localhost:3001/api/health"
Test-Service "Alertmanager" "http://localhost:9093/-/healthy"

Write-Host ""
Write-Host "Results: $Pass passed, $Fail failed"

if ($Fail -gt 0) {
    Write-Host "Environment validation failed" -ForegroundColor Red
    exit 1
}

Write-Host "All services validated" -ForegroundColor Green
