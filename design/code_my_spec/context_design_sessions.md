# Context Design Sessions

## Purpose
Manages the multi-step workflow for creating new application contexts through AI-assisted documentation generation, validation, and component scaffolding.

## Entity Ownership
- **Workflow orchestration**: Step progression logic based on session interaction history
- **Command generation**: Creating appropriate commands for each workflow step
- **Result processing**: Handling step completion and advancing workflow state

## Scope Integration

### Accepted Scopes
- **Primary Scope**: User-scoped sessions tied to active projects
- **Secondary Scope**: Project-scoped for team collaboration

### Scope Configuration
Sessions are scoped to both user and project through the existing session schema. All operations filter by the user's active project and account scope.

### Access Patterns
- Sessions belong to a specific user and project combination
- Commands and results are isolated within session scope
- No cross-session data access without explicit authorization

## Public API

```elixir
# Workflow Orchestration
@spec get_next_command(Scope.t(), session_id :: String.t()) :: {:command, Command.t()} | {:complete}
@spec submit_result(Scope.t(), session_id :: String.t(), Result.t()) :: {:ok, Session.t()} | {:error, String.t()}
```

## State Management Strategy

### Session State Storage
- Sessions persist in database with JSON state field containing current workflow position
- Interactions embedded as array tracking command execution history
- Status field tracks overall session state (active/complete/failed)

### Workflow Progression
- Linear workflow: environment → documentation → validation → components → complete
- Step progression determined by inspecting last completed interaction
- State transitions only move forward, never backward
- The client can retry failed steps manually

### Data Persistence
- All session data persists immediately after each step completion
- Commands and results stored as embedded schemas for full audit trail
- No temporary state - everything recoverable from database

## Component Diagram

- ContextDesignSessions
  - Workflow Orchestration
    - Step progression logic (inspect last interaction → determine next step)
  - Workflow Steps
    - EnvironmentSetup (git branching, directory setup)
    - Documentation Generation (Claude AI integration)  
    - Validation (schema and content checking)
    - Component Creation (Phoenix generators)

## Dependencies

- **CodeMySpec.Sessions**: Session persistence and interaction management
- **CodeMySpec.Users.Scope**: Project-based access control
- **CodeMySpec.Agents**: AI Agents
- **Git Utility Module**: Branch management and repository setup commands

## Execution Flow

### Step Progression Logic
1. **Inspect Session**: Load session and examine interaction history
2. **Determine Current Step**: Based on last successful interaction, determine next workflow step
3. **Generate Command**: Create appropriate command for current step
4. **Return Command**: Provide command to client for execution

### Command Generation Per Step

#### Environment Setup
- Inspects project structure to determine git commands needed
- Creates feature branch for context development  
- Establishes clean working directory
- Generates git utility commands for branch management

#### Documentation Generation
- Builds context-specific prompts based on project patterns
- Generates Claude Code execution commands with comprehensive context design instructions
- Specifies output file paths and format requirements

#### Validation Phase
- Creates validation commands to check generated documentation against Phoenix Context design rules
- Validates required sections are present and well-formed
- Generates commands to identify potential issues or missing elements

#### Component Creation
- Analyzes documentation to identify required Phoenix components
- Generates appropriate Phoenix generator commands (context, schema, etc.)
- Creates migration commands if schemas are needed
- Generates test commands to verify compilation

### Error Handling
- **Environment Failures**: Git operations fail, network issues, permission problems
- **AI Generation Failures**: Agent timeouts, malformed responses, API errors  
- **Validation Failures**: Generated documentation doesn't meet standards, missing required sections
- **Scaffolding Failures**: Phoenix generator errors, file conflicts, dependency issues

All failures halt workflow progression and preserve session state for debugging. Sessions can be inspected but not resumed from failure points.