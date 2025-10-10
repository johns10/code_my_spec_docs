# ProjectSetupSessions Context

## Purpose
Orchestrates Phoenix project setup workflow through idempotent command group execution validated by VS Code client, integrating GitHub repository creation and handling failures via Claude Code sessions.

## Entity Ownership

This context owns no entities. All session state is managed through the Sessions context.

## Access Patterns
- All operations scoped by account_id and user_id through the Scope struct
- Session data filtered by project_id to ensure project-specific setup operations
- VS Code client provides validation state for current project requirements

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(Session.t()) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration with Validation-Driven Command Generation
- All workflow state persisted through Sessions context
- Setup validation report received from VS Code client drives command generation
- Session.state tracks completed requirements: dependencies_added, deps_installed, doc_repo_created, content_repo_created, submodules_initialized
- Only missing requirements generate corresponding command groups
- Workflow progress tracked via embedded Interactions in Session records
- Failed command groups trigger Claude Code invocation with failure context
- Re-validation after Claude Code resolution determines next steps

## Components
### ProjectSetupSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of project setup steps, determining workflow progression based on validation state and completed interactions. Routes failures to Claude Code recovery step.

### ProjectSetupSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Validates current project setup state by receiving validation report from VS Code client. Stores validation results in session state to drive subsequent command generation. No commands are executed in this step.

### ProjectSetupSessions.Steps.AddDependencies

| field | value |
| ----- | ----- |
| type  | other |

Generates command to add required dependencies to mix.exs: file_system, ngrok (from GitHub), exunit_json_formatter (from GitHub), and dialyxir. Uses latest available versions. Only executes if dependencies_added requirement is false.

### ProjectSetupSessions.Steps.InstallDependencies

| field | value |
| ----- | ----- |
| type  | other |

Generates command to run `mix deps.get` to install newly added dependencies. Only executes if deps_installed requirement is false and dependencies_added is true.

### ProjectSetupSessions.Steps.CreateGitHubRepositories

| field | value |
| ----- | ----- |
| type  | other |

Generates commands to create GitHub repositories for doc and content submodules via GitHub API. Repository names follow {project_name}-doc and {project_name}-content format. Inherits visibility from parent project repository, defaults to private if parent visibility cannot be determined. Initializes with basic README files. Only executes if doc_repo_created or content_repo_created requirements are false.

### ProjectSetupSessions.Steps.AddSubmodules

| field | value |
| ----- | ----- |
| type  | other |

Generates commands to add git submodules for doc and content repositories at standard Phoenix locations (docs/ and content/). Only executes if corresponding GitHub repositories exist and submodules are not yet added.

### ProjectSetupSessions.Steps.InitializeSubmodules

| field | value |
| ----- | ----- |
| type  | other |

Generates command to run `git submodule update --init --recursive` to initialize all submodules. Only executes if submodules_initialized requirement is false and submodules have been added.

### ProjectSetupSessions.Steps.HandleFailure

| field | value |
| ----- | ----- |
| type  | other |

Invokes Claude Code with context about what failed and what was expected to happen. Provides failure details, command that failed, expected outcome, and current project state. User works with Claude to resolve issues, then can re-run validation to continue setup.

### ProjectSetupSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Validates all requirements are met and marks session as complete. Broadcasts completion status to project dashboard. Updates project setup status to indicate CodeMySpec integration is ready.

## Dependencies
- CodeMySpec.Sessions
- CodeMySpec.Projects
- CodeMySpec.Agents

## Execution Flow

### Primary Setup Flow
1. **Initialize**: Receive validation report from VS Code client
   - VS Code scans local project for setup requirements
   - Reports status: dependencies in mix.exs, deps installed, doc submodule exists, content submodule exists, GitHub repos created
   - Store validation state in session
   - If all requirements met → proceed to Finalize
   - If requirements missing → proceed to first missing requirement step

