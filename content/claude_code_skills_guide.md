# Claude Code Skills: Writing Apps for Agents

CLAUDE.md tells Claude who it is. Skills tell it what to do.

That distinction matters more than it sounds. CLAUDE.md loads every session -- it's ambient context, always there, always consuming your context window. A skill loads on demand. You type `/scan-reddit` and Claude becomes a Reddit scanner. You type `/develop-context` and it becomes a full-stack development orchestrator. The rest of the time, those instructions don't exist in context.

This is the first step toward a bigger idea: writing applications for agents instead of humans.

## What a Skill Actually Is

A skill is a markdown file in a directory. The directory lives at `.claude/skills/<skill-name>/` and contains a required `SKILL.md` file plus optional supporting files.

```
.claude/skills/scan-reddit/
  SKILL.md           # Required -- instructions Claude follows
  templates/         # Optional -- output templates
  examples/          # Optional -- reference material
```

When you type `/scan-reddit`, Claude reads `SKILL.md` and follows the instructions. That's it. No compilation, no runtime, no API. A markdown file that an agent reads and executes.

The older format -- single files in `.claude/commands/` -- still works. But the skill directory format is better because you can include supporting files that Claude loads on demand instead of cramming everything into one document.

## SKILL.md Anatomy

Every skill file has two parts: YAML frontmatter and markdown instructions.

```yaml
---
name: scan-reddit
description: Quick scan of Reddit for comment opportunities on CodeMySpec marketing
user-invocable: true
argument-hint: [subreddit or topic to focus on]
---

# Scan Reddit for Comment Opportunities

You are scanning Reddit for threads where CodeMySpec's approach
to AI-assisted development is relevant...
```

The frontmatter controls discovery and behavior. The markdown body is the actual application -- the instructions the agent follows.

### Frontmatter That Matters

**`description`** is the most important field. Claude uses it to decide whether to auto-invoke the skill. Write it in third person, be specific about what the skill does AND when to use it. "Helps with stuff" will never trigger. "Quick scan of Reddit for comment opportunities on CodeMySpec marketing" tells Claude exactly when this skill applies.

**`user-invocable`** and **`disable-model-invocation`** control who can trigger the skill:

| Setting | You invoke | Claude invokes | Use for |
|---|---|---|---|
| Default (both absent) | Yes | Yes | Most skills |
| `disable-model-invocation: true` | Yes | No | Side effects -- deploy, commit, send messages |
| `user-invocable: false` | No | Yes | Background knowledge Claude should just know |

**`allowed-tools`** restricts what tools Claude can use during the skill. `allowed-tools: Read, Grep, Glob` means it can read code but not edit anything.

**`context: fork`** runs the skill in an isolated subagent. The main conversation only sees the result, not the intermediate work. Good for research-heavy skills that would bloat your context.

**`argument-hint`** shows up in autocomplete. `/scan-reddit [subreddit or topic]` is better than a bare `/scan-reddit`.

## The Real Power: What Goes in the Body

The frontmatter is plumbing. The body is the application.

Here's what makes a skill more than a prompt: it structures an entire workflow with context loading, decision logic, output formats, and constraints. Consider what `/draft-response` does in my marketing workflow:

1. Loads memory files for voice, product context, and marketing intelligence
2. Reads the lead file to get the thread link, summary, and angle
3. Fetches the full Reddit thread and top comments via MCP
4. Analyzes the room -- what's the dominant sentiment, what's getting upvoted
5. Searches CodeMySpec content for genuinely relevant articles
6. Drafts a comment following specific tone rules (no bold headers, no links, no "I built a system that...")
7. Outputs in a structured format: thread summary, angle, research, room vibe, draft

That's not a prompt. That's an application. It has inputs (the lead file), processing logic (analyze the room, research relevant content), constraints (tone rules, formatting rules), and structured output. The consumer happens to be an AI agent instead of a human user.

## Progressive Disclosure

Skills are part of a broader pattern in Claude Code: progressive disclosure. The idea is that Claude should only load context it actually needs.

