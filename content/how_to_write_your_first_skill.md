# How to Write Your First Agent Skill

I wrote a 350-line "agent task" for code generation, then a 318-line one for QA journeys, then thirty more, before I figured out what I'd actually been building. They weren't tasks. They were skills. And almost every one of them was breaking the same rules I'm about to teach you.

For background: CodeMySpec is a Phoenix app that orchestrates AI coding agents through long-horizon development work -- specification, design, implementation, QA. The whole product runs on an abstraction I called `agent_task`. Each one generates a dynamic prompt from current project state, gates the next action on a validation check, and dispatches to a specific kind of work. Architecture design, BDD spec writing, code generation, persona research, three amigos. About thirty of them.

The performance was bad. Not "wrong answers" bad -- "too much context one way, not enough the other" bad. Each agent_task module had a 200-400 line `command/2` function that returned the prompt. Inside that prompt was a wall of procedural detail mixed with dynamic project state. The agent would chew through 1,500 tokens of "here's how to do a Three Amigos workshop" before reaching the actual thing I wanted it to do. Or worse: the prompt was lean and the procedural detail wasn't anywhere, so the agent wandered, guessed, or invented a workflow that didn't exist.

So I rewrote them. All of them. Same playbook on every one:

- Slim the prompt to a quick-start + decision tree + references.
- Move the procedural detail to `priv/knowledge/<task>/workflow.md`.
- Rewrite the `orchestrate/1` string (the routing signal) with a "Use when" clause.
- Surface the MCP tool surface explicitly in the prompt, by name.

QaJourney went from 318 lines to 252. StoryInterview lost a hundred. ThreeAmigos extracted the entire protocol to a knowledge file. Code generation got rewritten end to end. The agent's performance got better. The implementation got simpler. The tests also got better, in a way I didn't expect: I could assert on _what resources the agent was told to read_ instead of pinning exact phrasing in the prompt. Specs assert intent. Prompts deliver the artifact.

What I'd accidentally rebuilt was the Agent Skills convention. My `command/2` was a `SKILL.md` body. My `orchestrate/1` was the `description` field. My `priv/knowledge/<task>/` was the `references/` directory. Same three-tier loading. Same routing problem. Same failure modes.

This guide is what I would have read before I wrote the first one. By the end, you'll have a skill that triggers reliably, loads only when needed, and doesn't blow up your context window. If you haven't read [why your AI coding agent gets dumber the more tools you give it](/blog/progressive-disclosure) yet, start there -- it's the foundation this guide assumes.

## What a skill actually is

A skill is a directory with a `SKILL.md` at the root. The frontmatter (`name` + `description`) loads into every session as a one-line advertisement. The body loads only when the agent decides the skill is relevant. Supporting files in `scripts/`, `references/`, and `assets/` cost zero tokens until something opens them.

```
my-skill/
├── SKILL.md            ← required
├── references/         ← optional, loaded on demand
└── scripts/            ← optional, executed on demand
```

This three-tier loading is the whole point. It's what lets you bundle 5,000 lines of reference material into one skill without bloating context.

All three major platforms -- Claude Code, OpenCode, Codex -- implement the same model with the same `SKILL.md` filename and the same required frontmatter fields. They differ on discovery paths, optional frontmatter, and how MCP tools wire in. Cross-platform portability gets its own post; today we're shipping a single-platform skill that triggers reliably and stays small.

## Step 0: confirm a skill is the right primitive

Before you write a single line, ask: **who initiates the load, and is this content reusable across sessions?**

- User types `/foo bar` with a template → slash command.
- Agent picks from a menu when the situation matches → **skill** ✓
- Always loaded as project conventions → `AGENTS.md` / `CLAUDE.md`.
- Runtime side effect (hook, custom tool, dynamic data source) → plugin or MCP server.
- One-off operation specific to today's task → just put it in the conversation.

If you can't name two future sessions where this skill would trigger, you don't have a skill yet. You have an idea.

## Step 1: draft `name` and `description` first

Write these before anything else. They're the routing signal. Everything else is loaded on demand, which means everything else doesn't exist until the agent decides to pull it.

```yaml
---
name: kebab-case-name
description: <what it does, third person>. Use when <concrete trigger phrases>.
---
```

Naming rules: lowercase, digits, hyphens only, under 64 characters. The directory name has to equal the `name` field exactly. Be specific enough that a future reader can guess what it does -- `pdf-form-fill`, not `pdf-helper`.

