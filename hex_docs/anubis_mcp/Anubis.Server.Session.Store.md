# Anubis.Server.Session.Store

Behaviour for session persistence adapters.

This module defines the interface for implementing session storage backends
that can persist MCP session state across server restarts. Implementations
can use various storage solutions like Redis, PostgreSQL, ETS, or any other
persistence mechanism.

## Implementing a Store

To implement a custom session store, create a module that implements all
the callbacks defined in this behaviour:

    defmodule MyApp.RedisStore do
      @behaviour Anubis.Server.Session.Store

      def start_link(opts) do
        # Initialize connection to storage backend
      end

      def save(session_id, state, opts) do
        # Persist session state
        :ok
      end

      def load(session_id, opts) do
        # Retrieve session state
        {:ok, state}
      end

      # ... implement other callbacks
    end

## Using a Store

Configure the session store in your application config:

    config :anubis_mcp, :session_store,
      adapter: MyApp.RedisStore,
      redis_url: "redis://localhost:6379",
      ttl: 1800

## Session Security

Stores should implement appropriate security measures:
- Generate secure session tokens for validation
- Encrypt sensitive data before storage
- Validate session ownership on reconnection
- Implement proper TTL for automatic cleanup

## cleanup_expired/1

Cleans up expired sessions.

Removes all sessions that have exceeded their TTL. Should be called
periodically or on-demand.

## Parameters
  * `opts` - Additional options

## Returns
  * `{:ok, count}` - Number of sessions cleaned up
  * `{:error, reason}` - Failed to cleanup sessions

## delete/2

Deletes a session from the storage backend.

Removes all data associated with a session. Should be idempotent,
returning success even if the session doesn't exist.

## Parameters
  * `session_id` - Unique identifier for the session
  * `opts` - Additional options

## Returns
  * `:ok` - Session deleted or didn't exist
  * `{:error, reason}` - Failed to delete session

## list_active/1

Lists all active sessions.

Returns a list of session IDs that are currently stored and not expired.
Useful for session recovery on server startup.

## Parameters
  * `opts` - Additional options (e.g., filter by server)

## Returns
  * `{:ok, [session_id]}` - List of active session IDs
  * `{:error, reason}` - Failed to list sessions

## load/2

Loads a session state from the storage backend.

Retrieves and deserializes a previously saved session state.
Should handle expired sessions by returning an appropriate error.

## Parameters
  * `session_id` - Unique identifier for the session
  * `opts` - Additional options

## Returns
  * `{:ok, state}` - Session state retrieved successfully
  * `{:error, :not_found}` - Session does not exist
  * `{:error, :expired}` - Session has expired
  * `{:error, reason}` - Other retrieval error

## save/3

Saves a session state to the storage backend.

The implementation should serialize the session state and persist it
with appropriate TTL settings.

## Parameters
  * `session_id` - Unique identifier for the session
  * `state` - The session state map to persist
  * `opts` - Additional options (e.g., TTL, namespace)

## Returns
  * `:ok` - Session saved successfully
  * `{:error, reason}` - Failed to save session

## start_link/1

Starts the storage backend.

This is called during application startup to initialize the storage
connection and any required resources.

## Parameters
  * `opts` - Configuration options for the storage backend

## Returns
  * `{:ok, pid}` - Storage backend started successfully
  * `{:error, reason}` - Failed to start storage backend

## update/3

Performs atomic update of session state.

Updates specific fields in the session state without overwriting the entire
state. Useful for concurrent updates.

## Parameters
  * `session_id` - Unique identifier for the session
  * `updates` - Map of fields to update
  * `opts` - Additional options

## Returns
  * `:ok` - Session updated successfully
  * `{:error, :not_found}` - Session doesn't exist
  * `{:error, reason}` - Failed to update session

## update_ttl/3

Updates the TTL for a session.

Extends or shortens the expiration time for an existing session.
Useful for keeping active sessions alive.

## Parameters
  * `session_id` - Unique identifier for the session
  * `ttl_ms` - New TTL in milliseconds
  * `opts` - Additional options

## Returns
  * `:ok` - TTL updated successfully
  * `{:error, :not_found}` - Session doesn't exist
  * `{:error, reason}` - Failed to update TTL