# Claude Code Harness Modernization

## A Practical Guide to Scaling Agentic Workflows with Hooks, Commands, and Skills

**Version**: 1.2
**Date**: 2025-12-20 (Phase 3 Complete)
**Epic**: WOR-444 (Harness & Skills Modernization)
**Authors**: WTFB Development Team + ARCHitect-in-the-IDE (Auggie)

---

## Executive Summary

This whitepaper documents the modernization of our Claude Code harness—the collection of hooks,
slash commands, and (upcoming) skills that automate and guard our development workflow.
After a comprehensive audit revealed significant drift between documentation and reality,
we undertook a systematic effort to:

1. **Audit** the existing harness surface (24 commands, 5 hook events)
2. **Fix** terminology conflicts and command drift
3. **Document** the three-layer architecture (Hooks → Commands → Skills)
4. **Design** model-invoked Skills for proactive pattern enforcement

**Key Outcomes:**

- Unified terminology contract for dual-mode Docker deployment
- 24 slash commands organized into logical categories
- Clear distinction between automatic guardrails and user-invoked workflows
- **Four model-invoked Skills implemented** (WOR-447 through WOR-450):
  - `safe-workflow` - SAFe commit/branch/PR patterns
  - `pattern-discovery` - Pattern-first development enforcement
  - `rls-patterns` - Database security RLS context helpers
  - `frontend-patterns` - Next.js/Clerk/shadcn/PostHog conventions

---

## Table of Contents

