<!-- cms:task type="ComponentTest" component="CodeMySpec.TestContext.WidgetRepository" -->

Generate tests and fixtures for the following Phoenix component.
The component doesn't exist yet.
You are to write the tests before we implement the module, TDD style.
Only write the tests defined in the Test Assertions section of the design.
If you want to write more cases, you must modify the design first.


Tests should be grouped by describe blocks that match the function signature EXACTLY.
Any blocks that don't match the test assertions in the spec will be rejected and you'll have to redo them.

describe "get_test_assertions/1" do
  test "extracts test names from test blocks", %{tmp_dir: tmp_dir} do
    ...test code
  end
end

Project: Code My Spec
Project Description: # CodeMySpec - AI-Driven Development Automation Platform
## Core Mission CodeMySpec is a two-part platform — a Phoenix/LiveView web application (SaaS) and a local CLI/plugin — that automates software development workflows by orchestrating AI agents (Claude Code) through structured requirement gathering, component architecture, spec-driven development, and automated validation. The platform manages the full lifecycle from user stories through implementation, using graph-driven task orchestration, real-time hook-based feedback, and a multi-stage validation pipeline to keep AI agents productive and aligned with architectural decisions.
## Foundational Principle Effective AI-assisted development requires systematic processes, clear component boundaries, and traceability from requirements through implementation. CodeMySpec provides the scaffolding — requirement graphs, dependency-aware task dispatch, BDD specs, and automated quality gates — while AI agents handle the generation work within those guardrails.
## Platform Components
### 1. Web Application (SaaS) The Phoenix web app provides the management layer: - **User Story Management**: Web UI for creating, editing, importing, and organizing stories with acceptance criteria and tagging - **Component Architecture**: Define Phoenix contexts/modules with type classification (context, repository, schema, liveview, etc.) and dependency tracking with graph visualization - **Requirements Graph**: Dependency-aware requirement definitions that link stories to components and track implementation status - **Content Management**: Git-based content sync for markdown/HTML/HEEx files with dual-mode processing (server-side validation, client-side full schema) - **Multi-Tenancy**: Account-based scoping with invitations, members, and project isolation - **OAuth2 Provider**: Secure agent/CLI authentication via OAuth2 with PKCE support - **MCP Servers**: Stories (~15 tools), Components (~17 tools), and Architecture (~2 tools) servers exposed via Hermes for AI agent consumption
### 2. CLI & Claude Code Plugin A local webserver (port 4002) packaged as a native binary via Burrito, acting as a Claude Code extension: - **26 Skills**: User-invocable slash commands (e.g., `/start-implementation`, `/develop-liveview`, `/write-bdd-specs`, `/qa-app`, `/fix-issues`) that trigger agent task sessions - **6 Agent Definitions**: Role-specialized agents (qa, researcher, spec-writer, code-writer, test-writer, bdd-spec-writer) with tool access constraints - **Hook Integration**: Real-time Claude Code hooks (Stop, SubagentStop, PreToolUse, PostToolUse) that trigger validation pipelines and track file edits - **MCP Architecture Server**: HTTP MCP endpoint providing architecture tools to Claude Code - **Knowledge Base**: Comprehensive framework reference (Phoenix, LiveView, HEEx, Tailwind/DaisyUI, BDD/SexySpex, Boundary) - **Local Storage**: SQLite database (`~/.codemyspec/cli.db`) for credentials, project cache, and stories - **LaunchAgent Support**: macOS daemon management for persistent background operation
## Current Implementation 1. **Graph-Driven Task Orchestration**: `ProjectCoordinator` traverses the requirement/dependency graph via `NextActionable` to find ready work, then `Dispatch` translates requirements into agent task prompts 2. **35+ Agent Tasks**: Specialized task modules for specs (ComponentSpec, LiveViewSpec, ContextDesignReview), code generation (ComponentCode, DevelopContext, DevelopLiveView), QA (QaApp, QaStory, TriageIssues, FixIssues), and research (TechnicalStrategy, ResearchTopic) 3. **Validation Pipeline**: Hook-triggered multi-stage validation — compile, test, Credo, Sobelow, BDD specs (SexySpex), spec documents, QA documents — with problem aggregation and persistence 4. **Session Management**: Filesystem-backed sessions (`.code_my_spec/sessions/`) with status tracking, prompt generation, and evaluation 5. **Transcript Analysis**: Parse Claude Code transcripts to identify edited files, evaluate task completion, and extract component markers 6. **Content Sync**: Dual-mode git-based sync with Markdown/HTML processing, frontmatter metadata, and file watcher for dev mode 7. **Architecture Governance**: Boundary-enforced module dependencies, architecture health summaries, Mermaid diagram generation, and orphaned context detection
## Key Architecture - **Phoenix Contexts**: Stories, Components, Requirements, Projects, Content, Accounts, Users, BddSpecs, Problems, Validation, StaticAnalysis, Architecture, plus 10+ supporting contexts - **MCP Servers**: `StoriesServer`, `ComponentsServer`, and `ArchitectureServer` expose ~34 tools via Hermes HTTP endpoints with OAuth2 protection - **Project Coordinator**: Graph traversal (`NextActionable`) + task dispatch (`Dispatch`) + status file generation for observable orchestration - **Validation Pipeline**: `Pipeline.run/3` chains compile → test → Credo → Sobelow → Spex → spec/QA document validators, returning `Problem` structs - **Repository Pattern**: Consistent data access layer with Scope-based scoping (user, account, project, cwd) - **Environment Abstraction**: Unified interface for CLI (tmux), server, and VS Code execution contexts - **PubSub Broadcasting**: Real-time updates for accounts, projects, stories, components, and sessions
## Key Principles - **Graph-Driven Orchestration**: Dependency-aware traversal determines what to work on next, not manual sequencing - **Process-Guided AI**: Structured task modules generate prompts with constraints, then evaluate results against acceptance criteria - **Automated Quality Gates**: Every edit triggers compilation, tests, linting, security analysis, and BDD spec validation - **Human-in-the-Loop**: Approval gates, design reviews, and QA workflows maintain architectural integrity - **Traceability**: Stories → requirements → components → specs → tests → problems, all linked and tracked - **Context Boundaries**: `use Boundary` in every module enforces Phoenix architectural patterns at compile time - **Observable State**: Status files, prompts, and problems written to `.code_my_spec/status/` for agent and human consumption
## Technology Stack **Web App**: Phoenix 1.8, LiveView 1.1, Tailwind, DaisyUI, Ecto SQL, PostgreSQL, Hermes MCP, OAuth2 Provider (ex_oauth2_provider), Cloak (encryption), PaperTrail (audit), Git CLI, FileSystem watchers, SexySpex (BDD), Boundary (dependency enforcement)
**CLI/Plugin**: Burrito (native binary packaging), Bandit (HTTP server), SQLite (ecto_sqlite3), Optimus (CLI parsing), OAuth2 client with PKCE, Phoenix PubSub, shared domain logic from web app
Component Name: WidgetRepository
Component Type: repository

