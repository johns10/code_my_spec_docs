# Code My Spec

## New Project Creation

As a PM, I want to start a new project so that I can begin gathering requirements.

**Acceptance Criteria**
- System installs latest version of phx_new
- System creates new project workspace with `mix phx.new <project_name>`
- Initializes with PHX.Gen.Auth for user management
- Installs any standard/initial dependencies
- Sets up standard Phoenix LiveView application structure
- Creates initial Support context for cross-cutting concerns

## Project Configuration

As a user, I want the system to be opinionated about technology choices so that I don't have to make complex architectural decisions.

**Acceptance Criteria**
- Hardcoded to Phoenix/Elixir stack
- LiveView for web interface
- Vertical slice architecture using Phoenix contexts
- Standard dependencies (testing, code quality tools)
- Enforced file path and naming conventions

## Executive Summary Generation

As a PM, I want to define an executive summary of the application so that it can guide user story generation and project conversations.

**Acceptance Criteria**
- LLM conducts conversation to extract high-level application purpose and goals
- System captures executive summary including target users, core value proposition, and key business objectives
- Executive summary is editable and refinable through continued conversation
- Generated executive summary used to inform and guide subsequent user story interviews
- Summary provides context for LLM during user story generation process
- Executive summary must be approved before proceeding to user story gathering phase

## GitHub Authentication Setup

As a user, I want to authenticate with GitHub so that the system can manage repositories and perform Git operations on my behalf.

**Acceptance Criteria**
- System prompts for GitHub authentication during project setup
- Supports GitHub personal access tokens or OAuth authentication
- Validates authentication credentials before proceeding
- Stores authentication securely for subsequent Git operations
- System can create repositories, branches, and pull requests using authenticated credentials
- Authentication scope includes repository creation, branch management, and pull request operations

## GitHub Repository Setup

As a developer, I want a GitHub repository created for the project so that all code and documentation can be version controlled.

**Acceptance Criteria**
- System creates new GitHub repository for the project using authenticated credentials
- Repository initialized with Phoenix application structure
- Initial commit includes generated Phoenix scaffolding and PHX.Gen.Auth setup
- Main branch established as default branch
- Repository configured with appropriate .gitignore for Phoenix/Elixir projects
- Repository permissions set appropriately for project team access

## LLM-Driven Interview Process

As a PM, I want to be interviewed by an LLM to extract comprehensive user stories.

**Acceptance Criteria**
- LLM conducts adaptive interview asking relevant follow-up questions
- System drills down on vague requirements to get specific details
- Interview includes specific questions about security requirements, access control needs, and performance expectations
- Generates user stories in structured format (title, description, acceptance criteria)
- Supports iterative refinement through continued conversation

## User Story Management

As a PM, I want to edit and manage generated user stories directly so that I can refine them to match business needs.

**Acceptance Criteria**
- System generates initial user stories from LLM interview
- User stories are fully editable (title, description, acceptance criteria)
- Users can manually add, modify, or remove user stories
- System tracks changes and marks downstream artifacts as "dirty"
- Changes to user stories trigger regeneration approval workflow via events
- Simple locking prevents concurrent editing of same user story

## User Story Completeness Review

As a user, I want the system to review my user stories for completeness before decomposition begins.

**Acceptance Criteria**
- LLM analyzes user stories for gaps or inconsistencies
- LLM analyzes user stories for conflicts
- Provides feedback on completeness and conflicts
- Suggests areas that may need clarification or refinement
- User can proceed despite warnings

## Initial Context Mapping

As an architect, I want to map user stories to Phoenix contexts early so that I can generate a demo application structure.

**Acceptance Criteria**
- LLM maps user stories to Phoenix contexts based on entity ownership
- Uses business capability grouping within entity boundaries
- Ensures flat context structure (no nested contexts)
- Human architect reviews and approves initial context mapping
- Context mapping enables demo generation with PHX.Gen commands

## Phoenix Application Scaffolding

As a user, I want to see a working demo of my requirements so that I can validate the overall structure.

**Acceptance Criteria**
- System generates PHX.Gen commands based on approved context mapping
- Creates complete Phoenix application with realistic sample data
- Implements basic CRUD operations for all identified entities
- Provides seed files with demo data

## Guided Demo Validation