1. [Background and Motivation](#background-and-motivation)
2. [The Three-Layer Harness Architecture](#the-three-layer-harness-architecture)
3. [Audit Findings](#audit-findings)
4. [Solutions Implemented](#solutions-implemented)
5. [Terminology Contract](#terminology-contract)
6. [Command Surface Reference](#command-surface-reference)
7. [Hooks Configuration](#hooks-configuration)
8. [Skills Implementation (All Phases Complete)](#skills-implementation-all-phases-complete)
9. [Phase 3: Skills Expansion (COMPLETE)](#phase-3-skills-expansion-complete)
10. [Operational SOPs Reference](#section-4-operational-standard-operating-procedures)
11. [Lessons Learned](#lessons-learned)
12. [Appendix: Migration Checklist](#appendix-migration-checklist)
13. [Appendix: Artifact Status Snapshot](#appendix-artifact-status-snapshot)

---

## Background and Motivation

### The Problem

As our agentic workflow matured, we accumulated slash commands organically—each solving
an immediate need but without architectural coherence. Over time, this led to:

- **Command drift**: Deprecated commands lingered alongside canonical replacements
- **Terminology confusion**: "dev" meant different things in different contexts (branch vs. container vs. machine)
- **Documentation staleness**: README listed 7 commands when 24 existed
- **Hook mystery**: Scripts existed in `.claude/hooks/` that weren't actually wired

### The Trigger

A routine check revealed that our Docker deployment commands used inconsistent container names
and port assignments. The `remote-status` command checked staging before dev, while
`remote-deploy` deployed to dev first. This inconsistency caused confusion during incident response.

### The Solution Approach

Rather than patch individual issues, we conducted a comprehensive audit (WOR-445) followed by
documentation refresh (WOR-446) and designed a Skills layer (WOR-447-450) for proactive
pattern enforcement.

---

## The Three-Layer Harness Architecture

Our Claude Code harness operates on three distinct layers, each with different invocation models:

```text
┌──────────────────────────────────────────────────────────────────────┐
│                      Claude Code Harness                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  LAYER 1: HOOKS (Automatic Guardrails)                               │
│  ├─ Trigger: Events (SessionStart, PreToolUse, PostToolUse)          │
│  ├─ Invocation: Automatic, no user action                            │
│  ├─ Purpose: Reminders, blockers, auto-formatting                    │
│  └─ Examples: Push blocker, commit format reminder                   │
│                                                                       │
│  LAYER 2: SLASH COMMANDS (User-Invoked Workflows)                    │
│  ├─ Trigger: User types /command-name                                │
│  ├─ Invocation: Explicit user request                                │
│  ├─ Purpose: Multi-step workflows, deployments, validations          │
│  └─ Examples: /start-work, /pre-pr, /remote-deploy                   │
│                                                                       │
│  LAYER 3: SKILLS (Model-Invoked Expertise) ✅ Implemented            │
│  ├─ Trigger: Claude detects relevant context                         │
│  ├─ Invocation: Model decision, transparent to user                  │
│  ├─ Purpose: Pattern enforcement, domain knowledge injection         │
│  └─ Skills: safe-workflow, pattern-discovery, rls-patterns, frontend │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

### Why Three Layers?

| Layer    | Best For                                        | User Awareness                            |
| -------- | ----------------------------------------------- | ----------------------------------------- |
| Hooks    | Safety rails that should always apply           | Low (runs silently or with brief message) |
| Commands | Complex workflows user consciously initiates    | High (user explicitly invokes)            |
| Skills   | Domain expertise that should apply contextually | Medium (Claude mentions when relevant)    |

---

## Audit Findings

### What We Found (WOR-445 Audit)

#### 1. Command Surface Drift

- README documented 7 commands; actual count was 24
- Deprecated aliases coexisted with canonical commands
- No clear categorization or grouping

#### 2. Terminology Collision

- "dev" used for: Git branch, Docker container, Pop OS machine
- Commands inconsistently referenced "staging" vs "dev-mode"
- Port numbers scattered across multiple files without single source of truth

#### 3. Hook Reality Gap

- `hooks-config.json` contained inline commands
- `.claude/hooks/*.sh` scripts existed but weren't wired
- README implied scripts were active when they weren't
- Push blocker existed but documentation said "non-blocking warnings"

#### 4. Container Name Inconsistency

- Some commands checked `wtfb-staging-app` first
- Others checked `wtfb-dev-app` first
- Order affected troubleshooting and incident response

---

## Solutions Implemented

### WOR-445: Fix Docker Command/Hook Drift

**Problem**: Inconsistent container naming and check order across remote commands.

**Solution**: Established Terminology Contract and updated all commands to dev-first order.

**Files Modified**:

- `.claude/commands/remote-status.md` - Dev-first container checks
- `.claude/commands/remote-logs.md` - Consistent port documentation
- `.claude/commands/remote-deploy.md` - Clear mode terminology
- `.claude/commands/rollback-dev.md` - Updated container references
- Deprecated aliases converted to thin wrappers pointing to canonical commands

### WOR-446: Documentation Refresh

**Problem**: Stale README (last updated October 2025) with incomplete command list.

**Solution**: Complete rewrite with accurate hook documentation and command categorization.

**Changes**:

- Expanded command table from 7 to 24 (grouped by category)
- Added Harness Architecture diagram
- Rewrote hooks section to match `hooks-config.json` reality
- Added Skills preview section
- Established "Legacy Scripts" category for unwired `.sh` files
- Synced SessionStart message with new command surface

---

## Terminology Contract

### The Core Problem

When someone says "deploy to dev," do they mean:

- Push code to the `dev` Git branch?
- Deploy a Docker image to the dev-mode container?
- Update the Pop OS development machine?

### The Solution: Explicit Terminology

| Term                       | Meaning                           | Example                 |
| -------------------------- | --------------------------------- | ----------------------- |
| **dev branch**             | Git branch for integration        | `git checkout dev`      |
| **dev-mode container**     | Docker container on port 3000     | `wtfb-dev-app`          |
| **staging-mode container** | Docker container on port 3001     | `wtfb-staging-app`      |
| **Pop OS**                 | The physical/remote Linux machine | `ssh cheddarfox@pop-os` |

### Dual-Mode Deployment

Both containers run images built from the `dev` branch. The difference is configuration:

| Mode        | Container Name     | Port | Use Case                     |
| ----------- | ------------------ | ---- | ---------------------------- |
| **Dev**     | `wtfb-dev-app`     | 3000 | Daily development (STANDARD) |
| **Staging** | `wtfb-staging-app` | 3001 | Release validation/UAT       |

**Rule**: Dev-mode is the default. Commands check dev first, fall back to staging.

### The Real Model: From Branch to Container

This diagram shows how code flows from Git branch to running containers:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                         Git Branch: dev                                  │
│   (source of truth - all PRs merge here, GitHub Actions builds image)   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Docker Image: ghcr.io/bybren-llc/wtfb-app:latest     │
│              (built from dev branch, stored in GitHub Container Registry)│
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│   DEV-MODE CONTAINER            │   │   STAGING-MODE CONTAINER        │
│   Name: wtfb-dev-app            │   │   Name: wtfb-staging-app        │
│   Port: 3000 (standard)         │   │   Port: 3001 (alternate)        │
│   Use: Daily development        │   │   Use: Release validation/UAT   │
│   Source: Mounted (hot-reload)  │   │   Source: Baked into image      │
│   When: Always running          │   │   When: Pre-release testing     │
└─────────────────────────────────┘   └─────────────────────────────────┘
```

**Key Insight**: Both containers run the **same image** (built from `dev` branch).
The difference is **configuration** (ports, volume mounts, use case).
"Dev" in branch name ≠ "dev" in container name—they're orthogonal concepts.

---

## Command Surface Reference

### Workflow Commands (7)

| Command           | Purpose                               | When to Use                          |
| ----------------- | ------------------------------------- | ------------------------------------ |
| `/start-work`     | Begin new ticket with proper workflow | Starting any Linear ticket           |
| `/pre-pr`         | Run complete validation before PR     | Before creating pull request         |
| `/end-work`       | Complete work session cleanly         | End of work session                  |
| `/check-workflow` | Quick status check                    | Periodically during work             |
| `/update-docs`    | Identify and update documentation     | Before PR, after significant changes |
| `/retro`          | Conduct retrospective analysis        | After completing work                |
| `/sync-linear`    | Sync current work with Linear ticket  | Keep ticket status accurate          |

### Local Operations (3)

| Command         | Purpose                             | When to Use           |
| --------------- | ----------------------------------- | --------------------- |
| `/local-sync`   | Full sync after git pull            | After pulling changes |
| `/local-deploy` | Deploy to local Docker environment  | Testing locally       |
| `/quick-fix`    | Fast-track workflow for small fixes | Minor bug fixes       |

### Remote Operations (5 Canonical)

| Command            | Purpose                              | When to Use             |
| ------------------ | ------------------------------------ | ----------------------- |
| `/remote-status`   | Check if Docker environment outdated | Before/after deployment |
| `/remote-deploy`   | Deploy latest image to Pop OS        | After merge to dev      |
| `/remote-health`   | Full health dashboard                | Troubleshooting         |
| `/remote-logs`     | View container logs                  | Debugging issues        |
| `/remote-rollback` | Rollback to previous image           | When deployment breaks  |

### Deprecated Aliases (5)

| Deprecated             | Use Instead        | Note                  |
| ---------------------- | ------------------ | --------------------- |
| `/check-docker-status` | `/remote-status`   | Legacy naming         |
| `/deploy-dev`          | `/remote-deploy`   | Ambiguous terminology |
| `/dev-health`          | `/remote-health`   | Legacy naming         |
| `/dev-logs`            | `/remote-logs`     | Legacy naming         |
| `/rollback-dev`        | `/remote-rollback` | Legacy naming         |

### Other Commands (4)

| Command           | Purpose                                  |
| ----------------- | ---------------------------------------- |
| `/test-pr-docker` | Test PR with Docker image build workflow |
| `/audit-deps`     | Run comprehensive dependency audit       |
| `/search-pattern` | Search for code patterns across codebase |

---

## Hooks Configuration

### Active Hooks (from hooks-config.json)

**Session Lifecycle:**

| Event          | Behavior                                           |
| -------------- | -------------------------------------------------- |
| `SessionStart` | Shows key commands, points to README for full list |
| `SessionEnd`   | Warns if uncommitted changes exist                 |

**Pre-Tool Hooks (Prevention):**

| Trigger               | Behavior                                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------- |
| On prompt submit      | Reminds about `WOR-{number}` branch naming                                                   |
| Before `git commit`   | Reminds about SAFe commit format                                                             |
| Before `git push`     | ❌ **BLOCKS** if on dev/master; ❌ **BLOCKS** if uncommitted changes; ⚠️ warns if behind dev |
| Before `gh pr create` | Reminds to run `/pre-pr` first                                                               |

**Why Block Direct Push to dev/master?**

This blocker was added after a workflow violation where documentation was pushed directly to dev
without a PR. Even "simple" changes benefit from the PR process:

- PRs create review opportunities
- PRs trigger CI validation before merge
- PRs maintain an audit trail
- The process is the process—no exceptions

**Post-Tool Hooks (Feedback):**

| Trigger             | Behavior                                              |
| ------------------- | ----------------------------------------------------- |
| After `ci:validate` | Reports pass/fail result                              |
| After file edit     | Auto-formats with Prettier/ESLint; reminds about docs |

### Legacy Scripts (Not Wired)

These scripts exist in `.claude/hooks/` but are not currently called by `hooks-config.json`:

- `post-commit-linear-update.sh` - Planned: Auto-update Linear on commit
- `post-push-docker-check.sh` - Planned: Check if Pop OS needs image update
- `pre-bash-rls-validation.sh` - Planned: Validate RLS context before queries
- `session-start-pattern-check.sh` - Planned: Remind about pattern discovery

**Future Work**: Wire these scripts or consolidate their logic into inline hooks.

---

## Skills Implementation (All Phases Complete)

### Phase Completion Summary

| Phase   | Scope                         | Status | Tickets          | Notes                            |
| ------- | ----------------------------- | ------ | ---------------- | -------------------------------- |
| Phase 0 | Fix Docker command/hook drift | ✅     | WOR-445          | Terminology contract, dev-first  |
| Phase 1 | First Skills                  | ✅     | WOR-447, WOR-448 | safe-workflow, pattern-discovery |
| Phase 2 | Domain Skills                 | ✅     | WOR-449, WOR-450 | rls-patterns, frontend-patterns  |
| Phase 3 | Skills Expansion              | ✅     | WOR-458          | 13 skills, hooks wired/archived  |

All phases (0-3) completed. Phases 0-2 on 2025-12-19, Phase 3 on 2025-12-20 (WOR-458 epic).

### What Are Skills?

Skills are model-invoked expertise packs. Unlike hooks (automatic) or commands (user-invoked),
Skills are invoked by Claude when it detects relevant context.

### The Harness + Skills Relationship

Skills **complement** the harness—they don't replace it:

```text
┌─────────────────────────────────────────────────────────────────┐
│                    HARNESS (What We Keep)                       │
├─────────────────────────────────────────────────────────────────┤
│  HOOKS          = Guardrails + automatic reminders              │
│  SLASH COMMANDS = Explicit user-driven workflow execution       │
│  AGENT PROFILES = Role-specific tools + model + capabilities    │
├─────────────────────────────────────────────────────────────────┤
│                    SKILLS (What We Add)                         │
├─────────────────────────────────────────────────────────────────┤
│  = Model-invoked expertise packs                                │
│  = Progressive disclosure "playbooks"                           │
│  = Domain knowledge Claude accesses autonomously                │
│  = Points to the RIGHT command/doc/pattern                      │
└─────────────────────────────────────────────────────────────────┘
```

### Progressive Disclosure Model

Skills follow a three-level progressive disclosure model from Anthropic's architecture:

1. **Level 1 (Metadata)**: SKILL.md frontmatter (name + description) pre-loaded at startup
2. **Level 2 (Full Details)**: Complete SKILL.md content loaded when Claude determines relevance
3. **Level 3+ (Modular Content)**: Additional bundled files accessed only when needed

**Critical**: The `description` field triggers skill activation—it must clearly state
**what** the skill does AND **when** to use it.

### Implemented Skills (WOR-447 through WOR-450) ✅ COMPLETE

| Skill               | Ticket  | Status | Purpose                                        | Triggers When                        |
| ------------------- | ------- | ------ | ---------------------------------------------- | ------------------------------------ |
| `safe-workflow`     | WOR-447 | ✅     | SAFe commit format, branch naming, PR workflow | Creating commits, branches, PRs      |
| `pattern-discovery` | WOR-448 | ✅     | Search docs/patterns before creating new code  | About to write significant new code  |
| `rls-patterns`      | WOR-449 | ✅     | RLS context helpers, forbid direct Prisma      | Database operations, writing queries |
| `frontend-patterns` | WOR-450 | ✅     | Clerk auth, shadcn/Radix, Next.js App Router   | UI component work                    |

**Note**: All 4 skills were implemented and merged on 2025-12-19. Skills use YAML frontmatter
format with `name` and `description` fields for Claude Code discovery.

### How Skills Complement Commands

Skills provide context; commands execute actions. Here's how they work together:

| User Intent                   | Slash Command         | Skill (Auto-Invokes)                      |
| ----------------------------- | --------------------- | ----------------------------------------- |
| "Start work on WOR-123"       | `/start-work WOR-123` | `safe-workflow` provides context          |
| "Build a dashboard component" | (none needed)         | `frontend-patterns` + `pattern-discovery` |
| "Add API for payments"        | (none needed)         | `rls-patterns` + `pattern-discovery`      |
| "Ready for PR"                | `/pre-pr`             | `safe-workflow` validates approach        |

### SAFe Methodology Alignment

Our harness already implements key patterns from our SAFe agentic workflow methodology:

| SAFe Pattern               | Current Implementation                | Skills Enhancement                                            |
| -------------------------- | ------------------------------------- | ------------------------------------------------------------- |
| Pattern Discovery Protocol | `docs/patterns/` library              | `pattern-discovery` skill auto-triggers before implementation |
| Evidence-Based Delivery    | Linear comments, session IDs          | Skills can include validation command checklists              |
| Metacognitive Tags         | `#PATH_DECISION`, `#PLAN_UNCERTAINTY` | Skills can reference tag conventions                          |
| Stop-the-Line Authority    | Agent profiles with escalation paths  | Skills don't replace this—agents still have authority         |

### Skill Manifest Structure

Skills live in `.claude/skills/{skill-name}/SKILL.md` with YAML frontmatter:

```markdown
---
name: pattern-discovery
description: WTFB pattern library discovery for pattern-first development. Use BEFORE implementing any new feature, creating components, writing API routes, or adding database operations. Ensures existing patterns are checked first before writing new code.
---

# Pattern Discovery Skill

## Purpose

Enforce pattern-first development by checking the WTFB pattern library
before implementing new functionality.

## When to Use

Invoke this skill when:

- About to create a new API route
- About to create a new UI component
- About to add database operations
- User asks "how do I implement..." or "how should I build..."

## Pattern Discovery Protocol

[Detailed implementation guidance follows...]
```

**Critical**: The `description` field triggers skill activation—it must clearly state
**what** the skill does AND **when** to use it. Claude uses this field to decide
whether to load the full skill content.

**Known Issue (v2.0.73)**: The `/skills` command has a display bug (GitHub Issue #14733).
Skills work correctly but won't appear in `/skills` output. Workaround: Ask Claude directly
"What skills are available?"

---

## Phase 3: Skills Expansion (COMPLETE)

Phase 3 completed on 2025-12-20 via WOR-458 epic. Delivered 13 new skills,
wired 2 hooks, archived 2 redundant hooks, and evaluated MCP tool wrapping.

### 3.1 Legacy Hook Script Wiring (COMPLETE - WOR-459, WOR-463)

**Status**: ✅ Completed 2025-12-20

Four shell scripts existed in `.claude/hooks/`. Evaluation complete:

| Script                           | Purpose                                    | Decision | Reason                                          |
| -------------------------------- | ------------------------------------------ | -------- | ----------------------------------------------- |
| `post-commit-linear-update.sh`   | Auto-update Linear ticket with commit hash | ✅ WIRED | WOR-459: Provides actionable automation         |
| `post-push-docker-check.sh`      | Check if Pop OS needs Docker image update  | ✅ WIRED | WOR-459: Provides actionable automation         |
| `pre-bash-rls-validation.sh`     | Warn on DB ops without RLS context         | ARCHIVED | WOR-463: Redundant with ESLint RLS rules        |
| `session-start-pattern-check.sh` | Remind about pattern library               | ARCHIVED | WOR-463: Redundant with pattern-discovery skill |

**Wired hooks**: See `hooks-config.json` lines 57-77 for PostToolUse handlers.

**Archived hooks**: See `.claude/hooks/archive/ARCHIVE_DECISIONS.md` for full reasoning.

### 3.2 MCP Tool Wrapping Evaluation (COMPLETE - WOR-464)

**Status**: ✅ Completed 2025-12-20 - Decision: **Keep as Bash**

Evaluated four scripts against trigger thresholds. No triggers met:

| Script                | Trigger Met? | Decision     |
| --------------------- | ------------ | ------------ |
| `dev-docker.sh`       | ❌ No        | Keep as Bash |
| `backup-local-db.sh`  | ❌ No        | Keep as Bash |
| `restore-local-db.sh` | ❌ No        | Keep as Bash |
| `safe-docker-down.sh` | ❌ No        | Keep as Bash |

**Trigger thresholds** (none met): >3 bash failures, >500 tokens per invocation, user friction.
**Future**: Re-evaluate if any trigger threshold is met. See WOR-464 for monitoring plan.

### 3.3 Additional Skills (COMPLETE - WOR-460, WOR-461, WOR-462)

**Status**: ✅ Completed 2025-12-20 - 13 new skills created

#### High Value Skills (WOR-460)

| Skill                    | Status | Purpose                                      |
| ------------------------ | ------ | -------------------------------------------- |
| `stripe-patterns`        | ✅     | Payment integration patterns, webhook safety |
| `testing-patterns`       | ✅     | Unit/integration/E2E test conventions        |
| `linear-sop`             | ✅     | Linear ticket best practices                 |
| `orchestration-patterns` | ✅     | Agent loop patterns, evidence-based delivery |

**`stripe-patterns`** would cover:

- Checkout session creation with idempotency keys
- Webhook signature verification patterns
- Subscription lifecycle handling
- Error recovery and retry patterns
- Test mode vs live mode safety

**`testing-patterns`** would cover:

- Jest unit test structure and mocking patterns
- Playwright E2E patterns (page objects, fixtures)
- RLS-aware database test setup
- Payment testing with Stripe test mode
- CI-friendly test configuration

**`linear-sop`** would cover:

- Safe fields (never modify directly: ID, created, reporter)
- Acceptance criteria in description format
- UUID discipline for external links
- Status workflow (Backlog → In Progress → Done)
- Comment formatting conventions

#### Medium Value Skills (WOR-462)

| Skill             | Status | Purpose                                 |
| ----------------- | ------ | --------------------------------------- |
| `confluence-docs` | ✅     | Documentation templates and standards   |
| `deployment-sop`  | ✅     | Deployment workflow and rollback        |
| `git-advanced`    | ✅     | Complex git operations (rebase, bisect) |
| `api-patterns`    | ✅     | API route structure and error handling  |

#### Lower Priority (Defer)

| Skill              | Purpose                       | Notes                                       |
| ------------------ | ----------------------------- | ------------------------------------------- |
| `prisma-patterns`  | Prisma ORM beyond RLS context | Mostly covered by `rls-patterns`            |
| `tailwind-sop`     | Tailwind CSS conventions      | Covered partially by `frontend-patterns`    |
| `posthog-advanced` | Advanced analytics patterns   | Basic events covered in `frontend-patterns` |

#### SAFe Subagent Skills (WOR-461)

| Skill                | Status | Target Agents     | Purpose                                              |
| -------------------- | ------ | ----------------- | ---------------------------------------------------- |
| `release-patterns`   | ✅     | RTE               | PR templates, CI validation, deployment coordination |
| `agent-coordination` | ✅     | TDM               | Agent assignment matrix, escalation patterns         |
| `migration-patterns` | ✅     | Data Engineer     | Schema migration SOPs, rollback procedures           |
| `security-audit`     | ✅     | Security Engineer | Security checklist patterns, vulnerability scanning  |
| `spec-creation`      | ✅     | BSA               | Spec templates, acceptance criteria formatting       |

**`release-patterns`** would cover:

- PR title/body templates with Linear references
- CI validation sequence (type-check → lint → test → build)
- Rebase-first workflow enforcement
- Deployment coordination between dev and staging

**`agent-coordination`** would cover:

- Agent assignment matrix (who handles what)
- Blocker escalation paths
- Multi-agent handoff patterns
- Evidence attachment templates for Linear

These skills would reduce agent training time and ensure consistent behavior across the
11 specialized agents in the SAFe team.

### 3.4 SAFe Role Expansion Vision

Each agent maps to real-world SAFe roles. This section documents the **full vision** for
agent capabilities beyond current implementation.

#### RTE (Release Train Engineer) → SAFe: Release Train Engineer

**Current**: PR creation, CI/CD validation, merge coordination

**Expanded Vision**:

- **Deployment Orchestration**: Execute full deployment lifecycle
  - `dev` → Pop OS dev container (port 3000)
  - `staging` → Pop OS staging container (port 3001)
  - `production` → Coolify production (master branch merge)
- **Release Coordination**: Coordinate PI releases across sprint boundaries
- **Deployment Verification**: Run smoke tests after each environment promotion
- **Rollback Execution**: Execute rollback procedures when deployments fail
- **Release Notes**: Generate release notes from Linear tickets

**Operational SOPs**:

- `docs/ci-cd/Semantic-Release-Deployment-SOP.md` - Production release process
- `docs/sop/STAGING-UAT-RELEASE-SOP.md` - Staging validation checklist

**Skills Needed**: `release-patterns`, `deployment-sop`, `rollback-patterns`

#### TDM (Technical Delivery Manager) → SAFe: Delivery Manager (Reactive Role)

**Current (v1.3 SOP)**: Reactive blocker resolution, Linear updates, evidence tracking

**IMPORTANT**: TDM is NOT an orchestrator. ARCHitect-in-CLI is the primary orchestrator
(see `docs/workflow/ARCHITECT_IN_CLI_ROLE.md` v1.3).

**TDM Responsibilities** (per `docs/sop/AGENT_WORKFLOW_SOP.md` v1.3):

- **Monitor Progress**: Read session archaeology, Linear tickets, PR comments
- **Identify Blockers**: Search for `FAILED|error|blocked` in session history
- **Escalate Blockers**: Invoke appropriate specialist to resolve
- **Track Evidence**: Attach session IDs, test results, reports to Linear

**What TDM Does NOT Do** (v1.3):

- ❌ Proactively orchestrate feature implementation (ARCHitect-in-CLI's job)
- ❌ Assign work to specialists (ARCHitect-in-CLI's job)
- ❌ Run coordination checks like git status (removed Bash tool)

**Expanded Vision** (Future):

- **Sprint Facilitation**: Coordinate daily standups, retrospectives
- **PI Planning Support**: Prepare capacity, dependencies, risks for PI planning
- **Cross-Team Dependencies**: Track and resolve inter-team blockers
- **Metrics & Reporting**: Velocity tracking, burndown charts, cycle time

**Operational SOPs**:

- `docs/sop/AGENT_WORKFLOW_SOP.md` v1.3 - TDM reactive role definition
- `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md` - Agent selection guidance
- `docs/workflow/ARCHITECT_IN_CLI_ROLE.md` - Primary orchestrator definition

**Skills Needed**: `agent-coordination`, `linear-sop`

#### BSA (Business Systems Analyst) → SAFe: Product Owner Support

**Current**: Requirements decomposition, specs, acceptance criteria

**Expanded Vision**:

- **Backlog Refinement**: Break epics → features → stories
- **Stakeholder Communication**: Translate business needs to technical specs
- **Acceptance Testing**: Define and validate acceptance criteria
- **Demo Preparation**: Prepare demo scripts for sprint reviews
- **PI Objectives**: Help define PI objectives from business outcomes

**Skills Needed**: `spec-creation`, `acceptance-patterns`, `demo-scripts`

#### System Architect → SAFe: System Architect

**Current**: Pattern validation, architectural decisions, Stage 1 PR review, migration approval

**Expanded Vision**:

- **Architecture Runway**: Maintain technical runway for upcoming features
- **Stage 1 PR Review**: Technical/architectural validation after RTE creates PR
- **Migration Approval**: Approve database schema changes per RLS_DATABASE_MIGRATION_SOP
- **Enabler Creation**: Define architectural enablers for PI planning
- **NFR Definition**: Define non-functional requirements (performance, security, scalability)
- **Technical Debt Management**: Track and prioritize technical debt
- **Integration Architecture**: Design cross-system integrations

**Operational SOPs**:

- `docs/sop/AGENT_WORKFLOW_SOP.md` - Stage 1 PR review responsibilities
- `docs/database/RLS_DATABASE_MIGRATION_SOP.md` - Migration approval authority

**Skills Needed**: `architecture-runway`, `enabler-patterns`, `nfr-validation`

#### QAS (Quality Assurance Specialist) → SAFe: QA Engineer

**Current**: Test execution using patterns, acceptance validation

**Expanded Vision**:

- **Regression Testing**: Maintain and execute regression test suite
- **Performance Testing**: Load testing, response time validation
- **Accessibility Testing**: WCAG 2.1 AA compliance validation
- **Cross-Browser Testing**: Browser compatibility verification
- **Release Certification**: Sign-off on releases before production

**Skills Needed**: `testing-patterns`, `regression-suite`, `performance-testing`

#### Security Engineer → SAFe: Security Champion / AppSec

**Current**: RLS validation, vulnerability scanning, security audits

**Expanded Vision**:

- **Threat Modeling**: Identify and document security threats
- **Compliance Audits**: GDPR, SOC2, security compliance verification
- **Security Sign-Off**: Approve releases from security perspective
- **Incident Response**: Security incident investigation and remediation
- **Penetration Testing**: Coordinate and verify pen test results

**Skills Needed**: `security-audit`, `threat-modeling`, `compliance-patterns`

#### BE Developer → SAFe: Backend Developer

**Current**: API implementation with RLS patterns

**Expanded Vision**:

- **API Versioning**: Manage backward-compatible API changes
- **External Integrations**: Stripe, Clerk, PostHog integration patterns
- **Webhook Reliability**: Idempotency, retry logic, dead letter queues
- **Performance Optimization**: Query optimization, caching strategies
- **Background Jobs**: Job queue patterns, scheduled tasks

**Skills Needed**: `rls-patterns`, `api-versioning`, `webhook-patterns`

#### FE Developer → SAFe: Frontend Developer

**Current**: UI implementation with frontend patterns

**Expanded Vision**:

- **Accessibility Compliance**: WCAG 2.1 AA implementation
- **Performance Optimization**: Core Web Vitals, bundle optimization
- **Design System**: Component library maintenance
- **State Management**: Complex state patterns (forms, caching)
- **Error Boundaries**: Graceful error handling and recovery

**Skills Needed**: `frontend-patterns`, `accessibility-patterns`, `performance-patterns`

#### Data Engineer → SAFe: Data/Platform Engineer

**Current**: Schema migrations, RLS policies

**MANDATORY READING**: `docs/database/RLS_DATABASE_MIGRATION_SOP.md`
All database migrations MUST follow RLS procedures. ARCHitect approval required for production migrations.

**Expanded Vision**:

- **PROD Migration Execution**: Execute production migrations with ARCHitect present
- **Data Governance**: Data retention policies, PII handling
- **Backup & Recovery**: Database backup verification, disaster recovery
- **Schema Evolution**: Backward-compatible schema changes
- **Performance Tuning**: Index optimization, query analysis

**Operational SOPs**:

- `docs/database/RLS_DATABASE_MIGRATION_SOP.md` - MANDATORY for all schema changes
- `docs/database/MIGRATION_DEPLOYMENT_WORKFLOW.md` - Migration deployment process

**Skills Needed**: `migration-patterns`, `data-governance`, `prod-migration-sop`

#### Data Provisioning Engineer → SAFe: Data/ETL Engineer

**Current**: Data pipelines, ETL processes

**Expanded Vision**:

- **Data Quality Monitoring**: Automated data quality checks
- **Data Lineage**: Track data flow from source to destination
- **ETL Reliability**: Error recovery, retry logic, alerting
- **Data Validation**: Completeness, accuracy, consistency checks
- **Reporting Pipelines**: Analytics data preparation

**Skills Needed**: `etl-patterns`, `data-quality`, `data-lineage`

#### Tech Writer → SAFe: Technical Writer

**Current**: Documentation creation with patterns

**Expanded Vision**:

- **Release Notes**: Generate release notes from Linear tickets
- **User Guides**: End-user documentation for features
- **API Documentation**: OpenAPI specs, endpoint documentation
- **Knowledge Base**: Searchable documentation for common issues
- **Onboarding Docs**: Developer onboarding materials

**Skills Needed**: `documentation-patterns`, `release-notes`, `api-docs`

#### The Deployment Pipeline Vision

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SAFe Agentic Deployment Pipeline                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  DEVELOPMENT PHASE                                                           │
│  ├─ BSA: Creates spec with acceptance criteria                              │
│  ├─ System Architect: Reviews architectural approach                        │
│  ├─ BE/FE/DE Developers: Implement using patterns + skills                  │
│  ├─ Security Engineer: Validates RLS, scans vulnerabilities                 │
│  └─ QAS: Executes test suite, validates acceptance criteria                 │
│                                                                              │
│  RELEASE PHASE (RTE Orchestrates)                                           │
│  ├─ RTE: Creates PR, runs /pre-pr validation                                │
│  ├─ System Architect: Stage 1 technical review                              │
│  ├─ ARCHitect-in-CLI: Stage 2 comprehensive review                          │
│  ├─ Scott (HITL): Stage 3 final approval + merge                            │
│  │                                                                           │
│  │  ┌─ DEPLOYMENT ORCHESTRATION ─────────────────────────────┐              │
│  │  │                                                         │              │
│  │  │  1. DEV (Pop OS :3000)                                  │              │
│  │  │     └─ RTE: /remote-deploy → smoke test → ✅            │              │
│  │  │                                                         │              │
│  │  │  2. STAGING (Pop OS :3001)                              │              │
│  │  │     └─ RTE: /staging-deploy → QAS validates → ✅        │              │
│  │  │                                                         │              │
│  │  │  3. PRODUCTION (Coolify)                                │              │
│  │  │     └─ RTE: dev→master PR → Scott approves → ✅         │              │
│  │  │                                                         │              │
│  │  └─────────────────────────────────────────────────────────┘              │
│  │                                                                           │
│  └─ Tech Writer: Generates release notes                                    │
│                                                                              │
│  POST-RELEASE                                                                │
│  ├─ TDM: Updates Linear tickets, notifies stakeholders                      │
│  ├─ QAS: Runs production smoke tests                                        │
│  └─ Security Engineer: Monitors for security issues                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

This vision represents the **full SAFe agentic workflow** where each agent has
specialized skills and coordinates through well-defined handoffs.

### 3.5 Decision Framework for New Skills

Before creating a new skill, ask:

1. **Is it pattern-based?** Skills work best for "how to do X the WTFB way"
2. **Is it frequently needed?** Skills should address recurring contexts
3. **Is it currently causing errors?** Skills can prevent repeated mistakes
4. **Is it covered elsewhere?** Check existing skills, ESLint rules, and docs
5. **Is it actionable?** Skills should provide copy-paste patterns, not just theory

**Anti-patterns to avoid:**

- Skills that duplicate slash commands (use commands for actions)
- Skills that duplicate hooks (use hooks for automatic enforcement)
- Skills too generic to trigger reliably (vague descriptions)
- Skills with no code patterns (just prose explanations)

---

## Section 4: Operational Standard Operating Procedures

This section references the SOPs that govern how the harness and agents operate in practice.
These documents are the authoritative sources for operational procedures.

### 4.1 Deployment SOPs

| SOP              | Location                                        | Agent     | Purpose                               |
| ---------------- | ----------------------------------------------- | --------- | ------------------------------------- |
| Semantic Release | `docs/ci-cd/Semantic-Release-Deployment-SOP.md` | RTE       | Production releases via master branch |
| Staging UAT      | `docs/sop/STAGING-UAT-RELEASE-SOP.md`           | RTE + QAS | Pre-production validation gate        |

### 4.2 Agent Workflow SOPs

| SOP                   | Location                                       | Purpose                                   |
| --------------------- | ---------------------------------------------- | ----------------------------------------- |
| Agent Workflow v1.3   | `docs/sop/AGENT_WORKFLOW_SOP.md`               | TDM reactive role, orchestration patterns |
| Agent Configuration   | `docs/sop/AGENT_CONFIGURATION_SOP.md`          | Tool restrictions, model selection        |
| ARCHitect-in-CLI Role | `docs/workflow/ARCHITECT_IN_CLI_ROLE.md`       | Primary orchestrator definition           |
| TDM Assignment Matrix | `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md` | Agent selection guidance                  |

### 4.3 Database SOPs

| SOP                    | Location                                         | Agent         | Purpose                      |
| ---------------------- | ------------------------------------------------ | ------------- | ---------------------------- |
| RLS Database Migration | `docs/database/RLS_DATABASE_MIGRATION_SOP.md`    | Data Engineer | MANDATORY for schema changes |
| Migration Deployment   | `docs/database/MIGRATION_DEPLOYMENT_WORKFLOW.md` | Data Engineer | Migration deployment process |
| Disaster Recovery      | `docs/operations/DISASTER_RECOVERY_PLAYBOOK.md`  | RTE + DPE     | Database disaster recovery   |

### 4.4 Quick Reference

For daily agent workflow, see:

- **AGENTS.md** - Agent team quick reference (companion to this whitepaper)
- **CONTRIBUTING.md** - Complete developer workflow guide
- **CLAUDE.md** - Development commands and architecture overview

---

## Lessons Learned

### 1. Documentation Drifts Faster Than You Think

Our README was 2+ months stale. Commands were added without updating docs.
**Mitigation**: Include documentation updates in the Definition of Done for any command change.

### 2. Terminology Collisions Compound Over Time

"Dev" meant three different things. This caused confusion during incidents.
**Mitigation**: Establish explicit terminology contracts early. Use grep to find and standardize
terms across all files.

### 3. Unwired Code Creates False Confidence

Scripts existed in `.claude/hooks/` that developers assumed were running. They weren't.
**Mitigation**: Audit wiring regularly. If code isn't called, either wire it or document
it as "planned."

### 4. Hooks Should Be Mostly Non-Blocking

Our push blocker is the exception—it prevents a specific dangerous action
(pushing uncommitted changes). Most hooks should be reminders, not blockers.
**Mitigation**: Default to warnings. Use blockers only for truly dangerous operations.

### 5. Group Commands by Mental Model

Users think in workflows, not alphabetical order. Grouping commands by purpose
(Workflow, Local, Remote) makes the command surface learnable.
**Mitigation**: Organize by use case, not by implementation detail.

### 6. Skills Knowledge Doesn't Guarantee Compliance

Even with the `safe-workflow` skill loaded and knowing the process, we still pushed
directly to dev "because it's just docs." Skills provide knowledge but can't enforce behavior.
**Mitigation**: Critical workflow steps need hooks with blockers, not just skills with reminders.
We added a blocker that prevents pushing to dev/master directly.

### 7. Fix Workflow Violations Properly

When a workflow is violated (e.g., direct push to dev), the correct response is to:

1. Revert the violation
2. Create a proper feature branch
3. Cherry-pick the work to the branch
4. Create a PR following the standard process

**Mitigation**: Never "let it slide" because it was already done. The process exists for reasons.

---

## Appendix: Migration Checklist

Use this checklist when modernizing your own Claude Code harness:

### Audit Phase

- [ ] List all files in `.claude/commands/`
- [ ] List all hooks in `hooks-config.json`
- [ ] List all scripts in `.claude/hooks/`
- [ ] Compare hook scripts to hooks-config.json (find unwired scripts)
- [ ] Read each command file, note purposes and dependencies
- [ ] Compare README to actual command count
- [ ] Search for terminology inconsistencies (grep for ambiguous terms)

### Fix Phase

- [ ] Establish terminology contract for ambiguous terms
- [ ] Update all commands to use consistent terminology
- [ ] Convert deprecated commands to thin aliases
- [ ] Update README with complete command list
- [ ] Rewrite hooks section to match reality
- [ ] Label unwired scripts as "Legacy" or wire them

### Document Phase

- [ ] Create architecture diagram (Hooks → Commands → Skills)
- [ ] Group commands by use case
- [ ] Document each hook's trigger and behavior
- [ ] Update SessionStart message to reference documentation
- [ ] Add "Last Updated" timestamp to README

### Validate Phase

- [ ] Run each command, verify it works as documented
- [ ] Trigger each hook, verify expected behavior
- [ ] Have someone unfamiliar with the harness review docs
- [ ] Create Linear tickets for remaining gaps

---

## Appendix: Artifact Status Snapshot

This table from our audit shows which files were current vs. stale at time of assessment:

| Artifact                                  | Last Updated | Status     | Notes                                           |
| ----------------------------------------- | -----------: | ---------- | ----------------------------------------------- |
| `.claude/hooks-config.json`               |   2025-11-05 | ✅ Current | Core workflow guardrails aligned                |
| `.claude/README.md`                       |   2025-10-14 | ⚠️ Stale   | Didn't reflect expanded command surface         |
| `.claude/hooks/post-push-docker-check.sh` |   2025-11-05 | ❌ Drift   | Still inspected old container names             |
| `.claude/commands/local-deploy.md`        |   2025-12-08 | ✅ Current | Explicit dual mode, correct ports               |
| `.claude/commands/remote-status.md`       |   2025-12-08 | ✅ Current | Uses updated names, dual-mode aware             |
| `.claude/commands/check-docker-status.md` |   2025-12-17 | ❌ Drift   | Recently added but used old container name      |
| `.claude/commands/deploy-dev.md`          |   2025-12-17 | ❌ Drift   | Recently added, conflicts with `/remote-deploy` |
| `.claude/commands/dev-health.md`          |   2025-12-17 | ❌ Drift   | Recently added, conflicts with `/remote-health` |

**Lesson**: Recent modification date doesn't guarantee correctness.
Commands added without reviewing existing patterns caused terminology drift.

---

## References

### Internal Documentation

**Harness & Skills:**

- **Harness Audit**: `docs/agent-outputs/workflow-analysis/HARNESS_AND_SKILLS_AUDIT_2025-12-18.md`
- **README**: `.claude/README.md`
- **Hooks Config**: `.claude/hooks-config.json`

**Operational SOPs:**

- **Agent Workflow SOP v1.3**: `docs/sop/AGENT_WORKFLOW_SOP.md`
- **Agent Configuration SOP**: `docs/sop/AGENT_CONFIGURATION_SOP.md`
- **Semantic Release SOP**: `docs/ci-cd/Semantic-Release-Deployment-SOP.md`
- **Staging UAT SOP**: `docs/sop/STAGING-UAT-RELEASE-SOP.md`
- **RLS Migration SOP**: `docs/database/RLS_DATABASE_MIGRATION_SOP.md`

**Role Definitions:**

- **ARCHitect-in-CLI Role**: `docs/workflow/ARCHITECT_IN_CLI_ROLE.md`
- **TDM Assignment Matrix**: `docs/workflow/TDM_AGENT_ASSIGNMENT_MATRIX.md`

**Quick Reference:**

- **AGENTS.md**: `/AGENTS.md` (companion quick-reference to this whitepaper)
- **CONTRIBUTING.md**: `/CONTRIBUTING.md` (complete developer workflow)
- **CLAUDE.md**: `/CLAUDE.md` (development commands and architecture)

### External Resources

- **Claude Code Docs**: [Anthropic Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
- **Claude Code SDK**: [Claude Code SDK](https://docs.anthropic.com/en/docs/claude-code/sdk)
- **Claude Code GitHub Actions**: [Claude Code GitHub Actions](https://docs.anthropic.com/en/docs/claude-code/github-actions)
- **Claude Code Action (GitHub)**: [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)
- **Agent Skills Announcement**: [Agent Skills](https://www.anthropic.com/news/skills)
- **Equipping Agents with Skills**: [Equipping agents for the real world with agent skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- **Effective Harnesses**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- **Code Execution with MCP**: [Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- **Building Effective Agents**: [Building effective agents](https://www.anthropic.com/index/building-effective-agents)
- **Frontend Design Skills**: [Improving frontend design through skills](https://www.claude.com/blog/improving-frontend-design-through-skills)
- **SAFe Agentic Workflow**: [bybren-llc/wtfb-safe-agentic-workflow](https://github.com/bybren-llc/wtfb-safe-agentic-workflow)

---

## Changelog

| Version | Date       | Changes                                                                    |
| ------- | ---------- | -------------------------------------------------------------------------- |
| 1.2     | 2025-12-20 | Phase 3 complete (WOR-458): 13 skills, hooks wired/archived, MCP evaluated |
| 1.1     | 2025-12-19 | Phase 0-2 complete, added Phase 3 roadmap, updated skill format reference  |
| 1.0     | 2025-12-19 | Initial release covering WOR-445 and WOR-446                               |

---

**Contributing**: This document is part of the WTFB Claude Code harness.
Submit improvements via PR to this repository.
