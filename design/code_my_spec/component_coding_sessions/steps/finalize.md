# ComponentCodingSessions.Steps.Finalize

## Purpose

Completes the component coding session by tearing down the development environment, cleaning up temporary files, and executing repository finalization commands (such as committing changes or pushing branches).

## Public API

```elixir
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()}
@spec handle_result(Scope.t(), Session.t(), result :: any()) :: {:ok, map(), any()}
```

## Execution Flow

1. **Extract File Paths**: Use `CodeMySpec.Utils.component_files/2` to retrieve the code file path and test file path for the component
2. **Build File Names**: Strip project root from paths to create relative filenames for environment commands
3. **Prepare Attributes**: Construct attribute map containing:
   - `branch_name`: Generated from session via `ComponentCodingSessions.Utils.branch_name/1`
   - `code_file_name`: Relative path to component implementation file
   - `test_file_name`: Relative path to component test file
   - `working_dir`: Project root directory (".")
   - `context_name`: Component name from session
   - `context_type`: Component type from session
4. **Generate Teardown Command**: Call `Environments.code_environment_teardown_command/2` with environment and attributes to build the teardown command string
5. **Return Command**: Wrap command string in `Command.new/2` struct and return `{:ok, command}`
6. **Handle Result**: Pass through result unchanged with empty state map: `{:ok, %{}, result}`