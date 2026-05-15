# Cross-Platform Skill Design

Rules for writing one skill that works on Claude Code, OpenCode, and Codex.

## TL;DR portability recipe

1. Put the skill at `.claude/skills/<name>/SKILL.md` in your repo. OpenCode reads `.claude/skills/` natively; Codex doesn't, so also place at `.agents/skills/<name>/SKILL.md` or symlink one to the other.
2. Frontmatter contains **only** `name` + `description`. Everything else is platform-specific.
3. Body refers to scripts/references by **relative path**. All three platforms use ordinary `read`/`bash` to access them.
4. Document required MCP servers and tools in prose. None of the three platforms can install MCP servers from skill metadata. (Codex can *declare* deps in `agents/openai.yaml`, but the user still has to wire them up.)
5. Codex-only chrome (icons, brand color, MCP dep declarations, implicit-invocation policy) goes in a sibling `agents/openai.yaml` — Claude and OpenCode ignore it.
6. For explicit invocation, document both forms: `$name` (Codex), `/name` (Claude Code, if surfaced), agent menu pick (OpenCode).

## Discovery path matrix

| Platform | Project paths | User paths |
|---|---|---|
| Claude Code | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` |
| OpenCode | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` (project before global, opencode > claude > agents) | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| Codex | `.agents/skills/` (cwd → repo root) | `~/.agents/skills/` |

**Recommended layout for portability:**

```
your-repo/
├── .claude/
│   └── skills/
│       └── <name>/SKILL.md         # Claude Code + OpenCode
└── .agents/
    └── skills/
        └── <name> -> ../../.claude/skills/<name>   # symlink for Codex
```

A symlink keeps a single source of truth.

## Frontmatter compatibility

| Field | Claude Code | OpenCode | Codex |
|---|---|---|---|
| `name` | required | required | required |
| `description` | required | required | required |
| `allowed-tools` | honored | **ignored** (unknown field) | not in spec |
| `disable-model-invocation` | honored | not honored | use `policy.allow_implicit_invocation: false` in `openai.yaml` |
| `user-invocable` | honored | n/a | n/a |
| `model` | honored | done at agent level | done at config level |
| `effort`, `context`, `agent` | honored | n/a | n/a |
| `argument-hint`, `arguments` | honored | n/a | n/a |
| `paths` | honored | n/a | n/a |
| `license`, `compatibility`, `metadata` | ignored | honored | n/a |
| Custom Codex chrome | n/a | n/a | `agents/openai.yaml` sibling file |

**Portable subset:** `name` and `description` only. Anything else risks being silently ignored.

## Invocation syntax

| Platform | Implicit | Explicit |
|---|---|---|
| Claude Code | Description match → model auto-loads | `/skill-name` if `disable-model-invocation` not set; else not user-facing |
| OpenCode | Description advertised in system prompt, agent calls `skill({name: ...})` | `/skills` picker, or agent invokes by name |
| Codex | Description match → model auto-loads (subject to ~2% context budget) | `$skill-name` mention or `/skills` picker |

**Document both forms in the skill body** if you want users to be able to trigger explicitly.

## Tool naming differences (MCP)

| Platform | MCP tool naming |
|---|---|
| Claude Code | `mcp__<server>__<tool>` (double underscore) |
| OpenCode | `<server>_<tool>` (single underscore) |
| Codex | Per-server `enabled_tools` / `disabled_tools` lists by tool name |

Wildcard whitelists in `allowed-tools` / `tools` maps are **not portable verbatim** across Claude Code and OpenCode. In the skill body, refer to tools by their **conceptual** name ("the GitHub create_issue tool"), not their prefixed form. Each platform's user does the prefix wiring once in their own config.

## Per-skill tool restriction

- **Claude Code:** `allowed-tools` frontmatter, wildcards supported.
- **OpenCode:** done at the **agent** level (`tools` and `permission` maps) or top-level `permission.skill.<glob>` in `opencode.json`. Not in skill frontmatter.
- **Codex:** done at the MCP server level (`enabled_tools` / `disabled_tools`) and skill-level enable/disable. Not in skill frontmatter.

Verdict: don't rely on per-skill tool whitelists for portable behavior. Document tool needs in prose.

## Ambient project context

| Platform | File |
|---|---|
| Claude Code | `CLAUDE.md` |
| OpenCode | `AGENTS.md` (preferred), falls back to `CLAUDE.md` |
| Codex | `AGENTS.md` (with `AGENTS.override.md` and configurable fallbacks) |

For portability, write your project conventions in `AGENTS.md` — OpenCode prefers it, Codex requires it, and Claude Code can be pointed at it via a symlink from `CLAUDE.md`.

## What you can rely on across all three

- `SKILL.md` filename in a `<name>/` directory.
- `name` + `description` frontmatter.
- Markdown body with arbitrary structure.
- Sibling `scripts/`, `references/`, `assets/` directories accessed via `read` / `bash` (no skill-relative path resolution — use relative paths from `cwd` and document that).
- Progressive disclosure: only description loads upfront; body loads when relevant; supporting files load on demand.

## What you cannot rely on across all three

- Per-skill tool whitelists.
- Skill-level MCP server dependencies (Codex has it via `openai.yaml`, others don't).
- Skill-relative path resolution for scripts.
- Wildcard tool patterns in frontmatter.
- Slash-name invocation parity.
- Model/effort overrides at the skill level (Claude-only).
- Argument substitution in the body (Claude-only `$0..$N`).

## Pattern: portable skill template

```
my-skill/
├── SKILL.md                # name + description only
├── README.md               # human docs (optional)
├── scripts/
│   └── do-thing.sh
├── references/
│   └── deep-dive.md
└── agents/
    └── openai.yaml         # Codex chrome, ignored elsewhere
```

`SKILL.md`:

```markdown
---
name: my-skill
description: Does X. Use when the user asks about Y, mentions Z, or works with .foo files.
---

## What this skill does

One paragraph.

## How to invoke explicitly

- Claude Code: `/my-skill`
- OpenCode: `/skills` then pick "my-skill"
- Codex: `$my-skill`

## How to use

1. Check current state: `bash scripts/do-thing.sh --check`
2. For details on the underlying protocol, see [references/deep-dive.md](references/deep-dive.md).
3. ...

## Required tools

This skill assumes you have the **GitHub MCP server** installed and that the `create_issue` and `list_issues` tools are enabled. To set up:

- Claude Code: add `github` MCP server, then add `mcp__github__create_issue mcp__github__list_issues` to your `allowed-tools`.
- OpenCode: add to `opencode.json` `mcp` block, grant `github_*` in agent `tools`.
- Codex: `codex mcp add github ...`, set `enabled_tools = ["create_issue", "list_issues"]`.
```

This template trades platform-specific richness for portability. For a single-platform skill, use the native frontmatter fully.
