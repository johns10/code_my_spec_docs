# ContextComponentSpecs

Agent task for designing a context and all its child components through orchestrated subagent workflow.

## Functions

### command/3

Generate the orchestration prompt for designing child components.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Fetch the context component from session with preloaded requirements
2. Check if context itself needs a spec and generate prompt file if needed using ContextSpec.command/3
3. Fetch all descendant components (children, grandchildren, etc.) using recursive descent
4. Filter descendants to find children needing specs by checking their spec-related requirements
5. Generate prompt files for each child needing specs using ComponentSpec.command/3
6. Build orchestration prompt instructing Claude to invoke spec-writer subagents for each component
7. Return orchestration prompt with task instructions and file paths

**Test Assertions**:
- returns orchestration prompt when context and children need specs
- generates context prompt file when context requirements are unsatisfied
- skips context prompt file when context requirements are satisfied
- generates child prompt files for all children needing specs
- filters out children with satisfied spec requirements
- includes descendant components at all nesting levels
- creates prompt files in session-specific subagent_prompts directory
- returns "no action required" message when all requirements are satisfied
- includes correct file paths in orchestration instructions
- instructs parallel invocation of spec-writer subagents for efficiency

### evaluate/3

Evaluate whether all child components have valid specs and provide feedback.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Fetch the context component from session with preloaded requirements
2. Check context spec status by filtering spec-related requirements
3. Fetch all descendant components using recursive descent
4. Split children into satisfied and unsatisfied based on spec requirement status
5. Clean up prompt files for satisfied children components
6. Clean up context prompt file if context requirements are satisfied
7. If all requirements satisfied, clean up prompt directory and return valid
8. If any requirements unsatisfied, build feedback message listing components and requirements
9. Return invalid with feedback instructing re-invocation of spec-writer subagents

**Test Assertions**:
- returns valid when all context and child requirements are satisfied
- returns invalid with feedback when context requirements are unsatisfied
- returns invalid with feedback when any child requirements are unsatisfied
- cleans up prompt files for satisfied components
- preserves prompt files for unsatisfied components
- cleans up prompt directory when all requirements satisfied
- includes component names and module names in feedback
- includes requirement names and error messages in feedback
- differentiates between context and child components in feedback
- provides instructions for re-invoking spec-writer subagents
- includes prompt directory path in feedback

## Dependencies

- CodeMySpec.Requirements
- CodeMySpec.Environments
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Sessions.AgentTasks.ComponentSpec
- CodeMySpec.Sessions.AgentTasks.ContextSpec
