---
description: Check Pop OS dev environment health dashboard
---

Display comprehensive health status of the Pop OS dev environment including containers,
resources, connectivity, and recent issues.

## Workflow

### 1. Container Health Check

Check all WTFB services:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker ps --filter name=wtfb --format 'table {{.Names}}\t{{.Status}}\t{{.State}}'"
```

Get detailed health status:

```bash
# WOR-400: Updated container names - check both dev and staging
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-staging-app wtfb-staging-postgres wtfb-staging-redis --format='{{.Name}}: {{.State.Health.Status}}' 2>/dev/null || true"
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-dev-app wtfb-dev-postgres wtfb-dev-redis --format='{{.Name}}: {{.State.Health.Status}}' 2>/dev/null || true"
```

### 2. Resource Usage

Check CPU and Memory usage:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}'"
```

Check disk space:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "df -h / | tail -1"
```

Check Docker disk usage:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker system df"
```

### 3. Application Health Endpoint

Test Next.js health endpoint:

```bash
# Dev (STANDARD port 3000, WOR-401)
curl -s -w '\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n' http://pop-os:3000/api/health

# Staging (port 3001)
curl -s -w '\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n' http://pop-os:3001/api/health
```

Expected response:

```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T19:35:00.000Z",
  "uptime": 25234.567,
  "environment": "development"
}
```

### 4. Database Connectivity

Test PostgreSQL connection:

```bash
# WOR-400: Check staging or dev postgres container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker exec wtfb-staging-postgres pg_isready -U wtfb_user 2>/dev/null || docker exec wtfb-dev-postgres pg_isready -U wtfb_user"
```

Check active connections:

```bash
# WOR-400: Check staging or dev postgres container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker exec wtfb-staging-postgres psql -U wtfb_user -d wtfb_dev -c 'SELECT count(*) FROM pg_stat_activity;' 2>/dev/null || docker exec wtfb-dev-postgres psql -U wtfb_user -d wtfb_dev -c 'SELECT count(*) FROM pg_stat_activity;'"
```

### 5. Redis Connectivity

Test Redis connection:

```bash
# WOR-400: Check staging or dev redis container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker exec wtfb-staging-redis redis-cli ping 2>/dev/null || docker exec wtfb-dev-redis redis-cli ping"
```

Expected: `PONG`

Check Redis stats:

```bash
# WOR-400: Check staging or dev redis container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker exec wtfb-staging-redis redis-cli info stats 2>/dev/null | grep total_ || docker exec wtfb-dev-redis redis-cli info stats | grep total_"
```

### 6. Network Connectivity

Test Tailscale connectivity:

```bash
tailscale status | grep pop-os
```

Test HTTP access:

```bash
curl -s -o /dev/null -w "HTTP Response: %{http_code}\n" http://pop-os:3000
```

### 7. Recent Error Check

Check for recent errors in logs (last 5 minutes):

```bash
# WOR-400: Check staging or dev app container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-staging-app --since 5m 2>&1 | grep -i 'error\|fatal\|exception' | tail -10 || docker logs wtfb-dev-app --since 5m 2>&1 | grep -i 'error\|fatal\|exception' | tail -10"
```

### 8. Version Information

Get running version:

```bash
# WOR-400: Check staging or dev app container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-staging-app 2>/dev/null | grep 'org.opencontainers.image.revision' || docker inspect wtfb-dev-app | grep 'org.opencontainers.image.revision'"
```

Get uptime:

```bash
# WOR-400: Check staging or dev app container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-staging-app --format='{{.State.StartedAt}}' 2>/dev/null || docker inspect wtfb-dev-app --format='{{.State.StartedAt}}'"
```

### 9. Health Dashboard Report

Generate comprehensive health report:

````text
🏥 Pop OS Dev Environment Health Dashboard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Container Health (WOR-400/WOR-401: Dual Deployment)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Dev (STANDARD port 3000):
wtfb-dev-app          ✅ Healthy  Up 2 hours
wtfb-dev-postgres     ✅ Healthy  Up 2 hours
wtfb-dev-redis        ✅ Healthy  Up 2 hours

