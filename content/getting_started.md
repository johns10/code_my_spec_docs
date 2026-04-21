# Getting Started

Get a Phoenix project running on CodeMySpec in about 10 minutes.

## Prerequisites

- Elixir 1.18+, Phoenix 1.8+, PostgreSQL
- [Claude Code](https://docs.claude.com/claude-code) CLI
- A [CodeMySpec account](https://www.codemyspec.com/users/register)

## 1. Install the extension

Clone the extension repo, run the installer, and register it with Claude Code:

```bash
git clone https://github.com/Code-My-Spec/code_my_spec_claude_code_extension
cd code_my_spec_claude_code_extension
./install.sh
claude extension add $(pwd)
```

The installer detects your OS and architecture, then downloads the `cms` binary from the latest GitHub release. Starting the extension launches a local Phoenix app on port **4003** with an admin UI, the MCP server, the skill suite, and hooks wired into Claude Code's lifecycle.

## 2. Sign in (do this first)

Before your agent calls any MCP tool, you need a valid OAuth token. Open the admin UI in your browser:

```
http://localhost:4003/auth
```

Click **Sign in**. This runs an OAuth PKCE flow against the CodeMySpec server and stores the token locally.

You have to do this before running anything else. If the agent calls `list_projects` without a token, it'll get a `not_authenticated` error and stop &mdash; it won't prompt you to sign in.

## 3. Link your project

From the admin UI, go to `http://localhost:4003/projects`, pick a project, and point it at your Phoenix project directory.

Or inside Claude Code (with your Phoenix project as `$PWD`), tell the agent to link it. The agent calls `list_projects`, then `init_project` with the `project_id`. That sets `local_path` to `$PWD` on the project record.

## 4. Run the setup loop

Inside Claude Code, ask the agent to run project setup. It runs the `ProjectSetup` task, which renders a 12-step checklist and inlines the prompt for every incomplete step. Each step is idempotent; order doesn't matter. Re-run until everything checks off.

## 5. Drive development with the requirement graph

Once setup passes, the main loop is:

```
get_next_requirement → start_task → (do the work) → evaluate_task → repeat
```

The graph computes what to work on next based on prerequisites: specs before tests, tests before implementation, implementation before review. Follow the task prompts &mdash; they include file paths, spec templates, and the rules for the component type. `AGENTS.md` (installed during setup) has the full workflow reference.

## The local admin UI

Beyond `/auth` and `/projects`, the extension's LiveView UI at `http://localhost:4003/projects/:project_name/...` gives you:

- Requirements list and graph view
- Architecture overview and dependency graph
- Stories, issues, sessions, knowledge browser

Useful when you want to see what the agent sees without asking it.

## Just want the Product Manager?

If you're not using Claude Code and only want to interview stories with AI, add the remote Stories MCP server to your MCP client. See [Stories MCP setup](/documentation/stories-mcp-setup).

## Troubleshooting

**Extension server not running.** Claude Code starts the extension via the `SessionStart` hook. Check:

```bash
curl http://localhost:4003/health
```

**`not_authenticated` error.** Visit `http://localhost:4003/auth` and sign in before calling any MCP tool.

**macOS blocks the binary.** Allow it under System Preferences &rarr; Security & Privacy.

**Auth token expired.** Revisit `http://localhost:4003/auth` and sign in again.