As a stakeholder, I want to be guided through the demo application to validate requirements.

**Acceptance Criteria**
- System guides user through specific screens and workflows
- Asks targeted questions about interface and functionality
- Captures feedback through chat interface
- Allows modification of seed files and structure
- Validates that the entity structure meets expectations

## BDD Specification Decomposition

As a system, I want to decompose approved user stories into testable BDD specifications after demo validation so that coding agents have precise implementation guidance.

**Acceptance Criteria**
- LLM analyzes each approved user story after demo validation and generates multiple BDD specs
- Each BDD spec follows Given/When/Then format with specific, testable conditions
- BDD specs include API contracts, data structures, and error handling scenarios
- Each BDD spec is traceable back to its originating user story
- Generated BDD specs require human approval before proceeding to detailed design phase
- System alerts when user story generates excessive BDD specs (>25) and suggests story breakdown

## Requirements Traceability

As a stakeholder, I want to trace implementation back to original business requirements so that I can verify completeness.

**Acceptance Criteria**
- Each BDD spec links to its parent user story
- Each integration test links to its source BDD spec
- System provides traceability reports showing user story → BDD spec → test → implementation
- Failed tests can be traced back to original business requirement

## BDD Specification to Context Refinement

As an architect, I want to refine the context mapping using detailed BDD specifications so that I can optimize the application structure.

**Acceptance Criteria**
- LLM refines initial context mapping using detailed BDD specifications
- Validates entity ownership and business capability grouping with BDD spec details
- Attempts to keep context under 300-500 lines with detailed specifications
- Human architect reviews and approves refined context mapping
- System can recommend context decomposition if BDD specs indicate complexity

## Context Design Documentation

As an architect, I want comprehensive design documentation for each context so that coding agents have clear implementation guidance.

**Acceptance Criteria**
- Documentation structure mirrors Phoenix application file structure exactly
- One markdown document per Phoenix code file (1:1 mapping)
- Documentation requirements vary by file type:
  - Context modules: API contracts, component diagrams, state management, data flow diagrams
  - Schemas: Entity definitions, relationships, validation rules
  - Controllers/LiveViews: Interface specifications, data flow
  - Tests: Test strategy and coverage requirements
- Documents include explicit dependencies and reference rules to prevent architectural leakage
- All documents require human approval before proceeding

## Context Type Management

As an architect, I want to distinguish between domain contexts and coordination contexts so that the architecture remains clean.

**Acceptance Criteria**
- Domain contexts own entities and implement business logic
- Coordination contexts orchestrate between domain contexts without entity ownership
- System generates appropriate documentation for each context type
- Coordination contexts explicitly designed by architect

## Documentation Review Process

As an architect, I want to review context documentation as complete units to ensure architectural integrity.

**Acceptance Criteria**
- Each bounded context's documentation reviewed as a complete unit
- Review process ensures contexts are self-contained
- Review validates no architectural leakage between contexts
- Documentation references are validated (warns about non-existent files)
- All context documentation must be approved before implementation begins

## Manual Documentation Modification

As an architect, I want to manually edit design documentation so that I can refine and improve generated docs.

**Acceptance Criteria**
- All design documents are editable
- Users can modify any documentation content (context docs, component docs, etc.)
- Changes to documentation trigger impact analysis on downstream artifacts
- Modified documents require re-approval before proceeding to implementation
- System tracks changes and maintains version history of documentation modifications
- Simple locking prevents concurrent editing of same document

## Current Information Access

As an user, I want the LLM to have access to current information so that designs and code follow modern patterns and avoid deprecated approaches.

**Acceptance Criteria**
- LLM's and agents have internet access to search for current best practices
- System can access recent community discussions, updated guides, and current API documentation
- Design decisions reference up-to-date patterns rather than outdated training data
- LLM can verify current recommended approaches for Phoenix contexts, LiveView patterns, and Elixir OTP designs
- Generated designs avoid deprecated APIs and use current ecosystem standards

## Todo Generation

As a system, I want to break down contexts into discrete implementation tasks for external coding agents.

**Acceptance Criteria**
- Each todo represents one Phoenix component or simple context
- Todo includes references to related BDD specifications, design documents, API contracts, acceptance criteria and rules
- Todo includes all relevant files (existing code and test files agent will modify/extend)
- Todo includes rule files with task-specific instructions for the agent
- Simple contexts generate 2 files: implementation + test
- Complex contexts generate multiple files + tests
- Shall be one todo per context component
- Each todo gets its own Git branch

