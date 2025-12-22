---
description: Start work on a new Linear ticket with proper workflow
argument-hint: [{TICKET_PREFIX}-number]
---

> **📋 TEMPLATE**: This command is a template. See "Customization Guide" below to adapt for your infrastructure.

You are starting work on a new Linear ticket. Follow the MANDATORY @CONTRIBUTING.md workflow:

## Pre-Flight Checklist

1. **Linear Ticket Exists?**
   - If no ticket number provided in arguments, ask user for Linear ticket number
   - Verify ticket exists in Linear using `mcp__linear-mcp__get_issue`
   - Confirm ticket is in appropriate status (Todo, In Progress)

2. **Branch Naming**
   - Format: `{TICKET_PREFIX}-{number}-{short-description}`
   - Must start with {TICKET_PREFIX}- and ticket number
   - Use lowercase with hyphens

3. **Start from Latest Dev**
   - Ensure starting from clean dev branch: `git checkout dev && git pull origin dev`
   - Verify no uncommitted changes

4. **Create Feature Branch**
   - Create branch: `git checkout -b {TICKET_PREFIX}-{number}-{description}`
   - Confirm branch created successfully

## Workflow

If argument provided ($1):

- Use as ticket number (e.g., `/start-work 347` → {TICKET_PREFIX}-347)
- Fetch ticket details from Linear
- Suggest branch name based on ticket title
- Execute checkout workflow

If no argument:

- Ask user for Linear ticket number
- Proceed with workflow

## Success Criteria

- ✅ Linear ticket verified
- ✅ On latest dev branch
- ✅ Feature branch created with correct naming
- ✅ Ready to begin work

Report status and any blockers.

## Customization Guide

To adapt this command for your infrastructure, replace these placeholders:

| Placeholder       | Description               | Example               |
| ----------------- | ------------------------- | --------------------- |
| `{TICKET_PREFIX}` | Your Linear ticket prefix | `WOR`, `PROJ`, `TASK` |
