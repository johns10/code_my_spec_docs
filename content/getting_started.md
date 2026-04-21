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

The installer detects your OS and architecture, then downloads the `cms` binary from the latest GitHub release.

The extension ships with:

- A local Phoenix server on port **4003** with an admin LiveView UI at `/init` and `/projects/...`
- The **LocalServer** MCP with tools for requirements, tasks, architecture, stories, issues, knowledge, and hexdocs
- The skill suite: `codemyspec:design`, `codemyspec:implement`, `codemyspec:qa`, `codemyspec:develop`, and more
- Hooks wired into Claude Code's `SessionStart`, `PreToolUse`, `PostToolUse`, and `Stop` lifecycle for automatic evaluation

## 2. Sign in

The extension runs a Phoenix app locally. Open the admin UI in your browser:

```
http://localhost:4003/init
```

Click **Sign in**. This kicks off an OAuth PKCE flow against the CodeMySpec server, opens your default browser to authorize, and persists the token locally.

Alternatively, inside Claude Code the agent can call the `list_projects` MCP tool. If you're not authenticated, the response will include an auth URL for you to visit.

## 3. Link your project

Pick a CodeMySpec project and link it to your working directory.

**From the admin UI:**

1. Go to `http://localhost:4003/projects`
2. Pick a project and link it to your Phoenix project's working directory

**Or from inside Claude Code** (with your Phoenix project as the working directory):

1. `list_projects` &mdash; returns projects in your account
2. `init_project` with the `project_id` &mdash; sets `local_path` to `$PWD` on the project record

## 4. Run the setup loop

Inside Claude Code, ask the agent to run the project setup. It evaluates 12 steps and inlines prompts for any that are incomplete:

| Step | What it does |
|---|---|
| `ApplicationInWeb` | Restructure application files into a `_web` boundary |
| `CodemyspecDeps` | Add required hex dependencies |
| `Compilers` | Wire the `boundary` compiler |
| `SpexConfig` | Configure Spex for BDD tests |
| `TestBoundaries` | Tag test files with their boundaries |
| `TestSupportNamespace` | Move test support under the app namespace |
| `ProjectStructure` | Create `.code_my_spec/` directories |
| `IgnoredPaths` | Add `.gitignore` entries |
| `AgentsMd` | Install `.code_my_spec/AGENTS.md` |
| `Rules` | Copy design and test rules per component type |
| `CredoChecks` | Install the Credo configuration |
| `ClaudeMd` | Install the managed section in `CLAUDE.md` |

Each step is idempotent. Order doesn't matter &mdash; the setup loop re-evaluates every step each run and only prompts for incomplete ones.

## 5. Drive development with the requirement graph

Once setup passes, the main loop is:

```
get_next_requirement → start_task → (do the work) → evaluate_task → repeat
```

The graph computes what to work on next based on prerequisites: specs before tests, tests before implementation, implementation before review. Follow the task prompts &mdash; they include file paths, spec templates, and the rules for the component type.

## Project structure

After setup, your project contains:

```
.code_my_spec/
├── architecture/     Component graph, dependency diagram, decisions
├── spec/             Module specifications (*.spec.md)
├── rules/            Design and test rules by component type
├── status/           Implementation status per component
├── issues/           incoming/, accepted/, dismissed/
├── knowledge/        Project-specific research
├── qa/               QA briefs, results, journey plans
├── plugin_knowledge/ Framework reference docs (from the extension)
└── integrations/     Integration specs
```

## What's running locally

Once the extension is loaded, Claude Code starts a Phoenix app on port 4003 with:

- **MCP endpoint** at `http://localhost:4003/mcp` (with `X-Working-Dir` header set by the plugin)
- **Admin LiveView UI** at `http://localhost:4003/projects/:project_name/...` &mdash; requirements, architecture graph, stories, issues, sessions, knowledge browser
- **REST API** for hook callbacks, skill dispatching, notifications, and permission requests

Claude Code connects to the MCP server via the extension's `plugin.json`. You usually won't hit the REST API directly &mdash; the skills and hooks do.

## Just want the Product Manager?

If you're not using Claude Code and only want to interview stories with AI, add the remote Stories MCP server to your MCP client:

```
https://www.codemyspec.com/mcp/stories
```

See [Stories MCP server](/pages/stories-mcp-server) for the full tool reference.

## Troubleshooting

**Extension server not running.** Claude Code starts the extension via the `SessionStart` hook. If the server isn't up, check:

```bash
curl http://localhost:4003/health
```

**macOS blocks the binary.** Allow it under System Preferences &rarr; Security & Privacy.

**Auth token expired.** Revisit `http://localhost:4003/init` and sign in again.