## Branch Management

As a system, I want to manage Git branches for each todo so that work is isolated and can be safely integrated.

**Acceptance Criteria**
- System creates new branch from main for each todo task
- Branch names follow consistent naming convention (e.g., `feat-{component-name}-{id}`)
- Agent or human work is committed and pushed to assigned branch
- Failed branches are deleted and recreated for retry attempts
- Successful branches are preserved for integration
- System handles branch cleanup after successful integration

## Branch Management

As a system, I want to manage Git branches for each todo so that work is isolated and can be safely integrated.

**Acceptance Criteria**
- System creates new branch from main for each todo task
- Branch names follow consistent naming convention (e.g., `feat-{component-name}-{id}`)
- Agent or human work is committed and pushed to assigned branch
- Failed branches are deleted and recreated for retry attempts
- Successful branches are preserved for integration
- System handles branch cleanup after successful integration

## Dependency-Ordered Task Management

As a system, I want to ensure agents only receive tasks with satisfied dependencies so that implementation proceeds smoothly.

**Acceptance Criteria**
- System identifies dependencies between todos during planning
- `next_task` function only returns todos with all dependencies satisfied
- Unsatisfied dependencies indicate planning problems requiring review
- Task ordering prevents dependency deadlocks

## External Coding Agent Integration

As an engineer, I want to delegate implementation work to external coding agents so that I can focus on architecture and integration.

**Acceptance Criteria**
- System integrates with Claude Code via CLI interface
- System prepares and validates all rules and context before delegating tasks
- Provides agents with BDD specifications, design documents, file-specific requirements, and rule files
- Agents receive all relevant existing code files they need to work with
- Agents can implicitly trigger redesign by failing the task repeatedly
- Agents can explicitly fail task if insufficient information provided
- One agent works on one task at a time (synchronous)

## Test Failure Handling

As a system, I want coding agents to fix their own test failures so that implementation quality is maintained.

**Acceptance Criteria**
- When coding agent claims completion, system runs all tests for that component
- If tests fail, system provides failure details to coding agent with directive to fix
- Agent must resolve test failures before task is marked complete
- System does not automatically fix failing tests - agent must handle all fixes
- Agent retries until tests pass or retry limit reached

## Task Failure Recovery

As a system, I want to handle agent failures gracefully so that project progress continues.

**Acceptance Criteria**
- When agent fails a task, system discards the branch and starts over
- No attempt to preserve partial work from failed attempts
- Failed tasks restart with same todo specification
- After retry limit reached, task marked for human intervention

## Todo Administration and Human Assignment

As an engineer, I want to administer todos and assign them to myself so that I can take over any task in the project.

**Acceptance Criteria**
- Todo items have `assignee` field with values `:agent` or `:human`
- Engineer can change assignee of any todo to `:human` at any time (covers both failure case and "I want to do this" case)
- When todo assignee is `:human`, system creates the environment (so the branch exists) and stops processing to wait for human action
- Human receives same resources agent would have: branch name, environment details, and copy-pasteable prompt
- UI provides "View Agent Prompt" button that opens modal with full prompt text containing all context (docs, specs, rules, files)
- Task can be reassigned back to `:agent` if human chooses

## Human Task Completion

As an engineer, I want to mark my human-assigned task as complete so that it goes through the same validation as agent work.

**Acceptance Criteria**
- Human writes code, commits, and pushes to assigned branch
- Human clicks "Mark Complete" button to trigger completion workflow
- System runs same task completion validation as agent tasks (all tests for that component)
- If tests fail, human must fix issues and retry "Mark Complete"
- If tests pass, task marked complete and system resumes normal workflow from `next_task`
- Same integration pipeline applies regardless of original assignee

## Multi-Branch Integration

As an integration system, I want to safely combine multiple feature branches so that components work together correctly.

**Acceptance Criteria**
- System pulls completed branches into integration branch
- Each branch tested in isolation before integration
- Successfully integrated branches remain while failed branches get additional development cycles
- No merge conflicts due to isolated component development

## Pull Request Management

As a developer, I want pull requests created automatically so that code changes are tracked and can be reviewed.