**Layer 1 -- Always loaded:** CLAUDE.md and skill descriptions. This is ambient context. Keep it small. CLAUDE.md should be ~50 lines max. Skill descriptions add a few hundred characters each.

**Layer 2 -- Loaded on invoke:** The full SKILL.md body. Only enters context when the skill is triggered. This is where the bulk of your instructions live.

**Layer 3 -- Loaded on demand:** Supporting files in the skill directory. Claude reads them when it needs them during execution. Reference docs, templates, examples.

This matters because context window is a shared, finite resource. A 500-line skill that loads every session wastes tokens on instructions Claude doesn't need 90% of the time. That same skill loaded on demand costs nothing until invoked.

The CLAUDE.md file becomes a map, not a manual. It points to skills and directories. Skills point to supporting files. Each layer loads only when needed.

## Arguments and Dynamic Context

Skills accept arguments through `$ARGUMENTS`:

```yaml
---
name: develop-context
argument-hint: [ContextModuleName]
---

Develop the $ARGUMENTS context through the full lifecycle...
```

`/develop-context Accounts` substitutes "Accounts" for `$ARGUMENTS`. Positional args work too -- `$0`, `$1`, `$2` for specific positions.

More interesting is dynamic context injection. Prefix a backtick command with `!` and it executes before Claude sees the skill:

```yaml
PR diff: !`gh pr diff`
PR comments: !`gh pr view --comments`
```

Claude sees the actual diff and comments, not the commands. This lets skills adapt to the current state of the world -- pulling in live data from git, APIs, or any CLI tool.

In CodeMySpec's development skills, this goes even further. The skill calls an Elixir CLI that generates a complete prompt based on the current state of the project:

