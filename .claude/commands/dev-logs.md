---
description: View Pop OS dev container logs
argument-hint: [--follow] [--tail N]
---

> **DEPRECATED**: This command is an alias to `/remote-logs`. Use `/remote-logs` directly.

This command calls `/remote-logs` which is the canonical command for viewing Pop OS container logs.

## Usage

```bash
/remote-logs
/remote-logs --follow
/remote-logs --tail 500
```

## Why Deprecated?

Per WOR-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = Pop OS operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-logs` - **Canonical** - View Pop OS container logs
- `/remote-health` - Health dashboard for Pop OS
- `/remote-status` - Check if Pop OS needs update
- `/remote-deploy` - Deploy latest image to Pop OS
