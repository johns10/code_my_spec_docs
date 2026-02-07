# CodeMySpec.AgentTasks.ContextImplementation

**Type**: logic

Orchestrates implementing an entire context (tests + code for all child components) via subagents. Generates prompt files for test-writer and code-writer subagents, returns orchestration instructions with light dependency guidance, and validates all components pass quality checks.

## Functions

### command/3

Generate prompt files and orchestration instructions for implementing a context's child components.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Get all child components of the context from session
2. Use Requirements.check_requirements to find components needing tests (test_file, test_valid, test_alignment)
3. Use Requirements.check_requirements to find components needing code (code_file, tests_pass)
4. For each component needing work, generate prompt files:
   - `{safe_name}_test.md` using ComponentTest.command/3
   - `{safe_name}_code.md` using ComponentCode.command/3
5. Build orchestration prompt listing all components and their prompt files
6. Include light guidance on typical dependency order (schemas → repos → services)
7. Instruct Claude to invoke test-writer subagents first, then code-writer subagents per layer

**Test Assertions**:
- generates test prompt files for components with unsatisfied requirements of artifact_type `:tests`
- generates code prompt files for components with unsatisfied requirements of artifact_type `:code`
- returns orchestration prompt with component list
- includes dependency guidance in prompt
- skips prompt generation for components already passing

### evaluate/3

Validate all child components have passing tests and implementations.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Get all child components of the context
2. For each component, run ComponentTest.evaluate/3 (compilation, TDD state, spec alignment)
3. For each component, run ComponentCode.evaluate/3 (tests pass)
4. Aggregate results - collect all failures
5. Clean up prompt files for components that pass both checks
6. Return {:ok, :valid} if all pass, {:ok, :invalid, feedback} listing failures

**Test Assertions**:
- returns valid when all components pass both evaluations
- returns invalid with feedback when any component fails test evaluation
- returns invalid with feedback when any component fails code evaluation
- cleans up prompt files for passing components
- aggregates multiple component failures into single feedback

## Dependencies

- Sessions.AgentTasks.ComponentTest
- Sessions.AgentTasks.ComponentCode
- CodeMySpec.Requirements
