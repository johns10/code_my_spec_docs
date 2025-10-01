# Component Design: ReadComponentDesign

## Purpose

Reads component design documentation from the project's design directory and stores it in the session state. This component extracts the design information needed to guide subsequent implementation steps, ensuring all code generation follows the documented architecture and specifications.

## Public API

```elixir
@behaviour CodeMySpec.Sessions.StepBehaviour

@spec get_command(Scope.t(), map()) :: {:ok, Command.t()}
@spec handle_result(Scope.t(), Session.t(), result :: map()) :: {:ok, map(), map()}
```

## Execution Flow

1. **Build Design File Path**: Extract component and project from session context, then use `Utils.component_files/2` to get the design file path
2. **Create Command**: Generate a `cat` command to read the design document from `docs/design/{project}/{context}/{component}.md`
3. **Execute Command**: Command execution handled by Sessions context infrastructure
4. **Extract Design Content**: Parse the command result's stdout to retrieve design document content
5. **Update Session State**: Store the design document content in session state under the `"component_design"` key
6. **Return Result**: Return updated state map and result for workflow continuation