```yaml
!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task develop_context ${CLAUDE_SESSION_ID} $ARGUMENTS`
```

That one line calls an Elixir application that reads the project's component graph, checks requirement status, loads the relevant spec files, and generates a detailed prompt with everything the agent needs. The skill file is 3 lines. The application behind it is thousands of lines of Elixir.

## Real Examples

### Marketing: Scan, Evaluate, Draft

I have three skills that chain together for Reddit marketing:

**`/scan-reddit`** browses 4 subreddits via MCP, identifies 3-7 threads relevant to AI coding quality, and creates structured lead files in `.code_my_spec/leads/incoming/`. Each lead captures the thread title, score, top comment vibe, angle, and relevant content topics. Output: a summary with recommendations on which 2-3 threads to action first.

**`/draft-response`** takes a lead file and turns it into a Reddit comment. It loads my tone guide, reads the full thread, analyzes what's getting upvoted, and drafts something that sounds like a person talking in a thread -- not a blog post pasted into comments. The skill explicitly forbids bold headers, numbered lists, links, and the phrase "lights out software factory."

**`/dev-marketing-writer`** drafts longer content. Blog posts, tutorials, case studies. It loads the same tone guide and marketing context, but its instructions are about outside-in framing (write about the topic, not the product), developer-first language (specific claims, not superlatives), and format adaptation (Reddit is casual, blog posts can be structured).

Each skill is a self-contained application with its own inputs, constraints, and output format. They share context files but have distinct jobs.

### Development: The Full Lifecycle

CodeMySpec's development skills are more ambitious. They're distributed as a plugin -- a directory of skills that ship with the CLI tool and load when Claude Code starts with the plugin enabled.

**`/design-architecture`** starts a guided session that analyzes user stories, proposes bounded contexts, and maps stories to both surface components (LiveViews, controllers) and domain components (contexts, schemas). The skill calls an Elixir backend that generates a prompt with all unsatisfied stories, current component count, dependency graph, and architecture views.

**`/develop-context`** orchestrates the full lifecycle of a Phoenix context -- specification, design review, implementation of every child component in dependency order, tests, validation. One command, one context, soup to nuts.

**`/qa-story`** runs a QA session against the running application. The agent reads the story and acceptance criteria, writes a test brief, executes against the live app, records results with evidence, and files issues for failures.

These skills don't contain the logic themselves. They call an Elixir application that generates the right prompt based on current project state. The skill is the interface. The application behind it is the intelligence.

### QA: Manual Testing as a Skill

**`/test-feature`** turns Claude into a manual QA tester. The skill file contains environment details (server port, log locations, project paths), a testing workflow (check server, clear logs, run scenario, observe, report), and accumulated learnings from past QA runs (like "always use `--plugin-dir` when invoking Claude" and "`--print` mode won't spawn subagents").

This one's interesting because the skill file itself is a living document. The "Learnings & Gotchas" section grows over time as the team discovers new edge cases. The skill gets smarter every time someone updates it.

## Where Skills Fit in the Extensibility Stack

Claude Code has five layers of customization. Each solves a different problem:

**CLAUDE.md** -- Ambient context. Project conventions, stack info, key directories. Loaded every session. Keep it short. This is who Claude is in this project.

**Skills** -- On-demand workflows. Loaded when invoked. This is what Claude does when you ask it to do a specific thing.

**Hooks** -- Lifecycle automation. Shell commands that run before or after tool calls. Pre-edit formatting, post-save linting, post-stop validation. This is what happens automatically around Claude's actions.

**MCP Servers** -- External tool integrations. Reddit API, Google Analytics, browser automation, database access. This is how Claude reaches outside the filesystem.

**Subagents** -- Isolated parallel workers. Skills with `context: fork` run as subagents. Custom agent types (`Explore`, `Plan`, `general-purpose`) run different models or tool sets. This is how Claude does multiple things at once without context contamination.

The combination is what makes this powerful. A skill can invoke MCP tools (fetch Reddit threads), spawn subagents (research in parallel), and trigger hooks (validate after changes). Each layer does one thing well. Skills orchestrate them.

## Writing Apps for Agents

Here's the mental shift that matters: a skill is an application. The user is an AI agent. The interface is natural language.

Traditional software has rigid inputs (forms, APIs, CLI flags) and rigid outputs (screens, JSON, exit codes). A skill has flexible inputs (natural language arguments, dynamic context from shell commands) and flexible outputs (Claude decides how to present results based on the instructions).

But the core software design principles still apply:

**Single responsibility.** `/scan-reddit` scans. `/draft-response` drafts. Don't combine them. Small, focused skills compose better than monoliths.

**Separation of concerns.** Instructions in the skill file. Reference data in supporting files. External capabilities in MCP servers. State in the filesystem.

**Progressive loading.** Don't front-load everything into context. Load what you need when you need it. This is lazy evaluation for AI context windows.

**Explicit constraints.** Tell the agent what NOT to do. "Don't put links in comments." "Don't mention CodeMySpec by name." Constraints are more valuable than instructions because they prevent the most common failure modes.

**Accumulated knowledge.** Skills can grow. The `/test-feature` skill has a learnings section that captures edge cases discovered during use. Each run potentially improves the next one.

This is the beginning of a different kind of software development. Not writing code that humans interact with through GUIs. Writing instructions that agents interact with through language. The principles transfer. The medium changes.

If you've used CLAUDE.md to give Claude context about your project, you've already started. Skills are the next step -- packaging specific workflows into reusable, on-demand applications. From there, it's MCP servers for external capabilities, hooks for automation, and subagents for parallelism.

The end state isn't a single clever prompt. It's a system of skills, tools, and constraints that together make an agent reliably productive at complex, multi-step work. That's what writing apps for agents looks like.

## Getting Started

Create your first skill:

```
mkdir -p .claude/skills/my-skill
```

Write a `SKILL.md`:

```yaml
---
name: my-skill
description: Does X when you need Y
---

# My Skill

Instructions for what Claude should do...
```

Invoke it: `/my-skill`

Start simple. A skill that runs your test suite and explains failures. A skill that reviews a PR against your team's conventions. A skill that generates a changelog from recent commits.

The best skills emerge from repetition. If you find yourself giving Claude the same instructions across multiple sessions, that's a skill waiting to be extracted. Do it manually first. Notice the pattern. Package it.
