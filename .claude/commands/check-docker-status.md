---
description: Check if Pop OS Docker environment needs updating
---

> **DEPRECATED**: This command is an alias to `/remote-status`. Use `/remote-status` directly.

This command calls `/remote-status` which is the canonical command for checking Pop OS Docker status.

## Usage

```bash
/remote-status
```

## Why Deprecated?

Per WOR-445, we canonicalized around `/remote-*` and `/local-*` naming:

- `/remote-*` = Pop OS operations (staging-first, then dev)
- `/local-*` = Local machine operations

## Related Commands

- `/remote-status` - **Canonical** - Check if Pop OS needs update
- `/remote-deploy` - Deploy latest image to Pop OS
- `/remote-health` - Health dashboard for Pop OS
- `/remote-logs` - View Pop OS container logs
