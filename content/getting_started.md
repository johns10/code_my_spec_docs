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

## 2. Sign in

Inside Claude Code, with your Phoenix project as `$PWD`:

```
/codemyspec:init auth
```

The skill opens `http://localhost:4003/auth` in your browser. Click **Sign in** — OAuth PKCE runs against the CodeMySpec server and the token is stored locally. You only do this once (tokens refresh automatically).

Without a token, every MCP tool returns `not_authenticated` and stops. If you skip the skill you can hit the URL directly; the result is the same.

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

Beyond `/auth` and `/projects`, the extension's LiveView UI at `http://localhost:4003/projects/:project_name/...` gives you:

- **Init checklist** at `/projects/:project_name/init` — the 6-step pre-setup checklist (Auth, Elixir, Phoenix installer, PostgreSQL, Phoenix project, CLI config) with per-step instructions. Same data `get_next_requirement` walks the agent through, rendered for humans.
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
