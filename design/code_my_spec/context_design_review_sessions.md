# ContextReviewSessions

## Purpose
Orchestrates AI-driven holistic review of Phoenix context documentation and all child component designs. Sends Claude a comprehensive prompt including file paths to context design and child component designs, user stories, and project executive summary to validate architectural compatibility and identify integration issues.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific context review

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(Session.t()) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
@spec complete?(Session.t() | Interaction.t()) :: boolean()
```

## State Management Strategy
### Stateless Orchestration with Document Review
- All workflow state persisted through Sessions context
- Workflow progress tracked via embedded Interactions in Session records
- Context and component design file paths stored in session state
- Review results written to file on client

## Components
### ContextReviewSession.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of context review steps. Coordinates the review execution and finalization.

### ContextReviewSession.Steps.ExecuteReview

| field | value |
| ----- | ----- |
| type  | other |

Creates a review command that sends Claude a comprehensive prompt with file paths to context design, child component designs, user stories, and project executive summary. Instructs Claude to review documents holistically, validate architectural compatibility, check for integration issues, and write findings to specified review file path.

### ContextReviewSession.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes the context review session by executing git add for the review file and marking session status as complete.

## Dependencies
- Sessions
- Components
- Stories
- Projects
- Rules
- Agents

## Execution Flow
1. **Execute Review**: Send comprehensive review prompt to Claude with file paths to context design, child component designs, user stories, and project executive summary. Claude reviews documents holistically, validates architectural compatibility, checks for integration issues, fixes any issues found, and writes review summary to specified path.
   - If review execution fails → return :error, orchestrator retries
   - If review succeeds → return :ok, orchestrator proceeds to finalize
2. **Finalize Session**: Execute git add for review file and mark session complete