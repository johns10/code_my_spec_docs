# SexySpex.Helpers

Common helper functions for spex files.

These helpers provide reusable patterns for application startup,
connectivity testing, and other common spex operations.

## application_running?(app_name)

Checks if an application is currently running.

## can_connect_to_scenic_mcp?(port)

Checks if we can connect to a Scenic MCP server on the given port.

## start_scenic_app(app_name, opts \\ [])

Starts a Scenic application with MCP server and waits for it to be ready.

This helper handles the common pattern of:
1. Ensuring compilation (needed for mix spex)
2. Starting the application
3. Waiting for MCP server
4. Setting up cleanup

## Parameters
- `app_name` - The application atom (e.g., `:quillex`)
- `opts` - Optional configuration
  - `:port` - MCP server port (default: 9999)
  - `:timeout_retries` - Connection timeout retries (default: 20)

## Returns
- `{:ok, context}` with app_name and port on success
- Raises on failure

## Example
    setup_all do
      start_scenic_app(:quillex)
    end

## wait_for_mcp_server(port, retries \\ 20)

Waits for MCP server to be ready with configurable retries.