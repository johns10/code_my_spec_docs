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
- A coding agent: Claude Code and Codex are fully supported through plugins, and Antigravity has a plugin too. Any other agent (Cursor, Aider, Gemini CLI, Copilot, and so on) connects through the MCP server
- A [CodeMySpec account](https://www.codemyspec.com/users/register)

## 1. Install

Follow **[/install](/install)**. It is the canonical, per-platform source for both pieces and it carries the copy buttons.

In short, there are two pieces:

1. **The server.** The desktop app (download for macOS or Windows from [/install](/install), free account required) runs it for you. Prefer a terminal? A local `cms` process that hosts the tools. On macOS, `brew install Code-My-Spec/tap/codemyspec` then `brew services start codemyspec`. On Windows, the `cms-setup-x64.msi` from the [latest release](https://github.com/Code-My-Spec/plugins/releases). It runs in the background on `localhost:4003` and restarts on boot.
2. **The plugin.** In Claude Code: `/plugin marketplace add Code-My-Spec/plugins` then `/plugin install codemyspec@codemyspec`. Codex and Antigravity have their own plugin commands, listed on the install page. Other agents skip the plugin and connect to the MCP server directly.

The server hosts the admin UI, the MCP server, the skill suite, and the hooks wired into your agent's lifecycle.

## 2. Sign in

Inside your agent, with your Phoenix project as `$PWD`:

```
/codemyspec:init auth
```

The skill checks whether you are already authenticated, then opens a sign-in URL in your browser. OAuth PKCE runs against the CodeMySpec server and the token is stored locally. You only do this once (tokens refresh automatically).

Without a token, the MCP tools can't reach your project and report an authentication error.

On Codex, run the `init` skill from `/skills`. On Antigravity, run `/init auth`.

## 3. Initialize the project

Still inside Claude Code:

```
/codemyspec:init
```

This walks the agent through the 3-step pre-project checklist:

1. **Auth**: confirms you completed step 2
2. **Phoenix project**: `mix.exs`, `lib/`, and `config/` exist in `$PWD`
3. **CLI config**: links this directory to a CodeMySpec project

Each step is idempotent. The skill re-evaluates on every call and only inlines prompts for unfinished steps. Re-run until every step checks off. You can watch the same checklist in the web app at `https://www.codemyspec.com/app/projects/:project_id/init`.

## 4. Tell the agent to use `get_next_requirement`

Now the main development loop takes over. Say:

> Use the `get_next_requirement` tool.

The tool is self-driving. It inspects the project state and returns the right prompt for whatever comes next:

- **Project-level setup incomplete**: runs the `ProjectSetup` checklist (dependencies, compilers, `mix spex` configuration, test boundaries, `AGENTS.md`, rules, Credo checks, `CLAUDE.md`) and inlines the prompt for every unfinished step.
- **Setup done**: offers the next unsatisfied requirement. The agent calls `start_task`, does the work, and the stop hook auto-evaluates.

Every time the agent looks lost, the answer is the same: `get_next_requirement`. The main development loop is:

```
get_next_requirement, start_task, (do the work), evaluate_task, repeat
```

The requirement graph computes what to work on next. Executable BDD specs, the ones you run with `mix spex`, sit at the center: they define what each story must do, and the code and tests exist to satisfy them. Follow the task prompts. They include file paths, templates, and the rules for the component type. `AGENTS.md` (installed during setup) has the full workflow reference.

## The web app

The CodeMySpec web app at `https://www.codemyspec.com/app/projects/:project_id/...` shows the same state the agent sees:

- **Init checklist** at `/init`, the 3-step pre-setup checklist (Auth, Phoenix project, CLI config) with per-step prompts you can copy into your agent. Same data `get_next_requirement` walks the agent through, rendered for humans.
- Requirements graph at `/requirements/graph`
- Architecture dependency graph at `/architecture`
- Stories, epics, personas, issues, QA, and the knowledge browser

Useful when you want to see what the agent sees without asking it.

## Just want story interviews in chat?

If you only want to interview stories with AI, add the remote CodeMySpec MCP server to your MCP client. See [MCP setup](/documentation/stories-mcp-setup).

## Troubleshooting

**Server not running.** The `cms` server runs as a background service, so check it directly:

```bash
curl http://localhost:4003/health
```

On macOS, restart it with `brew services restart codemyspec`. If the port is already taken, something else is on 4003; stop that first.

**Authentication error.** Run `/codemyspec:init auth` and complete sign-in before calling any MCP tool.

**macOS blocks the app or binary.** The installers aren't code signed yet. Open System Settings, then Privacy and Security, and choose Open Anyway. On Windows, choose More info, then Run anyway at the SmartScreen prompt.

**Auth token expired.** Run `/codemyspec:init auth` again.

**Install questions.** [/install](/install) is the canonical source for per-platform steps and stays current with the shipped release.
