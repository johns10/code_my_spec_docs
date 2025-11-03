# CodeMySpec Methodology - Implementation Resources

This document contains references to code, design files, and documentation that demonstrate each part of the CodeMySpec methodology.

## Methodology Overview

**Stories ’ Context Design ’ Design Documents ’ Tests ’ Code**

## 1. User Stories Management

### Core Implementation
- **Story Schema**: `lib/code_my_spec/stories/story.ex`
- **Design Documentation**: `docs/design/code_my_spec/stories.md`
- **Story Entity Design**: `docs/design/code_my_spec/stories/story.md`

### MCP Tools (AI Interface)
- `lib/code_my_spec/mcp_servers/stories/tools/create_story.ex` - Create stories
- `lib/code_my_spec/mcp_servers/stories/tools/get_story.ex` - Retrieve stories
- `lib/code_my_spec/mcp_servers/stories/tools/update_story.ex` - Update stories
- `lib/code_my_spec/mcp_servers/stories/tools/start_story_interview.ex` - AI-assisted story refinement
- `lib/code_my_spec/mcp_servers/stories/tools/start_story_review.ex` - Completeness validation
- `lib/code_my_spec/mcp_servers/stories/tools/set_story_component.ex` - Map stories to architecture

### Key Features
- **Versioning**: PaperTrail integration for change tracking
- **Locking**: Prevents concurrent editing conflicts
- **Status Tracking**: `:in_progress`, `:completed`, `:dirty`
- **Component Association**: Maps stories to architectural components
- **Markdown Import/Export**: Supports `user_stories.md` workflow

### Content References
- `docs/content/managing_user_stories.md` - Manual process for managing stories

---

## 2. Context Design & Architecture

### Core Implementation
- **Components Context**: `lib/code_my_spec/components.ex`
- **Component Schema**: `lib/code_my_spec/components/component_repository.ex`
- **Design Documentation**: `docs/design/code_my_spec/components.md`

### Design Session Orchestration
- **Context Design Sessions**: `lib/code_my_spec/context_design_sessions.ex`
- **Orchestrator**: `lib/code_my_spec/context_design_sessions/orchestrator.ex`
- **Design Documentation**: `docs/design/code_my_spec/context_design_sessions.md`

### Multi-Component Orchestration (Highest Level)
- **Orchestrator**: `lib/code_my_spec/context_components_design_sessions/orchestrator.ex`
- **Initialize Step**: `lib/code_my_spec/context_components_design_sessions/steps/initialize.ex`
- **Spawn Component Sessions**: `lib/code_my_spec/context_components_design_sessions/steps/spawn_component_design_sessions.ex`
- **Review Step**: `lib/code_my_spec/context_components_design_sessions/steps/spawn_review_session.ex`
- **Finalize Step**: `lib/code_my_spec/context_components_design_sessions/steps/finalize.ex`
- **Design Documentation**: `docs/design/code_my_spec/context_components_design_sessions.md`

### MCP Tools
- `lib/code_my_spec/mcp_servers/components/tools/create_component.ex` - Create component
- `lib/code_my_spec/mcp_servers/components/tools/start_context_design.ex` - Initiate design workflow
- `lib/code_my_spec/mcp_servers/components/tools/review_context_design.ex` - Review designs
- `lib/code_my_spec/mcp_servers/components/tools/context_statistics.ex` - Analyze metrics
- `lib/code_my_spec/mcp_servers/components/tools/show_architecture.ex` - Visualize architecture
- `lib/code_my_spec/mcp_servers/components/tools/create_dependency.ex` - Define dependencies

### Key Architecture Patterns
- **Vertical Slice Architecture**: Phoenix contexts as bounded contexts
- **Component Types**: Schema, Repository, Service, LiveView, Controller, etc.
- **Dependency Tracking**: Explicit dependencies between components
- **Scope-Based Access**: Multi-tenant isolation via `Scope` struct

### Documentation
- `docs/context_mapping.md` - Context mapping overview
- `docs/rules/context_design.md` - Design rules and patterns
- `docs/rules/elixir_design.md` - Elixir-specific patterns

---

## 3. Design Documents

### Core Implementation
- **ContextDesign Schema**: `lib/code_my_spec/documents/context_design.ex`
- **Parser**: `lib/code_my_spec/documents/context_design_parser.ex`
- **Design Documentation**: `docs/design/code_my_spec/documents/context_design.md`

### Document Structure
Design documents contain:
- **Purpose**: What the context does and why
- **Entity Ownership**: What data models belong here
- **Access Patterns**: How data flows in/out
- **Public API**: Functions exposed to other contexts
- **State Management**: How state is handled
- **Execution Flow**: Step-by-step process flow
- **Components**: List of modules with types and descriptions
- **Dependencies**: What other contexts this depends on

