# Getting Started

Get a Phoenix project wired up with CodeMySpec in about 10 minutes.

## Prerequisites

- Elixir ~> 1.18
- PostgreSQL
- Git
- Claude Code (CLI)
- The `cms` CLI tool

## 1. Create Your Phoenix Project

```bash
mix phx.new your_project_name --database postgres
cd your_project_name
```

## 2. Authenticate

The local server runs at `localhost:4001` and handles OAuth PKCE automatically.

```bash
# Start the local server, then:
# POST /api/bootstrap/auth/start    → begins OAuth flow
# GET  /api/bootstrap/auth/status   → check if authenticated
```

## 3. Initialize

```bash
cms init -p PROJECT_ID
```

This creates `.code_my_spec/` as a Git submodule and generates `config.yml`:

```yaml
project_id: "your-project-id"
account_id: "your-account-id"
module_name: YourProjectName
name: Your Project Name
code_repo: "https://github.com/you/your_project"
docs_repo: "https://github.com/you/your_project_docs"
client_api_url: "https://www.codemyspec.com/api"
```

## 4. Install Scaffolding

```bash
# Run full setup at once:
# POST /api/bootstrap/setup

# Or individually:
# POST /api/bootstrap/install-symlinks     → framework/ and tools/
# POST /api/bootstrap/install-agents-md    → development guide
# POST /api/bootstrap/install-claude-md    → CLAUDE.md managed section
# POST /api/bootstrap/install-rules        → coding standards
```

**CLAUDE.md** gets an auto-managed section between `code_my_spec:start` and `code_my_spec:end` HTML comment markers. Add your own content outside them.

**AGENTS.md** is generated per-project — the full development guide agents reference during sessions.

## 5. Add Dependencies

```elixir
defp deps do
  [
    # ... your Phoenix deps ...
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
    {:boundary, "~> 0.10", runtime: false},
    {:client_utils, git: "https://github.com/johns10/client_utils"},
    {:sexy_spex, git: "https://github.com/johns10/sexy_spex"}
  ]
end
```

```bash
mix deps.get
```

## 6. Sync

```bash
cms sync
```

Pulls stories, components, requirements, and other project data for local agent use.

## MCP Servers

Five servers, no extension needed — AI agents access them directly via MCP protocol.

**Web (OAuth2):**
- Components (`/mcp/components`) — 17 tools
- Stories (`/mcp/stories`) — 12 tools
- Analytics Admin (`/mcp/analytics-admin`) — 14 tools

**Local only:**
- Architecture (`/mcp/architecture`) — 2 tools
- Issues — 1 tool

## Directory Structure

```
.code_my_spec/
├── config.yml          # Project config
├── AGENTS.md           # Generated dev guide
├── architecture/       # Component graph + ADRs
├── spec/               # Module specifications
├── status/             # Implementation status
├── rules/              # Coding standards (editable)
├── knowledge/          # Research
├── framework/          # → priv/knowledge/ (symlink)
├── tools/              # → priv/tools/ (symlink)
├── qa/                 # QA results
├── issues/             # Bug tracking
├── tasks/              # Task prompts
└── content/            # Website content
```

## Verify

```bash
mix test
mix phx.server
```

You're up. Claude Code agents can now work with your project through the structured task system.