## Step 2: get the description right

This is the single biggest lever in skill design and the place almost every first skill fails. The agent sees a list of skills like this:

```
- pdf-form-fill: <description>
- excel-pivot: <description>
- git-release: <description>
- ...40 more...
```

Given a user request, it picks one or none. The description has to make that choice unambiguous.

Two failure modes:

- **Undertrigger** -- the skill never fires because the description doesn't surface the right trigger words.
- **Overtrigger** -- the skill fires for unrelated work because the description is too generic.

Both reduce to "the description doesn't accurately scope what the skill is for."

❌ `description: Helps with PDFs`

✅ `description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`

The bad one has no verb and no trigger phrase. The good one names what it produces (extract, fill, merge) and the words a user would actually say ("PDFs", "forms", "document extraction").

I wrote a [whole rubric for descriptions](/blog/skill-description-rubric) -- it's the highest-leverage thing you'll ever write in a skill. For now, the quick form is:

> What it does, third person. Use when \<three trigger phrases or conditions\>.

Three trigger phrases minimum. If you can't name three, the skill is too narrow or the description is too vague.

## Step 3: test the trigger before writing the body

Write three plausible user prompts you'd want this skill to handle. Mentally simulate: given only the description, would the agent pick this skill from a menu of twenty others?

```
1. "Fill out this PDF form with the values from data.csv"
2. "Extract the form fields from the attached PDF"
3. "Can you merge these three PDFs and flatten the form fields?"
```

If even one prompt feels ambiguous, the description is too vague. Revise before you write a single line of body.

## Step 4: outline the body before writing it

A well-shaped `SKILL.md` body has the same structure every time:

```
# <skill name>

## What this does       (1 paragraph)
## When to use it       (3-5 bullets)
## Quick start          (one happy-path example)
## Decision tree        (which sub-path applies; links to references)
## Required tools       (MCP, bash, etc.)
## Failure modes        (what to do when things go wrong)
```

If the body needs more sections than this, you're inlining what should be a reference file.

## Step 5: write the body, keep it under 500 lines

Body persists for the rest of the session once loaded. Every token competes with conversation history. Aim for 1,500-2,000 words (roughly 200-400 lines). The agent is already smart -- don't re-explain general programming concepts. One recommended path per task. Escape hatches go in a reference file.

If you cross 500 lines, extract long-form content to `references/<topic>.md` and replace inline content with a one-line link: `For X, see [references/x.md](references/x.md)`.

## Step 6: extract references

Anything that's lookup material, not procedure, belongs in `references/`:

```
my-skill/
├── SKILL.md
└── references/
    ├── api.md
    ├── examples.md
    └── edge-cases.md
```

Three rules:

1. **One level deep only.** `SKILL.md → references/foo.md`. Not `references/foo.md → references/bar.md`. The model previews nested chains with `head` and gives up.
2. **Each reference file is self-contained.** The agent reads it without other context.
3. **Name files by topic, not type.** `references/forms.md` beats `references/details-1.md`.

Link from `SKILL.md` with intent: `For tracked-changes handling, see [references/redlining.md]`. "For X, see Y" is the unambiguous shape -- the model knows when to open it.

## Step 7: ship a script only when behavior must be deterministic

Reasoning stays in prose. Scripts are for things that have to come out the same every time: validation, schema checks, batch operations, anything where the agent would write the same code three times.

Conventions:

- Hashbang at the top, executable bit set.
- No venvs. Document `pip install` requirements in `SKILL.md`.
- Forward slashes only. Windows backslashes break on Unix.
- Handle errors **in the script**. Print a clear message and exit nonzero. Don't make the agent guess.

The error-handling rule matters more than people think. A script that crashes on a missing file forces the model to guess what went wrong. A script that prints `input.csv not found at /tmp/foo` and exits nonzero gives the agent something to work with.

## Step 8: document required MCP tools

Skills can't install MCP servers. They can document what's needed and assume the user wired it up:

```markdown
## Required tools

This skill uses the **GitHub MCP server**. Required tools:
- `create_issue` -- to file new issues
- `list_issues` -- to find duplicates

If your platform requires explicit allowlisting, see your platform's MCP config docs.
```

On Claude Code specifically, add `allowed-tools` to the frontmatter to pre-approve tool calls so the user isn't prompted on every invocation:

```yaml
allowed-tools: mcp__github__create_issue mcp__github__list_issues Bash(gh *)
```