### Format Specifications
- `docs/design/code_my_spec/documents/context_design.md` - Context design template
- `docs/design/code_my_spec/documents/schema_component_design.md` - Component design template
- `test/support/fixtures/documents_fixtures/context_design_fixture.md` - Example design

### Key Features
- **Structured Markdown**: Easy to read, easy to parse
- **Component References**: Explicit module names and types
- **Dependency Tracking**: Inter-context dependencies
- **Embedded Schemas**: Stored as Ecto embedded schemas for querying
- **Version Controlled**: All designs tracked in git

### Design Rules
- `docs/rules/schema_design.md` - Schema design patterns
- `docs/rules/liveview_design.md` - LiveView patterns
- `docs/design_driven_code_generation.md` - Overall methodology

---

## 4. Session Orchestration

### Core Implementation
- **Session Schema**: `lib/code_my_spec/sessions/session.ex`
- **Session Context**: `lib/code_my_spec/sessions.ex`
- **Orchestrator Pattern**: `lib/code_my_spec/sessions/orchestrator.ex`
- **Design Documentation**: `docs/design/code_my_spec/sessions.md`

### Orchestration Types
Each workflow has its own orchestrator:
- **Context Design**: `lib/code_my_spec/context_design_sessions/orchestrator.ex`
- **Component Design**: `lib/code_my_spec/component_design_sessions/orchestrator.ex`
- **Component Testing**: `lib/code_my_spec/component_test_sessions/orchestrator.ex`
- **Component Coding**: `lib/code_my_spec/component_coding_sessions/orchestrator.ex`
- **Context Components Design**: `lib/code_my_spec/context_components_design_sessions/orchestrator.ex`

### Session State Machine
- **States**: `:active` ’ `:complete` or `:failed`
- **Interactions**: Command/result pairs with timestamps
- **Commands**: Module, command string, execution metadata
- **Results**: Status, data, output, timing

### Orchestration Flow
1. Session created with type (e.g., ContextComponentsDesignSession)
2. `next_command/1` returns next workflow step
3. Client executes command via agent
4. `handle_result/3` processes outcome and updates session
5. Orchestrator determines next step based on result
6. Loop continues until terminal state

### Documentation
- `docs/design/code_my_spec/sessions/orchestrator.md` - Orchestrator pattern
- `docs/design/code_my_spec/context_design_sessions.md` - Context design workflow
- `docs/design/code_my_spec/component_design_sessions.md` - Component design workflow

---

## 5. Test Generation

### Core Implementation
- **Component Test Sessions**: `lib/code_my_spec/component_test_sessions.ex`
- **Test Session Orchestrator**: `lib/code_my_spec/component_test_sessions/orchestrator.ex`
- **Design Documentation**: `docs/design/code_my_spec/component_test_sessions.md`

### Test Generation Steps
1. **Initialize**: Setup workspace and repository state
2. **GenerateTestsAndFixtures**: AI generates tests from design documents
3. **RunTests**: Execute generated tests
4. **FixCompilationErrors**: AI fixes errors iteratively
5. **Finalize**: Commit test files

### Test Session Step Documentation
- `docs/design/code_my_spec/component_coding_sessions/steps/generate_tests.md`
- `docs/design/code_my_spec/component_coding_sessions/steps/analyze_and_generate_fixtures.md`
- `docs/design/code_my_spec/component_coding_sessions/steps/run_tests.md`
- `docs/design/code_my_spec/component_coding_sessions/steps/fix_test_failures.md`

### Test Infrastructure
- **Process Executor**: `lib/code_my_spec/tests/process_executor.ex`
- **JSON Parser**: `lib/code_my_spec/tests/json_parser.ex`
- **Tests Context**: `docs/design/code_my_spec/tests.md`

### Key Features
- **Design-Driven**: Tests generated from design documents
- **Comprehensive**: Includes fixtures, mocks, and edge cases
- **Iterative**: Fixes compilation/test failures automatically
- **Git Integration**: Commits tests to repository

---

## 6. Code Generation

### Core Implementation
- **Component Coding Sessions**: `lib/code_my_spec/component_coding_sessions.ex`
- **Coding Session Orchestrator**: `lib/code_my_spec/component_coding_sessions/orchestrator.ex`
- **Design Documentation**: `docs/design/code_my_spec/component_coding_sessions.md`

