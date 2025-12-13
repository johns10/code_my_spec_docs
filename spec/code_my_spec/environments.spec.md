# CodeMySpec.Environments

**Type**: logic

Provides execution primitives for running commands and file system operations across different execution contexts (server, CLI with tmux, VS Code client).

## Functions

### create/2

Create a new execution context and return an opaque Environment struct.

```elixir
@spec create(type :: atom(), opts :: keyword()) :: {:ok, Environment.t()} | {:error, term()}
```

**Process**:
1. Get the implementation module for the type
2. Delegate to implementation's create/1 with opts
3. Implementation returns its internal reference
4. Wrap reference in Environment struct with type and metadata
5. Return {:ok, environment}

**Test Assertions**:
- create/2 returns Environment struct for valid type
- create/2 returns error for unknown type
- create/2 delegates to correct implementation
- create/2 can create multiple contexts for same type

### destroy/1

Destroy an execution context and clean up resources.

```elixir
@spec destroy(env :: Environment.t()) :: :ok | {:error, term()}
```

**Process**:
1. Get implementation module from env.type
2. Delegate to implementation's destroy/1 with full Environment struct
3. Implementation extracts what it needs from struct
4. Return result

**Test Assertions**:
- destroy/1 cleans up execution context successfully
- destroy/1 is idempotent (can be called multiple times)
- destroy/1 delegates to correct implementation

### run_command/3

Execute a command in the environment context.

```elixir
@spec run_command(env :: Environment.t(), command :: String.t(), opts :: keyword()) ::
        {:ok, result :: map()} | {:error, term()}
```

**Process**:
1. Get implementation module from env.type
2. Delegate to implementation's run_command/3 with full Environment struct
3. Implementation extracts ref and executes command with opts
4. Return command result with output, exit_code, and status

**Test Assertions**:
- run_command/3 executes sync commands by default
- run_command/3 supports async: true option
- run_command/3 returns output and exit_code for sync commands
- run_command/3 returns command_id for async commands
- run_command/3 supports env option for setting environment variables
- run_command/3 delegates to correct implementation

### read_file/2

Read a file from the execution environment's file system.

```elixir
@spec read_file(env :: Environment.t(), path :: String.t()) ::
        {:ok, content :: String.t()} | {:error, term()}
```

**Process**:
1. Get implementation module from env.type
2. Delegate to implementation's read_file/2 with full Environment struct
3. Return file content or error

**Test Assertions**:
- read_file/2 returns file content for existing files
- read_file/2 returns error for non-existent files
- read_file/2 delegates to correct implementation

### list_directory/2

List contents of a directory in the execution environment.

```elixir
@spec list_directory(env :: Environment.t(), path :: String.t()) ::
        {:ok, entries :: [String.t()]} | {:error, term()}
```

**Process**:
1. Get implementation module from env.type
2. Delegate to implementation's list_directory/2 with full Environment struct
3. Return list of file/directory names

**Test Assertions**:
- list_directory/2 returns list of entries for existing directory
- list_directory/2 returns error for non-existent directory
- list_directory/2 delegates to correct implementation

## Dependencies

- environments/cli.spec.md
- environments/vscode.spec.md