Parent Context Design File: no parent design
Component Design File: .code_my_spec/spec/code_my_spec/test_context/widget_repository.spec.md

Similar Components (for test pattern inspiration):
No similar components provided

Test Rules:
# Repository Test Design Rules

## Test Structure
```elixir
defmodule App.Context.RepositoryTest do
  use App.DataCase, async: true
  
  import App.ContextFixtures
  
  alias App.Context.{Schema, Repository}
  alias App.Repo
  
  # Group tests by function with describe blocks
end
```

## Test Organization

### Describe Blocks
- One `describe` block per public function
- Use function name with arity: `describe "create_account/1"`
- Group related edge cases within the same describe block

### Test Coverage Per Function
- Happy path test (valid data succeeds)
- Validation error tests (invalid data fails appropriately)
- Constraint violation tests (uniqueness, foreign keys)
- Edge cases specific to business logic

## Fixture Usage

### Setup Data
- Use fixtures for test data creation: `account_fixture()`, `user_fixture()`
- Pass attributes to fixtures for specific scenarios: `account_fixture(%{slug: "test"})`
- Create composite fixtures for complex setups: `account_with_owner_fixture(user)`

### No Mocks
- Test against actual database operations
- Use real data and verify actual state changes
- Assert on database state after operations

## Assertion Patterns