### Code Generation Steps
1. **ReadComponentDesign**: Load design documents
2. **GenerateImplementation**: Create code from design
3. **GenerateTests**: Create test suite
4. **RunTests**: Validate code
5. **FixTestFailures**: Iterate on failures
6. **Finalize**: Commit code

### Key Features
- **Design-Driven**: Code matches design specifications
- **Test-First**: Tests generated before implementation
- **Iterative**: Fixes failures automatically
- **Quality Gates**: Tests must pass before finalization

---

## 7. MCP Server Architecture

### Core Implementation
- **MCP Servers Context**: `docs/design/code_my_spec/mcp_servers.md`
- **Stories Server**: `lib/code_my_spec/mcp_servers/stories_server.ex`
- **Components Server**: `lib/code_my_spec/mcp_servers/components_server.ex`

### MCP Infrastructure
- **Formatters**: `lib/code_my_spec/mcp_servers/formatters.ex`
- **Validators**: `lib/code_my_spec/mcp_servers/validators.ex`
- **Mappers**: Story/component serialization for AI consumption

### MCP Protocol Features
- **Tools**: Side-effecting operations (create, update, delete)
- **Resources**: Read-only data access with structured URIs
- **Prompts**: LLM assistance context for workflows
- **Authorization**: OAuth2 bearer token validation

### Key Concepts
- **Thin Interface Layer**: Delegates to business logic contexts
- **AI-First Design**: Optimized for AI agent consumption
- **Standardized Responses**: Consistent formatting for AI parsing
- **Scoped Access**: Multi-tenant isolation

---

## 8. Complete Workflow Example

### End-to-End Flow

```
1. User Stories
    ’ Create stories via Stories MCP tools
        ’ start_story_interview (refine with AI)
            ’ start_story_review (validate completeness)

2. Context Design
    ’ set_story_component (map to architecture)
        ’ create_component (define context)
            ’ start_context_design (initiate design session)

3. Context Components Design (Multi-Component)
    ’ Initialize (create git branch)
        ’ SpawnComponentDesignSessions (parallel child sessions)
            ’ [Each generates component design document]
        ’ SpawnReviewSession (validate consistency)
        ’ Finalize (create pull request)

4. Test Generation
    ’ ComponentTestSession orchestrator
        ’ Initialize workspace
            ’ GenerateTestsAndFixtures (from design docs)
                ’ RunTests
                    ’ FixCompilationErrors (iterate)
                        ’ Finalize (commit tests)

5. Code Generation
    ’ ComponentCodingSession orchestrator
        ’ ReadComponentDesign
            ’ GenerateImplementation (from design)
                ’ GenerateTests
                    ’ RunTests
                        ’ FixTestFailures (iterate)
                            ’ Finalize (commit code)

6. Integration Testing
    ’ IntegrationSession orchestrator
        ’ RunIntegrationTests
            ’ Finalize
```

---

## 9. Test Files (Validation)

Test files demonstrate and validate each part:
- `test/code_my_spec/mcp_servers/stories/tools/` - Story MCP tests
- `test/code_my_spec/mcp_servers/components/tools/` - Component MCP tests
- `test/code_my_spec/context_components_design_sessions/steps/` - Workflow tests
- `test/code_my_spec/sessions/` - Session orchestration tests

---

## 10. Key Architectural Patterns

### Session Orchestration Pattern
- **Stateless Orchestrators**: Pure functions in coordinating contexts
- **Persisted State**: All state in Session records with embedded Interactions
- **Step Modules**: Implement StepBehaviour with callbacks
- **Command/Result Pattern**: Each interaction has command and result

### Scope-Based Access Control
- **Multi-Tenant Isolation**: All operations scoped by account_id/user_id
- **Scope Struct**: Passed through all repository functions
- **PubSub Scoping**: Broadcasts scoped to account level
- **Repository Validation**: Scope validated on all operations

### Design Document Flow
- **Embedded Schemas**: Stored as Ecto embedded schemas
- **Markdown Parsing**: Converted from markdown to structured data
- **Component References**: Explicit module names and types
- **Dependency Tracking**: Inter-context dependencies

### MCP Server Pattern
- **Thin Interface**: Delegates to business logic
- **Authorization**: OAuth2 token validation
- **Tool/Resource Separation**: Write vs read operations
- **AI-Optimized**: Responses formatted for AI consumption

---

## Campaign Integration

This methodology is documented in:
- **Campaign 5**: Journey Series - "How I Learned to Control AI Code Generation"
- **Main Quest Posts**: Manual process (stories, context mapping, design documents)
- **Side Quest Posts**: Automation (MCP servers, Phoenix orchestration)

See: `docs/campaigns/campaign_05_journey_series.md`
