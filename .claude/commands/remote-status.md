---
description: Check if Pop OS Docker environment needs updating
---

Compare the Docker image running on Pop OS with the latest image in the registry.

## Deployment Modes

Pop OS supports two deployment modes (WOR-400/WOR-401):

| Mode            | Container Name     | Port | Use Case                                                           |
| --------------- | ------------------ | ---- | ------------------------------------------------------------------ |
| **Development** | `wtfb-dev-app`     | 3000 | Hot-reload, source-mounted, STANDARD ports for local tools         |
| **Staging**     | `wtfb-staging-app` | 3001 | Production-like, self-contained, survives git operations (WOR-401) |

**Dev mode uses STANDARD ports** so all local tools (Prisma CLI, IDE, tests) work by default.
**Staging mode is recommended for Pop OS** - it's stable and won't break during `git pull`.

## Workflow

### 1. Get Running Container Info

Check running container on Pop OS (check both modes):

```bash
# WOR-445: Dev-mode first (primary), staging fallback per Terminology Contract
# Check dev container (primary - STANDARD port 3000)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker ps --filter name=wtfb-dev-app --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"

# Check staging container (fallback - port 3001)
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker ps --filter name=wtfb-staging --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"
```

Extract commit SHA from running container:

```bash
# WOR-445: Dev-first, staging fallback per Terminology Contract
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker inspect wtfb-dev-app 2>/dev/null | grep 'org.opencontainers.image.revision' || docker inspect wtfb-staging-app 2>/dev/null | grep 'org.opencontainers.image.revision'"
```

Get image creation time:

```bash
ssh -i ~/.ssh/id_ed25519_pop_os cheddarfox@pop-os "docker images ghcr.io/bybren-llc/wtfb-app/dev:latest --format '{{.CreatedAt}}'"
```

### 2. Get Latest Registry Image Info

Check latest commit on dev branch:

```bash
git fetch origin dev
git log origin/dev -1 --format='%H %s'
```

Check latest GitHub Actions build status:

```bash
gh run list --workflow=build-dev-image.yml --limit 3
```

### 3. Compare and Report Status

**If commit SHAs match**:

- ✅ Pop OS is up-to-date
- Report current version info
- Show uptime
- No action needed

**If commit SHAs differ**:

- ⚠️ Update available
- Show current vs latest commits
- Check if GitHub Actions build is complete
- If build in progress: show estimated completion
- If build complete: provide deployment command

### 4. Output Format

Display comprehensive status:

````text
🐳 Docker Image Status Check

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pop OS Dev Environment (Running)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Container: wtfb-dev-app (STANDARD port 3000) or wtfb-staging-app (port 3001)
Status:    ✅ Up 7 hours (healthy)
Image:     ghcr.io/bybren-llc/wtfb-app/dev:latest
Commit:    e9722d4 - style(docs): apply markdown linting fixes [WOR-347]
Created:   2025-10-11 08:20:15 EDT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GitHub Container Registry (Latest)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commit:    3a49b85 - feat(ci): add Slack notifications [WOR-350]
Build:     ✅ Complete (31 seconds ago)
Status:    Ready to deploy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Result: ⚠️  UPDATE AVAILABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes since running version:
• feat(ci): add Slack notifications for Docker image builds [WOR-350]

To deploy update:
/remote-deploy
```text

### 5. Actionable Guidance

Based on status, provide appropriate next steps:

**Up-to-date**:

- "No action needed"
- Show next steps if user wants to check logs or health

**Update available + build complete**:

- "Ready to deploy"
- Provide `/remote-deploy` command
- Mention `/remote-status` to recheck before deploying

**Update available + build in progress**:

- "Build in progress (estimated X minutes remaining)"
- Provide link to GitHub Actions run
- Suggest checking Slack for completion notification

**Build failed**:

- "Latest build failed"
- Link to GitHub Actions failure
- Suggest checking logs

## Error Handling

If SSH fails:

- Check Tailscale connection
- Verify SSH key exists: `~/.ssh/id_ed25519_pop_os`
- Provide manual SSH command

If container not found:

- Check if services are running
- Provide start command: `/remote-deploy`

## Success Criteria

- ✅ SSH connection successful
- ✅ Container info retrieved
- ✅ Registry status checked
- ✅ Clear status comparison
- ✅ Actionable next steps provided
````
