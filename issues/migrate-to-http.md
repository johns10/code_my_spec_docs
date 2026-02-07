# HTTP-Based MCP Server Architecture

## Problem
The MCP CLI has a 2-3 second cold start due to BEAM/OTP boot time. Every Claude Code tool call pays this penalty.

## Solution
Remove stdio transport entirely. Run Phoenix server locally, Claude Code connects directly via HTTP/SSE.

## Architecture

```
Claude Code Instance 1                Phoenix Server (localhost:4000)
┌─────────────────────────┐           ┌─────────────────────────────┐
│ HTTP/SSE MCP Client     │ ────────► │ /mcp/architecture           │
│ Header: X-Working-Dir   │           │ ├─ StreamableHTTP transport │
└─────────────────────────┘           │ └─ ArchitectureServer       │
                                      │                             │
Claude Code Instance 2                │ Sessions isolated by:       │
┌─────────────────────────┐           │ - Session ID (existing)     │
│ HTTP/SSE MCP Client     │ ────────► │ - Working directory (new)   │
│ Header: X-Working-Dir   │           └─────────────────────────────┘
└─────────────────────────┘
```

## Key Changes

### 1. Plugin Configuration (HTTP instead of stdio)

**Before** (`plugin.json`):
```json
{
  "mcpServers": {
    "architecture-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/bin/mcp",
      "args": []
    }
  }
}
```

**After**:
```json
{
  "mcpServers": {
    "architecture-server": {
      "type": "sse",
      "url": "http://localhost:4000/mcp/architecture",
      "headers": {
        "X-Working-Dir": "${PWD}"
      }
    }
  }
}
```

### 2. Add Working Directory Context

**Modify: Router pipeline** (`lib/code_my_spec_web/router.ex`)

Add plug to extract and validate working directory from header:
```elixir
pipeline :mcp_local do
  plug :extract_working_dir  # New - reads X-Working-Dir header
  plug :require_local_only   # Security - only accept localhost
end

scope "/mcp" do
  pipe_through [:mcp_local]
  forward "/architecture", Hermes.Server.Transport.StreamableHTTP.Plug,
    server: CodeMySpec.McpServers.ArchitectureServer
end
```

### 3. Server Lifecycle Management

**New: CLI subcommands for server management**

```bash
codemyspec server start    # Start Phoenix server in background
codemyspec server stop     # Stop the server
codemyspec server status   # Show if running, port, connected sessions
```

**New file: `lib/code_my_spec_cli/commands/server.ex`**

```elixir
defmodule CodeMySpecCli.Commands.Server do
  def start do
    case check_server_running() do
      {:ok, :running} -> IO.puts("Server already running on port 4000")
      {:error, :not_running} -> start_server_daemon()
    end
  end

  defp start_server_daemon do
    # Start as detached process, write PID to ~/.codemyspec/server.pid
    # Use Port.open or :os.cmd to spawn
  end
end
```

### 4. Auto-Start via LaunchAgent

Server starts on login, always available. Zero friction.

**New file: `~/Library/LaunchAgents/com.codemyspec.server.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.codemyspec.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/codemyspec</string>
        <string>server</string>
        <string>run</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/codemyspec.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/codemyspec.error.log</string>
</dict>
</plist>
```

**CLI commands to manage LaunchAgent:**

```bash
codemyspec server install   # Install and load LaunchAgent
codemyspec server uninstall # Unload and remove LaunchAgent
codemyspec server start     # Manual start (if not using LaunchAgent)
codemyspec server stop      # Stop server
codemyspec server status    # Show status
```

**New file: `lib/code_my_spec_cli/commands/server.ex`**

```elixir
defmodule CodeMySpecCli.Commands.Server do
  @plist_path "~/Library/LaunchAgents/com.codemyspec.server.plist"

  def install do
    write_plist()
    System.cmd("launchctl", ["load", Path.expand(@plist_path)])
    IO.puts("Server installed and started")
  end

  def uninstall do
    System.cmd("launchctl", ["unload", Path.expand(@plist_path)])
    File.rm(Path.expand(@plist_path))
    IO.puts("Server uninstalled")
  end

  def run do
    # Called by LaunchAgent - runs server in foreground
    # Starts Phoenix with PHX_SERVER=true
  end
end
```

### 5. Session Working Directory Isolation

**Modify: `ArchitectureServer` and tool components**

Store working_dir in session context, not global app env:
```elixir
# In Plug - extract from header and add to context
def call(conn, opts) do
  working_dir = get_req_header(conn, "x-working-dir") |> List.first()
  context = %{working_dir: working_dir}
  # Pass context through to session
end

# In tool handlers - use context.working_dir instead of Application.get_env
def handle_call(%{params: params}, context) do
  working_dir = context.working_dir
  # Use working_dir for file operations
end
```

## Files to Modify

| File | Changes |
|------|---------|
| `CodeMySpec/.claude-plugin/plugin.json` | Change to SSE transport with URL |
| `lib/code_my_spec_web/router.ex` | Add local MCP pipeline, working_dir plug |
| `lib/code_my_spec/mcp_servers/architecture_server.ex` | Use context.working_dir |
| `lib/code_my_spec_cli/cli.ex` | Add `server` subcommand, remove `mcp` stdio code |

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec_cli/commands/server.ex` | Server start/stop/status commands |
| `lib/code_my_spec_web/plugs/working_dir.ex` | Extract working_dir from header |
| `lib/code_my_spec_web/plugs/local_only.ex` | Security - reject non-localhost |

## Files to Delete

| File | Reason |
|------|--------|
| `CodeMySpec/bin/mcp` | No longer needed - no stdio transport |

## Security Considerations

1. **Local-only access**: MCP endpoint should reject non-localhost connections
2. **Working directory validation**: Validate path exists and is accessible
3. **No OAuth for local**: Skip OAuth for localhost connections (already have file access)

## Verification

1. **Start server**
   ```bash
   codemyspec server start
   # Server starts on localhost:4000
   ```

2. **Check server status**
   ```bash
   codemyspec server status
   # Server running on port 4000, 0 active sessions
   ```

3. **Claude Code connects**
   - Open project, Claude Code auto-connects via HTTP
   - Tools work immediately (no cold start)

4. **Multiple instances**
   - Open second project in new window
   - Both connect to same server, isolated sessions

5. **Stop server**
   ```bash
   codemyspec server stop
   # Server stopped
   ```

## Configuration

```elixir
# config/config.exs
config :code_my_spec,
  local_mcp_port: 4000,
  server_idle_timeout_ms: :timer.hours(1)  # 0 = run forever
```

## Migration Path

1. Add HTTP endpoint alongside existing stdio
2. Test with manual plugin.json override
3. Update plugin.json to use HTTP by default
4. Remove stdio transport code

## Sources

- [Claude Code MCP Configuration](https://code.claude.com/docs/en/mcp)
- [SSE Transport Configuration](https://mehmetbaykar.com/posts/adding-mcp-servers-in-claude-code/)