**Acceptance Criteria**
- System creates pull request from feature branch to integration branch when todo is completed
- PR includes description with todo details, BDD specs implemented, and test results
- PR history provides audit trail of all changes

## Component Integration Testing

As a component integration tester, I want to validate that components within complex contexts work together properly.

**Acceptance Criteria**
- Tests components within individual complex contexts (GenServers, Tasks, etc.)
- Validates internal component communication and data flow
- Ensures components handle state management correctly
- Focuses on intra-context integration

## Context Integration Testing

As a context integration tester, I want to validate that coordination contexts work together correctly.

**Acceptance Criteria**
- Tests communication between different Phoenix contexts
- Validates coordination contexts work properly with domain contexts
- Ensures context boundaries are respected
- Focuses on inter-context integration

## BDD Validation Testing

As a BDD validation tester, I want to generate and maintain tests that validate BDD specifications are met.

**Acceptance Criteria**
- Generates integration tests automatically from BDD specifications
- Creates tests that exercise functionality at UI level (LiveView tests) where possible
- Creates tests that call application boundary APIs following Given/When/Then format
- Makes existing integration tests pass when components are updated
- BDD specifications marked as passing only when validation tests pass

## Integration Failure Handling

As an integration system, I want to handle integration failures without immediately triggering redesigns.

**Acceptance Criteria**
- Failed integration tests trigger additional development cycles rather than immediate redesign
- Integration conflicts result in branch disposal and restart
- Only after retry limits does system escalate to human intervention
- No special handling for integration test conflicts - restart approach applies

## Postmortem Analysis

As a system, I want to learn from implementation failures so that redesigns are more likely to succeed.

**Acceptance Criteria**
- When coding agent gives up, system conducts automated postmortem
- Postmortem analyzes entire conversation, design documents, and failure
- LLM determines why implementation failed and revises design
- Updated design incorporates lessons learned from failure

## Retry Management

As a system, I want to limit retry attempts so that the system doesn't get stuck in infinite loops.

**Acceptance Criteria**
- Maximum 5 redesign attempts per context
- After 5 failures, system halts and requests human assistance
- Retry counter tracks attempts per context
- Human can reset retry counter after intervention

## User Story Change Impact

As a PM, I want to understand the impact of user story changes so that I can make informed decisions.

**Acceptance Criteria**
- When user stories change, system marks all affected artifacts as "dirty"
- Queues regeneration work for human approval
- Shows impact analysis (affected BDD specs, contexts, todos, etc.)
- Prevents automatic regeneration without human approval
- Once downstream artificats are regenerated to reflect changed requirements and approved `:dirty` is to false

## Design Evolution

As an architect, I want designs to evolve safely when user stories change so that quality is maintained.

**Acceptance Criteria**
- All design documents must be re-approved after user story changes
- System regenerates affected BDD specifications and documentation
- Context decomposition triggers when size limits exceeded
- Integration tests updated to reflect new BDD specifications

## 1Multi-User Coordination

As a team, we want to work collaboratively on the same project so that we can leverage our different expertise.

**Acceptance Criteria**
- Multiple users can access same project simultaneously
- No role-based access control initially
- All users can view all artifacts and progress
- Changes visible to all team members in real-time

## 1Approval Workflows

As a team, we want to ensure quality through human review so that AI-generated artifacts meet our standards.

**Acceptance Criteria**
- All documents require human approval before proceeding
- Requirements document must be approved
- All design documents must be approved individually
- Users can start coding anytime but system encourages complete requirements first

## 1BDD Specification Status Tracking

As a stakeholder, I want to see progress toward implementing BDD specifications so that I can track project status.

**Acceptance Criteria**
- Primary metric: BDD specification status (passing/failing/in-progress)
- BDD specifications marked passing when integration tests pass
- Track partial completion percentages by user story
- Test coverage available via standard Elixir tools (mix test --cover)
- Traceability from failing tests back to original user stories

## 1Project Dashboard

As a user, I want visibility into overall project health so that I can identify issues quickly.

**Acceptance Criteria**
- Shows user story approval status
- Displays BDD specification implementation status
- Indicates context completion progress
- Shows integration health status
- Lists pending approvals and blocked items
- Provides traceability drill-down from user stories to implementation