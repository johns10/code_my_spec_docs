# Skill Authoring Guide

A turn-by-turn checklist for agents writing skills. Follow in order. Each step has a verification question — if you can't answer it, don't proceed.

## Step 0 — Confirm a skill is the right primitive

Ask: **who initiates the load, and is this content reusable across sessions?**

- User types `/foo bar` with a template → slash command / custom prompt.
- Agent picks from a menu when the situation matches → **skill** ✓
- Always loaded as project conventions → `AGENTS.md` / `CLAUDE.md`.
- Runtime side effect (hook, custom tool, dynamic data source) → plugin / MCP server.
- One-off operation specific to today's task → just put it in the conversation.

**Verify:** can I name two future sessions where this skill would trigger?

## Step 1 — Draft `name` and `description`

Write these first. They're the routing signal — everything else is loaded on demand.

```yaml
---
name: kebab-case-name        # must equal directory name
description: <see step 2>
---
```

Naming rules:
- Lowercase letters, digits, hyphens only.
- ≤ 64 chars.
- Specific enough that a future reader can guess the purpose: `pdf-form-fill`, not `pdf-helper`.

## Step 2 — Get the description right

This is the single biggest design lever. Use the [description rubric](description_rubric.md) — don't proceed until it passes.

Quick form:
> `<what it does, third person>. Use when <concrete trigger phrases>.`

**Verify:** does the description name at least three trigger phrases a user might say, and does it clearly say what the skill produces?

## Step 3 — Test the trigger

Write three plausible user prompts you'd want this skill to handle. Mentally simulate: would the agent pick this skill from a menu of 20 others, given only the description?

```
Prompt 1: "Fill out this PDF form with the values from data.csv"
Prompt 2: "Extract the form fields from the attached PDF"
Prompt 3: "Can you merge these three PDFs and flatten the form fields?"
```

If even one prompt feels ambiguous, the description is too vague. Revise.

**Verify:** are there real trigger phrases that match the description verbatim?

## Step 4 — Outline the body before writing it

Draft a section list. A well-shaped `SKILL.md` body:

```
# <skill name>

## What this does       (1 paragraph)
## When to use it       (3–5 bullets)
## Quick start          (a single happy-path example)
## Decision tree        (which sub-path applies; links to references)
## Required tools       (MCP, bash, etc.)
## Failure modes        (what to do when things go wrong)
```

If the body needs more sections than this, you're inlining what should be a reference.

**Verify:** can the outline fit on one screen?

## Step 5 — Write the body. Keep it under 500 lines.

Constraints:
- Body persists for the rest of the session once loaded. Every token competes with conversation history.
- Aim for **1,500–2,000 words** (≈ 200–400 lines).
- The agent is already smart. Don't re-explain general programming concepts.
- One recommended path per task. Escape hatches go in a reference file.

If the body crosses 500 lines:
- Extract long-form content to `references/<topic>.md`.
- Replace inline content with a one-line link: `For X, see [references/x.md](references/x.md)`.
- Re-check: is anything left that's not load-bearing?

**Verify:** if I cut every paragraph that doesn't change the agent's behavior, what survives?

## Step 6 — Extract references

Anything that's lookup material, not procedure, belongs in `references/`:

```
my-skill/
├── SKILL.md
└── references/
    ├── api.md
    ├── examples.md
    └── edge-cases.md
```

Rules:
- One level deep only. `SKILL.md → references/foo.md`. Not `references/foo.md → references/bar.md`.
- Each reference file is self-contained — the agent reads it without other context.
- Name files by topic, not type. `references/forms.md` beats `references/details-1.md`.
- Link from `SKILL.md` with intent: `For tracked-changes handling, see [references/redlining.md]`.

**Verify:** for each reference file, can I name the trigger phrase that would make the agent open it?

## Step 7 — Add scripts for deterministic work

Only ship a script when the behavior must be deterministic. Reasoning steps stay in prose.

