# Claude Code Configuration

This directory contains the SAFe Claude Code harness: hooks, slash commands, and (coming soon) skills for workflow automation.

## Harness Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│                      SAFe Claude Code Harness                         │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  HOOKS (Guardrails)              SLASH COMMANDS (User-Invoked)        │
│  ├─ Pre-commit reminders         ├─ /start-work                       │
│  ├─ Push blocker (uncommitted)   ├─ /remote-deploy                    │
│  └─ Auto-format on edit          └─ /pre-pr                           │
│                                                                       │
│  SKILLS (Model-Invoked) ✅ Available                                  │
│  ├─ wtfb-workflow      (SAFe commit/PR patterns)                      │
│  ├─ pattern-discovery  (search docs/patterns first)                   │
│  ├─ rls-patterns       (database security helpers)                    │
│  └─ frontend-patterns  (Clerk, shadcn, Next.js App Router)            │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

**Key distinction:**

- **Hooks**: Automatic guardrails (reminders and critical blockers)
- **Slash Commands**: Explicit user-invoked workflows (`/start-work`, `/pre-pr`)
- **Skills**: Model-invoked expertise packs (Claude auto-loads relevant context)

## Team Principles (SAFe + Round Table)

This harness is designed to help every teammate (human + AI) uphold:

- **SAFe Pillars**: Alignment, Built-in Quality, Program Execution, Transparency
- **SAFe Round Table**: humans + AI agents are peers; Stop-the-Line authority is encouraged

Canonical reference: `.cursor/rules/06-team-culture.mdc`

## Slash Commands

### Workflow Commands

| Command           | Purpose                               | Usage                              |
| ----------------- | ------------------------------------- | ---------------------------------- |
| `/start-work`     | Begin new ticket with proper workflow | `/start-work 347` or `/start-work` |
| `/pre-pr`         | Run complete validation before PR     | `/pre-pr`                          |
| `/end-work`       | Complete work session cleanly         | `/end-work`                        |
| `/check-workflow` | Quick status check of workflow        | `/check-workflow`                  |
| `/update-docs`    | Identify and update documentation     | `/update-docs`                     |
| `/retro`          | Conduct retrospective analysis        | `/retro`                           |
| `/sync-linear`    | Sync current work with Linear ticket  | `/sync-linear`                     |

### Local Operations

| Command         | Purpose                             | Usage           |
| --------------- | ----------------------------------- | --------------- |
| `/local-sync`   | Full sync after git pull            | `/local-sync`   |
| `/local-deploy` | Deploy to local Docker environment  | `/local-deploy` |
| `/quick-fix`    | Fast-track workflow for small fixes | `/quick-fix`    |

### Remote Operations ({DEV_MACHINE})

These are the **canonical commands** for {DEV_MACHINE} machine operations.

| Command            | Purpose                              | Usage              |
| ------------------ | ------------------------------------ | ------------------ |
| `/remote-status`   | Check if Docker environment outdated | `/remote-status`   |
| `/remote-deploy`   | Deploy latest image to staging       | `/remote-deploy`   |
| `/remote-health`   | Full health dashboard                | `/remote-health`   |
| `/remote-logs`     | View container logs                  | `/remote-logs`     |
| `/remote-rollback` | Rollback to previous image           | `/remote-rollback` |

### Deprecated Aliases

These commands are thin wrappers pointing to canonical `/remote-*` commands. **Use the canonical versions.**

| Command                | Alias For          | Note                               |
| ---------------------- | ------------------ | ---------------------------------- |
| `/check-docker-status` | `/remote-status`   | Deprecated per {TICKET_PREFIX}-445 |
| `/deploy-dev`          | `/remote-deploy`   | Deprecated per {TICKET_PREFIX}-445 |
| `/dev-health`          | `/remote-health`   | Deprecated per {TICKET_PREFIX}-445 |
| `/dev-logs`            | `/remote-logs`     | Deprecated per {TICKET_PREFIX}-445 |
| `/rollback-dev`        | `/remote-rollback` | Deprecated per {TICKET_PREFIX}-445 |

### Other Commands

| Command           | Purpose                            | Usage                 |
| ----------------- | ---------------------------------- | --------------------- |
| `/test-pr-docker` | Test PR Docker workflow            | `/test-pr-docker 225` |
| `/audit-deps`     | Run comprehensive dependency audit | `/audit-deps`         |
| `/search-pattern` | Search for code patterns           | `/search-pattern`     |

## Dual-Mode Deployment ({TICKET_PREFIX}-445 Terminology Contract)

{DEV_MACHINE} supports two deployment modes. **Use canonical terminology:**

| Mode        | Container Name     | Port | Use Case                     |
| ----------- | ------------------ | ---- | ---------------------------- |
| **Dev**     | `wtfb-dev-app`     | 3000 | Daily development (STANDARD) |
| **Staging** | `wtfb-staging-app` | 3001 | Release validation/UAT       |

**Important:**

- "dev branch" = Git branch (source code)
- "dev-mode container" = Docker deployment on {DEV_MACHINE} (port 3000)
- "staging-mode container" = Docker deployment on {DEV_MACHINE} (port 3001)

