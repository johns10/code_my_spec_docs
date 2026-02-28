# Replace MCP with Bash-Based Tools

## Problem

MCP has been unreliable for local-machine tool access. The protocol adds unnecessary complexity (SSE transport, connection handshakes, Hermes frame management) for what amounts to "call a function and get a result." The architecture server exposes only 3 tools (`list_stories`, `analyze_stories`, `validate_dependency_graph`), yet requires a full MCP server with protocol negotiation, session management, and a dedicated transport layer.

The plugin already works primarily through bash scripts (`bin/agent-task`) that curl the LocalServer REST API. MCP is a thin, fragile layer on top of infrastructure that already works.

## Solution

Replace MCP tools with simple bash scripts in a `tools/` directory at the plugin root. Each tool is a standalone executable that either:
- Calls the LocalServer REST API (for data operations needing the database)
- Performs filesystem operations directly (for listing specs, reading files)
- Runs Mix tasks or Elixir one-liners (for more complex local logic)

Tools are made discoverable to agents through skill `allowed-tools` patterns and agent prompt instructions.

## Architecture

```
Before:
  Claude Code → MCP protocol → Hermes SSE → McpPlug → ArchitectureServer → Tool Module → Business Logic

After:
  Claude Code → Bash tool → tools/list-stories → curl localhost:4002/api/stories → JSON response
  Claude Code → Bash tool → tools/list-specs → ls docs/specs/*.md → text output
```

## Plugin Structure Changes

```
CodeMySpec/
  .claude-plugin/
    plugin.json              # Remove mcpServers section entirely
    bin/
      agent-task             # Keep - starts agent sessions
      hook                   # Keep - handles Claude Code hooks
      ...
  tools/                     # NEW - agent-callable tools
    list-stories             # curl GET /api/stories
    get-story                # curl GET /api/stories/:id
    analyze-stories          # curl GET /api/stories/analyze
    validate-deps            # curl GET /api/architecture/validate-deps
    show-architecture        # curl GET /api/architecture/show
    list-specs               # ls docs/specs/*.md (pure filesystem)
    list-components          # curl GET /api/components
    architecture-health      # curl GET /api/architecture/health
  skills/                    # Update allowed-tools in SKILL.md files
  agents/                    # Update tool references in agent definitions
  hooks/
```

## Implementation Plan

### Phase 1: Add REST API Endpoints to LocalServer

Add simple JSON endpoints for the 3 operations currently behind MCP, plus commonly needed data operations. These go alongside the existing agent-tasks and hooks endpoints.

**New routes in `LocalServer.Router`:**

```elixir
# Story endpoints
get "/api/stories" do          # list (with ?tag=, ?search=, ?limit=, ?offset= params)
  ...
end

get "/api/stories/analyze" do  # analyze stories by tags
  ...
end

get "/api/stories/:id" do      # get single story
  ...
end

# Architecture endpoints
get "/api/architecture/validate-deps" do    # validate dependency graph
  ...
end

get "/api/architecture/show" do             # show architecture view
  ...
end

get "/api/architecture/health" do           # architecture health summary
  ...
end

# Component endpoints
get "/api/components" do                    # list components
  ...
end
```

**New controller: `LocalServer.Controllers.ToolsController`**

A single controller handling all tool-oriented read endpoints. Each action:
1. Extracts query params
2. Calls existing business logic (same functions MCP tools call)
3. Returns JSON (or formatted markdown text)

The existing plugs pipeline (LocalOnly → WorkingDir → LocalScope) applies to all tool routes, providing the scope automatically.

### Phase 2: Create Bash Tool Scripts

Each script in `tools/` follows a consistent pattern:

```bash
#!/bin/bash
# tools/list-stories - List project stories with optional filters
#
# Usage: list-stories [--tag TAG] [--search QUERY] [--limit N]
# Returns: Formatted story list with IDs, titles, and tags

set -euo pipefail
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${CODEMYSPEC_PORT:-4002}"
BASE="http://localhost:${PORT}"

# --help support
if [ "${1:-}" = "--help" ]; then
  head -n 6 "$0" | tail -n 4 | sed 's/^# //'
  exit 0
fi

# Build query string from args
QUERY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tag)    QUERY="${QUERY}&tag=$2"; shift 2 ;;
    --search) QUERY="${QUERY}&search=$2"; shift 2 ;;
    --limit)  QUERY="${QUERY}&limit=$2"; shift 2 ;;
    *)        shift ;;
  esac
done

curl -sf "${BASE}/api/stories?${QUERY#&}" \
  -H "X-Working-Dir: $(pwd)"
```

**Tool categories:**

| Tool | Type | Endpoint / Command |
|------|------|--------------------|
| `list-stories` | API | `GET /api/stories` |
| `get-story` | API | `GET /api/stories/:id` |
| `analyze-stories` | API | `GET /api/stories/analyze` |
| `validate-deps` | API | `GET /api/architecture/validate-deps` |
| `show-architecture` | API | `GET /api/architecture/show` |
| `architecture-health` | API | `GET /api/architecture/health` |
| `list-components` | API | `GET /api/components` |
| `list-specs` | Filesystem | `ls docs/specs/*.md` |
| `show-spec` | Filesystem | `cat docs/specs/$1.md` |
| `list-tests` | Filesystem | `find test/ -name "*_test.exs"` |
| `run-spex` | Mix | `mix spex` |

### Phase 3: Update Skills to Use Bash Tools

Update `allowed-tools` in all SKILL.md files that currently reference MCP tools.

**Before (`design-architecture/SKILL.md`):**
```yaml
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, mcp__plugin_codemyspec_architecture-server__*
```

**After:**
```yaml
allowed-tools: Bash(*/agent-task *), Bash(*/tools/* *), Read, Write, Glob, Grep
```

The `Bash(*/tools/* *)` pattern gives the skill access to all tools in the `tools/` directory. For skills that only need specific tools, use more targeted patterns like `Bash(*/tools/list-stories *)`.

### Phase 4: Update Agent Task Prompts

Agent tasks that currently instruct the agent to use MCP tools need updated prompts. The prompt returned by `agent-task` should reference the bash tools instead.

**Before** (in agent task prompt):
```
Use the `analyze_stories` MCP tool to group stories by tags.
```

**After:**
```
Run `${CLAUDE_PLUGIN_ROOT}/tools/analyze-stories` to group stories by tags.
```

Or, since `allowed-tools: Bash(*/tools/*)` makes them available, the agent can just be told:
```
Run `analyze-stories` from the tools directory to group stories by tags.
```

### Phase 5: Remove MCP Infrastructure

Once all tools are migrated and verified:

1. **plugin.json** - Remove `mcpServers` section entirely
2. **CLI application.ex** - Remove `{CodeMySpec.McpServers.ArchitectureServer, transport: {:streamable_http, start: true}}` from children
3. **LocalServer router** - Remove `forward "/mcp/architecture"` route
4. **Delete files:**
   - `lib/code_my_spec/local_server/mcp_plug.ex`
   - `lib/code_my_spec/mcp_servers/architecture_server.ex`
   - `lib/code_my_spec/mcp_servers/architecture/` directory
   - Related test files
5. **Evaluate Hermes dependency** - If no other MCP servers remain, remove `hermes_mcp` from deps

**Note:** The StoriesServer, ComponentsServer, and AnalyticsAdminServer are used by the web app, not the CLI plugin. They can stay as-is or be migrated separately. This plan only addresses the CLI/plugin MCP usage.

## Tool Discovery & Discoverability

### How agents find tools

1. **Skill-level gating** - `allowed-tools: Bash(*/tools/*)` in SKILL.md controls which tools a skill can invoke
2. **Agent prompts** - Agent task prompts list available tools with usage examples
3. **Self-documenting** - Every tool supports `--help` for usage info
4. **Naming convention** - Tool names match their function: `list-stories`, `get-story`, `validate-deps`

### Optional: Tool index

A `tools/README.md` or `tools/index` file listing all tools with one-line descriptions. Agent prompts can reference this:

```
For available tools, run: ls ${CLAUDE_PLUGIN_ROOT}/tools/
For tool usage, run: ${CLAUDE_PLUGIN_ROOT}/tools/<name> --help
```

## Response Format Convention

Tools should return **human-readable text by default** with an optional `--json` flag for structured output:

```bash
# Default: formatted markdown (for agents reading output)
$ tools/list-stories
## Stories (12 total)

1. [abc123] User can log in
   Tags: auth, mvp
2. [def456] User can reset password
   Tags: auth
...

# Structured: JSON (for piping/parsing)
$ tools/list-stories --json
{"stories": [...], "total": 12}
```

This gives agents nicely formatted context while preserving programmatic access.

## What You Gain

- **Debuggability** - Run any tool directly in terminal: `./tools/list-stories --tag auth`
- **Reliability** - No MCP connection handshakes, no SSE keepalives, no protocol negotiation
- **Simplicity** - Each tool is a 10-30 line bash script
- **Speed** - Direct HTTP call or filesystem op, no protocol layer
- **Composability** - Tools can pipe into each other: `tools/list-stories --json | jq '.stories[].id'`
- **Transparency** - Agent tool calls show up as bash commands in the conversation

## What You Lose

- **Schema validation** - MCP validates params before your code runs. Mitigated by: bash arg parsing + server-side validation on API endpoints
- **Auto-description** - MCP tools self-describe to Claude. Mitigated by: `--help` flags and agent prompt instructions

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/local_server/controllers/tools_controller.ex` | REST endpoints for tool operations |
| `CodeMySpec/tools/list-stories` | Bash tool: list stories |
| `CodeMySpec/tools/get-story` | Bash tool: get single story |
| `CodeMySpec/tools/analyze-stories` | Bash tool: analyze stories by tags |
| `CodeMySpec/tools/validate-deps` | Bash tool: validate dependency graph |
| `CodeMySpec/tools/show-architecture` | Bash tool: show architecture view |
| `CodeMySpec/tools/architecture-health` | Bash tool: architecture health summary |
| `CodeMySpec/tools/list-components` | Bash tool: list components |
| `CodeMySpec/tools/list-specs` | Bash tool: list spec files (filesystem) |

## Files to Modify

| File | Changes |
|------|---------|
| `CodeMySpec/.claude-plugin/plugin.json` | Remove `mcpServers` section |
| `lib/code_my_spec/local_server/router.ex` | Add REST API routes for tools |
| `lib/code_my_spec_cli/application.ex` | Remove ArchitectureServer from supervision tree |
| `CodeMySpec/skills/design-architecture/SKILL.md` | Replace MCP tool refs with `Bash(*/tools/*)` |
| Other SKILL.md files referencing MCP | Same pattern |

## Files to Delete

| File | Reason |
|------|--------|
| `lib/code_my_spec/local_server/mcp_plug.ex` | No more MCP routing |
| `lib/code_my_spec/mcp_servers/architecture_server.ex` | Replaced by REST endpoints |
| `lib/code_my_spec/mcp_servers/architecture/` | Tool modules no longer needed |
| Related test files | Tests for removed code |

## Migration Path

1. Add REST endpoints (Phase 1) - additive, nothing breaks
2. Create bash tools (Phase 2) - additive, nothing breaks
3. Update one skill as proof of concept (Phase 3) - test with `design-architecture`
4. Verify end-to-end: `/design-architecture` works with bash tools instead of MCP
5. Update remaining skills (Phase 3 continued)
6. Remove MCP infrastructure (Phase 5) - only after all skills migrated

## Verification

1. **Tool scripts work standalone:**
   ```bash
   cd /path/to/project
   ./tools/list-stories
   ./tools/list-stories --tag auth
   ./tools/get-story abc123
   ./tools/validate-deps
   ```

2. **Skills work end-to-end:**
   - Run `/design-architecture` in Claude Code
   - Agent should invoke tools via bash instead of MCP
   - Same results, no MCP errors

3. **MCP fully removed:**
   - No `mcpServers` in plugin.json
   - No MCP-related processes in supervision tree
   - `curl localhost:4002/mcp/architecture` returns 404