Good script candidates:
- Validation (schema check, lint pass, syntax verification).
- Batch operations over many files.
- Anything where the agent would write the same code three times.

```
my-skill/
└── scripts/
    └── validate.py        # #!/usr/bin/env python3, chmod +x
```

Rules:
- Hashbang at the top, executable bit set.
- No venvs. Document `pip install` requirements in `SKILL.md`.
- Handle errors **in the script**. Print a clear message and exit nonzero — don't make the agent guess.
- Forward slashes only.

Invoke from `SKILL.md`:
```markdown
Run: `python scripts/validate.py <input>`
```

On Claude Code specifically, you can use `${CLAUDE_SKILL_DIR}` for install-path-independent paths.

**Verify:** for each script, would having the agent write equivalent code produce inconsistent results?

## Step 8 — Document required tools

Be explicit about MCP servers and external tools the skill assumes. Don't bake in platform-specific config syntax — describe what's needed in prose.

```markdown
## Required tools

This skill uses the **GitHub MCP server**. Required tools:
- `create_issue` — to file new issues
- `list_issues` — to find duplicates

If your platform requires explicit allowlisting, see your platform's MCP config docs.
```

On Claude Code, also add `allowed-tools` to frontmatter to pre-approve calls:

```yaml
allowed-tools: mcp__github__create_issue mcp__github__list_issues Bash(gh *)
```

**Verify:** if a new user installed this skill on a fresh machine, would they know what to wire up?

## Step 9 — Self-review

Run through this checklist before declaring done:

- [ ] Description includes what + when + ≥3 trigger phrases.
- [ ] Body under 500 lines.
- [ ] References are one level deep from `SKILL.md`.
- [ ] Every reference file is linked from `SKILL.md` with intent ("for X, see ...").
- [ ] Scripts handle errors and exit nonzero on failure.
- [ ] Required tools documented in prose.
- [ ] Forward slashes everywhere.
- [ ] No nested reference chains (`SKILL.md → a.md → b.md`).
- [ ] No `disable-model-invocation` without a documented manual invocation path.
- [ ] No platform-specific frontmatter unless the skill targets that platform exclusively.

## Step 10 — Test from a fresh session

Open a new session. Don't mention the skill by name. Use one of the trigger prompts from step 3.

Did the agent find the skill? If not, the description failed — go back to step 2.

Did the agent read the right reference file when needed? If not, the body's pointers are unclear — fix the link prose ("for X, see Y" should be unambiguous).

Did scripts run? If not, check hashbangs, permissions, paths.

## Step 11 — Iterate

Skills are tuned, not written once. Watch for:
- **Undertriggering** — skill exists but agent never uses it → description needs trigger phrases.
- **Overtriggering** — skill activates for unrelated tasks → description is too generic.
- **Reference miss** — agent reasons from `SKILL.md` alone when a reference would help → strengthen the link prose, or inline the key fact.
- **Script crashes** — add error handling and a useful stderr message.

## Pattern: skill template scaffold

When starting fresh, copy this scaffold:

```
my-skill/
├── SKILL.md
├── references/
│   └── .gitkeep
└── scripts/
    └── .gitkeep
```

`SKILL.md`:

```markdown
---
name: my-skill
description: <one-line what + when + trigger phrases>
---

# My Skill

## What this does

<one paragraph>

## When to use it

- When the user <trigger 1>
- When the user <trigger 2>
- When working with <file type / domain>

## Quick start

<one happy-path example>

## How to use

1. <step>
2. <step>
3. For <edge case>, see [references/<topic>.md](references/<topic>.md).

## Required tools

<MCP servers, bash commands, external tools>

## Failure modes

- If <X>: <what to do>
- If <Y>: <what to do>
```

Replace placeholders, then run through the checklist.

## See also

- [description_rubric.md](description_rubric.md) — focused guide on the description field.
- [design_patterns.md](design_patterns.md) — progressive disclosure, MCP integration, dynamic data.
- [cross_platform.md](cross_platform.md) — what to keep portable vs platform-specific.
