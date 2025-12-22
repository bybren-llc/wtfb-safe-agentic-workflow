# Claude Code Harness for Multi-Agent Team Workflows

**A Production-Tested Three-Layer Architecture for Coordinated AI Teams**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-green.svg)](whitepaper/README.md)
[![Production Validated](https://img.shields.io/badge/5+%20months-production%20validated-brightgreen.svg)](whitepaper/data/REAL-PRODUCTION-DATA-SYNTHESIS.md)
[![Skills](https://img.shields.io/badge/skills-17%20model--invoked-purple.svg)](.claude/skills/)
[![Commands](https://img.shields.io/badge/commands-23%20workflows-orange.svg)](.claude/commands/)

> **LLM Context**: Get the entire repository as LLM-ready context using [GitIngest](https://gitingest.com/) with your fork.

---

## What This Is

A **production-tested Claude Code harness** for teams that want structured AI workflows.

**Built on SAFe methodology** (Scaled Agile Framework), adapted for AI agent teams.
Works for any team with repeatable processes: Software, Marketing, Research, Legal, Operations.

Includes:

- **17 Model-Invoked Skills** - Domain expertise Claude loads automatically
- **23 Slash Commands** - Workflow automation for common tasks
- **11 SAFe Agent Profiles** - Specialized roles with clear boundaries
- **Three-Layer Architecture** - Hooks → Commands → Skills

> **Origin**: 5 months production use, 169 issues, 2,193 commits. Implements patterns from
> [6 Anthropic engineering papers](#implementing-anthropics-research) and [SAFe methodology](https://scaledagileframework.com/).

---

## Quick Start (30 seconds)

```bash
# Copy harness to your project
cp -r .claude/ /your-project/.claude/

# Customize placeholders
edit .claude/SETUP.md  # Replace {TICKET_PREFIX}, {PROJECT_NAME}

# Start working
/start-work TICKET-123
```

**That's it.** Claude now has your team's workflow patterns built in.

---

## The Three-Layer Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│                      Claude Code Harness                              │
├──────────────────────────────────────────────────────────────────────┤
│  LAYER 1: HOOKS     │ Automatic guardrails (format checks, blockers) │
│  LAYER 2: COMMANDS  │ User-invoked workflows (/start-work, /pre-pr)  │
│  LAYER 3: SKILLS    │ Model-invoked expertise (pattern discovery)    │
└──────────────────────────────────────────────────────────────────────┘
```

> **Philosophy**: Process as _service_, not _control_.
> Everything exists to reduce cognitive load on already-solved problems.

---

## Choose Your Path

<details>
<summary><strong>For Practitioners</strong> - I want to use this today</summary>

### Getting Started

1. Copy `.claude/` directory to your project
2. Edit placeholders in `.claude/SETUP.md`
3. Run `/start-work` on your first ticket

### Key Commands

| Command           | Purpose                           |
| ----------------- | --------------------------------- |
| `/start-work`     | Begin ticket with proper workflow |
| `/pre-pr`         | Validate before pull request      |
| `/end-work`       | Complete session cleanly          |
| `/check-workflow` | Quick status check                |

### Full Command Reference

**Workflow** (7): `/start-work`, `/pre-pr`, `/end-work`, `/check-workflow`, `/update-docs`, `/retro`, `/sync-linear`

**Local Operations** (3): `/local-sync`, `/local-deploy`, `/quick-fix`

**Remote Operations** (5): `/remote-status`, `/remote-deploy`, `/remote-health`, `/remote-logs`, `/remote-rollback`

[Complete Setup Guide](.claude/SETUP.md)

</details>

<details>
<summary><strong>For Researchers</strong> - I want to understand the methodology</summary>

### Research Foundation

This harness implements patterns from 6 Anthropic engineering papers (see [below](#implementing-anthropics-research)).

### Key Documents

- [Executive Summary](whitepaper/section-1-executive-summary.md) - 5 min overview
- [Case Studies](whitepaper/section-6-case-studies.md) - Real production examples
- [Limitations](whitepaper/section-7-limitations-honest-assessment.md) - Honest assessment
- [Background & Related Work](whitepaper/section-3-background-related-work.md) - Academic context

### Meta-Circular Validation

The methodology caught its own fabricated data before publication.
See [Validation Summary](whitepaper/validation/VALIDATION-SUMMARY.md).

[Complete Whitepaper](whitepaper/README.md) (12 sections)

</details>

<details>
<summary><strong>For Leaders</strong> - I want ROI and risk assessment</summary>

### Production Results

| Metric           | Value              | Source     |
| ---------------- | ------------------ | ---------- |
| Issues Completed | 169                | Linear     |
| Velocity Growth  | 14× (Cycle 3→8)    | Linear     |
| Commits          | 2,193 (10.3/day)   | GitHub     |
| PR Merge Rate    | 90.9% (159/175)    | GitHub     |
| Documentation    | 136 docs, 36 specs | Repository |

### Adoption Requirements

- Claude Code CLI installed
- Git repository
- Team buy-in for structured workflows

### Known Limitations

- Single-team validation only
- Claude Code specific (may need adaptation for other tools)

[Implementation Guide](whitepaper/section-9-implementation-guide.md)

</details>

---

## Implementing Anthropic's Research

This harness directly implements patterns from Anthropic's engineering papers:

| Paper                                                                                                       | What We Implement          |
| ----------------------------------------------------------------------------------------------------------- | -------------------------- |
| [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)                | 11-agent team structure    |
| [Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)    | Three-layer architecture   |
| [Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) | 17 model-invoked skills    |
| [Skills Announcement](https://www.anthropic.com/news/skills)                                                | Skill trigger patterns     |
| [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)                    | Tool restrictions per role |

> "The best harness is one you forget exists." — [Agent Perspective](docs/whitepapers/CLAUDE-CODE-HARNESS-AGENT-PERSPECTIVE.md)

---

## SAFe Foundation

<details>
<summary><strong>For Agile Practitioners</strong> - Deep dive into SAFe integration</summary>

This harness maps SAFe roles to AI agents:

| SAFe Role                | Agent            | Responsibility                    |
| ------------------------ | ---------------- | --------------------------------- |
| Business Systems Analyst | BSA              | Requirements, acceptance criteria |
| System Architect         | System Architect | Architecture decisions, ADRs      |
| Product Owner            | POPM (human)     | Final approval on deliverables    |
| Scrum Master             | TDM              | Coordination, blocker escalation  |
| Release Train Engineer   | RTE              | CI/CD, release coordination       |

### SAFe Concepts Implemented

- **Epic → Feature → Story → Enabler** hierarchy in specs
- **Sprint cycles** with velocity tracking
- **Evidence-based delivery** with Linear integration
- **Specs-driven workflow** - BSA plans, developers execute

[Complete SAFe Integration](whitepaper/section-5-architecture-implementation.md)

</details>

---

## The 11-Agent Team

| Agent             | Role                    | When to Use               |
| ----------------- | ----------------------- | ------------------------- |
| BSA               | Requirements & specs    | Starting any feature      |
| System Architect  | Architecture review     | Significant changes       |
| FE Developer      | Frontend implementation | UI components             |
| BE Developer      | Backend implementation  | API routes, server logic  |
| Data Engineer     | Database & migrations   | Schema changes            |
| QAS               | Quality assurance       | Test validation           |
| Security Engineer | Security validation     | RLS, vulnerability checks |
| Tech Writer       | Documentation           | Guides, technical content |
| DPE               | Data provisioning       | Test data, seeds          |
| RTE               | Release coordination    | CI/CD, deployments        |
| TDM               | Coordination            | Blockers, escalation      |

See [AGENTS.md](AGENTS.md) for complete reference with invocation examples.

---

## Domain Adaptation Guide

The harness patterns work beyond software engineering:

### Marketing Team Example

| SWE Concept     | Marketing Adaptation  |
| --------------- | --------------------- |
| BSA (specs)     | Campaign Brief Writer |
| Code Review     | Asset Review          |
| `/pre-pr`       | `/pre-launch`         |
| Pattern Library | Brand Guidelines      |

### Research Team Example

| SWE Concept   | Research Adaptation  |
| ------------- | -------------------- |
| User Stories  | Research Questions   |
| Test Cases    | Validation Criteria  |
| CI/CD         | Peer Review Pipeline |
| Documentation | Literature Notes     |

---

## What Makes This Different

### Round Table Philosophy

Human and AI input have equal weight. No hierarchy, just expertise.

### Stop-the-Line Authority

Any agent can halt work for architectural or security concerns.

### Pattern Discovery Protocol

"Search First, Reuse Always, Create Only When Necessary"

### Evidence-Based Delivery

All work requires verifiable evidence. No "trust me, it works."

---

## Important Caveats

**Version 2.0** - Production-tested but with known limitations:

- **Production validated**: 5+ months, 169 issues, 2,193 commits
- **Generalized**: Placeholders for project-specific values
- **Single-team validation**: Multi-team scalability not yet proven
- **Claude Code specific**: May require adaptation for other tools
- **Domain examples**: Non-SWE adaptations are theoretical (documented, not validated)

See [Limitations](whitepaper/section-7-limitations-honest-assessment.md) for honest assessment.

---

## Repository Structure

```text
.claude/                 # Claude Code harness configuration
├── commands/            # 23 slash commands for workflow automation
├── skills/              # 17 model-invoked skills for domain expertise
├── agents/              # 11 SAFe agent profiles
└── SETUP.md             # Installation and customization guide

whitepaper/              # Complete whitepaper (12 sections)
├── data/                # Supporting data and metrics
└── validation/          # Meta-circular validation evidence

docs/                    # Additional documentation
├── whitepapers/         # Harness architecture and philosophy
└── onboarding/          # Getting started guides
```

---

## Meta-Note: Self-Validation

This methodology was **validated by itself**: 7 SAFe agents performed meta-circular validation of the whitepaper and caught critical fabricated data before publication.

See [Validation Summary](whitepaper/validation/VALIDATION-SUMMARY.md) for the complete story.

**The methodology caught its own problems.** That's the proof it works.

---

## Citation

Download: [CITATION.bib](CITATION.bib) | [CITATION.cff](CITATION.cff)

### APA 7th Edition

```text
Graham, J. S., & WTFB Development Team. (2025). Evidence-based multi-agent
development: A SAFe framework implementation with Claude Code [White paper].
https://github.com/ByBren-LLC/WTFB-SAFe-Agentic-Workflow
```

---

## Contributing

We welcome contributions:

- **Patterns**: Share production-tested patterns
- **Case Studies**: Document your implementation experience
- **Research**: Explore open questions from Section 10
- **Improvements**: Suggest methodology enhancements

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Contact

- **Website**: [WordsToFilmBy.com](https://WordsToFilmBy.com)
- **Email**: [scott@wordstofilmby.com](mailto:scott@wordstofilmby.com)
- **Author**: J. Scott Graham (cheddarfox)
- **Historical Context**: Evolved from [Auggie's Architect Handbook](https://github.com/cheddarfox/auggies-architect-handbook)

---

**Version**: 2.0 (December 2025)
**Status**: Production-validated, academically honest, publication-ready

**This repository contains the whitepaper, complete working template, AND a battle-tested Claude Code harness for implementing the methodology!**
