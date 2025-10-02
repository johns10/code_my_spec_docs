# IntegrationSessions

## Purpose
Manages context integration testing workflows that validate components within a context work together correctly, write integration tests satisfying user story acceptance criteria, and trigger component redesign when integration issues arise.

## Entity Ownership

This context owns no entities.

## Access Patterns
- All operations scoped by account_id through the Scope struct
- Session data filtered by project_id to ensure project-specific integration workflows
- Integration test results scoped to session context
- Component integration state maintained within session lifecycle

## Public API
```elixir
# Session workflow delegation
@spec get_next_interaction(step_module_atom()) :: {:ok, module()} | {:error, :session_complete | :invalid_interaction}
@spec steps() :: [module()]
```

## State Management Strategy
### Stateless Orchestration with Integration Test-Driven Development
- All workflow state persisted through Sessions context
- Context component integration state maintained in Session.state field
- Workflow progress tracked via embedded Interactions in Session records
- Integration test results and full project test failures stored in session state
- User story acceptance criteria can be queried and referenced throughout workflow
- Component file paths, test paths, and document paths can be queried on demand
- Component session IDs tracked to enable session continuation for targeted fixes
- Session continuation allows resuming component conversations with integration failure context

## Components
### IntegrationSessions.Orchestrator

| field | value |
| ----- | ----- |
| type  | other |

Stateless orchestrator managing the sequence of integration testing steps, determining workflow progression based on completed interactions. Handles integration test failures by locating the original component session that created the failing component, continuing that conversation with integration failure context to enable targeted fixes with full conversational history.

### IntegrationSessions.Steps.Initialize

| field | value |
| ----- | ----- |
| type  | other |

Prepares the integration testing environment, and initializes workspace for integration test development.

### IntegrationSessions.Steps.GenerateIntegrationTests

| field | value |
| ----- | ----- |
| type  | other |

Creates a prompt including all file paths, test paths, and user stories related to the context. Generates integration test files that validate acceptance criteria from user stories. Tests focus on context-level behavior and component interactions rather than individual component implementation. For coordination contexts, tests validate proper orchestration of external context calls.

Similar to GenerateTests in ComponentCodingSessions, this step should:
1. Query component file and test paths for this context
2. Load user stories for this context
3. Build prompt with coding rules specific to integration testing
4. Use Agents context to create agent and build command
5. Write integration test files to appropriate test directory 

### IntegrationSessions.Steps.GenerateContext

| field | value |
| ----- | ----- |
| type  | other |

Creates a prompt including project context, file and test paths, and document paths, all user stories, location of the integration tests, generates context file that satisfies all of the acceptance tests, instructs the agent to be very concise and not add that much code, just make the existing components work together. Tracks which session created each component for future continuation. Has access to the Sessions MCP tool, and can initiate session reactivation for very problematic components.

### IntegrationSessions.Steps.RunIntegrationTests

| field | value |
| ----- | ----- |
| type  | other |

Executes the integration test suite for the context and analyzes results. Captures integration failures, component interaction issues, and acceptance criteria violations. Determines whether failures require simple inline fixes or session reactivation. Has access to the Sessions MCP tool, and can initiate session reactivation for very problematic components.

### IntegrationSessions.Steps.FixIntegrationTestFailures

| field | value |
| ----- | ----- |
| type  | other |

Prompts agent to fix failing integration tests. Agent should make small fixes inline. For major design flaws preventing integration, agent uses MCP tools to trigger session continuation for the problematic component, allowing user to address design issues before resuming integration. 

### IntegrationSessions.Steps.RunTestSuite

| field | value |
| ----- | ----- |
| type  | other |

Executes the test suite for the entire project and categorizes all test failures in session state. Separates failures into: (1) failures within this context's tests, (2) failures in other context tests.

If outside-context tests fail, this indicates architectural problems - the new context is breaking existing functionality it shouldn't touch. In this case:
- Identify what shared component/dependency is being modified incorrectly
- Flag as architectural issue requiring human intervention
- Mark integration session as failed
- Terminate workflow immediately - no commits, merges, or PRs

Since this context is new, nothing should depend on it yet. Outside tests breaking means we're violating context boundaries or modifying shared dependencies incorrectly. 

### IntegrationSessions.Steps.FixTestFailures

| field | value |
| ----- | ----- |
| type  | other |

Handles within-context test failures only (outside-context failures already terminated the session in RunTestSuite). Agent makes small inline fixes or triggers session reactivation via MCP tools for components with design flaws. This step exists to give user/agent a chance to clean up any mess made during integration.