### CRUD Operations
- **Create**: Assert return tuple, verify attributes, check database persistence
- **Get**: Assert returned data matches expected, test nil returns
- **Update**: Verify changes applied, assert unchanged fields remain
- **Delete**: Confirm removal from database, test cascade behavior

### Error Cases
- Assert `{:error, changeset}` return format
- Use `errors_on(changeset)` to verify specific field errors
- Test constraint violations with appropriate error messages

### Query Builders
- Test query composition with `Repo.all(query)`
- Verify filtering logic with known test data
- Assert preloads work with `Ecto.assoc_loaded?/1`

## Database State Verification

### Direct Database Checks
- Use `Repo.get_by/2` to verify records exist/don't exist
- Check associations are properly created/deleted
- Verify cascade behavior on deletions

### Transaction Testing
- Test complex operations that involve multiple repositories
- Verify rollback scenarios when part of operation fails
- Assert all-or-nothing behavior for multi-step operations

## Test Data Strategies

### Isolation
- Use `async: true` when tests don't interfere
- Each test creates its own data via fixtures
- No shared state between tests

### Edge Cases
- Test boundary conditions (empty strings, large values)
- Verify handling of non-existent IDs
- Test reserved values or special business rules

## Query Composition Testing

### Individual Builders
- Test each query builder function separately
- Verify they return proper `Ecto.Query.t()` structures
- Test with known data and verify filtering

### Combined Usage
- Show query builders can be composed together
- Test realistic query patterns from the application
- Verify performance considerations (preloads, N+1 prevention)

Test the happy path first and thoroughly at the top of the file.
Continue to write tests in descending order of likelihood.
Avoid mocks wherever possible. Use real data and implementations.
Use recorders like ex_vcr to record actual system interactions where you can't use real data and implementations.
Mocks are appropriate to use at the boundary of the application, especially when they will heavily impact the performance of the test suite.
Identify application boundaries that need mocks, and write them if necessary.
Tests should be relatively fast. We don't want to slow the test suite down.
Write fixed, concrete assertions. 
Never use case, if or "or" in your test assertions.
Do not use try catch statements in tests.
Use fixtures wherever possible.
Delegate as much setup as possible.
Use ExUnit.CaptureLog to prevent shitting up the logs.

# Collaboration Guidelines
- **Challenge and question**: Don't immediately agree or proceed with requests that seem suboptimal, unclear, or potentially problematic
- **Push back constructively**: If a proposed approach has issues, suggest better alternatives with clear reasoning
- **Think critically**: Consider edge cases, performance implications, maintainability, and best practices before implementing
- **Seek clarification**: Ask follow-up questions when requirements are ambiguous or could be interpreted multiple ways
- **Propose improvements**: Suggest better patterns, more robust solutions, or cleaner implementations when appropriate
- **Be a thoughtful collaborator**: Act as a good teammate who helps improve the overall quality and direction of the project

You run in an environment where ast-grep is available; whenever a search requires syntax-aware or structural matching, default to ast-grep --lang elixir -p '<pattern>' (or set --lang appropriately) and avoid falling back to text-only tools like rg or grep unless I explicitly request a plain-text search.

Write the test file to test/code_my_spec/test_context/widget_repository_test.exs.

Focus on:
- Reading the design files to understand the component architecture and parent context
- Creating reusable fixture functions for test data
- Testing all public API functions
- Testing edge cases and error conditions
- Testing with valid and invalid data
- Following test and fixture organization patterns from the rules
- Only implementing the test assertions from the design file
