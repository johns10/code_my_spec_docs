# CodeMySpec.Sessions.Steps.Helpers

Helper functions for step modules to reduce boilerplate and provide a stable API for common command building patterns.

This module centralizes common patterns in step implementations so that future changes to the orchestration layer don't require updating every single step module. It handles agent creation, command building, session context management, and option normalization.

## Functions

### build_agent_command/6

Creates an agent instance and builds a command struct with full session context.

```elixir
@spec build_agent_command(
  module(),
  Session.t(),
  atom(),
  String.t(),
  String.t(),
  keyword()
) :: {:ok, Command.t()} | {:error, String.t()}
```

**Process**:
1. Normalize options by calling `handle_opts/2` with session context
2. Create agent instance using `Agents.create_agent/4` with agent_type, agent_name, and :claude_code implementation
3. Build command struct using `Agents.build_command_struct/3` with agent, prompt, and normalized opts
4. Add module field to command struct using `Map.put/3` with step_module
5. Return {:ok, command} tuple

**Test Assertions**:
- creates agent and command with all required fields
- adds module field to command struct
- includes resume option when session has external_conversation_id
- includes auto option when session execution_mode is :auto
- passes through additional opts to command
- returns error when agent creation fails
- returns error when command building fails
- handles nil external_conversation_id correctly
- handles non-auto execution modes correctly

### build_command_with_agent/5

Builds a command struct using an existing agent instance with session context.

```elixir
@spec build_command_with_agent(
  module(),
  Session.t(),
  Agent.t(),
  String.t(),
  keyword()
) :: {:ok, Command.t()} | {:error, String.t()}
```

**Process**:
1. Normalize options by calling `handle_opts/2` with session context
2. Build command struct using `Agents.build_command_struct/3` with agent, prompt, and normalized opts
3. Add module field to command struct using `Map.put/3` with step_module
4. Return {:ok, command} tuple

**Test Assertions**:
- builds command with existing agent
- adds module field to command struct
- includes resume option when session has external_conversation_id
- includes auto option when session execution_mode is :auto
- passes through additional opts to command
- returns error when command building fails
- allows custom agent configurations

### build_shell_command/2

Builds a simple shell command struct for non-agent operations.

```elixir
@spec build_shell_command(module(), String.t()) :: {:ok, Command.t()}
```

**Process**:
1. Create Command struct with module, command_string, and execution_strategy :sync
2. Set metadata to empty map
3. Set timestamp to current UTC time using `DateTime.utc_now/0`
4. Return {:ok, command} tuple

**Test Assertions**:
- creates command struct with correct fields
- sets execution_strategy to :sync
- sets metadata to empty map
- sets timestamp to current time
- includes module field
- works with any command string

### handle_opts/2

Normalizes options by applying session context transformations.

```elixir
@spec handle_opts(keyword(), Session.t()) :: keyword()
```

**Process**:
1. Apply `handle_resume_opts/2` to add resume option if session has external_conversation_id
2. Apply `handle_auto_opts/2` to add auto option if session execution_mode is :auto
3. Return normalized keyword list

**Test Assertions**:
- adds resume option when external_conversation_id is present
- adds auto option when execution_mode is :auto
- preserves existing options
- handles nil external_conversation_id
- handles non-auto execution modes
- combines both resume and auto when applicable
- returns unchanged opts when no session context applies

## Dependencies

- CodeMySpec.Agents
- CodeMySpec.Sessions.Command
- CodeMySpec.Sessions.Session
- CodeMySpec.Agents.Agent
