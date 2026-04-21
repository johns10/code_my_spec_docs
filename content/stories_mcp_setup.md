# Add the Stories MCP Server

Point your MCP client at CodeMySpec's remote Product Manager server and start drafting user stories with AI.

## What this gives you

The Stories MCP server is a hosted Model Context Protocol endpoint. Once connected, your AI client can:

- Interview you about features and write structured user stories
- Review existing stories for quality and completeness
- Manage acceptance criteria, tags, and priority
- Triage incoming issues

It's the lightweight path &mdash; you don't install anything locally. Everything runs on the CodeMySpec server and your AI client connects over HTTP with OAuth.

For the full spec-driven workflow (design, specs, tests, code, QA), install the [Claude Code extension](/documentation/getting-started) instead.

## Prerequisites

- A [CodeMySpec account](https://www.codemyspec.com/users/register) with at least one project
- An MCP-capable AI client (Claude Code, Claude Desktop, Cursor, etc.)

## Server details

```
URL:       https://www.codemyspec.com/mcp/stories
Transport: Streamable HTTP
Auth:      OAuth 2.0 (browser-based, handled by your client)
```

On first use, your client will open a browser window for you to sign in. The token is cached by the client afterward.

## Claude Code

One command:

```bash
claude mcp add --transport http codemyspec-stories https://www.codemyspec.com/mcp/stories
```

Then start Claude Code in any directory and ask it to draft a story. The first tool call triggers the OAuth flow.

To remove it later:

```bash
claude mcp remove codemyspec-stories
```

## Claude Desktop

Point and click. No config file needed.

1. Open Claude Desktop &rarr; **Settings** &rarr; **Customize**
2. Click **Add Connector**
3. Paste the URL: `https://www.codemyspec.com/mcp/stories`
4. Sign in when the OAuth window opens

The connector shows up in the chat input immediately. No restart required.

## Cursor

Edit `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (per project):

```json
{
  "mcpServers": {
    "codemyspec-stories": {
      "url": "https://www.codemyspec.com/mcp/stories"
    }
  }
}
```

Restart Cursor. Open Settings &rarr; MCP to confirm the server is connected.

## First use

In your AI client, ask naturally:

> "I want to add a feature where logged-in drivers can log their fill-ups. Help me turn that into user stories."

The client will call `start_story_session` with mode `"interview"` and the AI will walk you through a PM-style conversation, producing well-formed stories with acceptance criteria.

To review what's already in your project:

> "Review my project's user stories for quality."

This triggers `start_story_session` with mode `"review"`.

## Picking an account or project

The server scopes every call to your **active account** and **active project**. Set these once:

1. Sign in at [codemyspec.com](https://www.codemyspec.com)
2. From the top-right menu, pick an account
3. From the project picker, pick a project

All MCP calls from your client use those as scope until you change them.

## Available tools

The server exposes 17 tools covering story CRUD, acceptance criteria, tagging, guided sessions, and issue triage. See the [Stories MCP tool reference](/pages/stories-mcp-server) for full parameter details.

## Troubleshooting

**OAuth window doesn't open.** Check your client's logs. For Claude Desktop, open the Developer pane in Settings &rarr; Developer and look at the server's stderr.

**"Not authenticated" after signing in.** Your token may be cached against a different account. Revoke and reconnect from your client's MCP settings.

**"No active project."** Sign in to [codemyspec.com](https://www.codemyspec.com) and pick a project from the project picker before calling tools.

**Tools don't appear in the client.** Confirm the server is listed as connected (hammer icon in Claude Desktop, MCP panel in Cursor). Some clients require a restart after config changes.