## Step 9: test from a fresh session

Open a new session. Don't mention the skill by name. Use one of the trigger prompts from step 3.

Three questions:

1. **Did the agent find the skill?** If not, the description failed. Back to step 2.
2. **Did the agent read the right reference file?** If not, the link prose is unclear. Strengthen the "For X, see Y" pointers.
3. **Did scripts run?** If not, check hashbangs, permissions, paths.

This is the single most-skipped step. I've shipped skills that worked perfectly in the session where I wrote them and never triggered again. Fresh-session test catches it.

## Step 10: iterate

Skills are tuned, not written once. Watch for:

- **Undertriggering** -- skill exists, agent never uses it → description needs more trigger phrases.
- **Overtriggering** -- skill fires for unrelated tasks → description is too generic.
- **Reference miss** -- agent reasons from `SKILL.md` alone when a reference would help → strengthen link prose, or inline the key fact.
- **Script crashes** -- add error handling and a useful stderr message.

The biggest design mistake is starting with a 500-line `SKILL.md` and trying to trim it. Start with a five-line body, ship it, watch what happens, and grow only when you've seen a real failure mode.

## A real example

Here's a skill from my CodeMySpec marketing workflow. It scans Reddit for threads where my product's approach is genuinely relevant.

```yaml
---
name: scan-reddit
description: Quick scan of Reddit for comment opportunities on CodeMySpec marketing. Browses 4 subreddits via MCP, identifies 3-7 threads relevant to AI coding quality, writes lead files. Use when you want to find new threads to comment on, do a daily Reddit scan, or check for engagement opportunities.
user-invocable: true
---

# Scan Reddit for Comment Opportunities

## What this does

Browses r/ClaudeAI, r/vibecoding, r/elixir, and r/SaaS via the reddit MCP. Surfaces 3-7 threads where CodeMySpec's approach to AI-assisted development is genuinely relevant. Writes a lead file for each.

## When to use it

- Daily Reddit scan
- Looking for new comment opportunities
- After publishing new content (to find threads to link to)

## Quick start

Run with no arguments for the default sub list, or pass a single sub name to focus there.

## How it works

1. For each subreddit, fetch the front-page threads via `mcp__reddit-mcp-buddy__browse_subreddit`.
2. Filter for AI coding / agentic dev / spec / BDD topics.
3. For threads that pass the filter, fetch top comments to read the room.
4. Write a lead file to `.code_my_spec/leads/incoming/<date>_<topic>.md`.

For the lead file template, see [references/lead-format.md](references/lead-format.md).

## Required MCP tools

- `mcp__reddit-mcp-buddy__browse_subreddit` -- fetches front-page threads
- `mcp__reddit-mcp-buddy__get_post_details` -- fetches top comments for room-reading

## Failure modes

- If a sub returns nothing useful, skip and continue. Don't fabricate a lead.
- If you can't tell whether a thread fits, err on the side of skipping. False positives waste later steps.
```

About sixty lines. Description names three trigger phrases ("scan", "daily Reddit scan", "engagement opportunities"). Body has the shape from step 4. Reference file lives one level deep. MCP tools are documented by name. Failure modes are explicit.

It triggers reliably, costs roughly 100 tokens at session start, and only loads the body when I actually run a Reddit scan.

The same shape scales up. My ~30 CodeMySpec agent_tasks aren't markdown files -- they're Phoenix modules that generate prompts dynamically from project state -- but they follow the same rules. Slim body. Procedural detail in a `workflow.md` next door. MCP tools named in the prompt. Routing signal that says "Use when X." Sixty-line marketing skill and three-hundred-line Phoenix module follow the same three tiers. The shape is what scales.

## Where to go next

You've now got a working skill. The two posts that pick up from here:

- **[Why your skill isn't triggering, and the description rubric that fixes it](/blog/skill-description-rubric)** -- bad-to-good transformations, self-check questions, anti-patterns. This is the post that turns "my skill kind of works" into "my skill fires every time."
- **[One skill, three platforms: portability across Claude Code, OpenCode, and Codex](/blog/skill-portability)** -- when you want a single `SKILL.md` to work everywhere. Discovery path matrix, frontmatter compatibility, what's portable and what isn't.

Most of the leverage is in the description. Most of the maintenance is in iteration. Most of the failure modes are progressive disclosure misses. The first skill you write won't be great. The fifth one will be. Start small, ship, iterate.