Staging (port 3001):
wtfb-staging-app      ✅ Healthy  Up 7 hours
wtfb-staging-postgres ✅ Healthy  Up 7 hours
wtfb-staging-redis    ✅ Healthy  Up 7 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource Usage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Container               CPU      Memory
wtfb-staging-app       2.45%    312MB / 2GB  (15%)
wtfb-staging-postgres  0.12%    45MB / 2GB   (2%)
wtfb-staging-redis     0.08%    8MB / 2GB    (0%)
wtfb-dev-app           1.80%    280MB / 2GB  (14%)
wtfb-dev-postgres      0.10%    42MB / 2GB   (2%)
wtfb-dev-redis         0.06%    6MB / 2GB    (0%)

Disk Space:            125GB / 250GB (50% used)
Docker Images:         3.2GB
Docker Volumes:        1.1GB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Application Health
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Health Endpoint:       ✅ Responding (142ms)
Status:                healthy
Environment:           development
Uptime:                7h 14m 23s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Database Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PostgreSQL:            ✅ Ready
Active Connections:    3 / 100
Last Backup:           N/A (dev environment)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cache Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Redis:                 ✅ PONG
Total Commands:        1,234
Keys:                  45

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Network Connectivity
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tailscale:             ✅ Connected (pop-os)
HTTP Access:           ✅ 200 OK
SSH Access:            ✅ Authenticated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commit:                3a49b85
Message:               feat(ci): add Slack notifications [WOR-350]
Deployed:              7 hours ago
Image:                 ghcr.io/bybren-llc/wtfb-app/dev:latest

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Recent Issues (Last 5 Minutes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Errors:                0
Warnings:              2

Recent warnings:
  [14:31:15] WARN: Using development build
  [14:31:18] WARN: PostHog not initialized

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Status: ✅ HEALTHY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All systems operational
No critical issues detected
Warnings are expected for dev environment

Quick Actions:
• View logs: /remote-logs
• Check updates: /remote-status
• Deploy latest: /remote-deploy
• Rollback: /remote-rollback
```text

### 10. Health Score Calculation

Calculate overall health score (0-100):

**Criteria**:

- Containers running: +30 points (10 per container)
- Health checks passing: +20 points
- Resource usage < 80%: +15 points
- No recent errors: +15 points
- Response time < 500ms: +10 points
- Database/Redis responding: +10 points

**Score Interpretation**:

- 90-100: ✅ Excellent
- 70-89: ⚠️ Good (minor issues)
- 50-69: ⚠️ Degraded (needs attention)
- 0-49: ❌ Critical (immediate action required)

## Alert Conditions

### Critical Alerts (❌)

- Any container stopped/crashed
- Health endpoint not responding (5xx errors)
- Database unreachable
- Redis unreachable
- Disk space > 90%
- Memory usage > 95%
- Recent FATAL errors in logs

**Action**: Immediate investigation required, consider rollback

### Warning Alerts (⚠️)

- Response time > 1 second
- Memory usage > 80%
- Disk space > 75%
- Error spike in last 5 minutes
- Redis connection timeouts
- Database connection pool exhausted

**Action**: Monitor closely, investigate when possible

### Info (ℹ️)

- Expected warnings (dev build, missing optional services)
- Normal resource usage
- All systems operational

## Error Handling

### SSH Connection Fails

Check Tailscale:

```bash
tailscale status
````

Reconnect if needed:

```bash
sudo tailscale up
```

### Health Endpoint Timeout

If health check times out:

- Check if containers are running
- View logs for errors: `/remote-logs`
- Consider restart or rollback

### Resource Issues

If resource usage high:

- Show top processes consuming resources
- Suggest restart to clear memory leaks
- Check for disk space cleanup opportunities

## Success Criteria

- ✅ All containers checked
- ✅ Resource usage retrieved
- ✅ Health endpoint tested
- ✅ Database/Redis verified
- ✅ Network connectivity confirmed
- ✅ Recent errors identified
- ✅ Version information displayed
- ✅ Overall health score calculated
- ✅ Actionable recommendations provided

## Related Commands

- `/remote-logs` - View detailed logs
- `/remote-status` - Check for updates
- `/remote-deploy` - Deploy latest version
- `/remote-rollback` - Rollback if unhealthy