Both containers run images built from the `dev` branch. The difference is configuration (ports, volume mounts).

See: `docs/agent-outputs/workflow-analysis/HARNESS_AND_SKILLS_AUDIT_2025-12-18.md`

## Typical Workflow

```bash
# 1. Start new ticket
/start-work 347

# 2. Make changes, commit work...
# git add . && git commit -m "feat(scope): description [{TICKET_PREFIX}-347]"

# 3. Check status periodically
/check-workflow

# 4. Update documentation before PR
/update-docs

# 5. Validate before creating PR
/pre-pr

# 6. Create PR (if validation passes)
# git push --force-with-lease origin {TICKET_PREFIX}-347-branch
# # Use the PR template as your PR body baseline:
# # gh pr create --title "feat(scope): description [{TICKET_PREFIX}-347]" --body "$(cat .github/pull_request_template.md)"
# gh pr create ...

# 7. End session cleanly
/end-work
```

## Hooks Configuration

Hooks provide automatic reminders, validation, and critical blockers during development.
Configuration is in `hooks-config.json`.

### Active Hooks (from hooks-config.json)

**Session Lifecycle:**

| Event          | Behavior                                        |
| -------------- | ----------------------------------------------- |
| `SessionStart` | Shows available commands and workflow reminders |
| `SessionEnd`   | Warns if uncommitted changes exist              |

**Pre-Tool Hooks (Prevention):**

| Trigger               | Behavior                                                                      |
| --------------------- | ----------------------------------------------------------------------------- |
| On prompt submit      | Reminds about `WOR-{number}` branch naming convention                         |
| Before `git commit`   | Reminds about SAFe commit format                                              |
| Before `git push`     | ❌ **BLOCKS** if on dev/master; ❌ **BLOCKS** if uncommitted; warns if behind |
| Before `gh pr create` | Reminds to run `/pre-pr` validation first                                     |

**Post-Tool Hooks (Feedback):**

| Trigger             | Behavior                                              |
| ------------------- | ----------------------------------------------------- |
| After `ci:validate` | Reports pass/fail result                              |
| After file edit     | Auto-formats with Prettier/ESLint; reminds about docs |

### Legacy Scripts (Not Yet Wired)

Scripts in `.claude/hooks/` are planned for future wiring but not currently active:

- `post-commit-linear-update.sh`
- `post-push-docker-check.sh`
- `pre-bash-rls-validation.sh`
- `session-start-pattern-check.sh`

### Installing Hooks

1. Open Claude Code settings
2. Navigate to hooks configuration
3. Copy contents of `hooks-config.json`
4. Paste into hooks settings
5. Save and reload Claude Code

## Skills

Skills are model-invoked expertise packs that Claude loads automatically when relevant context is detected.

**Available Skills:**

| Skill               | Status | Purpose                                        |
| ------------------- | ------ | ---------------------------------------------- |
| `wtfb-workflow`     | ✅     | SAFe commit format, branch naming, PR workflow |
| `pattern-discovery` | ✅     | Search docs/patterns before creating new code  |
| `rls-patterns`      | ✅     | RLS context helpers, forbid direct Prisma      |
| `frontend-patterns` | ✅     | Clerk auth, shadcn/Radix, Next.js App Router   |

Skills live in `.claude/skills/{skill-name}/SKILL.md`.

### Listing Available Skills

**Known Issue**: The `/skills` command has a display bug in Claude Code v2.0.73 (GitHub Issue #14733).
Skills ARE working, but won't appear in `/skills` output.

**Workaround**: Ask Claude directly:

```text
What skills are available?
```

Or list the filesystem:

```bash
ls .claude/skills/
```

## Customization

### Adding New Slash Commands

Create a new markdown file in `.claude/commands/`:

```markdown
---
description: Command purpose
argument-hint: [optional args]
---

Command instructions here.

Use $1, $2 for positional arguments.
Use $ARGUMENTS for all arguments.
```

### Modifying Hooks

Edit `hooks-config.json` following this structure:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "shell-command-here",
            "description": "What this hook does"
          }
        ]
      }
    ]
  }
}
```

## Documentation

- **Harness Audit**: `docs/agent-outputs/workflow-analysis/HARNESS_AND_SKILLS_AUDIT_2025-12-18.md`
- **CONTRIBUTING.md**: Project workflow requirements
- **Slash Commands Guide**: [Claude Code slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- **Hooks Guide**: [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)

## Troubleshooting

### Slash Commands Not Working

1. Verify `.claude/commands/` directory exists
2. Check file permissions (should be readable)
3. Restart Claude Code
4. Run `claude --debug` to see command loading

### Hooks Not Triggering

1. Verify hooks are configured in Claude Code settings
2. Check JSON syntax in `hooks-config.json`
3. Run `claude --debug` to see hook execution
4. Verify matchers are correct regex patterns

## Maintenance

These configurations are part of the project and should be:

- Committed to version control
- Updated when workflow changes
- Documented when modified
- Tested after changes

---

**Last Updated**: 2025-12-19
**Maintained by**: {PROJECT_NAME} Development Team + ARCHitect-in-the-IDE (Auggie)
