# GenerateIntegrationTests

## Purpose

Delegates to an AI agent to generate comprehensive integration test files for a Phoenix context. The agent queries all components within the context, loads related user stories, and writes tests that validate acceptance criteria and component interactions rather than individual component implementation. For coordination contexts, tests validate proper orchestration of external context calls.

## Public API

```elixir
@spec get_command(Scope.t(), Session.t()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t()) :: {:ok, map(), Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/2

1. **Extract Context Component**: Get the context component from session (session.component represents the context being integrated)
2. **Query Context Components**: Query all child components where parent_component_id = context.id to get all components within this context
3. **Build File Path Lists**: For each child component, use Utils.component_files/2 to get design_file, code_file, and test_file paths
4. **Load User Stories**: Query Stories context for all stories where component_id matches any child component in this context
5. **Load Integration Test Rules**: Query Rules context for integration-test-specific coding rules (session_type: "integration", component_type: "*")
6. **Compose Agent Prompt**: Build prompt instructing agent to:
   - Review all component code files to understand current implementation
   - Review all user stories to extract acceptance criteria
   - Refer to component design files as needed to understand component architecture
   - Refer to component test files as needed understand component contracts
   - Write integration tests that validate:
     - Context public API coordinates component calls appropriately
     - Components work together correctly within context boundaries
     - Acceptance criteria from user stories are satisfied
     - For coordination contexts: external context calls are orchestrated correctly
   - Focus on context-level behavior and component interactions
   - Include path where integration test file should be written
7. **Create Agent**: Use Agents.create_agent/3 with appropriate agent type for integration test generation
8. **Build Command**: Use Agents.build_command_string/2 to create command from agent and prompt
9. **Return Command**: Create and return Command struct with agent invocation

### handle_result/3

1. **Extract Agent Output**: Get integration test generation results from Result struct
2. **Update Session State**: Store response on result
3. **Return Updates**: Return session updates map and updated Result

## Dependencies

- Sessions
- Components
- Stories
- Agents
- Rules
- Utils

## Error Handling

- Missing context component in session → return error tuple
- No child components found for context → return error (context must have components to integrate)
- Agent invocation failures → return error with agent context
- File system errors during test generation → return error with file context
- Missing user stories → proceed with warning (integration tests may be incomplete without acceptance criteria)
