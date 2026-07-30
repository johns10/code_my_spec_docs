---
# Metadata for getting_started.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: getting-started
type: documentation  # Options: blog, page, landing
title: Getting Started with CodeMySpec

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2025-10-28T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: Getting Started with CodeMySpec - Project Setup Guide
meta_description: Set up a Phoenix project on CodeMySpec in about 10 minutes. Install the server and plugin, sign in, and start the requirement loop.
og_title: Getting Started with CodeMySpec
og_description: Learn how to set up a new Phoenix project with CodeMySpec for AI-driven development
og_image: null  # URL to Open Graph image

# Additional metadata (custom key-value pairs)
metadata:
  template: tutorial  # Options: default, article, tutorial
  author: CodeMySpec Team
  category: Getting Started
  featured: true

# Tags (optional, list of tag names)
tags:
  - documentation
  - getting-started
  - setup
  - tutorial
  - phoenix
---

# Getting Started

Get a Phoenix project running on CodeMySpec in about 10 minutes.

## Prerequisites

- macOS (Apple Silicon) or Windows (x64)
- A Phoenix project: Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- A coding agent: [Claude Code](https://docs.claude.com/claude-code) is the deepest integration; Codex and Antigravity are supported early
- A [CodeMySpec account](https://www.codemyspec.com/users/register)

## 1. Install

Follow **[/install](/install)**. It is the canonical, per-platform source for both pieces and it carries the copy buttons.

In short, there are two pieces:

1. **The server.** A local `cms` process that hosts the tools. On macOS, `brew install Code-My-Spec/tap/codemyspec` then `brew services start codemyspec`. On Windows, the `cms-setup-x64.msi` from the [latest release](https://github.com/Code-My-Spec/plugins/releases). It runs in the background on `localhost:4003` and restarts on boot.
2. **The plugin.** In Claude Code: `/plugin marketplace add Code-My-Spec/plugins` then `/plugin install codemyspec@codemyspec`. Codex and Antigravity have their own commands, listed on the install page.

The server hosts the admin UI, the MCP server, the skill suite, and the hooks wired into your agent's lifecycle.

## 2. Sign in

Inside your agent, with your Phoenix project as `$PWD`:

```
/codemyspec:init auth
```

The skill checks whether you are already authenticated, then opens a sign-in URL in your browser. OAuth PKCE runs against the CodeMySpec server and the token is stored locally. You only do this once (tokens refresh automatically).

Without a token, every MCP tool returns `not_authenticated` and stops.

On Codex, run the `init` skill from `/skills`. On Antigravity, run `/init auth`.

## 3. Initialize the project

Still inside Claude Code:

```
/codemyspec:init
```

This walks the agent through the 6-step pre-project checklist:

1. **Auth** — confirms you completed step 2
2. **Elixir** — correct version installed
3. **Phoenix installer** — `mix phx.new` available
4. **PostgreSQL** — running and reachable
5. **Phoenix project** — `mix.exs` and a usable Phoenix app in `$PWD`
6. **CLI config** — calls `list_projects` + `init_project` to link this directory to a CodeMySpec project

Each step is idempotent; the skill re-evaluates on every call and only inlines prompts for unfinished steps. Re-run until every step checks off. You can watch the same checklist in the browser at `http://localhost:4003/projects/:project_name/init` once the project is linked.

## 4. Tell the agent to use `get_next_requirement`

Now the main development loop takes over. Say:

> Use the `get_next_requirement` tool.

The tool is self-driving. It inspects the project state and returns the right prompt for whatever comes next:

- **Project-level setup incomplete** → runs the `ProjectSetup` checklist and inlines the prompt for every unfinished step.
- **Setup done** → returns the highest-priority unsatisfied requirement. The agent calls `start_task`, does the work, and the stop hook auto-evaluates.

Every time the agent looks lost, the answer is the same: `get_next_requirement`. The main development loop is just:

```
get_next_requirement → start_task → (do the work) → evaluate_task → repeat
```

The graph computes what to work on next based on prerequisites: specs before tests, tests before implementation, implementation before review. Follow the task prompts &mdash; they include file paths, spec templates, and the rules for the component type. `AGENTS.md` (installed during setup) has the full workflow reference.

## The local admin UI

Beyond `/auth` and `/projects`, the local server's LiveView UI at `http://localhost:4003/projects/:project_name/...` gives you:

- **Init checklist** at `/projects/:project_name/init` — the 6-step pre-setup checklist (Auth, Elixir, Phoenix installer, PostgreSQL, Phoenix project, CLI config) with per-step instructions. Same data `get_next_requirement` walks the agent through, rendered for humans.
- Requirements list and graph view
- Architecture overview and dependency graph
- Stories, issues, sessions, knowledge browser

Useful when you want to see what the agent sees without asking it.

## Just want the Product Manager?

If you're not using Claude Code and only want to interview stories with AI, add the remote Stories MCP server to your MCP client. See [Stories MCP setup](/documentation/stories-mcp-setup).

## Troubleshooting

**Server not running.** The `cms` server runs as a background service, so check it directly:

```bash
curl http://localhost:4003/health
```

On macOS, restart it with `brew services restart codemyspec`. If the port is already taken, something else is on 4003; stop that first.

**`not_authenticated` error.** Run `/codemyspec:init auth` and complete sign-in before calling any MCP tool. Every tool returns this until you do.

**macOS blocks the binary.** Allow it under System Settings &rarr; Privacy & Security.

**Auth token expired.** Run `/codemyspec:init auth` again.

**Install questions.** [/install](/install) is the canonical source for per-platform steps and stays current with the shipped release.
