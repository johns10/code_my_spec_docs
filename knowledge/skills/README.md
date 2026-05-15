# Agent Skills — Knowledge Base

Reference material for designing skills/agents that work across Claude Code, OpenCode, and Codex.

Researched 2026-05-12. All claims linked. Verify with source URLs before relying on a specific frontmatter field or path — these three platforms move fast.

## What you're looking for

| You want to... | Read |
|---|---|
| Design a skill for one platform only | [claude_code.md](claude_code.md) / [opencode.md](opencode.md) / [codex.md](codex.md) |
| Ship one skill that works on all three | [cross_platform.md](cross_platform.md) |
| Understand progressive disclosure, scripts, MCP integration, dynamic context | [design_patterns.md](design_patterns.md) |
| Author a new skill step-by-step | [authoring_guide.md](authoring_guide.md) |
| Write a good `description` field (the single highest-leverage decision) | [description_rubric.md](description_rubric.md) |
| Apply skill principles to CodeMySpec agent tasks (`lib/code_my_spec/agent_tasks/`) | [agent_task_guide.md](agent_task_guide.md) |
| Mental model in one paragraph | below |

## One-paragraph mental model

A "skill" is a directory with a `SKILL.md` at its root. The frontmatter (`name` + `description`) is loaded into every session as a one-line advertisement; the body is loaded only when the agent decides the skill is relevant; supporting files (`scripts/`, `references/`, `assets/`) are read on demand and cost zero tokens until accessed. This three-tier progressive disclosure is the whole point — it's what lets you bundle 50+ reference files into one skill without bloating context. All three platforms (Claude Code, OpenCode, Codex) implement the same model with the same `SKILL.md` filename and the same required frontmatter fields. They differ on discovery paths, on optional frontmatter, and on how tools (especially MCP) get wired in.

## Quick-reference: directory paths

| Platform | Project | User |
|---|---|---|
| Claude Code | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` |
| OpenCode | `.opencode/skills/`, also reads `.claude/skills/` and `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| Codex | `.agents/skills/<name>/SKILL.md` | `~/.agents/skills/<name>/SKILL.md` |

OpenCode reads all three project paths — put your skill in `.claude/skills/<name>/` for maximum portability with Claude Code, or in `.agents/skills/<name>/` to share with Codex too.

## Quick-reference: minimum frontmatter

The portable subset honored by all three:

```yaml
---
name: skill-name
description: What this does AND when to use it. Include trigger phrases.
---
```

That's it. Everything else is platform-specific. See [cross_platform.md](cross_platform.md) for the full compatibility matrix.
