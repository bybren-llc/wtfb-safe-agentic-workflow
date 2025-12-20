---
description: Deploy latest Docker image to Pop OS staging environment
---

Deploy the latest Docker image to Pop OS staging environment using the self-contained staging mode.

## Quick Deploy Command

Execute single deploy command on Pop OS:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && ./scripts/dev-docker.sh deploy"
```

This command handles everything:

1. Pulls latest image from ghcr.io
2. Starts staging compose (no source mounts)
3. Waits for health check (up to 90s)
4. Reports status with container revision

Expected output on success:

```text
Deploying to staging environment...
Pulling latest image...
Starting staging services...
Waiting for health check...
Deploy complete!
Status: Up 5 seconds (health: starting)
Revision: abc1234
URL: http://localhost:3001
```

Expected duration: 2-5 minutes

## Success Criteria

- Container running (healthy)
- Health endpoint returns 200
- Image revision matches latest dev commit

## Error Handling

### Pull Failed

Possible causes:

- `docker login ghcr.io` - Registry auth expired
- `df -h` - Disk space full

### Health Check Failed

The deploy script will show recent logs. Common actions:

- Check logs for startup errors
- Verify database connection
- Run `/remote-rollback` to restore previous working state

## Verify Deployment

After deployment, verify with:

```bash
# Health check (staging port 3001 per WOR-401)
curl -s http://pop-os:3001/api/health | jq

# Container status
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker ps --filter name=wtfb-staging"
```

## Related Commands

- `/remote-health` - Full health dashboard
- `/remote-logs` - View container logs
- `/remote-rollback` - Rollback to previous image
- `/remote-status` - Check if update needed
