---
description: Rollback Pop OS dev environment to previous Docker image
argument-hint: [commit-sha]
---

Rollback the Pop OS dev environment to a previous Docker image version.

## Workflow

### 1. Assess Current Situation

Get current problematic version:

```bash
# WOR-400: Check staging or dev container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-staging-app 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4 || docker inspect wtfb-dev-app | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

Check current status:

```bash
curl -s http://pop-os:3000/api/health 2>/dev/null || echo "Health check failed"
```

Document the issue for Linear ticket creation later.

### 2. List Available Rollback Targets

Show recent images on Pop OS:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker images ghcr.io/bybren-llc/wtfb-app/dev --format 'table {{.Tag}}\t{{.ID}}\t{{.CreatedAt}}'"
```

Cross-reference with git commits to show messages:

```bash
git log origin/dev -10 --oneline
```

### 3. Select Rollback Target

**If argument provided** (commit SHA like `e9722d4`):

- Use specified commit as rollback target
- Verify image exists with that SHA tag

**If no argument provided**:

- Display last 5 available images with commit messages
- Recommend previous stable version (before current)
- Ask user to confirm selection

Default behavior: Select image before current (most common rollback scenario)

### 4. Pull Rollback Image

Pull the specific version from registry:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker pull ghcr.io/bybren-llc/wtfb-app/dev:dev-{target-sha}"
```

If image not in registry (old version pruned), use local cached image.

### 5. Update Configuration

Create backup of current config:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && cp docker-compose.dev.yml docker-compose.dev.yml.backup.$(date +%Y%m%d_%H%M%S)"
```

Update docker-compose.dev.yml to use specific image tag:

```bash
# From: image: ghcr.io/bybren-llc/wtfb-app/dev:latest
# To:   image: ghcr.io/bybren-llc/wtfb-app/dev:dev-{target-sha}
```

Use SSH + sed for inline replacement:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && sed -i 's|ghcr.io/bybren-llc/wtfb-app/dev:latest|ghcr.io/bybren-llc/wtfb-app/dev:dev-{target-sha}|g' docker-compose.dev.yml"
```

### 6. Restart Services

Restart with rollback image:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && ./scripts/dev-docker.sh restart"
```

Monitor startup:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && ./scripts/dev-docker.sh logs --tail 50"
```

### 7. Verify Rollback Success

Check services started:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker ps --filter name=wtfb"
```

Verify health endpoint:

```bash
curl -s http://pop-os:3000/api/health | jq
```

Confirm correct commit SHA:

```bash
# WOR-400: Check staging or dev container
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-staging-app 2>/dev/null | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4 || docker inspect wtfb-dev-app | grep 'org.opencontainers.image.revision' | cut -d'\"' -f4"
```

### 8. Post-Rollback Actions

**If rollback successful**:

- Keep rollback configuration in place
- Create Linear ticket documenting the issue with broken version
- Include error logs and health check failures
- Tag ticket with `bug` and `deployment-rollback` labels
- Notify team via Slack about rollback

**If rollback still has issues**:

- Try rolling back to an even older version
- Check if issue is environmental (database, Redis, etc.)
- Escalate to team for investigation

### 9. Rollback Report

Provide comprehensive rollback summary:

````text
⏮️  Pop OS Dev Environment Rollback

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Problem Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version:  3a49b85 - feat(ci): add Slack notifications [WOR-350]
Issue:    Health check failing / Services crashing
Time:     Deployed 5 minutes ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Target
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Selected: e9722d4 - style(docs): apply markdown linting fixes [WOR-347]
Reason:   Last known stable version
Age:      7 hours ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rollback Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[14:30:00] Backup config... ✅ docker-compose.dev.yml.backup.20251011_143000
[14:30:05] Pull rollback image... ✅ dev-e9722d4 (45s)
[14:30:50] Update config... ✅ Set to dev-e9722d4
[14:30:55] Restart services... ✅ Complete (28s)
[14:31:23] Health check... ✅ Passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Post-Rollback Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running:  e9722d4 - style(docs): apply markdown linting fixes [WOR-347]
Status:   ✅ Healthy
URL:      http://pop-os:3000
Duration: 1m 23s

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Rollback Complete - Environment Restored
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
• Create Linear ticket for broken version (3a49b85)
• Include error logs and symptoms
• Investigate root cause before redeploying
• Keep this version until fix is verified

To return to latest (when fixed):
  /remote-deploy
```text

### 10. Restore to Latest (When Fixed)

When issue is resolved and new build is ready, restore to latest:

```bash
# Restore docker-compose.dev.yml to use :latest tag
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "cd ~/Projects/wtfb-team && sed -i 's|ghcr.io/bybren-llc/wtfb-app/dev:dev-[a-f0-9]*|ghcr.io/bybren-llc/wtfb-app/dev:latest|g' docker-compose.dev.yml"

# Then deploy normally
/remote-deploy
```text

## Error Handling

### Image Not Available

If rollback target image not found:

- Try older version
- Pull from registry manually
- Check available tags: `docker images | grep wtfb-app`

### Services Still Failing

If rollback doesn't fix issue:

- Problem may be environmental (database, Redis, config)
- Check database status
- Verify environment variables unchanged
- Try even older version

### Configuration Restore Fails

If config update fails:

- Manually restore from backup
- Verify SSH permissions
- Check disk space

## Success Criteria

- ✅ Rollback target selected
- ✅ Config backed up
- ✅ Rollback image pulled/available
- ✅ Config updated to specific version
- ✅ Services restarted successfully
- ✅ Health check passes
- ✅ Correct commit SHA running
- ✅ Error logs clean
- ✅ Linear ticket created for issue

## Prevention

Document issue in Linear to prevent recurrence:

- What broke
- How it was detected
- What version caused it
- How to test for this issue before deployment
- Consider adding pre-deployment checks
````
