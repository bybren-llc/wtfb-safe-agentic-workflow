---
description: View Pop OS dev container logs
argument-hint: [--follow] [--tail N]
---

View logs from the Pop OS dev environment containers.

## Workflow

### 1. Determine Log Mode

**If argument contains `--follow` or `-f`**:

- Stream logs in real-time
- Useful for monitoring deployments
- Press Ctrl+C to exit

**If argument contains `--tail N`**:

- Show last N lines
- Default to 100 if not specified

**If no arguments**:

- Show last 100 lines (default)

### 2. Execute Log Command

Get logs from all WTFB services:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && ./scripts/dev-docker.sh logs --tail 100"
```

For specific service:

```bash
# WOR-400/WOR-445: Container names and ports per Terminology Contract

# Next.js app logs (dev-mode - STANDARD port 3000)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-dev-app --tail 100"

# Next.js app logs (staging-mode - port 3001)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-staging-app --tail 100"

# PostgreSQL logs (staging)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-staging-postgres --tail 100"

# PostgreSQL logs (dev)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-dev-postgres --tail 100"

# Redis logs (staging)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-staging-redis --tail 100"

# Redis logs (dev)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-dev-redis --tail 100"
```

### 3. Filter and Highlight

Parse logs for common patterns:

**Error Detection**:

- `ERROR`, `Error`, `error`
- `FATAL`, `Fatal`
- `Exception`, `exception`
- Stack traces

**Warning Detection**:

- `WARN`, `Warning`, `warning`
- `deprecated`

**Success Markers**:

- `started`, `listening`, `ready`
- `connected`, `successful`

Highlight critical issues in output.

### 4. Log Analysis

Provide quick analysis:

```text
📋 Pop OS Dev Logs Analysis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dev Containers (STANDARD port 3000) - WOR-401
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

wtfb-dev-app (Next.js):
  Status:    ✅ Running
  Errors:    0
  Warnings:  2
  Last Line: [14:35:22] Ready on http://localhost:3000

wtfb-dev-postgres:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:10] database system is ready

wtfb-dev-redis:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:08] Ready to accept connections

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Staging Containers (port 3001) - WOR-401
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

wtfb-staging-app (Next.js):
  Status:    ✅ Running
  Errors:    0
  Warnings:  1
  Last Line: [14:35:22] Ready on http://localhost:3001
  Recent warnings:
    [14:34:15] WARN: Using development build
    [14:34:18] WARN: PostHog not initialized (missing key)

wtfb-staging-postgres:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:10] database system is ready

wtfb-staging-redis:
  Status:    ✅ Running
  Errors:    0
  Last Line: [14:34:08] Ready to accept connections

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Health: ✅ Healthy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommendation: No critical issues detected
Warnings are expected for dev environment
```

### 5. Interactive Follow Mode

If `--follow` requested, start streaming:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && ./scripts/dev-docker.sh logs --follow"
```

Inform user:

- "Streaming logs... (Press Ctrl+C to stop)"
- Show timestamp of each log line
- Highlight errors in red if possible

### 6. Log Search

Offer quick log search options:

**Search for specific term**:

```bash
# WOR-400: Search staging or dev logs
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-staging-app 2>&1 | grep -i 'search-term'"
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker logs wtfb-dev-app 2>&1 | grep -i 'search-term'"
```

**Common search patterns**:

- "ERROR" - All errors
- "database" - Database connection logs
- "Redis" - Redis connection logs
- "API" - API request logs
- "POST /api" - POST requests only

## Usage Examples

### View Recent Logs

```bash
/remote-logs
```

Shows last 100 lines from all containers

### Follow Logs in Real-Time

```bash
/remote-logs --follow
```

Streams logs continuously

### View More Lines

```bash
/remote-logs --tail 500
```

Shows last 500 lines

### View and Follow

```bash
/remote-logs --tail 200 --follow
```

Shows last 200 lines, then continues streaming

## Error Handling

### SSH Connection Fails

Check Tailscale:

```bash
tailscale status | grep pop-os
```

Provide manual SSH command:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os
```

### Container Not Found

If container doesn't exist:

- Check services are running: `/remote-health`
- Start services: `/remote-deploy`

### Permission Issues

If log access denied:

- Verify docker group membership
- Provide sudo alternative

## Output Options

### Compact Mode (Default)

Show analysis summary + filtered logs (errors/warnings highlighted)

### Full Mode (If requested)

Show complete raw logs without filtering

### Service-Specific Mode

If user specifies container name (WOR-400: updated container mapping):

Staging mode:

- `app` or `next` → wtfb-staging-app
- `postgres` or `db` → wtfb-staging-postgres
- `redis` → wtfb-staging-redis

Dev mode:

- `app` or `next` → wtfb-dev-app
- `postgres` or `db` → wtfb-dev-postgres
- `redis` → wtfb-dev-redis

## Success Criteria

- ✅ SSH connection successful
- ✅ Logs retrieved
- ✅ Errors/warnings identified
- ✅ Quick analysis provided
- ✅ Follow mode works (if requested)
- ✅ Easy to read formatting

## Related Commands

- `/remote-health` - Check service health
- `/remote-status` - Check deployment status
- `/remote-deploy` - Deploy latest version
- `/remote-rollback` - Rollback if errors found
