# CodeMySpec - AI-Assisted Phoenix Development Platform

## Core Mission
CodeMySpec is a Phoenix/LiveView application that helps teams manage software development workflows through structured requirement gathering, component design, and test-driven development. The platform integrates with AI agents (Claude Code) via MCP servers to assist with design generation and test creation while maintaining human oversight of architectural decisions.

## Foundational Principle
Effective AI-assisted development requires systematic processes, clear component boundaries, and traceability from requirements through implementation. CodeMySpec provides the scaffolding to manage user stories, component architecture, dependencies, and testing workflows while AI agents handle generation tasks.

## Current Implementation
1. **User Story Management**: Web UI for creating, editing, and organizing user stories with project scoping
2. **Component Architecture**: Define Phoenix contexts/modules with type classification (context, repository, schema, liveview, etc.) and dependency tracking
3. **MCP Integration**: Expose Stories and Components APIs to AI agents via Hermes MCP servers for Claude Code/Desktop integration
4. **Session Orchestration**: Structured workflows for component design and test generation with AI agents
5. **Content Sync**: Git-based content management for syncing markdown/HTML/HEEx files with frontmatter metadata
6. **Multi-Tenancy**: Account-based scoping with OAuth2 provider for secure agent access

## Key Architecture
- **Phoenix Contexts**: Stories, Components, Sessions, Projects, Content, Agents, Accounts, Users
- **MCP Servers**: `StoriesServer` and `ComponentsServer` expose tools for AI agent consumption
- **Session Orchestration**: `ComponentDesignSessions` and `ComponentTestSessions` manage AI-driven workflows through discrete steps
- **Project Coordinator**: Analyzes component requirements against filesystem and test results to determine next actions
- **Repository Pattern**: Consistent data access layer with user/project scoping
- **Multi-Tenant Security**: All operations scoped by `Scope` struct containing active account and project

## Key Principles
- **Process-Guided AI**: Structured session workflows guide AI agents through design and test generation
- **Human-in-the-Loop**: Approval gates and review steps maintain architectural integrity
- **Traceability**: Stories link to components; components track dependencies; sessions maintain audit trail
- **Context Boundaries**: Component types enforce Phoenix architectural patterns
- **Fail-Fast**: Test-driven workflows detect issues early with clear failure paths

## Technology Stack
Phoenix 1.8-rc, LiveView 1.1-rc, Ecto SQL, PostgreSQL, Oban (background jobs), Hermes MCP, OAuth2 Provider, Git CLI integration, FileSystem watchers