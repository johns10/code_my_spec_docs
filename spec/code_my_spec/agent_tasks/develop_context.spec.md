# CodeMySpec.AgentTasks.DevelopContext

Orchestrates the full lifecycle of a context from specification through implementation.

Creates prompt files for all subagent tasks in order:
1. Context spec (ContextSpec)
2. Component specs (ComponentSpec) for each child
3. Design review (ContextDesignReview)
4. Tests for each component (ComponentTest)
5. Code for each component (ComponentCode)

The module generates prompt files in `.code_my_spec/internal/sessions/{external_id}/subagent_prompts/`
and provides orchestration instructions for AI agents to invoke appropriate subagents for each phase.

## Dependencies

- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.ContextDesignReview
- CodeMySpec.AgentTasks.ContextSpec
- CodeMySpec.Utils
