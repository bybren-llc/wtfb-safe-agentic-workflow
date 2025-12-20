---
description: Deploy latest Docker image to Pop OS dev environment
---

> **DEPRECATED**: This command is an alias to `/remote-deploy`. Use `/remote-deploy` directly.

This command calls `/remote-deploy` which is the canonical command for deploying to Pop OS.

## Usage

```bash
/remote-deploy
```

## Why Deprecated?

Per WOR-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = Pop OS operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-deploy` - **Canonical** - Deploy latest image to Pop OS
- `/remote-status` - Check if Pop OS needs update
- `/remote-health` - Health dashboard for Pop OS
- `/remote-logs` - View Pop OS container logs
- `/remote-rollback` - Rollback Pop OS to previous image
