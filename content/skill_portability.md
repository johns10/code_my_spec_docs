# One Skill, Three Platforms

When I write a new skill, it goes in `.claude/skills/<name>/`. Not because I only run Claude Code -- because OpenCode reads that directory natively, and a single symlink from `.agents/skills/` makes Codex find it too. One source of truth, three platforms, one place to edit.

That's possible because Claude Code, OpenCode, and Codex independently arrived at the same skill convention. `SKILL.md` in a named directory, `name` and `description` in the frontmatter, body loaded on demand. The discovery paths differ. Some platforms honor extra frontmatter fields, others silently ignore them. The core artifact is the same.

The convergence is the prize. One skill, three platforms -- if you know which fields are portable and which aren't.

This post is the matrix: what's portable, what's platform-specific, what's silently dropped if you guess wrong, and the template I start from.

It assumes [how to write your first agent skill](/blog/how-to-write-your-first-skill) for the mental model and [the description rubric](/blog/skill-description-rubric) for the routing signal. If your skill doesn't trigger on one platform, that's the first place to look.

## The portable subset

Stick to this and your skill works everywhere:

- `SKILL.md` in a directory named the same as the skill.
- Frontmatter with `name` + `description`. Nothing else.
- Markdown body with arbitrary structure.
- Sibling `scripts/`, `references/`, `assets/` directories accessed via `read` / `bash`.
- Tools referred to by conceptual name in the body (not by prefixed identifier).
- Forward slashes in paths. Always.

Everything else is platform-specific. Use it when targeting one platform, skip it when targeting three.

## Discovery paths

Where the skill lives on disk determines who finds it. The three platforms diverge here.

| Platform | Project paths | User paths |
|---|---|---|
| Claude Code | `.claude/skills/<name>/` | `~/.claude/skills/<name>/` |
| OpenCode | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` (precedence: opencode > claude > agents) | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| Codex | `.agents/skills/` (cwd, walking up to repo root) | `~/.agents/skills/` |

OpenCode is the one that gives you portability for free -- it reads all three project paths. Claude Code only reads `.claude/skills/`; Codex only reads `.agents/skills/`. Put the skill in `.claude/skills/` and symlink it from `.agents/skills/` and you're covered.

**Recommended layout for portability:**

```
your-repo/
├── .claude/
│   └── skills/
│       └── <name>/SKILL.md         # Claude Code + OpenCode read this
└── .agents/
    └── skills/
        └── <name> -> ../../.claude/skills/<name>   # symlink for Codex
```

A symlink keeps a single source of truth. Edit the file in `.claude/skills/<name>/SKILL.md`, all three platforms see the change.

## Frontmatter compatibility

This is where portability bugs come from. Fields silently get ignored on platforms that don't know them, and the skill quietly degrades.

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

**The portable subset is `name` and `description`.** Anything else risks being silently ignored. If you depend on `allowed-tools` or `disable-model-invocation` for safety, you're writing a Claude Code skill, not a portable one.

The trade-off is real. Claude Code's `allowed-tools` whitelist pre-approves MCP calls so the user doesn't get prompted on every invocation. Losing it means OpenCode users see permission prompts your Claude Code users don't. There's no portable substitute -- per-skill tool restriction lives at the agent or config layer on the other two platforms. Document the requirement in prose and accept the friction.

## Invocation syntax

Implicit invocation (the agent picks the skill from the description) works the same way on all three. Explicit invocation -- when the user wants to force the skill to load -- diverges.

| Platform | Explicit invocation |
|---|---|
| Claude Code | `/skill-name` (if `disable-model-invocation` not set) |
| OpenCode | `/skills` picker, or agent invokes by name |
| Codex | `$skill-name` mention or `/skills` picker |

If you want users to be able to trigger explicitly, document both forms in the skill body:

```markdown
## How to invoke explicitly

- Claude Code: `/my-skill`
- OpenCode: `/skills` then pick "my-skill"
- Codex: `$my-skill`
```

This costs you ten lines of `SKILL.md` body and saves new users from "how do I even run this" friction.

## MCP tool naming differences

MCP tools register under different prefix conventions on each platform.

| Platform | MCP tool naming |
|---|---|
| Claude Code | `mcp__<server>__<tool>` (double underscore) |
| OpenCode | `<server>_<tool>` (single underscore) |
| Codex | Per-server `enabled_tools` lists by tool name |

This breaks any frontmatter that references tools by their prefixed name. `allowed-tools: mcp__github__create_issue` works on Claude Code, gets ignored on OpenCode, and isn't a thing on Codex.

Refer to tools **conceptually** in the body:

```markdown
## Required tools

