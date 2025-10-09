# FixIntegrationTestFailures

## Purpose

Delegates to an AI agent to fix failing integration tests through iterative refinement. The agent attempts small inline fixes for minor integration issues. For major design flaws preventing integration, the agent uses MCP tools to trigger session continuation for the problematic component, allowing the user to address design issues before resuming integration with full conversational context.

## Public API

```elixir
@spec get_command(Scope.t(), Session.t(), keyword()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t(), keyword()) :: {:ok, map(), Result.t()}
```

## Execution Flow

### get_command/3

1. **Extract Integration Test Failures**: Retrieve test failure details from the previous RunIntegrationTests interaction
   - Search session.interactions for most recent interaction with test failures
   - Look for Result with status `:error` or Result.data containing test_run with failures > 0
   - Extract test failure details from Result.error_message or parsed test_run structure
2. **Validate Failure Data**: Ensure integration test failures are present and accessible
   - Return error if no failures found (step should not be reached without failures)
   - Return error if failure data is malformed or inaccessible
3. **Create Agent**: Use Agents.create_agent/3 to instantiate an integration fixer agent
   - Agent type: `:integration_fixer` (specialized for context integration fixes)
   - Agent name: `"integration-test-fixer"`
   - Implementation: `:claude_code`
4. **Build Fix Prompt**: Compose prompt instructing agent to:
   - Review integration test failures and error details
   - Identify root causes (component interaction issues, acceptance criteria gaps, etc.)
   - Make small inline fixes for simple integration problems
   - For major design flaws or architectural issues:
     - Use MCP Sessions tools to trigger session continuation for problematic component
     - Include integration failure context when continuing sessions
     - Explain why session continuation is necessary
   - Focus on making components work together correctly
   - Re-run integration tests to verify fixes
5. **Build Command**: Use Agents.build_command_struct/3 to create Command struct
   - Pass prompt and failure details
   - Include `continue: true` option to maintain conversation context
   - Set metadata with session context for MCP tool access
6. **Return Command**: Return Command struct for agent execution

### handle_result/4

1. **Extract Agent Output**: Get fix attempt results from Result struct
2. **Update Session State**: Store agent response and fix context on result
3. **Return Updates**: Return session state updates map and updated Result
   - Orchestrator will route back to RunIntegrationTests to verify fixes
   - Loop continues until integration tests pass or session is abandoned

## Dependencies

- Sessions
- Agents
- Components
- Tests

## Error Handling

- **No Failures Found**: Return error if step executed without prior integration test failures
  - Indicates orchestration bug (step should not be reached)
  - Provide clear error message for debugging
- **Malformed Failure Data**: Return error if test failure data cannot be extracted
  - Check Result.error_message and Result.data structures
  - Handle missing or corrupted test_run data
- **Agent Creation Failures**: Return error if agent instantiation fails
  - Include agent type and configuration context
  - Provide fallback guidance
- **MCP Tool Access Failures**: Agent reports inability to trigger session continuation
  - Failure logged in agent output
  - Agent should explain why MCP tools were needed but unavailable
  - Orchestrator may need to intervene based on agent report

## Integration Test Failure Analysis

### Simple Inline Fixes
Agent should attempt inline fixes for:
- Missing function implementations in context module
- Incorrect function signatures or return types
- Minor component wiring issues (wrong function calls)
- Simple data transformation problems
- Scope filtering mistakes

### Session Continuation Triggers
Agent should use MCP tools to continue component sessions for:
- Fundamental design flaws in component architecture
- Missing core functionality that should have been designed
- Type mismatches requiring schema changes
- Complex business logic errors indicating design gaps
- Architectural violations (boundary crossing, improper dependencies)

### Session Continuation Context
When triggering session continuation, agent should provide:
- Specific integration test failures with error messages
- Component interaction context (how component fits into broader integration)
- Architectural constraints or requirements discovered during integration
- Explanation of why inline fixes are insufficient

## Prompt Structure

The fix prompt should include:

1. **Failure Summary**: Concise description of integration test failures
2. **Error Details**: Full error messages, stack traces, and failure locations
3. **Integration Context**: Which components are involved and how they interact
4. **Fix Strategy Guidance**:
   - Try inline fixes first for simple issues
   - Use MCP Sessions tools for design-level problems
   - Re-run tests to verify fixes
5. **MCP Tool Availability**: Remind agent that Sessions MCP tools are available
6. **Success Criteria**: All integration tests must pass before proceeding

## Integration Fix Loop

This step is part of an iterative fix loop:

1. **RunIntegrationTests** executes test suite → captures failures
2. **FixIntegrationTestFailures** (this step) attempts fixes → inline or session continuation
3. **Loop back to RunIntegrationTests** to verify fixes
4. **Repeat** until all integration tests pass or orchestrator abandons session

The orchestrator controls loop termination based on:
- Maximum iteration count to prevent infinite loops
- Lack of progress (same failures recurring)
- User intervention request
- Successful test passage (exit loop, proceed to RunTestSuite)
