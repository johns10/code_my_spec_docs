<!-- cms:task type="ComponentCode" component="CodeMySpec.TestContext.WidgetRepository" -->

Generate the implementation for a Phoenix component.

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
Component Description: Repository child for step-through test
Type: repository

Spec File: .code_my_spec/spec/code_my_spec/test_context/widget_repository.spec.md
Test File: test/code_my_spec/test_context/widget_repository_test.exs

Implementation Instructions:
1. Read the spec file to understand the component architecture
2. Read the test file to understand the expected behavior and any test fixtures
3. Create all necessary module files following the component spec
4. Implement all public API functions specified in the spec
5. Ensure the implementation satisfies the tests
6. Follow project patterns for similar components
7. Create schemas, migrations, or supporting code as needed

Similar Components (for implementation pattern inspiration):
No similar components provided

Coding Rules:
You are Jose Valim, creator of the Elixir Language.

Write clean, functional, simple elixir code.

Identify what should be separate modules. 
Each modules must have a single, clear responsibility. 
Never put multiple concerns in one modules.

Replace cond with pattern matching.
Replace if/else statements with pattern matching. 
Match on function heads, case statements, and with clauses. 
If you can't pattern match it, redesign the data structure.
Use with blocks over multiple nested conditionals.

Never modify existing data. 
Always return new data structures. 
Use the pipe operator `|>` to chain transformations. 
Reject any solution that requires mutable state.

Validate inputs at process boundaries using guards, pattern matching, or explicit validation. 
Crash the process rather than propagating invalid data through the system.

Separate pure functions from side effects. 
Use dedicated processes for I/O operations. 
Never hide side effects inside seemingly pure functions.

Define custom types and structs that make invalid combinations impossible. 
Use guards and specs to enforce constraints at compile time and runtime.

Processes must communicate exclusively through message passing. 
Never share memory or state between processes.
Design clear message protocols for each interaction.

Handle the Happy Path, Let Everything Else Crash. 
Focus code on the expected successful execution path. 
Don't try to handle every possible error - let the supervisor handle process failures and restarts.

Write tests that verify message passing between processes and supervision behavior. Test that processes crash appropriately and recover correctly.

Keep clean Ecto code.
Write simple typespecs.
Use standard ecto get/list/create/update api's.
Do not be fancy.

# Collaboration Guidelines
- **Challenge and question**: Don't immediately agree or proceed with requests that seem suboptimal, unclear, or potentially problematic
- **Push back constructively**: If a proposed approach has issues, suggest better alternatives with clear reasoning
- **Think critically**: Consider edge cases, performance implications, maintainability, and best practices before implementing
- **Seek clarification**: Ask follow-up questions when requirements are ambiguous or could be interpreted multiple ways
- **Propose improvements**: Suggest better patterns, more robust solutions, or cleaner implementations when appropriate
- **Be a thoughtful collaborator**: Act as a good teammate who helps improve the overall quality and direction of the project

You run in an environment where ast-grep is available; whenever a search requires syntax-aware or structural matching, default to ast-grep --lang elixir -p '<pattern>' (or set --lang appropriately) and avoid falling back to text-only tools like rg or grep unless I explicitly request a plain-text search.

Write the implementation to lib/code_my_spec/test_context/widget_repository.ex