2. **Add Dependencies**: Generate command for missing dependencies
   - Check session state for dependencies_added flag
   - If false → generate mix.exs update command
   - Send command to VS Code for execution
   - On success → mark dependencies_added as true, proceed to Install Dependencies
   - On failure → proceed to Handle Failure

3. **Install Dependencies**: Generate deps.get command
   - Check session state for deps_installed flag
   - If false and dependencies_added true → generate `mix deps.get` command
   - Send command to VS Code for execution
   - On success → mark deps_installed as true, proceed to Create GitHub Repositories
   - On failure → proceed to Handle Failure

4. **Create GitHub Repositories**: Generate GitHub API commands
   - Check session state for doc_repo_created and content_repo_created flags
   - Query parent project repository for visibility settings
   - For each missing repository → generate GitHub API create command with README
   - Use naming format: {project_name}-doc, {project_name}-content
   - Default to private if parent visibility cannot be determined
   - On success → mark corresponding repo flags as true, proceed to Add Submodules
   - On failure → proceed to Handle Failure

5. **Add Submodules**: Generate git submodule add commands
   - Check that GitHub repositories exist
   - For each submodule not yet added → generate `git submodule add` command
   - Use standard Phoenix locations: docs/ and content/
   - On success → proceed to Initialize Submodules
   - On failure → proceed to Handle Failure

6. **Initialize Submodules**: Generate submodule init command
   - Check session state for submodules_initialized flag
   - If false and submodules added → generate `git submodule update --init --recursive`
   - On success → mark submodules_initialized as true, proceed to Finalize
   - On failure → proceed to Handle Failure

7. **Finalize**: Complete session
   - Validate all requirements are met
   - Broadcast completion to project dashboard
   - Update project setup status
   - Mark session as complete

### Failure Recovery Flow
1. **Handle Failure**: Invoke Claude Code for resolution
   - Compose failure context with:
     - Failed command
     - Expected outcome
     - Actual error message
     - Current session state
     - Remaining requirements
   - Send to Claude Code agent
   - User works with Claude to diagnose and fix issue
   - User re-runs validation from VS Code
   - Session resumes from Initialize with updated validation state

### Idempotency Guarantees
- Session can be safely re-run at any point
- Initialize step re-validates current state on each run
- Only missing requirements generate commands
- Completed requirements are skipped automatically
- Session state persists across runs
- VS Code validation provides source of truth for current state

## Command Group Structure

Each step generates a command group that includes:
- **Command**: Shell command or API call to execute
- **Expected Outcome**: Description of what should happen on success
- **Validation**: How to verify the command succeeded
- **Rollback** (optional): How to undo changes if needed

Command groups are sent to VS Code client for execution. Client reports success or failure back to the session. Session orchestrator uses this feedback to determine next step.

## Integration with Sessions Context

ProjectSetupSessions follows the standard session pattern:
- Leverages Sessions.create_session/2 with type: :project_setup
- Uses Sessions.next_command/2 to drive workflow progression
- Reports results via Sessions.handle_result/4
- Follows StepBehaviour contract for all step modules
- Embeds interactions in Session record for audit trail

## GitHub Integration Requirements

- GitHub API token must be configured for repository operations
- Token requires repo creation permissions
- Parent project repository must be accessible to determine visibility
- Submodule repositories created under same owner as parent project
- All repositories initialized with minimal README for valid git state

## VS Code Extension Integration

Extension provides:
- **Validation Command**: Scans project and reports setup status
- **Command Execution**: Runs generated commands in user's terminal
- **Result Reporting**: Reports success/failure to session API
- **Dashboard UI**: Shows setup incomplete status with action button
- **Session Trigger**: Initiates setup session via command palette

Extension validation checks:
- Dependencies exist in mix.exs (file_system, ngrok, exunit_json_formatter, dialyxir)
- Dependencies installed in deps/ directory
- Doc submodule exists at docs/ path
- Content submodule exists at content/ path
- GitHub repositories exist and are accessible
