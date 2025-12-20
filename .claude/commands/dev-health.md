---
description: Check Pop OS dev environment health dashboard
---

> **DEPRECATED**: This command is an alias to `/remote-health`. Use `/remote-health` directly.

This command calls `/remote-health` which is the canonical command for Pop OS health checks.

## Usage

```bash
/remote-health
```

## Why Deprecated?

Per WOR-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = Pop OS operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-health` - **Canonical** - Health dashboard for Pop OS
- `/remote-status` - Check if Pop OS needs update
- `/remote-deploy` - Deploy latest image to Pop OS
- `/remote-logs` - View Pop OS container logs
