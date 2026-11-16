---
# Metadata for stories_mcp_setup.md
# Setup guide for connecting the remote Stories MCP server to Claude Code,
# Claude Desktop, Cursor, and other MCP-capable clients.

# Required fields
slug: stories-mcp-setup
type: documentation
title: Add the Stories MCP Server - Setup Guide

# Publishing control
protected: false
publish_at: "2026-04-20T00:00:00Z"
expires_at: null

# SEO Metadata
meta_title: Stories MCP Setup - Claude Code, Desktop, Cursor
meta_description: Connect your chat client to CodeMySpec's remote MCP server with OAuth. Interview user stories and review them without installing anything locally.
og_title: Add the Stories MCP Server - Setup Guide
og_description: Connect your AI client to CodeMySpec's remote MCP server. Claude Code, Claude Desktop, and Cursor instructions included.
og_image: null

metadata:
  template: tutorial
  category: Getting Started

# Tags
tags:
  - mcp
  - model-context-protocol
  - user-stories
  - claude-code
  - claude-desktop
  - cursor
  - setup
  - tutorial
---

# Add the CodeMySpec MCP Server

Point your MCP client at CodeMySpec's remote server and start drafting user stories with AI, with nothing installed on your machine.

## What this gives you

The remote MCP server is a hosted Model Context Protocol endpoint. Once connected, your AI client can:

- Interview you about features and write user stories
- Review existing stories for quality and completeness
- Manage acceptance criteria, tags, epics, and personas
- Triage incoming issues
- Look at your project's architecture and requirements

It's the lightweight path. Story, architecture, and issue work doesn't need a local server. Running code, tests, and `mix spex` does, because that happens on your machine or on a dev box.

For the full loop (executable BDD specs, code, QA), follow the [getting started guide](/documentation/getting-started) and install the local server and plugin instead.

## Prerequisites

- A [CodeMySpec account](https://www.codemyspec.com/users/register) with at least one project
- An MCP-capable AI client (Claude Code, Codex, Claude Desktop, Cursor, Gemini CLI, Copilot, etc.)

## Server details

```
URL:       https://codemyspec.com/mcp/harness
Transport: Streamable HTTP
Auth:      OAuth 2.0 (browser-based, handled by your client)
```

On first use, your client opens a browser window for you to sign in. The client caches the token afterward. The endpoint is named `harness` for historical reasons. It doesn't require a local harness.

## Claude Code

One command:

```bash
claude mcp add --transport http codemyspec https://codemyspec.com/mcp/harness
```

Then start Claude Code in any directory and ask it to draft a story. The first tool call triggers the OAuth flow.

To remove it later:

```bash
claude mcp remove codemyspec
```

## Claude Desktop

No config file needed.

1. Open Claude Desktop, then **Settings**, then **Customize**
2. Click **Add Connector**
3. Paste the URL: `https://codemyspec.com/mcp/harness`
4. Sign in when the OAuth window opens

## Cursor

Edit `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (per project):

```json
{
  "mcpServers": {
    "codemyspec": {
      "url": "https://codemyspec.com/mcp/harness"
    }
  }
}
```

Restart Cursor and open Settings, then MCP, to confirm the server is connected.

## How the tools are exposed

The server keeps its tool list short on purpose. A few tools are direct, such as `get_next_requirement`, `start_task`, `evaluate_task`, and `sync_project`. Everything else, including the story tools, is reached through two code-mode tools:

- `tool_docs` returns the arguments for a named tool
- `run_script` runs a short Lua script that calls one or more tools

Your client does this for you. You ask in plain language. See [progressive tool disclosure](/blog/progressive-disclosure) for why.

## First use

In your AI client, ask naturally:

> "I want to add a feature where logged-in drivers can log their fill-ups. Help me turn that into user stories."

The client calls `start_story_interview` and the AI walks you through a PM-style conversation, producing well-formed stories. Acceptance criteria come later, in a Three Amigos session (`start_three_amigos_session`).

To review what's already in your project:

> "Review my project's user stories for quality."

This triggers `start_story_review`.

## Picking an account or project

The server scopes every call to your **active account** and **active project**. Set these once:

1. Sign in at [codemyspec.com](https://www.codemyspec.com)
2. Pick an account
3. Pick a project from the project picker

All MCP calls from your client use those as scope until you change them.

## Troubleshooting

**OAuth window doesn't open.** Check your client's logs. For Claude Desktop, open the Developer pane in Settings and look at the server's stderr.

**"Not authenticated" after signing in.** Your token may be cached against a different account. Revoke and reconnect from your client's MCP settings.

**"No active project."** Sign in to [codemyspec.com](https://www.codemyspec.com) and pick a project before calling tools.

**Tools don't appear in the client.** Confirm the server is listed as connected (hammer icon in Claude Desktop, MCP panel in Cursor). Some clients cache the tool list at connect, so reconnect after any change.
