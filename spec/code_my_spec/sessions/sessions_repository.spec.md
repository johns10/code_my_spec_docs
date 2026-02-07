# CodeMySpec.Sessions.SessionsRepository

**Type**: repository

Filesystem-backed CRUD for sessions. Each session is a directory under `.code_my_spec/internal/sessions/{id}/` containing a `session.json` file. All file operations go through `CodeMySpec.Environments` so the repository works across CLI, local, and VS Code environments.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Sessions.Session

## Functions

### create_session/2

Create a new session directory and write session.json.

```elixir
@spec create_session(Environment.t(), map()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Build Session changeset from attrs
2. Generate UUID for id if not provided
3. Create directory at `.code_my_spec/internal/sessions/{id}/`
4. Write `session.json` via `Environments.write_file/3`
5. Return `{:ok, session}`

**Test Assertions**:
- creates session directory and writes session.json
- generates UUID when id not provided
- returns error for invalid attrs (e.g. missing type)
- session.json is valid JSON that roundtrips through from_json

### get_session/2

Read a session by ID from its directory.

```elixir
@spec get_session(Environment.t(), String.t()) :: {:ok, Session.t()} | {:error, :not_found}
```

**Process**:
1. Read `.code_my_spec/internal/sessions/{id}/session.json` via `Environments.read_file/2`
2. Decode JSON and build Session struct via `Session.from_json/1`
3. Return `{:ok, session}` or `{:error, :not_found}`

**Test Assertions**:
- returns session struct for existing session
- returns `{:error, :not_found}` when directory doesn't exist
- returns `{:error, :not_found}` when session.json is missing

### list_sessions/1

List all sessions from the sessions directory.

```elixir
@spec list_sessions(Environment.t()) :: {:ok, [Session.t()]}
```

**Process**:
1. List directories under `.code_my_spec/internal/sessions/` via `Environments.list_directory/2`
2. Read and parse `session.json` from each directory
3. Skip directories with missing or malformed session.json
4. Return list of Session structs

**Test Assertions**:
- returns all sessions as structs
- returns empty list when sessions directory is empty or missing
- skips directories with invalid session.json

### update_session/2

Update a session by rewriting its session.json.

```elixir
@spec update_session(Environment.t(), Session.t()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Serialize session via `Session.to_json/1`
2. Write to `.code_my_spec/internal/sessions/{id}/session.json` via `Environments.write_file/3`
3. Return `{:ok, session}`

**Test Assertions**:
- overwrites session.json with updated data
- returns error when session directory doesn't exist

### delete_session/2

Remove a session directory and all its contents.

```elixir
@spec delete_session(Environment.t(), String.t()) :: :ok
```

**Process**:
1. Delete the session directory at `.code_my_spec/internal/sessions/{id}/`
2. Return :ok (idempotent — succeeds even if directory doesn't exist)

**Test Assertions**:
- removes session directory and all contents
- returns :ok when directory doesn't exist

### clear_sessions/1

Remove all session directories.

```elixir
@spec clear_sessions(Environment.t()) :: :ok
```

**Process**:
1. List all directories under `.code_my_spec/internal/sessions/`
2. Delete each directory and its contents
3. Return :ok

**Test Assertions**:
- removes all session directories
- returns :ok when sessions directory is empty or missing