Loops back to Run Test Suite until all tests pass - workflow cannot proceed to validation until the entire project test suite is green.  

### IntegrationSessions.Steps.ValidateAcceptanceCriteria

| field | value |
| ----- | ----- |
| type  | other |

Reviews integration test results against user story acceptance criteria to ensure all criteria are satisfied. Identifies gaps in test coverage or unmet acceptance criteria. Triggers additional test generation if criteria are not fully validated.

### IntegrationSessions.Steps.Finalize

| field | value |
| ----- | ----- |
| type  | other |

Completes successful integration session by updating context integration status metadata, recording acceptance criteria satisfaction, and cleaning up temporary integration state. Marks context as integration-tested and ready for use.

## Dependencies
- Sessions
- Tests
- Components
- Stories
- ComponentDesignSessions
- ComponentCodingSessions

## Execution Flow
1. **Initialize Environment**: Set up workspace and prepare integration testing environment
2. **Generate Integration Tests**: Query component file/test paths and user stories, create comprehensive integration tests validating acceptance criteria and component interactions
3. **Generate Context**: Query project context, paths, and stories, generate context file making existing components work together with minimal code (has MCP access to trigger session reactivation)
4. **Run Integration Tests**: Execute integration test suite for this context only and capture results
   - If all tests pass → proceed to Run Test Suite
   - If tests fail → proceed to Fix Integration Test Failures
5. **Fix Integration Test Failures**: Agent fixes failing integration tests
   - Make small fixes inline for simple issues
   - Use MCP tools to trigger session reactivation for components with design flaws
   - Return to Run Integration Tests (loop until integration tests pass)
6. **Run Test Suite**: Execute entire project test suite and categorize all test failures in session state
   - If all tests pass → proceed to Validate Acceptance Criteria
   - If tests fail → proceed to Fix Test Failures
7. **Fix Test Failures**: Last chance for user and LLM to fix out-of-context failures.
8. **Validate Acceptance Criteria**: Review integration test results against user story acceptance criteria (only reached when ALL tests pass)
   - All criteria satisfied → proceed to Finalize
   - Gaps identified → return to Generate Integration Tests with gap analysis
9. **Finalize Session**: Update context status, record acceptance criteria satisfaction, complete session

## Integration Testing Focus

### Domain Context Integration
Validates components within a domain context work together correctly:
- Context public API coordinates component calls appropriately
- Repository components properly handle data access with scope filtering
- Schema components and changesets integrate correctly
- Business logic flows properly through context boundaries
- Component interactions respect architectural patterns
- Context maintains clean separation of concerns

### Coordination Context Integration
Validates coordination contexts properly orchestrate external contexts:
- Coordination context public API delegates to appropriate external contexts
- Multiple external context calls coordinated correctly
- Transaction boundaries and error handling work across contexts
- Context boundaries respected (no direct access to external context internals)
- Orchestration logic remains high-level without business logic details
- External context independence maintained

## Session Continuation Strategy

### Component Session Tracking
- Each component tracks which session created it (component_id → session_id relationship)
- Session IDs stored on component records during ComponentDesignSessions and ComponentCodingSessions
- Integration session queries component sessions to enable targeted continuation

### Session Continuation for Fixes
When integration tests reveal component issues:
1. **Identify Failing Components**: Parse test failures to determine which components need fixes
2. **Locate Component Sessions**: Query Sessions context to find the original ComponentCodingSession or ComponentDesignSession that created each failing component
3. **Continue Conversations**: Reactivate each component session and push new interaction with:
   - Integration test failure details
   - Context about how the component fits into broader integration
   - Specific issues preventing integration success
4. **Agent Context Benefits**: Agent has full conversational history including:
   - Original design discussions and decisions
   - Previous test failures and fixes
   - Component implementation evolution
   - Design constraints and requirements
5. **Coordinate Multiple Sessions**: When failures span multiple components, continue multiple sessions and coordinate their completion before re-running test suite

### Session Continuation vs New Sessions
**Continue Existing Session When**:
- Component exists and has associated session
- Fix needed is refinement or correction
- Agent benefits from conversational context

**Create New Session When**:
- Component needs complete redesign (ComponentDesignSession)
- No existing session found for component
- Architectural changes required that invalidate original session context

## Session Management Requirements
This design assumes Sessions context supports:
- Session reactivation (change status from complete → active)
- Pushing new interactions onto existing sessions
- Querying sessions by component_id
- Multiple concurrent active sessions
- Session completion tracking for coordination