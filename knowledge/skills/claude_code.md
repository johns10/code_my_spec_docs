# Claude Code — Skill Reference

Authoritative mechanics for designing skills that Claude Code can discover and invoke. All claims sourced from Anthropic docs as of 2026-05.

## File layout

```
<skill-name>/
├── SKILL.md            # required
├── reference.md        # optional, loaded on demand
├── examples.md         # optional, loaded on demand
├── templates/*.md      # optional
├── scripts/*.py        # optional, invoked via Bash
└── assets/*            # optional, static data
```

Only `SKILL.md` is required. The directory name **must equal** the skill `name` in frontmatter.

## Discovery paths

| Scope | Path | Notes |
|---|---|---|
| Personal | `~/.claude/skills/<name>/SKILL.md` | All projects |
| Project | `.claude/skills/<name>/SKILL.md` | This repo only; searched upward to repo root |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |
| Enterprise | managed settings | Highest priority |

Adding or editing a skill takes effect immediately in the current session — no restart needed.

## Frontmatter

Required:

```yaml
---
name: skill-name           # lowercase + hyphens, max 64 chars, must match dir name
description: Specific 1–1024 char description with trigger phrases.
---
```

Optional fields the project may use:

| Field | Purpose |
|---|---|
| `allowed-tools` | Space-separated whitelist. Supports wildcards (`Bash(git *)`) and MCP tools (`mcp__github__create_issue`). Pre-approves tool calls so the user isn't prompted each time. |
| `disable-model-invocation` | `true` → manual `/skill-name` only. Use for skills with side effects (deploy, send-message). |
| `user-invocable` | `false` → hide from `/` menu; only auto-invoked. |
| `model` | Override model while skill is active (e.g. `opus-4-1`). Reverts after the turn. |
| `effort` | Override effort level (`low`/`medium`/`high`/`xhigh`/`max`). |
| `context` | `fork` → run in isolated subagent context. |
| `agent` | When `context: fork`, which subagent type to use (`Explore`, `Plan`, `general-purpose`, custom). |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]`. |
| `arguments` | Named positional args mapped to `$name` placeholders in the body. |
| `paths` | Glob list (`*.js,*.ts`) limiting when skill auto-loads. |
| `shell` | `bash` (default) or `powershell` for inline commands. |
| `hooks` | Hooks scoped to the skill lifecycle. |

The `description` is the **only** lever for relevance matching. Vague descriptions undertrigger. Include both "what it does" and "when to use it" with concrete trigger phrases. Anthropic's [best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) call this out as the single biggest skill-design lever.

## Progressive disclosure — Claude Code's three tiers

1. **Tier 1 — metadata** (~100 tokens per skill, loaded at startup): just `name` + `description`. This is what the model uses to decide whether to load the skill.
2. **Tier 2 — body** (loaded on trigger, persists for the session): the full `SKILL.md` body. Once loaded, every token competes with conversation history. Keep under **500 lines / 1,500–2,000 words**.
3. **Tier 3 — supporting files** (loaded on demand, zero cost until accessed): `reference.md`, `examples.md`, `scripts/`, `assets/`. The body links to these; the model reads them only when the current task needs them.

Practical implication: bundle generously. A skill with one 200-line `SKILL.md` and 5,000 lines of `references/*.md` costs nothing extra until the model actually opens a reference file.

## Supporting files

Path rules:
- Forward slashes only (`scripts/helper.py`, not `scripts\helper.py`).
- Relative to the skill directory.
- Use `${CLAUDE_SKILL_DIR}` in bash invocations for install-path-independent references: `` !`python ${CLAUDE_SKILL_DIR}/scripts/validate.py` ``.

Loading model:
- Markdown files are loaded by the model issuing a `Read` (only when referenced from `SKILL.md`).
- Scripts are **executed**, not loaded — their source never enters context, only their stdout/stderr.

Keep references one level deep from `SKILL.md`. Nested reference chains (`SKILL.md → a.md → b.md`) get read incompletely (the model previews with `head -100` and gives up).

## Scripts

Conventions:
- Place under `scripts/`.
- Hashbang (`#!/usr/bin/env python3`, `#!/bin/bash`) + `chmod +x`.
- Don't ship a venv. Document `pip install` requirements in `SKILL.md`, or include a `subprocess.check_call([pip, install, ...])` bootstrap.
- Handle errors **inside the script**. Don't punt error cases to the model — produce a clear error message and exit nonzero.

Two invocation syntaxes from `SKILL.md`:

```markdown
Run: `python ${CLAUDE_SKILL_DIR}/scripts/validate.py input.json`
```

```markdown
```!
python ${CLAUDE_SKILL_DIR}/scripts/setup.py --init
npm install -g my-package
```
```

The `` !` `` prefix is preprocessing — the command runs *before* Claude sees the rendered skill, and its output is inlined.

## MCP tool integration

Skills cannot declare "I need MCP server X installed." They can:

1. Reference MCP tools in `allowed-tools`:

   ```yaml
   allowed-tools: mcp__github__create_issue mcp__github__list_issues
   ```

2. Use fully qualified names (`mcp__<server>__<tool>`) in the body.

3. Assume the user has the MCP server already configured. Document the requirement in `SKILL.md`.

The Anthropic mental model: MCP gives the model **access** to tools; skills teach it **when and how** to use them. They compose, but the skill doesn't install the MCP server.

## Dynamic data / runtime context

Three patterns:

1. **Command injection** — `` !`git diff HEAD` `` in `SKILL.md`. Preprocesses at skill-load time, inlines output. Best for snapshot context.
2. **Helper scripts** — skill body tells the model to run `python scripts/scan.py`, which writes JSON the model then reads. Best for structured live data.
3. **Arguments** — `arguments: [input-file, output-format]` in frontmatter, referenced as `$0`/`$1` in body. Best for parameterized invocation.

## Skill vs subagent vs slash command

| | Skill | Subagent | Slash command |
|---|---|---|---|
| Trigger | Auto via description | Manual delegation | Manual user input |
| Context | Persists in main convo | Forked, isolated | None / fixed |
| Best for | Procedural knowledge, conventions | Complex isolated tasks | Common ops with fixed logic |
| Token cost | ~100 metadata + body when active | Varies | None |

Decision rule of thumb:
- Repeated instructions you copy-paste → skill.
- Complex research that shouldn't pollute the main convo → subagent.
- Deterministic operation with a hotkey → slash command.

## Anti-patterns

- **Bloated `SKILL.md`** — every token persists for the session. Move detail to `references/`.
- **Vague descriptions** — "Helps with documents" never triggers. Use concrete phrases: "Extracts text and tables from PDF files, fills forms... Use when working with PDFs, forms, or document extraction."
- **No `allowed-tools` whitelist** — user gets a permission prompt on every tool call.
- **Windows paths in scripts** — breaks on Unix.
- **Deeply nested reference chains** — `SKILL.md → a.md → b.md` reads incompletely. Keep one level.
- **Punting errors to Claude** — scripts that crash on a missing file leave the model to guess. Handle the error in code.
- **Disabling discovery without good reason** — `disable-model-invocation: true` is for side-effect skills (deploy), not general-purpose ones.

## Real examples worth studying

- [anthropics/skills](https://github.com/anthropics/skills) — official repo. Start with `skill-creator`, `frontend-design`, `mcp-server`.
- [anthropics/claude-code](https://github.com/anthropics/claude-code) — bundled skills like `simplify`, `init`, `review` ship in the plugin-dev directory.

## Sources

- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Skill authoring best practices — Claude API Docs](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices)
- [Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [GitHub: anthropics/skills](https://github.com/anthropics/skills)
- [Plugin development skill](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/skill-development/SKILL.md)
- [Equipping agents for the real world with Agent Skills (engineering blog)](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp)