This skill uses the **GitHub MCP server**. Required tools:
- `create_issue` -- to file new issues
- `list_issues` -- to find duplicates
```

The agent resolves "the GitHub create_issue tool" against whatever prefix its platform uses. User wires up the server once, out of band. Skill stays portable.

## Ambient project context: AGENTS.md vs CLAUDE.md

The always-loaded project conventions file is a separate primitive from skills, and the three platforms disagree on what to name it.

| Platform | Convention file |
|---|---|
| Claude Code | `CLAUDE.md` |
| OpenCode | `AGENTS.md` (preferred), falls back to `CLAUDE.md` |
| Codex | `AGENTS.md` (with override and fallback chain) |

For portability, write your project conventions in `AGENTS.md`. OpenCode prefers it, Codex requires it, and Claude Code can be pointed at it via a `CLAUDE.md` symlink:

```
CLAUDE.md -> AGENTS.md
```

It shows up in every cross-platform skill repo, so worth covering.

## What you can rely on across all three

- `SKILL.md` filename in a `<name>/` directory.
- `name` + `description` frontmatter.
- Markdown body with arbitrary structure.
- Sibling `scripts/`, `references/`, `assets/` accessed via `read` / `bash`.
- Three-tier progressive disclosure: only description loads upfront; body loads when relevant; supporting files load on demand.
- Tools referred to by conceptual name in the body.

## What you cannot rely on across all three

- Per-skill tool whitelists in frontmatter.
- Skill-level MCP server dependencies (only Codex has this via `openai.yaml`).
- Skill-relative path resolution for scripts (no `$CLAUDE_SKILL_DIR` equivalent on the other two).
- Wildcard tool patterns in frontmatter.
- Slash-name invocation parity.
- Model / effort overrides at the skill level (Claude-only).
- Argument substitution in the body (Claude-only `$0..$N`).

If your skill design depends on any of the second list, you're writing a Claude Code skill. That's fine -- just be honest about it.

## The portable skill template

This is what I start from when I write a new skill that needs to work everywhere.

```
my-skill/
├── SKILL.md                # name + description only
├── README.md               # human docs (optional)
├── scripts/
│   └── do-thing.sh
├── references/
│   └── deep-dive.md
└── agents/
    └── openai.yaml         # Codex chrome, ignored by the other two
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
2. For protocol detail, see [references/deep-dive.md](references/deep-dive.md).

## Required tools

This skill assumes the **GitHub MCP server** is installed with the `create_issue` and `list_issues` tools enabled. To wire it up:

- Claude Code: add the `github` MCP server, then add `mcp__github__create_issue mcp__github__list_issues` to your `allowed-tools`.
- OpenCode: add to `opencode.json` under `mcp`, grant `github_*` in the agent's `tools`.
- Codex: `codex mcp add github ...`, set `enabled_tools = ["create_issue", "list_issues"]`.
```

The Codex chrome (icon, brand color, MCP dep declarations) lives in `agents/openai.yaml` -- the other two platforms ignore it, so it costs nothing to include.

## When to go portable vs single-platform

Portability trades richness for reach. Claude Code-only frontmatter gives you `allowed-tools`, model overrides, argument hinting, paths-based auto-loading, isolated subagent contexts. Useful stuff. None of it survives porting.

Default to portable when:

- The skill is methodology, not infrastructure (BDD writer, code reviewer, release drafter).
- Users on different platforms are likely to want it.
- You're publishing the skill to a repo or marketplace.

Default to Claude Code-specific when:

- The skill needs `allowed-tools` to avoid permission prompts on every call.
- It needs argument substitution or paths-based auto-loading.
- It's for your own use and you don't run multiple platforms.

The cost of going portable is mostly the loss of `allowed-tools`. Everything else is recoverable through the body. If you can live with permission prompts on tool calls, portability is free.

## Where to go next

That's the cross-platform layer. Open three sessions, one on each platform, and confirm the skill triggers on each. Then forget you wrote it. The shape is what scales.
