<!-- cms:task type="ContextDesignReview" component="CodeMySpec.TestContext" -->

# Context Design Review

Review the architecture of a Phoenix context and its child components.

## Project

**Project:** Code My Spec
**Description:** # CodeMySpec - AI-Driven Development Automation Platform
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

## Context Being Reviewed

**Name:** TestContext
**Module:** CodeMySpec.TestContext
**Type:** context
**Description:** Test context for children_designs step-through

## Spec Files to Review

### Context Spec
.code_my_spec/spec/code_my_spec/test_context.spec.md

### Child Component Specs
- Widget (schema): .code_my_spec/spec/code_my_spec/test_context/widget.spec.md
- WidgetRepository (repository): .code_my_spec/spec/code_my_spec/test_context/widget_repository.spec.md

## User Stories
No user stories have been associated with this context.



## Review Tasks

1. **Read All Spec Files**: Read the context spec and every child component spec. Do not skip any.

2. **Cross-check types against descriptions**: For every function, verify the @spec types make sense for what the component description says it does. A module described as doing numeric operations must use numeric types, not strings.

3. **Verify every function belongs**: Each function in a component must align with that component's stated purpose. Flag any function that doesn't belong (e.g. multiply/2 in an addition-only module).

4. **Check test assertions for contradictions**: Read each function's Test Assertions list. Flag any pair of assertions that contradict each other (e.g. same input producing different expected outputs).

5. **Validate dependencies exist**: Every module listed in a Dependencies section must correspond to a real component in this architecture. Cross-reference against the context spec's Components section.

6. **Check context delegates match child APIs**: The context spec's Delegates section should reference functions that actually exist in child component specs.

7. **Verify story coverage**: Each user story's acceptance criteria should map to at least one function across the specs.

8. **Fix Issues**: If you find ANY problems in steps 2-6, you MUST update the spec files directly before writing the review. Do not write a passing review with known issues.

9. **Write Review**: Document your findings using the format below. The Issues section is REQUIRED if you fixed anything.

## Review Document Format
# Design Review

Design review documents summarize architectural analysis of a Phoenix context
and its child components. Reviews validate consistency, integration, and
alignment with user stories. Keep reviews concise and actionable.


## Required Sections

### Overview

Format:
- Use H2 heading
- Brief paragraph (2-4 sentences)

Content:
- State what was reviewed (context name and component count)
- Summarize the overall assessment (sound/needs work)


### Architecture

Format:
- Use H2 heading
- Bullet list of findings

Content:
- Assess separation of concerns
- Validate component type usage (schema, repository, service patterns)
- Check dependency relationships
- Flag any architectural concerns


### Integration

Format:
- Use H2 heading
- Bullet list of integration points

Content:
- List how components connect
- Identify public APIs and delegation points
- Note any missing or problematic integration points


### Conclusion

Format:
- Use H2 heading
- Single paragraph

Content:
- State readiness for implementation (ready/blocked)
- List any remaining action items if blocked


## Optional Sections

### Stories

Format:
- Use H2 heading
- Bullet list mapping stories to components

Content:
- For each user story, confirm which components satisfy it
- Identify any gaps in coverage


### Issues

Format:
- Use H2 heading
- Bullet list or "None found"

Content:
- List any issues discovered during review
- For each issue, note if it was fixed and how



## Output

Write your review to: **.code_my_spec/spec/code_my_spec/test_context/design_review.md**

The review should be concise - focus on findings, not repetition of what was reviewed.
