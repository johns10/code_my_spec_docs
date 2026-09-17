# Architecture Proposal

## Contexts

### CodeMySpec.AcceptanceCriteria

- **Type:** context

#### Children

- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository (module): Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filtering by story and verification status filtering. All operations respect project and account scoping. The context module delegates read operations directly to this repository and wraps write operations with PubSub broadcasting.
- CodeMySpec.AcceptanceCriteria.Criterion (schema): Ecto schema representing a single acceptance criterion. Contains the description text, verification status, and belongs to a story. Scoped to account and project for multi-tenancy.

### CodeMySpec.Accounts

- **Type:** context
- **Description:** The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

#### Children

- CodeMySpec.Accounts.Account (schema): Ecto schema representing user accounts in the multi-tenant system. Accounts can be either personal (belonging to a single user) or team-based (shared among multiple members). Each account has a unique slug for URL-friendly identification.
- CodeMySpec.Accounts.AccountsRepository (module): Data access layer for account entities, handling personal and team account creation, basic account operations, and query building within the multi-tenant architecture.
- CodeMySpec.Accounts.Member (schema): Ecto schema managing the many-to-many relationship between accounts and users with role-based permissions. Supports a three-tier role hierarchy (owner, admin, member) with business rules ensuring each account maintains at least one owner.
- CodeMySpec.Accounts.MembersRepository (module): Provides data access layer for account membership relationships, handling user addition/removal, role management, and access control within the multi-tenant architecture.

### CodeMySpec.AgentTasks

- **Type:** context
- **Description:** Specialized task modules — codegen, QA, research, integration planning, three amigos, persona research, spex boundary readiness, architecture design, ADRs, component spec / test, BDD specs — that build agent prompts and evaluate output. Each task is a child module surfaced via the local MCP tools server.

#### Children

- CodeMySpec.AgentTasks.ArchitectureDesign (skill)
- CodeMySpec.AgentTasks.CodeGeneration (skill)
- CodeMySpec.AgentTasks.ComponentCode (module)
- CodeMySpec.AgentTasks.ComponentSpec (module): Agent task module for generating component specification documents via Claude Code slash commands.

This module orchestrates the workflow of creating component spec documents through AI agents. It provides two main entry points: `command/3` builds the initial prompt for Claude with design rules and document specifications, while `evaluate/3` validates the generated spec against artifact requirements and checks for persisted problems on the spec file.
- CodeMySpec.AgentTasks.ComponentTest (module)
- CodeMySpec.AgentTasks.ContextDesignReview (module)
- CodeMySpec.AgentTasks.ContextSpec (module)
- CodeMySpec.AgentTasks.ControllerSpec (module)
- CodeMySpec.AgentTasks.Deploy (module)
- CodeMySpec.AgentTasks.DesignUi (skill)
- CodeMySpec.AgentTasks.DevelopContext (module): Orchestrates the full lifecycle of a context from specification through implementation.

Creates prompt files for all subagent tasks in order:
1. Context spec (ContextSpec)
2. Component specs (ComponentSpec) for each child
3. Design review (ContextDesignReview)
4. Tests for each component (ComponentTest)
5. Code for each component (ComponentCode)

The module generates prompt files in `.code_my_spec/internal/sessions/{external_id}/subagent_prompts/`
and provides orchestration instructions for AI agents to invoke appropriate subagents for each phase.
- CodeMySpec.AgentTasks.DevelopLiveView (logic)
- CodeMySpec.AgentTasks.DevopsSetup (module)
- CodeMySpec.AgentTasks.Evaluator (module)
- CodeMySpec.AgentTasks.FixAllBddSpecs (module)
- CodeMySpec.AgentTasks.FixBddSpecs (agent_task)
- CodeMySpec.AgentTasks.FixIssues (skill)
- CodeMySpec.AgentTasks.FixStoryIssues (module)
- CodeMySpec.AgentTasks.Init (module)
- CodeMySpec.AgentTasks.LiveContextSpec (module)
- CodeMySpec.AgentTasks.LiveViewSpec (module)
- CodeMySpec.AgentTasks.PersonaResearch (skill)
- CodeMySpec.AgentTasks.ProblemFeedback (module)
- CodeMySpec.AgentTasks.ProjectSetup (module)
- CodeMySpec.AgentTasks.PromoteWork (module)
- CodeMySpec.AgentTasks.QaApp (module)
- CodeMySpec.AgentTasks.QaIntegrationPlan (skill)
- CodeMySpec.AgentTasks.QaJourney (skill)
- CodeMySpec.AgentTasks.QaSetup (skill)
- CodeMySpec.AgentTasks.QaStory (skill)
- CodeMySpec.AgentTasks.Release (module)
- CodeMySpec.AgentTasks.ResearchTopic (module)
- CodeMySpec.AgentTasks.Setup.AgentsMd (module)
- CodeMySpec.AgentTasks.Setup.ApplicationInWeb (module)
- CodeMySpec.AgentTasks.Setup.ClaudeMd (module)
- CodeMySpec.AgentTasks.Setup.CodemyspecDeps (module)
- CodeMySpec.AgentTasks.Setup.Compilers (module)
- CodeMySpec.AgentTasks.Setup.Context (module)
- CodeMySpec.AgentTasks.Setup.CredoChecks (module)
- CodeMySpec.AgentTasks.Setup.Helpers (module)
- CodeMySpec.AgentTasks.Setup.ProjectStructure (module)
- CodeMySpec.AgentTasks.Setup.Rules (module)
- CodeMySpec.AgentTasks.Setup.SpexCase (module)
- CodeMySpec.AgentTasks.Setup.SpexConfig (module)
- CodeMySpec.AgentTasks.Setup.TestBoundaries (module)
- CodeMySpec.AgentTasks.Setup.TestSupportNamespace (module)
- CodeMySpec.AgentTasks.SkillRouter (module)
- CodeMySpec.AgentTasks.SpexBoundaryReady (skill)
- CodeMySpec.AgentTasks.StartAgentTask (module): Orchestrates agent task session startup. Validates inputs, syncs the project,
resolves the correct AgentTask module, creates a filesystem-backed Session,
and calls the module's `command/2` to generate the initial prompt.

Classifies tasks into five categories — bootstrap, project, componentless,
topic, and component — each with a different startup pipeline.
- CodeMySpec.AgentTasks.StartImplementation (module)
- CodeMySpec.AgentTasks.StoryInterview (skill)
- CodeMySpec.AgentTasks.TechnicalStrategy (skill)
- CodeMySpec.AgentTasks.ThreeAmigos (skill)
- CodeMySpec.AgentTasks.TriageIssues (module)
- CodeMySpec.AgentTasks.WriteBddSpecs (skill)

### CodeMySpec.Agents

- **Type:** context
- **Description:** The agents CodeMySpec has started, and the credential each one runs on.

Server-side half of starting an agent. Owns which agents exist, on which working copy, and on which provider; mints the per-copy Pi configuration from the account's provider integration; and holds the record a conversation attaches to. `CmsHarness.Agents` is the other half — the OS process on the device — reached over the harness channel. Same split as Provisioning: state and ordering live server-side, execution happens on the box.

An agent is only started when it can be watched. Registration, login and the first messages are one act, not three: a started agent joins over `HarnessSocket`, `AgentHarness.relay_up/2` carries its turns into `Conversations`, and it appears in the agent chat surface alongside a Claude Code agent on the same copy. An agent the server cannot observe is indistinguishable from one that never started, which is what makes "it appears in chat and is talking" the acceptance signal rather than an exit status.

Credentials are held here as integrations, per provider, and both Pi credential kinds are in scope — OAuth for subscriptions, API key for coding plans. Adding a provider is adding an integration, not a second way to start an agent.

Dependencies: Integrations, Conversations, AgentHarness, Projects, Harnesses.

#### Children

- CodeMySpec.Agents.Agent (schema)
- CodeMySpec.Agents.AgentsRepository (module)
- CodeMySpec.Agents.Credential (module)
- CodeMySpec.Agents.Defaults (module)
- CodeMySpec.Agents.LaunchRequest (module)
- CodeMySpec.Agents.ModelSetting (schema)
- CodeMySpec.Agents.OperatingRules (module)
- CodeMySpec.Agents.Phase (module)
- CodeMySpec.Agents.Providers (module)
- CodeMySpec.Agents.RoleBrief (module)
- CodeMySpec.Agents.StopDecision (module)
- CodeMySpec.Agents.ToolIndex (module)
- CodeMySpec.Agents.ToolSets (module)
- CodeMySpec.Agents.Transport (module)

### CodeMySpec.Authorization

- **Type:** context
- **Description:** Authorization module. (Stub — @moduledoc not found; flesh out manually.)

### CodeMySpec.BddRules

- **Type:** context
- **Description:** The BddRules context — Three Amigos blue cards.

#### Children

- CodeMySpec.BddRules.BddRulesRepository (module)
- CodeMySpec.BddRules.GherkinRenderer (module)
- CodeMySpec.BddRules.Rule (schema)

### CodeMySpec.BddSpecs

- **Type:** context

#### Children

- CodeMySpec.BddSpecs.ContentCheck (module)
- CodeMySpec.BddSpecs.Parser (module)
- CodeMySpec.BddSpecs.Scenario (schema (non-persisted))
- CodeMySpec.BddSpecs.Spec (schema (non-persisted))
- CodeMySpec.BddSpecs.SpecProjector (module)
- CodeMySpec.BddSpecs.Spex (component)
- CodeMySpec.BddSpecs.Step (schema (non-persisted))
- CodeMySpec.BddSpecs.Types.AtomArray (module)

### CodeMySpec.ClientUsers

- **Type:** context
- **Description:** The ClientUsers context.

#### Children

- CodeMySpec.ClientUsers.ClientUser (schema)

### CodeMySpec.CodeMode

- **Type:** context

#### Children

- CodeMySpec.CodeMode.Bindings (module)
- CodeMySpec.CodeMode.Catalog (module)
- CodeMySpec.CodeMode.Docs (module)
- CodeMySpec.CodeMode.LuaValue (module)
- CodeMySpec.CodeMode.Result (module)
- CodeMySpec.CodeMode.Sandbox (module)

### CodeMySpec.Components

- **Type:** context
- **Description:** Manages component definitions, metadata, type classification, and inter-component dependencies for architectural design.

#### Children

- CodeMySpec.Components.Component (schema)
- CodeMySpec.Components.ComponentRepository (module): Repository for managing Component entities within a project scope. Provides CRUD operations, filtering by type and name, dependency preloading, architecture visualization, and requirement-based work tracking.
- CodeMySpec.Components.ComponentStatus (schema)
- CodeMySpec.Components.ConventionalPaths (module)
- CodeMySpec.Components.Dependency (schema): Ecto schema representing a directed dependency relationship between two components.
Models "source depends on target" semantics where the source component requires
the target component to function.
- CodeMySpec.Components.DependencyRepository (module): Repository for managing component dependency relationships within a project scope. Provides CRUD operations for dependencies between components and graph analysis utilities for detecting circular dependencies and resolving dependency order.
- CodeMySpec.Components.DependencyTree (module): Build nested dependency trees for components by processing them in optimal order.

Uses topological sorting to ensure all dependencies are fully analyzed before
dependent components, enabling efficient construction of nested dependency trees.
- CodeMySpec.Components.HierarchicalTree (module): Build nested hierarchical trees for components based on parent-child relationships.

Unlike dependency trees which require topological sorting to handle cycles,
hierarchical trees are naturally acyclic tree structures that can be built
through simple recursive traversal.
- CodeMySpec.Components.Registry (module): Central registry containing all component type-specific metadata and behavior definitions.
Provides the authoritative source for component type characteristics including requirements,
display properties, workflow rules, and validation logic.

### CodeMySpec.Configurations

- **Type:** context
- **Description:** Per-project local quality-gate settings (`require_specs`, `require_reviews`, `require_unit_tests`). Filters the requirement graph without breaking edges or producing vacuous actionable nodes.

#### Children

- CodeMySpec.Configurations.ProjectConfiguration (schema)

### CodeMySpec.Content

- **Type:** context
- **Description:** Generator-output rendering surface dropped into deployed client apps. Receives content pushes from ContentAdmin, persists locally, renders `/blog/:slug`, `/pages/:slug`, `/landing/:slug`, `/documentation/:slug` honoring publish_at/expires_at and tag filters.

#### Children

- CodeMySpec.Content.CloudflareClient (module)
- CodeMySpec.Content.Content (schema)
- CodeMySpec.Content.ContentRepository (module): Provides data access functions for published Content entities. Handles content retrieval with optional scope filtering - passing a Scope allows access to protected content for authenticated users, while nil scope only returns public content. Does NOT apply multi-tenant filtering by account_id/project_id.

Note: This repository is for published content access only. ContentAdminRepository handles validation/preview with multi-tenant scoping.
- CodeMySpec.Content.ContentTag (schema)
- CodeMySpec.Content.ExAwsReqClient (module)
- CodeMySpec.Content.Pull (module)
- CodeMySpec.Content.PullClient (module)
- CodeMySpec.Content.S3Client (module)
- CodeMySpec.Content.Tag (schema): Ecto schema representing content tags for categorization and organization. Tags have a many-to-many relationship with content items through a join table.
- CodeMySpec.Content.TagRepository (module): Query builder module for tag upsert and lookup.

Handles tag normalization and conflict resolution on unique constraints.
Tags are single-tenant (no account_id/project_id scoping) and shared globally
across the deployed content system.
- CodeMySpec.Content.TriggerClient (module)

### CodeMySpec.Conversations

- **Type:** context
- **Description:** Chat domain for operator-to-end-user messaging. Owns conversations (one thread per end-user, scoped to account+project) and messages. Participant-agnostic envelope: a message's author is identified by (role, sender_id) with role in [:user, :operator] and :assistant reserved for future LLM participants. Human-to-human only in v1; no streaming/parts/tool-call/model-config machinery. Account-scoped so any CMS user in the account can read and reply; end-users isolated to their own thread.

#### Children

- CodeMySpec.Conversations.Checkpoint (schema)
- CodeMySpec.Conversations.Conversation (schema): One continuous thread between an end-user and the account. Belongs to an account and a project; carries the end-user's identity (external user id/email). Has many messages. Unique per (account, project, end-user) so repeat messages append rather than fork a new thread.
- CodeMySpec.Conversations.Message (schema): A single message in a conversation. Has a text body and an author identified by (role, sender_id): role is :user (end-user) or :operator (a CMS user in the account), with :assistant reserved for future LLM authors. Ordered by inserted_at. No streaming/parts/tool-call structure in v1 — body is plain text.

### CodeMySpec.Documents

- **Type:** context

#### Children

- CodeMySpec.Documents.DocumentSpecProjector (other)
- CodeMySpec.Documents.Field (schema)
- CodeMySpec.Documents.Function (schema)
- CodeMySpec.Documents.MarkdownParser (other)
- CodeMySpec.Documents.Parsers.ComponentParser (other)
- CodeMySpec.Documents.Parsers.ContextParser (module)
- CodeMySpec.Documents.Parsers.DependencyParser (other)
- CodeMySpec.Documents.Parsers.FieldParser (other)
- CodeMySpec.Documents.Parsers.FunctionParser (other)
- CodeMySpec.Documents.Parsers.IssueParser (module)
- CodeMySpec.Documents.Parsers.LiveviewParser (module)
- CodeMySpec.Documents.Parsers.SurfaceComponentParser (module)
- CodeMySpec.Documents.QaIssue (schema)
- CodeMySpec.Documents.Registry (other)
- CodeMySpec.Documents.SpecComponent (schema)

### CodeMySpec.Embeddings

- **Type:** context
- **Description:** Context for document embeddings and semantic search.

#### Children

- CodeMySpec.Embeddings.Backend (module)
- CodeMySpec.Embeddings.DocEmbedding (schema)
- CodeMySpec.Embeddings.EmbeddingService (module)
- CodeMySpec.Embeddings.HexDocProjector (module)
- CodeMySpec.Embeddings.PgVectorBackend (module)
- CodeMySpec.Embeddings.Serving (module)
- CodeMySpec.Embeddings.SqliteVecBackend (module)
- CodeMySpec.Embeddings.TestBackend (module)

### CodeMySpec.EpicDispatch

- **Type:** context

### CodeMySpec.Epics

- **Type:** context
- **Description:** Epics are named, user-managed collections that organize a project's user stories. A story belongs to at most one epic. Epics are purely organizational — they carry no execution semantics; releasing an epic's stories for development is a one-shot bulk edit of the stories themselves.

#### Children

- CodeMySpec.Epics.Epic (schema): Epic schema — a named collection of stories scoped to a project and account. Stories reference their epic; a story belongs to at most one.
- CodeMySpec.Epics.EpicsRepository (module): Scope-based data access for epics — list, get, create, update, delete, assign stories to an epic, and bulk-set the ready-for-development flag across an epic's stories.

### CodeMySpec.Files

- **Type:** context
- **Description:** Filesystem-to-DB projection of tracked project files. Stores path, role, mtime, fingerprint, validity, owning component. Drives auto-embedding (project_knowledge + hex_doc roles) so semantic_search reflects current disk state.

#### Children

- CodeMySpec.Files.ComponentExtract (module)
- CodeMySpec.Files.ComponentSync (module)
- CodeMySpec.Files.File (schema)
- CodeMySpec.Files.FileSync (module)
- CodeMySpec.Files.ReconcileRegistry (module)
- CodeMySpec.Files.Scanner (module)

### CodeMySpec.Generators

- **Type:** context
- **Description:** Deploy boilerplate a generated project ships with: Dockerfile, CI workflow, per-environment deploy configuration, SOPS env scaffolding, and a health route outside all router pipelines. Always emitted, never behind a flag, so the setup routine fills in values instead of generating files. The templates themselves live in the cms_new generator repo; this component represents them in the architecture.

#### Children

- CodeMySpec.Generators.DeployArtifacts (module)
- CodeMySpec.Generators.DeployBoilerplate (module)

### CodeMySpec.Git

- **Type:** context
- **Description:** Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations for cloning and pulling repositories using OAuth tokens from the Integrations context.

#### Children

- CodeMySpec.Git.Behaviour (module)
- CodeMySpec.Git.CLI (module): Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library.
- CodeMySpec.Git.URLParser (module): Parses HTTPS git repository URLs to extract provider information and construct authenticated URLs with injected access tokens. This module supports GitHub and GitLab providers, converting HTTPS URLs into authenticated formats suitable for git operations.

### CodeMySpec.Intake

- **Type:** context
- **Description:** Pre-signup plans. Holds the visitor's description, their answers about sign-in and separate copies, and the names the plan proposes, as a row keyed to an anonymous session cookie that never expires. Generates the plan from the description, and converts a confirmed plan into an account and project at signup — under the confirmed names, with no collision ever surfaced to the visitor.

#### Children

- CodeMySpec.Intake.Agent (module)
- CodeMySpec.Intake.Conversation (module)
- CodeMySpec.Intake.Funnel (module)
- CodeMySpec.Intake.Interview (module)
- CodeMySpec.Intake.Interviewer (module)
- CodeMySpec.Intake.Phases.Shape (module)
- CodeMySpec.Intake.Plan (schema)
- CodeMySpec.Intake.Planner (module)
- CodeMySpec.Intake.PlansRepository (module)
- CodeMySpec.Intake.Shaper (module)
- CodeMySpec.Intake.Turn (schema)

### CodeMySpec.Integrations

- **Type:** context
- **Description:** Context module for managing OAuth provider integrations.

#### Children

- CodeMySpec.Integrations.Integration (schema)
- CodeMySpec.Integrations.IntegrationRepository (module)
- CodeMySpec.Integrations.Providers.ApiKey (module)
- CodeMySpec.Integrations.Providers.Behaviour (module)
- CodeMySpec.Integrations.Providers.Cloudflare (module): Cloudflare connection implementing Integrations.Providers.Behaviour — config/0, strategy/0 and normalize_user/1 — so the token lands in an Integration row encrypted at rest like every other provider. Covers the scopes the devops routine needs: DNS edit plus Registrar write. Provisioning.Cloudflare reads its token through Integrations rather than holding a credential of its own.
- CodeMySpec.Integrations.Providers.GitHub (module)
- CodeMySpec.Integrations.Providers.Google (module)
- CodeMySpec.Integrations.Providers.OpenAI (module)
- CodeMySpec.Integrations.Providers.Resend (module): Resend connection implementing Integrations.Providers.Behaviour, covering both outbound sending domains and inbound. Provisioning.Resend reads its token through Integrations so mail setup carries no credential of its own.

### CodeMySpec.Issues

- **Type:** context

#### Children

- CodeMySpec.Issues.Issue (schema)
- CodeMySpec.Issues.IssuesRepository (repository)

### CodeMySpec.Mail

- **Type:** context
- **Description:** Email-on-your-domain for an account: per-project mailboxes (each assigned to a user or shared, with a catch-all for unmatched addresses) over the project's verified domain. Inbound arrives via the provider's email.received webhook (routed by To-address to a mailbox); outbound sends with the mailbox address as From. We persist message metadata + text/html body for durable per-correspondent threads (the provider only retains ~30 days); attachments are linked within the provider window, not stored (v1). Provider (Resend) sits behind an adapter. Not coupled to Conversations/chat.

#### Children

- CodeMySpec.Mail.Attachments (module)
- CodeMySpec.Mail.Email (schema): A persisted email in a mailbox: belongs to a mailbox, carries direction (inbound/outbound), from/to, subject, text/html body, provider id, and threading headers (message_id, in_reply_to, references). Persisted on the inbound webhook and on send so history outlives the provider's ~30-day window. Threaded per correspondent (the other party's address). Attachments are referenced by provider URL within the window, not stored (v1).
- CodeMySpec.Mail.EmailAttachment (schema)
- CodeMySpec.Mail.HtmlSanitizer (module)
- CodeMySpec.Mail.ImageProxy (module)
- CodeMySpec.Mail.Mailbox (schema): A mailbox on a project's domain: belongs to a project, has an address (local-part on the project domain), and is either assigned to a user (user_id) or shared (user_id nil). One mailbox per project may be the catch-all for unmatched inbound addresses.
- CodeMySpec.Mail.ResendClient (module)

### CodeMySpec.MainAgent

- **Type:** context

#### Children

- CodeMySpec.MainAgent.AgentWork (module)
- CodeMySpec.MainAgent.Cadence (module)
- CodeMySpec.MainAgent.CapabilityGap (schema)
- CodeMySpec.MainAgent.CheckInReport (module)
- CodeMySpec.MainAgent.Digest (module)
- CodeMySpec.MainAgent.GapRepository (module)
- CodeMySpec.MainAgent.Machinery (module)
- CodeMySpec.MainAgent.MachineryRepository (module)
- CodeMySpec.MainAgent.OpenQuestion (module)
- CodeMySpec.MainAgent.QuestionsRepository (module)
- CodeMySpec.MainAgent.Restart (schema)
- CodeMySpec.MainAgent.RestartRepository (module)
- CodeMySpec.MainAgent.WorkRepository (module)

### CodeMySpec.McpServers

- **Type:** context
- **Description:** MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

This context serves as the namespace for MCP server implementations that expose CodeMySpec functionality to AI agents (Claude Code, Claude Desktop) via the Anubis MCP library. The actual protocol handling is delegated to Anubis.Server - this context organizes the server definitions, tools, and shared infrastructure.

#### Children

- CodeMySpec.McpServers.AgentAlert (module)
- CodeMySpec.McpServers.Agents.AgentsMapper (module)
- CodeMySpec.McpServers.Agents.Tools.ListAgents (module)
- CodeMySpec.McpServers.Agents.Tools.MessageAgent (module)
- CodeMySpec.McpServers.Agents.Tools.StartAgent (module)
- CodeMySpec.McpServers.Agents.Tools.StopAgent (module)
- CodeMySpec.McpServers.Analysis.Tools.AwaitAnalysis (module)
- CodeMySpec.McpServers.Architecture.ArchitectureMapper (module): Response formatter for architecture-related MCP server tools. Transforms component data, architecture summaries, validation results, and error states into standardized Anubis MCP Response structures for consumption by AI agents.
- CodeMySpec.McpServers.Architecture.Tools.AnalyzeStories (module)
- CodeMySpec.McpServers.Architecture.Tools.ExecuteProposal (module)
- CodeMySpec.McpServers.Architecture.Tools.RegenerateProposal (module)
- CodeMySpec.McpServers.Architecture.Tools.ShowArchitectureOverview (module)
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph (module): MCP tool that validates the component dependency graph for circular dependencies. Returns validation result indicating success or detailed list of detected cycles. Circular dependencies violate clean architecture principles and make code harder to test and maintain.
- CodeMySpec.McpServers.ArchitectureServer (module): MCP (Model Context Protocol) server that exposes architecture analysis tools to AI agents. Provides tools for validating dependency graphs and analyzing user stories. Integrates with the Anubis MCP framework to make CodeMySpec's architecture capabilities accessible to Claude Code and other MCP clients.
- CodeMySpec.McpServers.BddRules.BddRulesMapper (module)
- CodeMySpec.McpServers.BddRules.Tools.AddQuestion (module)
- CodeMySpec.McpServers.BddRules.Tools.AddRule (module)
- CodeMySpec.McpServers.BddRules.Tools.AddScenario (module)
- CodeMySpec.McpServers.BddRules.Tools.DeleteRule (module)
- CodeMySpec.McpServers.BddRules.Tools.GetStoryGherkin (module)
- CodeMySpec.McpServers.BddRules.Tools.ListQuestions (module)
- CodeMySpec.McpServers.BddRules.Tools.ListRules (module)
- CodeMySpec.McpServers.BddRules.Tools.ResolveQuestion (module)
- CodeMySpec.McpServers.BddRules.Tools.UpdateRule (module)
- CodeMySpec.McpServers.BddRules.Tools.UpdateScenario (module)
- CodeMySpec.McpServers.Bootstrap.BootstrapMapper (module)
- CodeMySpec.McpServers.Bootstrap.Content (module)
- CodeMySpec.McpServers.Bootstrap.Installers (module)
- CodeMySpec.McpServers.Bootstrap.Tools.InitProject (module)
- CodeMySpec.McpServers.Bootstrap.Tools.InstallAgentsMd (module)
- CodeMySpec.McpServers.Bootstrap.Tools.InstallClaudeMd (module)
- CodeMySpec.McpServers.Bootstrap.Tools.InstallCredoChecks (module)
- CodeMySpec.McpServers.Bootstrap.Tools.InstallRules (module)
- CodeMySpec.McpServers.Bootstrap.Tools.ListProjects (module)
- CodeMySpec.McpServers.CodeMode (module)
- CodeMySpec.McpServers.Components.ComponentsMapper (module): Maps component data to MCP responses in JSON format for programmatic access. This module handles all response formatting for component-related MCP tool operations, including single components, component lists, batch operations, dependencies, and error responses.
- CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary (module): MCP tool that provides a comprehensive health assessment of the system architecture. Analyzes story coverage (entry/dependency/orphaned components), context distribution patterns, dependency issues (missing references, high fan-out, circular dependencies), and calculates an overall health score with recommendations for improvement.
- CodeMySpec.McpServers.Components.Tools.ContextStatistics (module): MCP tool that provides statistical overview of component contexts including story counts, dependency counts (incoming/outgoing), and aggregate summaries sorted by story count or dependency count for LLM analysis.
- CodeMySpec.McpServers.Components.Tools.CreateComponent (module)
- CodeMySpec.McpServers.Components.Tools.CreateComponents (module)
- CodeMySpec.McpServers.Components.Tools.DeleteComponent (module): MCP tool that deletes a component from the system. Validates scope (active account and project), retrieves the component, deletes it from the database, and broadcasts the deletion event. Implements the Anubis MCP tool protocol for integration with AI agents via Claude Code/Desktop.
- CodeMySpec.McpServers.Components.Tools.GetComponent (module)
- CodeMySpec.McpServers.Components.Tools.ListComponents (module): MCP tool that lists all components in a project, providing component summaries with essential metadata.
- CodeMySpec.McpServers.Components.Tools.OrphanedContexts (module): Lists all contexts with no user story and no dependencies. This MCP tool identifies orphaned contexts - components of type "context" that are not linked to any user stories and are not dependencies of any components that have stories.
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign (module): MCP tool that reviews the current context design against best practices and provides architectural feedback. Analyzes system architecture, story assignments, and dependency relationships to help maintain clean architectural boundaries and ensure all stories are properly satisfied by components.
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture (module): MCP tool that provides comprehensive system architecture visualization including dependency graphs, component relationships, architecture layers, and story associations. Exposes complete architectural context to LLM agents for understanding component organization, dependencies, and requirements.
- CodeMySpec.McpServers.Components.Tools.StartContextDesign (module): MCP tool that initiates guided context design sessions for AI agents. Generates a structured prompt containing unsatisfied user stories and existing components, then guides the agent through Phoenix context architecture design following entity ownership and business capability principles.
- CodeMySpec.McpServers.Components.Tools.UpdateComponent (module)
- CodeMySpec.McpServers.ComponentsServer (module): MCP (Model Context Protocol) server that exposes component management, dependency tracking, architecture analysis, and design workflow tools to AI agents via Anubis. Provides comprehensive CRUD operations for components, dependency graph manipulation, similar component tracking, context design workflows, and architecture health reporting. This server enables AI agents like Claude Code to interact with the CodeMySpec component system through standardized MCP tool calls.
- CodeMySpec.McpServers.Devops.Tools.AdoptRepository (module)
- CodeMySpec.McpServers.Devops.Tools.DevopsStatus (module)
- CodeMySpec.McpServers.Devops.Tools.EnsureEnvironment (module)
- CodeMySpec.McpServers.Devops.Tools.EnsureServerAccessKey (module)
- CodeMySpec.McpServers.Devops.Tools.GenerateDeployFiles (module)
- CodeMySpec.McpServers.Devops.Tools.ImportAgeKey (module)
- CodeMySpec.McpServers.Devops.Tools.LinkServer (module)
- CodeMySpec.McpServers.Devops.Tools.ProviderRequest (module)
- CodeMySpec.McpServers.Devops.Tools.ProvisionAccountServer (module)
- CodeMySpec.McpServers.Devops.Tools.ReadDatabaseUrl (module)
- CodeMySpec.McpServers.Devops.Tools.ReadProjectFile (module)
- CodeMySpec.McpServers.Devops.Tools.ReadRegistryCredential (module)
- CodeMySpec.McpServers.Devops.Tools.RunDevopsSetup (module)
- CodeMySpec.McpServers.Devops.Tools.RunProvisioningStep (module)
- CodeMySpec.McpServers.Devops.Tools.WriteProjectFile (module)
- CodeMySpec.McpServers.Formatters (module): Formats responses and errors for MCP servers in a hybrid format combining human-readable summaries with structured data for programmatic access. This module provides consistent error formatting across MCP server tools.
- CodeMySpec.McpServers.Ga4.Tools (module)
- CodeMySpec.McpServers.Ga4Server (module)
- CodeMySpec.McpServers.GoogleAds.Tools (module): Thin MCP tool wrappers for the Google Ads server: resolve the authenticated user's Google credentials, call CodeMySpec.Google.Ads, and render results. Read tools (list_accessible_accounts, get_account_overview, get_campaign_performance, get_ad_group_performance, get_keyword_performance, get_search_terms_report, get_ad_performance, get_recommendations) run auto; write tools (update_campaign_budget, update_bid, add_keywords, add_negative_keywords, create_ad, update_campaign_status) require operator approval.
- CodeMySpec.McpServers.GoogleAdsServer (module): Anubis MCP server exposing Google Ads tools to AI agents — 7 read tools (auto) + 6 write tools (approval-gated via Claude Code's built-in tool-permission system). The agent surface for story 817; registers each tool via component(...). Backed by the GoogleAds.Tools wrappers over CodeMySpec.Google.Ads.
- CodeMySpec.McpServers.GoogleTools (module)
- CodeMySpec.McpServers.Gsc.Tools.AddSite (module)
- CodeMySpec.McpServers.Gsc.Tools.BatchUrlInspection (module)
- CodeMySpec.McpServers.Gsc.Tools.CheckIndexingIssues (module)
- CodeMySpec.McpServers.Gsc.Tools.CompareSearchPeriods (module)
- CodeMySpec.McpServers.Gsc.Tools.DeleteSite (module)
- CodeMySpec.McpServers.Gsc.Tools.DeleteSitemap (module)
- CodeMySpec.McpServers.Gsc.Tools.GetAdvancedSearchAnalytics (module)
- CodeMySpec.McpServers.Gsc.Tools.GetCapabilities (module)
- CodeMySpec.McpServers.Gsc.Tools.GetCreatorInfo (module)
- CodeMySpec.McpServers.Gsc.Tools.GetPerformanceOverview (module)
- CodeMySpec.McpServers.Gsc.Tools.GetSearchAnalytics (module)
- CodeMySpec.McpServers.Gsc.Tools.GetSearchByPageQuery (module)
- CodeMySpec.McpServers.Gsc.Tools.GetSiteDetails (module)
- CodeMySpec.McpServers.Gsc.Tools.GetSitemapDetails (module)
- CodeMySpec.McpServers.Gsc.Tools.GetSitemaps (module)
- CodeMySpec.McpServers.Gsc.Tools.InspectUrlEnhanced (module)
- CodeMySpec.McpServers.Gsc.Tools.ListProperties (module)
- CodeMySpec.McpServers.Gsc.Tools.ListSitemapsEnhanced (module)
- CodeMySpec.McpServers.Gsc.Tools.ManageSitemaps (module)
- CodeMySpec.McpServers.Gsc.Tools.Reauthenticate (module)
- CodeMySpec.McpServers.Gsc.Tools.SubmitSitemap (module)
- CodeMySpec.McpServers.GscServer (module)
- CodeMySpec.McpServers.Issues.IssuesMapper (module)
- CodeMySpec.McpServers.Issues.Tools.AcceptIssue (module)
- CodeMySpec.McpServers.Issues.Tools.CreateIssue (module)
- CodeMySpec.McpServers.Issues.Tools.DismissIssue (module)
- CodeMySpec.McpServers.Issues.Tools.GetIssue (module)
- CodeMySpec.McpServers.Issues.Tools.ListIssues (module)
- CodeMySpec.McpServers.Issues.Tools.ResolveIssue (module)
- CodeMySpec.McpServers.Issues.Tools.UpdateIssue (module)
- CodeMySpec.McpServers.IssuesServer (module)
- CodeMySpec.McpServers.Knowledge.Tools.ListKnowledge (module)
- CodeMySpec.McpServers.Knowledge.Tools.ReadKnowledge (module)
- CodeMySpec.McpServers.Knowledge.Tools.SemanticSearch (module)
- CodeMySpec.McpServers.LocalServer (module)
- CodeMySpec.McpServers.MainAgent.AgentWorkMapper (module)
- CodeMySpec.McpServers.MainAgent.AnswerMapper (module)
- CodeMySpec.McpServers.MainAgent.AnswersMapper (module)
- CodeMySpec.McpServers.MainAgent.EpicsMapper (module)
- CodeMySpec.McpServers.MainAgent.MachineryMapper (module)
- CodeMySpec.McpServers.MainAgent.MainAgentMapper (module)
- CodeMySpec.McpServers.MainAgent.RestartMapper (module)
- CodeMySpec.McpServers.MainAgent.Tools.AnswerNotification (module)
- CodeMySpec.McpServers.MainAgent.Tools.AnswerQuestion (module)
- CodeMySpec.McpServers.MainAgent.Tools.Cadence (module)
- CodeMySpec.McpServers.MainAgent.Tools.CheckIn (module)
- CodeMySpec.McpServers.MainAgent.Tools.CheckMachinery (module)
- CodeMySpec.McpServers.MainAgent.Tools.EscalateQuestion (module)
- CodeMySpec.McpServers.MainAgent.Tools.ListAgentWork (module)
- CodeMySpec.McpServers.MainAgent.Tools.ListNotifications (module)
- CodeMySpec.McpServers.MainAgent.Tools.ListOpenQuestions (module)
- CodeMySpec.McpServers.MainAgent.Tools.ReadAgentConversation (module)
- CodeMySpec.McpServers.MainAgent.Tools.ReadyStoriesWithoutEpic (module)
- CodeMySpec.McpServers.MainAgent.Tools.RestartAgent (module)
- CodeMySpec.McpServers.MainAgent.Tools.SearchAnswers (module)
- CodeMySpec.McpServers.MainAgent.Tools.TakeOverWork (module)
- CodeMySpec.McpServers.Personas.PersonasMapper (module): Maps persona data to MCP responses. Produces text-only responses (no structured_content) per project convention, embedding persona identifiers in a text footer so agents can reference them in follow-up calls.
- CodeMySpec.McpServers.Personas.Tools.CreatePersona (module): MCP tool that creates a project-scoped persona. Invoked by the agent during persona research or by an engineer action through the persona library surface on the active project.
- CodeMySpec.McpServers.Personas.Tools.DeletePersona (module)
- CodeMySpec.McpServers.Personas.Tools.GetPersona (module)
- CodeMySpec.McpServers.Personas.Tools.LinkPersonaToStory (module): MCP tool that links an existing persona to a story via the persona_stories join. Rejects cross-account attempts at the repository layer.
- CodeMySpec.McpServers.Personas.Tools.ListPersonas (module)
- CodeMySpec.McpServers.Personas.Tools.UnlinkPersonaFromStory (module)
- CodeMySpec.McpServers.Personas.Tools.UpdatePersona (module)
- CodeMySpec.McpServers.Problems.Tools.ClearProblems (module)
- CodeMySpec.McpServers.Problems.Tools.ListProblems (module)
- CodeMySpec.McpServers.Promotion.Responses (module)
- CodeMySpec.McpServers.Promotion.Tools.Promote (module)
- CodeMySpec.McpServers.Promotion.Tools.PromoteSync (module)
- CodeMySpec.McpServers.Qa.Tools.CallMcpServer (module)
- CodeMySpec.McpServers.Qa.Tools.InvalidateQaAttempt (module): MCP tool that invalidates a passed QaAttempt. Schema: attempt_id (required), reason (required, non-empty). Delegates to CodeMySpec.Qa.invalidate_qa_attempt/3. Returns invalidation_id in text response. Rejects empty reason at tool boundary per story 727 R4 (criterion 6457 failure path).
- CodeMySpec.McpServers.Qa.Tools.ListQaAttempts (module): MCP tool that lists QA attempts for a story. Schema: story_id (required). Delegates to CodeMySpec.Qa.list_qa_attempts/2. Returns text list ordered most-recent-first with status, agent, scenarios, issue_ids, parent_attempt_id, and any invalidation events. Per story 727 R3.
- CodeMySpec.McpServers.Qa.Tools.SubmitQaResult (module): MCP tool that submits a QA outcome. Schema: task_id (required), status (required: pass | partial | fail), scenarios (required, list of %{name, status, observation}), issue_ids (optional, list of uuid). Delegates to CodeMySpec.Qa.submit_qa_result/2. Returns attempt_id in text response. Per story 726 R1-R7.
- CodeMySpec.McpServers.Requirements.RequirementsMapper (module)
- CodeMySpec.McpServers.Requirements.Tools.GetNextRequirement (module)
- CodeMySpec.McpServers.Requirements.Tools.ListRequirements (module)
- CodeMySpec.McpServers.Requirements.Tools.RefreshEmbeddings (module)
- CodeMySpec.McpServers.Requirements.Tools.ShowComponentRequirements (module)
- CodeMySpec.McpServers.Requirements.Tools.ShowRequirement (module)
- CodeMySpec.McpServers.Requirements.Tools.ShowStoryRequirements (module)
- CodeMySpec.McpServers.Requirements.Tools.SyncProject (module)
- CodeMySpec.McpServers.Research.Tools.WebFetch (module)
- CodeMySpec.McpServers.Research.Tools.WebSearch (module)
- CodeMySpec.McpServers.ScriptResult (module)
- CodeMySpec.McpServers.ScriptableTools (module)
- CodeMySpec.McpServers.Stories.StoriesMapper (module): Maps story data to MCP responses using a hybrid format that combines human-readable summaries with structured JSON data for programmatic access. This module handles all response formatting for story-related MCP tool operations, criterion operations, error responses, and resource responses.
- CodeMySpec.McpServers.Stories.Tools.AddCriterion (module)
- CodeMySpec.McpServers.Stories.Tools.AnalyzeStoryLinkage (module)
- CodeMySpec.McpServers.Stories.Tools.AssignEpicToWorkingCopy (module)
- CodeMySpec.McpServers.Stories.Tools.AssignStoryToEpic (module)
- CodeMySpec.McpServers.Stories.Tools.ClearStoryComponent (module)
- CodeMySpec.McpServers.Stories.Tools.CreateEpic (module)
- CodeMySpec.McpServers.Stories.Tools.CreateStories (module): MCP tool for batch creation of user stories. Processes multiple story creation requests in a single operation, returning successful creations and validation errors for failed attempts.
- CodeMySpec.McpServers.Stories.Tools.CreateStory (module): MCP tool for creating user stories with title, description, and acceptance criteria. This tool transforms acceptance criteria strings into nested criteria parameters for story creation and returns a hybrid response format containing both human-readable summary and structured JSON data.
- CodeMySpec.McpServers.Stories.Tools.CreateWorkingCopy (module)
- CodeMySpec.McpServers.Stories.Tools.DeleteCriterion (module): MCP tool that deletes an acceptance criterion from a story. Provides protection against deleting verified (locked) criteria to maintain data integrity.
- CodeMySpec.McpServers.Stories.Tools.DeleteStory (module): MCP tool that permanently deletes a user story from the system. This tool integrates with the Anubis MCP framework to expose story deletion functionality to AI agents like Claude Code.
- CodeMySpec.McpServers.Stories.Tools.GetStory (module): MCP tool that retrieves a single story by ID with full details including acceptance criteria. Part of the Stories MCP Server exposing story data to AI agents (Claude Code/Desktop).
- CodeMySpec.McpServers.Stories.Tools.LinkCriterionToRule (module)
- CodeMySpec.McpServers.Stories.Tools.ListEpics (module)
- CodeMySpec.McpServers.Stories.Tools.ListProjectTags (module)
- CodeMySpec.McpServers.Stories.Tools.ListStories (module): MCP tool for listing stories in a project with pagination and optional search filtering. Returns full story details including acceptance criteria. For lightweight operations that only need titles, use list_story_titles instead.
- CodeMySpec.McpServers.Stories.Tools.ListStoryTitles (module): Lists story titles in a project (lightweight).

Returns just ID, title, and component_id - no criteria or full descriptions. Use this for quick lookups, selection lists, or when you need to find a story ID.

This MCP tool is exposed via the Anubis server framework and provides a lightweight alternative to full story listing operations.
- CodeMySpec.McpServers.Stories.Tools.ListWorkingCopies (module)
- CodeMySpec.McpServers.Stories.Tools.MoveCriterion (module)
- CodeMySpec.McpServers.Stories.Tools.OffboardWorkingCopy (module)
- CodeMySpec.McpServers.Stories.Tools.ProposeEpic (module)
- CodeMySpec.McpServers.Stories.Tools.SetEpicStoriesReady (module)
- CodeMySpec.McpServers.Stories.Tools.SetStoryComponent (module): MCP tool for linking a story to a component that implements it. This tool allows AI agents to track which components satisfy which user stories, enabling traceability from requirements through implementation.
- CodeMySpec.McpServers.Stories.Tools.SetWorkingCopyLoop (module)
- CodeMySpec.McpServers.Stories.Tools.StartStoryInterview (module): MCP tool that initiates an interactive interview session to help develop and refine user stories. Acts as an expert Product Manager guiding users through thoughtful questions about requirements, acceptance criteria, dependencies, and edge cases.
- CodeMySpec.McpServers.Stories.Tools.StartStoryReview (module): MCP tool that initiates a comprehensive review of user stories in a project by generating an AI prompt with review criteria and story context.
- CodeMySpec.McpServers.Stories.Tools.StartThreeAmigosSession (module)
- CodeMySpec.McpServers.Stories.Tools.TagStories (module)
- CodeMySpec.McpServers.Stories.Tools.TriageIssues (module)
- CodeMySpec.McpServers.Stories.Tools.UpdateCriterion (module): MCP tool for updating the description of existing acceptance criteria. Protects verified (locked) criteria from modification to maintain test integrity.
- CodeMySpec.McpServers.Stories.Tools.UpdateEpic (module)
- CodeMySpec.McpServers.Stories.Tools.UpdateStory (module)
- CodeMySpec.McpServers.Tasks.TasksMapper (module)
- CodeMySpec.McpServers.Tasks.Tools.AskUserQuestion (module)
- CodeMySpec.McpServers.Tasks.Tools.AssignSubagent (module)
- CodeMySpec.McpServers.Tasks.Tools.AssignTask (module)
- CodeMySpec.McpServers.Tasks.Tools.CancelTask (module)
- CodeMySpec.McpServers.Tasks.Tools.CheckAnswer (module)
- CodeMySpec.McpServers.Tasks.Tools.EvaluateTask (module)
- CodeMySpec.McpServers.Tasks.Tools.ListSessionSubagents (module)
- CodeMySpec.McpServers.Tasks.Tools.ListTasks (module)
- CodeMySpec.McpServers.Tasks.Tools.ListUserQuestions (module)
- CodeMySpec.McpServers.Tasks.Tools.RegisterSession (module)
- CodeMySpec.McpServers.Tasks.Tools.SendMessage (module)
- CodeMySpec.McpServers.Tasks.Tools.ShowInPanel (module)
- CodeMySpec.McpServers.Tasks.Tools.StartAnalysis (module)
- CodeMySpec.McpServers.Tasks.Tools.StartTask (module)
- CodeMySpec.McpServers.Tasks.Tools.TapOut (module)
- CodeMySpec.McpServers.Validators (module)

### CodeMySpec.Migration

- **Type:** context
- **Description:** Copies a project's authored records from a local harness to the cloud. Stories, criteria, rules, personas, epics, issues, questions and project configuration — never files, problems, sessions or components, which the cloud rebuilds from the working copy.

#### Children

- CodeMySpec.Migration.Client (module)

### CodeMySpec.Oauth

- **Type:** context
- **Description:** Public API for the OAuth2 authorization server.

#### Children

- CodeMySpec.Oauth.AccessGrant (schema)
- CodeMySpec.Oauth.AccessToken (schema)
- CodeMySpec.Oauth.Application (schema)

### CodeMySpec.Permissions

- **Type:** context
- **Description:** Asking a human to approve something an agent cannot decide alone, and applying
their answer.

Today that is one thing: tapping out of the autonomous loop. An agent in
continuous mode cannot clear `session.continuous` itself — that is the point of
the flag — so it raises a request, a human approves or rejects it on their
phone, and the decision comes back over a socket and is applied to the session.

`TapOut`, `TapOutWaiter` and `PermissionSocket` existed first and callers reached
straight into them: the `tap_out` MCP tool, both permission controllers, a spex
and the fixtures bridge — five consumers, all naming an internal. That is the
coupling a context exists to remove, and every sibling here (`Notifications`,
`Sessions`, `Analysis`) already reads that way.

An earlier version of this spec described "a Slipstream WebSocket client that
connects to the production server's permission channel and waits for a
decision", which is `PermissionSocket`'s job written one level up. That made the
context look like a namespace anchor rather than an API, and the requirement
graph asked for an implementation nobody could justify writing. The description
above is what the context is actually for; the socket is one of its parts, stays
internal, and the two controllers naming it should move here when they next
change.

Everything below delegates — the behaviour stays in the modules that have it and
are already tested through it.

#### Children

- CodeMySpec.Permissions.PermissionSocket (module)
- CodeMySpec.Permissions.TapOut (module)
- CodeMySpec.Permissions.TapOutWaiter (module)

### CodeMySpec.Personas

- **Type:** context
- **Description:** Project-scoped personas. Personas represent product users — role, goals, pain points, context, decision drivers — with identity + metadata in the DB and research text on disk under `.code_my_spec/personas/<slug>/`. Each persona belongs to exactly one project; the same role researched for two products is two separate records.

#### Children

- CodeMySpec.Personas.Persona (schema): Ecto schema for project-scoped personas. Identity + metadata only; research text lives on disk at `.code_my_spec/personas/<slug>/`.
- CodeMySpec.Personas.PersonaStory (schema): Join schema linking personas to stories. Both sides are project-scoped — cross-project links are rejected at the repository level by checking `persona.project_id == story.project_id`.
- CodeMySpec.Personas.PersonasRepository (repository): Ecto queries for personas and persona_stories. All queries filter by `scope.active_project_id`. Cross-project operations are rejected.

### CodeMySpec.Problems

- **Type:** context

#### Children

- CodeMySpec.Problems.Problem (schema)
- CodeMySpec.Problems.ProblemConverter (module): Utility module for transforming heterogeneous tool outputs (Credo, compiler warnings, test failures) into normalized Problem structs. Provides consistent data transformation regardless of source tool format.
- CodeMySpec.Problems.ProblemRenderer (module): Utility module for rendering Problem structs into human and AI-readable formats. Transforms normalized problems from static analysis tools, compilers, and test failures into actionable feedback strings for Claude Code agent evaluation hooks.
- CodeMySpec.Problems.ProblemRepository (module): Repository module providing scoped data access operations for problems. Handles database queries with proper scope filtering and user/project isolation.

### CodeMySpec.ProjectSecrets

- **Type:** context
- **Description:** Encrypted store for a project's provider credentials, held in a dedicated table rather than the process environment so decrypted values never reach an agent. Peer to Projects so anything — including a cloud-run agent — can read credentials without depending on Provisioning. Uses the existing Encrypted types for at-rest encryption, following the precedent set by projects.deploy_key.

#### Children

- CodeMySpec.ProjectSecrets.ProjectSecret (schema)
- CodeMySpec.ProjectSecrets.ProjectSecretRepository (module)

### CodeMySpec.ProjectUsers

- **Type:** context
- **Description:** Reads the list of users registered for a project's target application, live via the project's deploy key and client API URL — never stored in CodeMySpec. Future home for enriched user / ICP marketing data.

#### Children

- CodeMySpec.ProjectUsers.Client (module)
- CodeMySpec.ProjectUsers.Page (module)
- CodeMySpec.ProjectUsers.User (module)

### CodeMySpec.Projects

- **Type:** context
- **Description:** Per-project records (id, name, local_path, docs_repo, account_id). Project creation from /app's wizard sets the new project active; the local app resolves scope from `local_path` against the current working directory.

#### Children

- CodeMySpec.Projects.Project (schema)
- CodeMySpec.Projects.ProjectsSocket (module)

### CodeMySpec.Qa

- **Type:** context
- **Description:** Per-story QA workflow context. Owns the typed-event audit trail for QA
attempts on stories. Replaces the file-parsing evaluator in
`CodeMySpec.AgentTasks.QaStory` with DB-backed events submitted
through dedicated MCP tools.

#### Children

- CodeMySpec.Qa.Evidence (module)
- CodeMySpec.Qa.Invalidation (schema): Audit event recording that an engineer invalidated a QaAttempt. Fields: id, qa_attempt_id (fk), invalidated_by_user_id, reason (non-empty string), invalidated_at. Append-only audit row; the original attempt is preserved. Per story 727 R4.
- CodeMySpec.Qa.Invalidations (module): Invalidate action on a QaAttempt. Public API: invalidate/3 (validates non-empty reason, writes Invalidation row stamped with engineer scope id + timestamp, leaves original attempt unchanged). Delegated to from CodeMySpec.Qa. Per story 727 R4 + R7 (qa_complete re-clamp is a side effect of the checker reading current state, not orchestrated here).
- CodeMySpec.Qa.QaAttempt (schema): Immutable QA attempt row. Fields: id, story_id, status (:pass | :partial | :fail), scenarios (list of embedded Scenario), issue_ids (list of uuid), agent_id, parent_attempt_id (nullable, links to prior attempt on same story), submitted_at. Append-only — never mutated after insert. Per story 727 R1.
- CodeMySpec.Qa.QaAttempts (module): CRUD + query module for QaAttempt. Public API: submit/2 (validates required fields, writes row, links parent_attempt_id), list/2 (most-recent-first per story_id, includes invalidation events), complete?/2 (true iff latest non-invalidated attempt on story has status :pass). Delegated to from CodeMySpec.Qa.
- CodeMySpec.Qa.Scenario (schema): Embedded schema for a single tested scenario within a QaAttempt. Fields: name (string), status (:pass | :partial | :fail), observation (string). Stored as embeds_many on QaAttempt so each scenario is queryable individually per story 726 R6.

### CodeMySpec.Questions

- **Type:** context
- **Description:** The Questions context — Three Amigos red cards (parked questions).

#### Children

- CodeMySpec.Questions.Question (schema)
- CodeMySpec.Questions.QuestionsRepository (module)

### CodeMySpec.Requirements

- **Type:** context
- **Description:** Manages component requirement checking, persistence, and workflow queries. Requirements are computed from checker modules and persisted for efficient UI queries.

#### Children

- CodeMySpec.Requirements.ArchitectureChecker (module)
- CodeMySpec.Requirements.BddRulesChecker (module)
- CodeMySpec.Requirements.CachedGraph (schema)
- CodeMySpec.Requirements.CheckerResult (module)
- CodeMySpec.Requirements.Difference (module)
- CodeMySpec.Requirements.DispatchChecker (module)
- CodeMySpec.Requirements.DrainCost (module)
- CodeMySpec.Requirements.Edge (schema)
- CodeMySpec.Requirements.Freshness (module)
- CodeMySpec.Requirements.GraphCache (module)
- CodeMySpec.Requirements.GraphFingerprint (module)
- CodeMySpec.Requirements.GraphInputs (module)
- CodeMySpec.Requirements.GraphProjector (module)
- CodeMySpec.Requirements.GraphWatcher (module)
- CodeMySpec.Requirements.Handlers (module)
- CodeMySpec.Requirements.IncrementalReport (module)
- CodeMySpec.Requirements.Invalidation (schema)
- CodeMySpec.Requirements.Invalidations (module)
- CodeMySpec.Requirements.IssuesChecker (module)
- CodeMySpec.Requirements.Node (schema)
- CodeMySpec.Requirements.NodeRepository (module)
- CodeMySpec.Requirements.PersonasChecker (module): Delegate checker for the `personas_complete` requirement node in `project_graph`. Iterates over personas linked to the active project and verifies each has a DB row, `summary.md`, and `sources.md`, and that `summary.md` validates against the `persona_summary` document type.
- CodeMySpec.Requirements.PlainLanguage (module)
- CodeMySpec.Requirements.Predicates (module)
- CodeMySpec.Requirements.Preloader (module)
- CodeMySpec.Requirements.Profiles (module)
- CodeMySpec.Requirements.Projection (module)
- CodeMySpec.Requirements.Registry (module)
- CodeMySpec.Requirements.Requirement (module): Embedded schema representing a component requirement instance with its satisfaction status. Created from RequirementDefinition templates and tracks runtime satisfaction state. Supports both boolean pass/fail via satisfied field and incremental quality scoring (0.0 to 1.0) for nuanced requirement assessment.
- CodeMySpec.Requirements.RequirementCalculator (module): Computes requirement satisfaction from File records, Problems, and entity fields.

Dispatches on the `check_type` field of each RequirementDefinition rather than
pattern-matching on requirement names. Covers component, story, and project
requirements with a unified set of check types.

Check types:

- **`:file_exists`** — a File record with the configured role exists for the entity
- **`:file_valid`** — a File record with the configured role exists AND has `valid: true`
- **`:path_exists`** — a file at the configured path exists in the project file list
- **`:field_present`** — a field on the entity is not nil
- **`:no_problems`** — zero Problem records from the configured source
- **`:tests_passing`** — zero exunit Problem records for the entity
- **`:spex_passing`** — zero spex Problem records for the entity

Each check type reads its parameters from `definition.config`:
- `:file_exists` → `%{role: :spec}`, `%{role: :bdd_spec}`, etc.
- `:file_valid` → `%{role: :spec}`, `%{role: :test}`, etc.
- `:path_exists` → `%{path: ".code_my_spec/qa/journey_plan.md"}` or `%{path_prefix: ".code_my_spec/integrations/"}`
- `:field_present` → `%{field: :component_id}`
- `:no_problems` → `%{source: "credo"}`, `%{source: "sobelow"}`, etc.
- `:tests_passing` → no config needed (source is always "exunit")
- `:spex_passing` → no config needed (source is always "spex")

The old children aggregate checks (`context_specs`, `context_implementation`)
are removed — child dependencies are handled by the requirement graph edges,
not by the calculator.

Story and project checks are also handled here instead of in RequirementGraph.
The graph is responsible for topology (edges), the calculator for satisfaction
(nodes). `project_setup` remains a special case that delegates to
`ProjectSetup.evaluate`.
- CodeMySpec.Requirements.RequirementDefinition (schema)
- CodeMySpec.Requirements.RequirementDefinitionData (data)
- CodeMySpec.Requirements.RequirementGraph (module)
- CodeMySpec.Requirements.RequirementsFormatter (module)
- CodeMySpec.Requirements.Shadow (module)
- CodeMySpec.Requirements.ShadowProjector (module)
- CodeMySpec.Requirements.SpecsPassingChecker (module)
- CodeMySpec.Requirements.SpexBoundaryChecker (module)
- CodeMySpec.Requirements.StoriesChecker (module)
- CodeMySpec.Requirements.Topology (module)

### CodeMySpec.Resources

- **Type:** context
- **Description:** What the account should have, against what it actually has.

Two checks feeding one answer. Per project, the expected set is derived from `Provisioning.Sequence` and the project's chosen options — no second manifest to disagree with the sequence that does the work. Across the account, the cross-cutting checks no single project can see: a DNS record aimed at an address no server holds, a bucket no environment names, a firewall covering nothing.

A project counts only when it is meant to be deployed — `devops != :off` and it has engaged with provisioning. Ten projects that were never meant to have infrastructure would otherwise report as entirely missing and drown the one real problem.

Never derives health from stored step state. `provisioning_steps.state` records what happened on the last run; a certificate that expired since then still reads as done. The expected side comes from our records, the actual side from the providers.

#### Children

- CodeMySpec.Resources.Acknowledgement (schema): A record that a resource is there on purpose.

Keyed on provider and identifier at the account grain, not on a resource row — the resources it describes are frequently ones we have no row for. A DNS record added by hand for another tool appears in no step's resource list, so there is nothing to put a flag on, and it is precisely the case that needs marking.

Outlives the inventory being rebuilt, which happens on every page load. Marking something and having to mark it again on the next read would make the feature worse than useless.

What it buys is that deleting becomes safe to offer. Without it the page keeps reporting deliberate leftovers as broken, and a red mark that is wrong often enough stops being read at all — which costs more than the resource does. Reversible: unmarking puts the resource back among the dangling.

Distinct from `Provisioning.Resource.origin`, which says who created a resource we know about. This says who wants it kept.
- CodeMySpec.Resources.Inventory (module): Everything each provider says the account holds, enumerated once.

Asks each provider for its whole list — servers, firewalls and SSH keys from Hetzner, zones and records from Cloudflare, buckets from object storage, domains and webhooks from Resend — rather than verifying resources one at a time. Eleven projects times fifteen steps is a hundred and sixty-five calls that would rate-limit and take a minute; six list calls answer the same question.

Enumerating is also the only way to see a resource nobody recorded. A bucket created by hand is invisible to any check that starts from what setup wrote down, and it is billing exactly like the ones we know about.

Each provider is asked independently and a failure is confined to its own section: one provider being unreachable must not decide what the page can say about the other three.

### CodeMySpec.Servers

- **Type:** context
- **Description:** Servers an account owns, whether CodeMySpec created them or Sam did.

Account-scoped on purpose. `Provisioning` is project-scoped, and today a server is two denormalised strings — `server_name` and `ip` — on a `provisioning_environments` row, so a box cannot be shared between projects, an existing box cannot be adopted, and nothing owns a server's lifecycle. That last gap is the root of the environment-removal and dangling-DNS defects.

This context owns the server as a thing in its own right: listing what the provider actually reports, linking boxes Sam made himself, provisioning new ones, and keeping unlinked servers visible so none slips out of view. It reads through `Provisioning.Hetzner` rather than reimplementing the provider client.

Deliberately not a child of `Provisioning`: the grain is different, and that difference is what story 994 exists to fix.

#### Children

- CodeMySpec.Servers.Containers (module): Reads what is running on a server, from the server. Runs `docker ps` over SSH with the account's access key and returns every container the box reports — running, exited or restarting — with the reason it is in that state. Never consults our record of what was deployed: a container that crashed an hour ago is exactly what this exists to surface, and the deploy that put it there still says it succeeded. Returns an error naming the cause when the box cannot be reached, which is distinct from a box running nothing, and distinct again from a box that never gave us a key.
- CodeMySpec.Servers.Server (schema)

### CodeMySpec.Sessions

- **Type:** context

#### Children

- CodeMySpec.Sessions.Session (schema)
- CodeMySpec.Sessions.SessionType (module)
- CodeMySpec.Sessions.Subagent (schema)
- CodeMySpec.Sessions.Task (schema)

### CodeMySpec.StaticAnalysis

- **Type:** context

#### Children

- CodeMySpec.StaticAnalysis.AnalyzerBehaviour (module)
- CodeMySpec.StaticAnalysis.Analyzers.Credo (module)
- CodeMySpec.StaticAnalysis.Analyzers.Sobelow (module)
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment (module)
- CodeMySpec.StaticAnalysis.CredoRun (module)
- CodeMySpec.StaticAnalysis.Pipeline (module)
- CodeMySpec.StaticAnalysis.Runner (module)

### CodeMySpec.Stories

- **Type:** context

#### Children

- CodeMySpec.Stories.Markdown (module): Handles parsing and formatting of user stories in markdown format for import/export functionality. Provides clean separation between markdown processing logic and story domain operations.
- CodeMySpec.Stories.StoriesRepository (module): Repository for managing Story entities within a project scope. Provides CRUD operations, scoped queries, composable query functions for filtering and sorting, lock management for concurrent editing, and component assignment tracking.
- CodeMySpec.Stories.Story (schema): Ecto schema representing user stories in the system. Stories capture requirements with titles, descriptions, and acceptance criteria. Each story is scoped to an account and project, and can be optionally linked to a component. Stories support locking mechanisms for concurrent editing protection and integrate with PaperTrail for version tracking.

### CodeMySpec.Tags

- **Type:** context

#### Children

- CodeMySpec.Tags.StoryTag (schema)
- CodeMySpec.Tags.Tag (schema)
- CodeMySpec.Tags.TagRepository (module)

### CodeMySpec.TaskHelp

- **Type:** context
- **Description:** Read-only context that resolves per-task help content for the agent progress view. Maps an agent task type to `.code_my_spec/content/<task_type>.md` (curated body) plus its `.yaml` sidecar (`video_url`), returning the curated help for major task types and signalling a generic fallback otherwise. Reads through the scope environment.

#### Children

- CodeMySpec.TaskHelp.Help (module)

### CodeMySpec.Tests

- **Type:** context
- **Description:** The Tests context provides a functional interface for executing ExUnit tests with real-time streaming and structured result parsing. It executes mix test commands asynchronously via Erlang ports, streams JSON-formatted test events, and returns parsed test run data including statistics, failures, and passes.

#### Children

- CodeMySpec.Tests.TestError (schema): Embedded schema representing test failure information from ExUnit test runs. Captures error details including file location, line number, and error message. Used within TestResult to provide detailed failure context.
- CodeMySpec.Tests.TestResult (schema): Embedded Ecto schema representing an individual test result from ExUnit execution. Captures test metadata (title, full title), execution outcome (passed/failed), and error details for failures. Used within TestRun to track test execution results.
- CodeMySpec.Tests.TestRun (schema): Embedded schema representing a single test execution run with execution metadata, test statistics, results, and failure details. Used throughout the system for test-driven development workflows, quality validation, and project requirement coordination.
- CodeMySpec.Tests.TestStats (schema): Embedded schema for capturing ExUnit test execution statistics and timing information. This struct is used within TestRun to aggregate test results and provides a standardized representation of test suite performance metrics.

### CodeMySpec.UserPreferences

- **Type:** context
- **Description:** The UserPreferences context.

#### Children

- CodeMySpec.UserPreferences.UserPreference (schema)

### CodeMySpec.Users

- **Type:** context
- **Description:** Email + OAuth identity. Magic-link registration delivers a login link that drops the user at /app where the onboarding wizard takes over.

#### Children

- CodeMySpec.Users.LocalScope (module)
- CodeMySpec.Users.Scope (module)
- CodeMySpec.Users.User (schema)
- CodeMySpec.Users.UserNotifier (module)
- CodeMySpec.Users.UserToken (schema)

### CodeMySpec.Validation

- **Type:** context

#### Children

- CodeMySpec.Validation.Menu (module)
- CodeMySpec.Validation.TaskEvaluator (module): Evaluates agent tasks. Two entry points for the two hook events: `evaluate_component/2` resolves a component task from a transcript marker and delegates to the task module's `evaluate/3` (SubagentStop). `evaluate_sessions/2` looks up sessions by external conversation ID, evaluates the session stack at highest priority, deletes passing sessions, and returns combined feedback for failures (Stop).

### CodeMySpec.WorkingCopies

- **Type:** context

#### Children

- CodeMySpec.WorkingCopies.WorkingCopy (schema)

### CodeMySpec.Workspaces

- **Type:** context
- **Description:** One visitor's running application instance: bring it up, report whether it came up or failed, and hand back the URL to look at it. In development that is the devbox container in Docker; the shared-host path is 986's and lands later. Failure is a first-class outcome here — the caller has to be able to tell the visitor it failed rather than leave them on a spinner.

#### Children

- CodeMySpec.Workspaces.Boot (module)
- CodeMySpec.Workspaces.BootSteps (module)
- CodeMySpec.Workspaces.PreviewAddress (module)
- CodeMySpec.Workspaces.PreviewTunnel (module)
- CodeMySpec.Workspaces.Runner (module)
- CodeMySpec.Workspaces.Tracking (module)
- CodeMySpec.Workspaces.Workspace (schema)
- CodeMySpec.Workspaces.WorkspacesRepository (module)

## Surface Components

### CodeMySpecLocalWeb.Hooks.SessionStartController

- **Type:** controller

### CodeMySpecLocalWeb.Hooks.StopController

- **Type:** controller

### CodeMySpecLocalWeb.QaHistoryComponent

- **Type:** liveview_component
- **Description:** Phoenix LiveView function component that renders the QA history chain for a story. Displays each attempt's status, agent, timestamp, scenarios, linked issues, and any invalidation event with reason. Includes an invalidate action button on passed attempts that opens the confirm_dialog component to collect a reason. Used by CodeMySpecLocalWeb.StoryLive. Per story 727 R6.

### CodeMySpecWeb.AccountLive.Agents

- **Type:** liveview
- **Stories:** 983, 984

### CodeMySpecWeb.AccountLive.Components.MembersList

- **Type:** liveview_component
- **Description:** Live component that renders the account members table with inline role editing.

### CodeMySpecWeb.AccountLive.Components.Navigation

- **Type:** liveview_component
- **Description:** Live component that renders the account settings tab navigation (Manage / Members / Invitations).

### CodeMySpecWeb.AccountLive.Form

- **Type:** liveview
- **Description:** LiveView form for creating or editing an account record.

### CodeMySpecWeb.AccountLive.Index

- **Type:** liveview
- **Description:** LiveView listing all accounts for the current user with actions to manage members or switch the active account.

### CodeMySpecWeb.AccountLive.Invitations

- **Type:** liveview
- **Description:** LiveView for managing account invitations — send new invitations and view pending ones.

### CodeMySpecWeb.AccountLive.Manage

- **Type:** liveview
- **Description:** LiveView for editing account details (name, slug) with authorization guard.

### CodeMySpecWeb.AccountLive.Members

- **Type:** liveview
- **Description:** LiveView listing account members with role management for authorized users.

### CodeMySpecWeb.AccountLive.Picker

- **Type:** liveview
- **Description:** LiveView for selecting the active account from the user's memberships.

### CodeMySpecWeb.AgentConversationLive

- **Type:** live_context
- **Description:** Live context for watching agents work: the list of sessions recorded against a
project, and the read-only transcript of any one of them.

Deliberately separate from `InboxLive`. That is a support queue where a person is
writing to the operator; this is a machine being watched, and nothing here sends
anything back.

One conversation is one Claude session, not one project. A project has as many
sessions at once as it has working copies being worked in, and merging them
produces a single interleaved transcript answering no question anybody asked.
That is why the group is two pages rather than one — `Show` used to mean
"whichever conversation moved most recently", which reads as *the* conversation
while a project has one agent and hides four when it has five.

An earlier version of this file carried `Show`'s description and did not mention
`Index`, so it typed the group as a single `liveview`. That asked the graph for a
parent module no sibling live context has: `EpicsLive` and `IssuesLive` are
`Index` and `Show` and nothing else, and the registry says so outright — "live
contexts have no code file, they are spec-only groupings".
- **Stories:** 870, 962, 966, 967

#### Children

- CodeMySpecWeb.AgentConversationLive.Index (liveview): Every agent session recorded against a project, newest activity first.

Exists because `Show` used to answer "whichever conversation moved most
recently". With one agent that reads as *the* conversation; with five it hides
four, and which one you land on changes as they take turns.

A session carries a name so it can be told apart. The name is generated when the
conversation is created — an index of five UUIDs is the problem this page exists
to solve, and it would have appeared before anyone had a chance to name anything
— and it is editable here, because the useful name is "backend refactor" and only
a person knows that.
- CodeMySpecWeb.AgentConversationLive.Show (liveview) [Stories: 966, 967]: Read-only view of one agent session's conversation — the turns it took, the tools
it called and what they returned, with sub-agent turns attributed to the
sub-agent via `agent_role`. New turns arrive live while the agent runs, with no
reload and nothing the operator can send back.

One page is one session, taken from the URL. A model turn arrives addressed to a
working copy — all `/v1/messages` can carry, since the Anthropic API has no
session and nothing sits between the agent and the proxy to add one — and the
server resolves that to the session running there through
`Sessions.external_id_for_harness/1`, naming the conversation with Claude's own
session id.

Renders through `CodeMySpecWeb.ChatComponents`, shared with the story interview
and the support inbox. It passes `tool_role={:call}`, because `role: :tool` means
a tool *call* here — that is what `ConversationRecorder.write_tool_calls/3`
writes with it.

Read-only today, but not permanently: `ask_user` and the agent's messages are
meant to land in the transcript, so a notification takes the reader to the
conversation the question came from rather than to a page showing the question
and none of the work behind it. The interaction is targeted — a specific question
answered in place — not a composer.

### CodeMySpecWeb.AgentProgressLive

- **Type:** liveview
- **Description:** The non-technical user's live spectator screen — what the agent is doing, in
language that does not assume they can read the code.

Left rail: project-level requirement milestones with status. Centre: one vertical
timeline per session, most-recently-updated first. The active session has its
current step auto-expanded — the last task that is not completed or cancelled —
and that step shows its artifact plus plain-language help, a curated body and
video for the major task types and a generic explanation otherwise. Any task can
be expanded to override the auto-focus.

Liveness is recency, not status. The PostToolUse hook touches the session's
`updated_at` on every tool call, so "active" means "updated in the last few
minutes" — known on load, with no polling and no timer. Persisted task status is
deliberately not trusted as a live signal, because a crashed agent leaves stale
`:active` tasks behind and the screen would report work nobody is doing.

Sessions with no activity and sessions with no tasks are hidden, and the list is
capped at the ten most recent, so the timeline stays readable.

This spec used to name `CodeMySpecLocalWeb.AgentProgressLive`, which is not where
the code is or ever was: it lives in `CodeMySpecWeb` and is routed there, and the
harness UI's move into `CodeMySpecWeb` left the document behind. The graph asked
for an implementation file for a module nobody was going to write while the real
one sat beside it.

### CodeMySpecWeb.AppLive

- **Type:** live_context
- **Description:** The `/app` onboarding wizard + overview. Renders the next missing setup step (account creation, then project creation) until both are done; lands returning users with at least one project on the Overview view.
- **Stories:** 811, 813, 828

#### Children

- CodeMySpecWeb.AppLive.Overview (liveview) [Stories: 811, 828, 813]: The primary app view at `/app` — install funnel and live CLI status, and the wizard's replacement for a returning user who already has projects.

**`/app` does not redirect to a project, and that is deliberate.** An earlier version bounced a returning user to their last project; it satisfied the idea that a bookmark should pick a landing page and broke twelve of story 603's criteria, whose criterion 5501 is exactly "a user with an account and a project sees the primary app view on /app". The stored active project still earns its keep — it answers for `/api/issues`, which has no URL to read a project from — and choosing a project is the sidebar picker's job.

What *is* project-aware is the way in. The marketing chrome's "Open workspace" links to the active project when there is one and to `/app` when there is not, so resuming work does not cost a click through a page you did not want. That is a link target, not a redirect: `/app` reached directly still renders this view, which is what keeps 603 true. The rule lives on story 605 and the helper is `Layouts.workspace_path/1`.

### CodeMySpecWeb.AuthorLive

- **Type:** liveview
- **Description:** Marketing LiveView rendering the founder bio page with published blog content.

### CodeMySpecWeb.ChatLive

- **Type:** liveview
- **Description:** Two-way chat with an agent. Where someone lands after signup, to do the brief story interview: the agent asks, they answer, and the tool calls it makes are visible as it makes them. The story it creates is rendered inline through the real story UI so it can be corrected without leaving the conversation.

Distinct from IntakeLive, which is everything BEFORE signup — the short exchange that leads to the intake form. Distinct from AgentConversationLive, which watches a sprite read-only with nothing to send back. Expected to generalise: this is the first agent chat surface, and the main conversation view later on is likely to absorb it rather than sit beside it.

### CodeMySpecWeb.CmsUsersController

- **Type:** controller
- **Description:** Deploy-key-authenticated controller that returns paginated registered users for the CodeMySpec dashboard.

### CodeMySpecWeb.ContentController

- **Type:** controller
- **Description:** Controller serving published content (blog, docs, landing, pages) with SEO metadata and JSON-LD schema.

### CodeMySpecWeb.ContentSyncController

- **Type:** controller
- **Description:** Deploy-key-authenticated controller that accepts content push payloads from the CodeMySpec server.

### CodeMySpecWeb.DeviceLive.Index

- **Type:** liveview
- **Description:** Every machine on the account, and what it is: local or cloud, present or not, and which working copies sit on it.

The surface for story 958. One level above `CodeMySpecWeb.WorkingCopyLive.Index`, which lists checkouts — this lists the machines those checkouts are on, so a 105-row list of copies becomes a handful of machines you can actually read.

Three liveness questions live in a chain and only the middle one exists today: a **device** is present when its harness holds a connection, a **working copy** is present when its path still exists on that device, and an **agent** is present when its lane is joined and working. This surface owns the first, and must not present it as either of the other two — a machine being on is not the same as something happening on it.

Reading and naming only. No stop, no destroy: a device is somebody's machine, and the server observes it rather than reaching across to end anything on it. Same decision `WorkingCopyLive` makes about agents, for the same reason.
- **Stories:** 958

### CodeMySpecWeb.EpicsLive

- **Type:** live_context
- **Description:** Live context grouping the LiveViews and LiveComponents for the active project's epics. Users browse epics, create and edit them, assign stories, and mark a story or an epic's stories ready for development to control the pace at which work enters the build queue.
- **Stories:** 844

#### Children

- CodeMySpecWeb.EpicsLive.FormComponent (liveview_component): Form for creating and editing an epic — name and description — submitting through Epics.create_epic/2 or Epics.update_epic/3.
- CodeMySpecWeb.EpicsLive.Index (liveview) [Stories: 844]: Lists the active project's epics with their story counts and how many of each epic's stories are ready for development.
- CodeMySpecWeb.EpicsLive.Show (liveview): Shows a single epic and the stories it contains, with per-story ready-for-development toggles and a one-shot bulk action to mark the epic's stories ready.

### CodeMySpecWeb.InboxLive

- **Type:** liveview
- **Description:** Operator's unified inbox surface in the CodeMySpec dashboard. Lists conversations across all of the account's projects, shows a selected thread, lets any CMS user in the account read and reply in real time, and displays per-user online presence. Depends on CodeMySpec.Conversations.

Renders its thread through `CodeMySpecWeb.ChatComponents`, shared with the story interview and the agent conversation view. It is the one surface where the reader is a person rather than a watcher, so it passes `own_role={:operator}` and puts attachments in the bubble's `:extra` slot.
- **Stories:** 846, 866

### CodeMySpecWeb.IntakeLive

- **Type:** live_context
- **Description:** The anonymous intake flow. A visitor describes what they want to build, answers the two shaping questions in operator language, and gets back a plan stating every inference it made — all without signing in. The plan survives leaving and returning in the same browser. Signup turns the confirmed names into an account and project, then hands off to the running workspace and the story interview.
- **Stories:** 875, 1033

#### Children

- CodeMySpecWeb.IntakeLive.Plan (liveview) [Stories: 1033, 875]: Everything before the gate. The visitor describes what they want to build, answers the two shaping questions in operator language, and is shown the plan with every inference stated and correctable. Leaving and coming back in the same browser lands here with the plan intact; a different browser gets a fresh start rather than an error.
- CodeMySpecWeb.IntakeLive.Workspace (liveview): Everything after the gate. Shows the workspace coming up, then the running application — or says plainly that it failed, keeping the plan. Once it is up the story interview starts on its own and reaches its derived rules within four questions.

### CodeMySpecWeb.IntegrationsController

- **Type:** controller
- **Description:** OAuth provider callback controller handling both social login and integration connect flows.

### CodeMySpecWeb.InvitationsLive.Accept

- **Type:** liveview
- **Description:** LiveView for accepting an account invitation via a tokenized link.

### CodeMySpecWeb.InvitationsLive.Components.PendingInvitations

- **Type:** liveview_component
- **Description:** Live component that renders a table of pending account invitations with revoke actions.

### CodeMySpecWeb.InvitationsLive.Form

- **Type:** liveview_component
- **Description:** Live component form for sending an account invitation by email and role.

### CodeMySpecWeb.IssuesController

- **Type:** controller
- **Description:** JSON API controller for listing, showing, and creating project issues.

### CodeMySpecWeb.IssuesLive

- **Type:** live_context
- **Description:** Project-scope issue browser — list with severity / status filters, per-issue detail with triage actions, link-back to the originating story or QA run.
- **Stories:** 807

#### Children

- CodeMySpecWeb.IssuesLive.Index (liveview) [Stories: 807]: LiveView listing project issues with status and severity filters.
- CodeMySpecWeb.IssuesLive.Show (liveview): LiveView showing a single issue with triage actions (accept, dismiss, resolve).

### CodeMySpecWeb.LlmsTxtController

- **Type:** controller
- **Description:** Controller generating the llms.txt file that lists all published content for AI crawler indexing.

### CodeMySpecWeb.MailboxLive

- **Type:** live_context
- **Description:** The operator's mail surface in the dashboard: lists the mailboxes the member can see (shared + own; owners/admins see all), opens a mailbox to its per-correspondent threads, and composes/replies (From = the mailbox address). Depends on CodeMySpec.Mail.
- **Stories:** 845, 867

### CodeMySpecWeb.NotificationController

- **Type:** controller
- **Description:** OAuth-authenticated API controller that dispatches push notifications from local servers to browser subscribers.

### CodeMySpecWeb.OAuthController

- **Type:** controller
- **Description:** OAuth2 authorization server controller handling the authorize and token endpoints for MCP clients.

### CodeMySpecWeb.PageController

- **Type:** controller
- **Description:** Controller rendering the marketing homepage with SEO meta tags and JSON-LD structured data.

### CodeMySpecWeb.PermissionController

- **Type:** controller
- **Description:** OAuth-authenticated API controller that creates permission requests from the local Claude Code agent.

### CodeMySpecWeb.PermissionLive.Show

- **Type:** liveview
- **Description:** Approve or deny a pending agent permission request.

### CodeMySpecWeb.PersonasLive

- **Type:** live_context
- **Description:** Live context grouping the server-side LiveViews and LiveComponents for the active project's persona library. PMs browse, create, view, and link personas here.
- **Stories:** 801

#### Children

- CodeMySpecWeb.PersonasLive.FormComponent (module)
- CodeMySpecWeb.PersonasLive.Index (module) [Stories: 801]
- CodeMySpecWeb.PersonasLive.Show (module)

### CodeMySpecWeb.PreviewComponents

- **Type:** liveview_component
- **Description:** The preview pane: a function component handed a URL and a state, rendering the
right thing for each.

Its whole input is `src` plus `:absent | :starting | :running | :down`, and
that is deliberate — it makes the pane provable by handing it values, with no
container, no proxy and no DNS behind it. It decides nothing about where the
app is or whether it is up; story 886 computes those and passes them in.

An iframe rather than rendering the target in-page. The alternative fails on
things that cannot be fixed without forking: the target's `push_patch` calls
`history.pushState` on `window` and would rewrite the host's address bar,
`window.liveSocket` is a single global, and the generated app's Tailwind
preflight would flatten host styles in a shared cascade. The isolation this
component promises — address bar untouched, styling contained — is what an
iframe gives for free.

`:down` and `:starting` are different screens. Conflating them is how a broken
app reads as a slow one.

`:running` with no `src` is refused rather than framed: an iframe pointed at an
empty address renders a blank rectangle indistinguishable from an app that
rendered nothing, which is the one outcome the pane exists to prevent.

Viewport width arrives as an assign. The host owns that control, so the pane
stays a pure function of its input and can be tested with `render_component/2`
rather than a LiveView harness.
- **Stories:** 885

### CodeMySpecWeb.PreviewLive.Show

- **Type:** liveview
- **Description:** Hosts the preview pane at `/build/preview` so it can be seen and driven.

A convenience host rather than the pane's identity. The same component is meant
to sit on a project page Sam returns to later, so nothing here may become
something the pane depends on.

Owns the viewport control Sam operates and passes the chosen width to the pane
as an assign — which is what keeps the pane a pure function of `src` and state.

Resolves the workspace for the active project and hands the pane the address
and state that `CodeMySpec.Workspaces` reports. Asked, never inferred from
whether a request succeeded: a booting container and a crashed one both fail to
answer, and telling them apart is the distinction the pane renders.

### CodeMySpecWeb.ProjectController

- **Type:** controller
- **Description:** JSON API controller returning the authenticated user's project list.

### CodeMySpecWeb.ProjectLive.Form

- **Type:** liveview
- **Description:** LiveView form for creating or editing a project record.

### CodeMySpecWeb.ProjectLive.Index

- **Type:** liveview
- **Description:** LiveView listing all projects for the current account with streaming updates.

### CodeMySpecWeb.ProjectLive.Picker

- **Type:** liveview
- **Description:** LiveView for selecting the active project from the account's project list.

### CodeMySpecWeb.ProjectLive.Show

- **Type:** liveview
- **Description:** LiveView displaying project detail with OAuth credentials management.

### CodeMySpecWeb.ProjectTimeline

- **Type:** liveview_component
- **Stories:** 965

### CodeMySpecWeb.ProjectUsersLive.Index

- **Type:** liveview
- **Description:** Project-scoped LiveView listing the users registered for the target application
(the index of the ProjectUsers resource), paginated, with clear error states
when the app is unreachable or rejects the deploy key. A future
ProjectUsersLive.Show will hold per-user enriched / ICP data.
- **Stories:** 847

### CodeMySpecWeb.ProvisioningLive

- **Type:** liveview
- **Description:** Setup status page. Shows the whole step sequence in order, each step's state validated against the provider on demand rather than remembered from the last run, and a retry affordance per step. Streams state changes live while setup runs. Surfaces a paused step with what Sam must do elsewhere, and an errored step with what the agent could not fix. Also where Sam turns individual setup options on and off.
- **Stories:** 849, 850, 871

#### Children

- CodeMySpecWeb.ProvisioningLive.Components.CredentialsForm (module)
- CodeMySpecWeb.ProvisioningLive.Components.EnvironmentsForm (module)
- CodeMySpecWeb.ProvisioningLive.Components.SecretsForm (module)

### CodeMySpecWeb.PushSubscriptionController

- **Type:** controller
- **Description:** Browser-session-authenticated controller for subscribing, unsubscribing, and retrieving the VAPID key for Web Push.

### CodeMySpecWeb.ResendWebhookController

- **Type:** controller
- **Description:** Inbound mail webhook controller that verifies Svix signatures from Resend and routes received emails to project mailboxes.

### CodeMySpecWeb.ResourceLive.Index

- **Type:** liveview
- **Description:** Everything the account owns at every provider, at `/app/resources`, with whether it is healthy readable before any of it.

Two audiences on one page and neither is served by the other's version. The count of what is wrong sits at the top, so someone who does not know what a DNS record is can tell whether today is a bad day without reading a list. Underneath, every resource with its location and what it belongs to, because the person fixing it needs to know which record on which zone.

Grouped by what actually owns each thing rather than by the project that created it. An SSH key and a firewall are one Hetzner object shared by every server; filing them under whichever project provisioned first is how they become invisible when that project is deleted.

Read-only. Acting on what it finds is story 999.
- **Stories:** 883, 884

### CodeMySpecWeb.ServerLive.Index

- **Type:** liveview
- **Description:** The servers screen at `/app/servers` — every box the account owns, linked or not.

Lists what the provider reports right now rather than what CodeMySpec recorded earlier, so a box resized in the Hetzner console reads correctly here. Linked servers are shown first; unlinked ones stay reachable behind a count ("+3 more") rather than being omitted, because a box nobody can see is a box that keeps billing.

Both ways in start here: link a server Sam already runs, or provision a new one. Provisioning states the cost and creates nothing until he confirms, the same discipline the domain purchase already has.

Two failure surfaces it must render rather than swallow: a provider that cannot be reached says so instead of showing an empty list (which would read as "you have no servers"), and a linked server destroyed at the provider is called out as missing rather than quietly disappearing.
- **Stories:** 879, 989

### CodeMySpecWeb.ServerLive.Show

- **Type:** liveview
- **Description:** One server's page: what is running on it, and what setup put there. Two halves with different truth sources, and the page says which is which — containers are read live from the box every time it loads, while the resources setup created are our own records. The live read happens off the mount so a box that hangs cannot hold up the records beside it, and gives up after a stated wait rather than spinning. A step that never ran reads differently from one that ran and failed, because "no backups" and "backups broke" are different problems.
- **Stories:** 882

### CodeMySpecWeb.SitemapController

- **Type:** controller
- **Description:** Controller generating the XML sitemap from static routes and published content.

### CodeMySpecWeb.Tasks.TaskQueueLive

- **Type:** liveview
- **Description:** The engineer's at-a-glance view of the agent's task queue: the requirement being
worked right now and the ordered list of what comes next, on one screen.

Backed directly by `RequirementGraph.next_actionable/1`. The head of the
actionable list is the active task and the tail, up to the configured cap of 25,
is the upcoming list.

An empty actionable list renders an explicit empty state rather than an empty
page, so "everything is satisfied" cannot be mistaken for a render error — the
two look identical otherwise, and the one that means success is the one a reader
is least prepared to see.

Subscribes to this project's file-change events, so every sync — manual or
watcher-driven — re-renders the queue without a refresh.

This spec used to name `CodeMySpecLocalWeb.Tasks.TaskQueueLive`, which is not
where the code is: it lives in `CodeMySpecWeb.Tasks` alongside `NextTaskLive` and
is routed there. The harness UI's move into `CodeMySpecWeb` left the document
behind, so the graph asked for an implementation file for a module nobody was
going to write while the real one sat beside it.
- **Stories:** 862

### CodeMySpecWeb.TokenController

- **Type:** controller
- **Description:** Exchanges a deployed environment's refresh secret for a short-lived access token. The refresh secret can do nothing else, and the five authenticated surfaces accept only the short-lived tokens — so a credential captured from any of them is useless within minutes. Refusals distinguish expiry from a bad credential so the app knows to renew and retry, and a live widget socket re-authenticates in place rather than dropping.
- **Stories:** 857

### CodeMySpecWeb.UploadController

- **Type:** controller
- **Description:** Controller generating presigned S3 upload URLs for project file uploads.

### CodeMySpecWeb.UserController

- **Type:** controller
- **Description:** JSON API controller returning the current authenticated user's id and email.

### CodeMySpecWeb.UserLive.CheckEmail

- **Type:** liveview
- **Description:** LiveView confirmation screen shown after sending a magic-link login email.

### CodeMySpecWeb.UserLive.Login

- **Type:** liveview
- **Description:** LiveView login page for requesting a magic-link or re-authenticating an existing session.

### CodeMySpecWeb.UserLive.Registration

- **Type:** liveview
- **Description:** LiveView registration page for new users to create an account with magic-link email.

### CodeMySpecWeb.UserLive.Settings

- **Type:** liveview
- **Description:** LiveView for managing user account settings including email and integrations; requires sudo mode.

### CodeMySpecWeb.UserPreferenceLive.Form

- **Type:** liveview
- **Description:** LiveView form for viewing and updating user preferences including active account, project, and API token.

### CodeMySpecWeb.UserSessionController

- **Type:** controller
- **Description:** Controller handling magic-link token confirmation, session creation, and user logout.

### CodeMySpecWeb.WorkingCopiesLive

- **Type:** live_context
- **Description:** Every working copy on a project, and what is running on each.

A harness is a working copy — `Harnesses.issue/3` mints one id per checkout, so "harness id" and "working copy id" are the same thing, and this page says so in the user's words rather than making them infer it. On this project that is this checkout and the QA checkout; on a shared host it is one per tenant.

Renders three joins that already exist: `Harnesses.list_harnesses/1` for the copies, `agents.working_copy` for what is running on each, and `pi:<working_copy>` for the transcript — the same key `AgentConversationLive` reads.

Watches and talks; starts and stops nothing. A harness is installed and run on its own machine, and a page reaching across to end it is a different kind of thing from a page showing what is happening.

The one fact it has to get right is liveness, because there are two of them. A Pi lane is tracked in Presence on the harness channel, so a dead process stops being present with nothing to expire. A Claude Code agent has no channel to be present on — it reports over HTTP hooks and `touch_session/2` bumps a timestamp — so what is known about it is recency, not liveness. Showing both under one badge would invent a fact for half the rows.

Depends on: Harnesses, Agents, Conversations.

## Dependencies

- CodeMySpec.AcceptanceCriteria -> CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository
- CodeMySpec.AcceptanceCriteria -> CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.AcceptanceCriteria -> CodeMySpec.Repo
- CodeMySpec.AcceptanceCriteria -> CodeMySpec.Stories.Story
- CodeMySpec.AcceptanceCriteria -> CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository -> CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository -> CodeMySpec.Repo
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository -> CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.Criterion -> CodeMySpec.Stories.Story
- CodeMySpec.Accounts -> CodeMySpec.Accounts.Account
- CodeMySpec.Accounts -> CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Accounts -> CodeMySpec.Accounts.Member
- CodeMySpec.Accounts -> CodeMySpec.Accounts.MembersRepository
- CodeMySpec.Accounts -> CodeMySpec.Authorization
- CodeMySpec.Accounts -> CodeMySpec.Repo
- CodeMySpec.Accounts -> CodeMySpec.Users.Scope
- CodeMySpec.Accounts.Account -> CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.Account -> CodeMySpec.Users.User
- CodeMySpec.Accounts.AccountsRepository -> CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.AccountsRepository -> CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.AccountsRepository -> CodeMySpec.Repo
- CodeMySpec.Accounts.AccountsRepository -> CodeMySpec.Users.User
- CodeMySpec.Accounts.Member -> CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.Member -> CodeMySpec.Users.User
- CodeMySpec.Accounts.MembersRepository -> CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.MembersRepository -> CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.MembersRepository -> CodeMySpec.Repo
- CodeMySpec.Accounts.MembersRepository -> CodeMySpec.Users.User
- CodeMySpec.AgentTasks -> CodeMySpec.Architecture
- CodeMySpec.AgentTasks -> CodeMySpec.Auth
- CodeMySpec.AgentTasks -> CodeMySpec.BddSpecs
- CodeMySpec.AgentTasks -> CodeMySpec.Components
- CodeMySpec.AgentTasks -> CodeMySpec.Configurations
- CodeMySpec.AgentTasks -> CodeMySpec.Documents
- CodeMySpec.AgentTasks -> CodeMySpec.Environments
- CodeMySpec.AgentTasks -> CodeMySpec.Files
- CodeMySpec.AgentTasks -> CodeMySpec.Issues
- CodeMySpec.AgentTasks -> CodeMySpec.Paths
- CodeMySpec.AgentTasks -> CodeMySpec.Problems
- CodeMySpec.AgentTasks -> CodeMySpec.ProjectSync
- CodeMySpec.AgentTasks -> CodeMySpec.Projects
- CodeMySpec.AgentTasks -> CodeMySpec.PublicUrl
- CodeMySpec.AgentTasks -> CodeMySpec.Qa
- CodeMySpec.AgentTasks -> CodeMySpec.Repo
- CodeMySpec.AgentTasks -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks -> CodeMySpec.Rules
- CodeMySpec.AgentTasks -> CodeMySpec.Sessions
- CodeMySpec.AgentTasks -> CodeMySpec.Stories
- CodeMySpec.AgentTasks -> CodeMySpec.Users
- CodeMySpec.AgentTasks -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Architecture.Proposal
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Components
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Environments.Environment
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Requirements.ArchitectureChecker
- CodeMySpec.AgentTasks.ArchitectureDesign -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.CodeGeneration -> CodeMySpec.AgentTasks.Setup.Helpers
- CodeMySpec.AgentTasks.CodeGeneration -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.CodeGeneration -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Components
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Rules
- CodeMySpec.AgentTasks.ComponentCode -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Components.Component
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Components.Registry
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Rules
- CodeMySpec.AgentTasks.ComponentSpec -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Components
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Components.Component
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Rules
- CodeMySpec.AgentTasks.ComponentTest -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Components
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Components.Registry
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Documents
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Rules
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.ContextSpec -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.DesignUi -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.DesignUi -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.AgentTasks.ContextDesignReview
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.AgentTasks.ContextSpec
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.DevelopContext -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.AgentTasks.LiveViewSpec
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.DevelopLiveView -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.BddSpecs.Parser
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.Components
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.Problems
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.FixBddSpecs -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.FixIssues -> CodeMySpec.Issues
- CodeMySpec.AgentTasks.FixIssues -> CodeMySpec.Issues.Issue
- CodeMySpec.AgentTasks.FixIssues -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.Init -> CodeMySpec.AgentTasks.Init.Auth
- CodeMySpec.AgentTasks.Init -> CodeMySpec.AgentTasks.Init.CliConfig
- CodeMySpec.AgentTasks.Init -> CodeMySpec.AgentTasks.Init.PhoenixProject
- CodeMySpec.AgentTasks.Init.Auth -> CodeMySpec.Auth
- CodeMySpec.AgentTasks.Init.CliConfig -> CodeMySpec.Projects
- CodeMySpec.AgentTasks.Init.CliConfig -> CodeMySpec.Repo
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Components
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Components.Component
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Components.ComponentRepository
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Components.Registry
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Rules
- CodeMySpec.AgentTasks.LiveViewSpec -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.PersonaResearch -> CodeMySpec.Requirements.CheckerResult
- CodeMySpec.AgentTasks.PersonaResearch -> CodeMySpec.Requirements.PersonasChecker
- CodeMySpec.AgentTasks.ProblemFeedback -> CodeMySpec.Problems
- CodeMySpec.AgentTasks.ProblemFeedback -> CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.AgentTasks.ProblemFeedback -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ProjectSetup -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaApp -> CodeMySpec.AgentTasks.QaStory
- CodeMySpec.AgentTasks.QaApp -> CodeMySpec.BddSpecs
- CodeMySpec.AgentTasks.QaApp -> CodeMySpec.BddSpecs.SpecProjector
- CodeMySpec.AgentTasks.QaApp -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaApp -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.QaIntegrationPlan -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.QaIntegrationPlan -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaIntegrationPlan -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.QaJourney -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.QaJourney -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaJourney -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.QaJourney -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.QaSetup -> CodeMySpec.Documents
- CodeMySpec.AgentTasks.QaSetup -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.QaSetup -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaSetup -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.BddSpecs
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Components
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Documents
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Issues
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.QaStory -> CodeMySpec.Utils
- CodeMySpec.AgentTasks.ResearchTopic -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.ResearchTopic -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.SpexBoundaryReady -> CodeMySpec.AgentTasks.Setup.Helpers
- CodeMySpec.AgentTasks.SpexBoundaryReady -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.SpexBoundaryReady -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.SpexBoundaryReady -> CodeMySpec.Requirements.CheckerResult
- CodeMySpec.AgentTasks.SpexBoundaryReady -> CodeMySpec.Requirements.SpexBoundaryChecker
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.AgentTasks
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Components
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Environments.Environment
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.ProjectSync.FileWatcherServer
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.ProjectSync.Sync
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Sessions
- CodeMySpec.AgentTasks.StartAgentTask -> CodeMySpec.Sessions.Session
- CodeMySpec.AgentTasks.StoryInterview -> CodeMySpec.Requirements.CheckerResult
- CodeMySpec.AgentTasks.StoryInterview -> CodeMySpec.Requirements.StoriesChecker
- CodeMySpec.AgentTasks.StoryInterview -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.TechnicalStrategy -> CodeMySpec.Components
- CodeMySpec.AgentTasks.TechnicalStrategy -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.TechnicalStrategy -> CodeMySpec.Paths
- CodeMySpec.AgentTasks.TechnicalStrategy -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.ThreeAmigos -> CodeMySpec.Requirements.BddRulesChecker
- CodeMySpec.AgentTasks.ThreeAmigos -> CodeMySpec.Requirements.CheckerResult
- CodeMySpec.AgentTasks.ThreeAmigos -> CodeMySpec.Stories
- CodeMySpec.AgentTasks.WriteBddSpecs -> CodeMySpec.BddSpecs
- CodeMySpec.AgentTasks.WriteBddSpecs -> CodeMySpec.BddSpecs.Parser
- CodeMySpec.AgentTasks.WriteBddSpecs -> CodeMySpec.Components
- CodeMySpec.AgentTasks.WriteBddSpecs -> CodeMySpec.Environments
- CodeMySpec.AgentTasks.WriteBddSpecs -> CodeMySpec.Stories
- CodeMySpec.Architecture -> CodeMySpec.Components
- CodeMySpec.Architecture -> CodeMySpec.Documents
- CodeMySpec.Architecture -> CodeMySpec.Environments
- CodeMySpec.Architecture -> CodeMySpec.McpServers
- CodeMySpec.Architecture -> CodeMySpec.Paths
- CodeMySpec.Architecture -> CodeMySpec.Repo
- CodeMySpec.Architecture -> CodeMySpec.Stories
- CodeMySpec.Architecture -> CodeMySpec.Users.Scope
- CodeMySpec.Architecture.NamespaceProjector -> CodeMySpec.Components.Component
- CodeMySpec.Architecture.OverviewProjector -> CodeMySpec.Components.Component
- CodeMySpec.Architecture.Proposal -> CodeMySpec.Components
- CodeMySpec.Architecture.Proposal -> CodeMySpec.Documents
- CodeMySpec.Architecture.Proposal -> CodeMySpec.Environments
- CodeMySpec.Architecture.Proposal -> CodeMySpec.Stories
- CodeMySpec.Authorization -> CodeMySpec.Accounts
- CodeMySpec.Authorization -> CodeMySpec.Users
- CodeMySpec.BddRules -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.BddRules -> CodeMySpec.Accounts
- CodeMySpec.BddRules -> CodeMySpec.Personas
- CodeMySpec.BddRules -> CodeMySpec.Projects
- CodeMySpec.BddRules -> CodeMySpec.Repo
- CodeMySpec.BddRules -> CodeMySpec.Rules
- CodeMySpec.BddRules -> CodeMySpec.Stories
- CodeMySpec.BddRules -> CodeMySpec.Users
- CodeMySpec.BddSpecs -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.BddSpecs -> CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.BddSpecs -> CodeMySpec.Environments
- CodeMySpec.BddSpecs -> CodeMySpec.Stories
- CodeMySpec.BddSpecs -> CodeMySpec.Stories.Story
- CodeMySpec.BddSpecs -> CodeMySpec.Users.Scope
- CodeMySpec.BddSpecs.Parser -> CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.Parser -> CodeMySpec.BddSpecs.Spec
- CodeMySpec.BddSpecs.Parser -> CodeMySpec.BddSpecs.Step
- CodeMySpec.BddSpecs.Parser -> CodeMySpec.Code
- CodeMySpec.BddSpecs.Spec -> CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.SpecProjector -> CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.BddSpecs.SpecProjector -> CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.SpecProjector -> CodeMySpec.BddSpecs.Spec
- CodeMySpec.BddSpecs.SpecProjector -> CodeMySpec.BddSpecs.Step
- CodeMySpec.BddSpecs.SpecProjector -> CodeMySpec.Stories.Story
- CodeMySpec.ClientUsers -> CodeMySpec.Encrypted
- CodeMySpec.ClientUsers -> CodeMySpec.Repo
- CodeMySpec.Code.ElixirAst -> CodeMySpec.Code
- CodeMySpec.Components -> CodeMySpec.Accounts
- CodeMySpec.Components -> CodeMySpec.Problems
- CodeMySpec.Components -> CodeMySpec.Projects
- CodeMySpec.Components -> CodeMySpec.Repo
- CodeMySpec.Components -> CodeMySpec.Requirements
- CodeMySpec.Components -> CodeMySpec.Stories
- CodeMySpec.Components -> CodeMySpec.Users
- CodeMySpec.Components.ComponentRepository -> CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository -> CodeMySpec.Components.DependencyRepository
- CodeMySpec.Components.ComponentRepository -> CodeMySpec.Repo
- CodeMySpec.Components.ComponentRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Components.Dependency -> CodeMySpec.Components.Component
- CodeMySpec.Components.DependencyRepository -> CodeMySpec.Components.Component
- CodeMySpec.Components.DependencyRepository -> CodeMySpec.Components.Dependency
- CodeMySpec.Components.DependencyRepository -> CodeMySpec.Repo
- CodeMySpec.Components.DependencyRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Components.DependencyTree -> CodeMySpec.Components.Component
- CodeMySpec.Components.HierarchicalTree -> CodeMySpec.Components.Component
- CodeMySpec.Components.Registry -> CodeMySpec.Components.Component
- CodeMySpec.Components.Registry -> CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Components.Registry -> CodeMySpec.Requirements.RequirementDefinitionData
- CodeMySpec.Configurations -> CodeMySpec.Repo
- CodeMySpec.Configurations -> CodeMySpec.Users
- CodeMySpec.Content -> CodeMySpec.Repo
- CodeMySpec.Content -> CodeMySpec.Users
- CodeMySpec.Content -> CodeMySpec.Utils
- CodeMySpec.Content.ContentRepository -> CodeMySpec.Content.Content
- CodeMySpec.Content.ContentRepository -> CodeMySpec.Repo
- CodeMySpec.Content.ContentRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Content.Tag -> CodeMySpec.Content.Content
- CodeMySpec.Content.TagRepository -> CodeMySpec.Content.Tag
- CodeMySpec.Content.TagRepository -> CodeMySpec.Repo
- CodeMySpec.Documents -> CodeMySpec.Accounts
- CodeMySpec.Documents -> CodeMySpec.Components
- CodeMySpec.Documents -> CodeMySpec.Paths
- CodeMySpec.Documents -> CodeMySpec.Utils
- CodeMySpec.Documents.DocumentSpecProjector -> CodeMySpec.Documents.Registry
- CodeMySpec.Documents.MarkdownParser -> CodeMySpec.Documents.Parsers.ComponentParser
- CodeMySpec.Documents.MarkdownParser -> CodeMySpec.Documents.Parsers.DependencyParser
- CodeMySpec.Documents.MarkdownParser -> CodeMySpec.Documents.Parsers.FieldParser
- CodeMySpec.Documents.MarkdownParser -> CodeMySpec.Documents.Parsers.FunctionParser
- CodeMySpec.Documents.Parsers.ComponentParser -> CodeMySpec.Documents.SpecComponent
- CodeMySpec.Documents.Parsers.FieldParser -> CodeMySpec.Documents.Field
- CodeMySpec.Documents.Parsers.FunctionParser -> CodeMySpec.Documents.Function
- CodeMySpec.Embeddings -> CodeMySpec.Environments
- CodeMySpec.Embeddings -> CodeMySpec.Paths
- CodeMySpec.Embeddings -> CodeMySpec.Repo
- CodeMySpec.Embeddings -> CodeMySpec.Users
- CodeMySpec.Encrypted -> CodeMySpec.Vault
- CodeMySpec.Environments -> CodeMySpec.Environments.Cli
- CodeMySpec.Epics -> CodeMySpec.Epics.Epic
- CodeMySpec.Epics -> CodeMySpec.Epics.EpicsRepository
- CodeMySpec.Epics -> CodeMySpec.Projects
- CodeMySpec.Epics -> CodeMySpec.Repo
- CodeMySpec.Epics -> CodeMySpec.Stories
- CodeMySpec.Epics -> CodeMySpec.Users.Scope
- CodeMySpec.Events -> CodeMySpec.Repo
- CodeMySpec.FileEdits -> CodeMySpec.Repo
- CodeMySpec.Files -> CodeMySpec.Components
- CodeMySpec.Files -> CodeMySpec.Configurations
- CodeMySpec.Files -> CodeMySpec.Documents
- CodeMySpec.Files -> CodeMySpec.Embeddings
- CodeMySpec.Files -> CodeMySpec.Environments
- CodeMySpec.Files -> CodeMySpec.Git
- CodeMySpec.Files -> CodeMySpec.Paths
- CodeMySpec.Files -> CodeMySpec.Problems
- CodeMySpec.Files -> CodeMySpec.Projects
- CodeMySpec.Files -> CodeMySpec.Repo
- CodeMySpec.Files -> CodeMySpec.StaticAnalysis
- CodeMySpec.Files -> CodeMySpec.Stories
- CodeMySpec.Files -> CodeMySpec.Users
- CodeMySpec.Git -> CodeMySpec.Git.CLI
- CodeMySpec.Git -> CodeMySpec.Git.URLParser
- CodeMySpec.Git -> CodeMySpec.Integrations
- CodeMySpec.Git -> CodeMySpec.Users.Scope
- CodeMySpec.Git.CLI -> CodeMySpec.Git.URLParser
- CodeMySpec.Git.CLI -> CodeMySpec.Integrations
- CodeMySpec.Git.CLI -> CodeMySpec.Users.Scope
- CodeMySpec.GitHub -> CodeMySpec.Integrations
- CodeMySpec.GitHub -> CodeMySpec.Users
- CodeMySpec.Google -> CodeMySpec.Integrations
- CodeMySpec.Google -> CodeMySpec.Users
- CodeMySpec.IndexNow -> CodeMySpec.PublicUrl
- CodeMySpec.Intake -> CodeMySpec.Accounts
- CodeMySpec.Intake -> CodeMySpec.Projects
- CodeMySpec.Integrations -> CodeMySpec.Encrypted
- CodeMySpec.Integrations -> CodeMySpec.PublicUrl
- CodeMySpec.Integrations -> CodeMySpec.Repo
- CodeMySpec.Integrations -> CodeMySpec.Users
- CodeMySpec.Invitations -> CodeMySpec.Accounts
- CodeMySpec.Invitations -> CodeMySpec.Authorization
- CodeMySpec.Invitations -> CodeMySpec.Mailer
- CodeMySpec.Invitations -> CodeMySpec.PublicUrl
- CodeMySpec.Invitations -> CodeMySpec.Repo
- CodeMySpec.Invitations -> CodeMySpec.Users
- CodeMySpec.Issues -> CodeMySpec.Accounts
- CodeMySpec.Issues -> CodeMySpec.Auth
- CodeMySpec.Issues -> CodeMySpec.Documents
- CodeMySpec.Issues -> CodeMySpec.Environments
- CodeMySpec.Issues -> CodeMySpec.Issues.Issue
- CodeMySpec.Issues -> CodeMySpec.Issues.IssuesRepository
- CodeMySpec.Issues -> CodeMySpec.Paths
- CodeMySpec.Issues -> CodeMySpec.Projects
- CodeMySpec.Issues -> CodeMySpec.Repo
- CodeMySpec.Issues -> CodeMySpec.Users.Scope
- CodeMySpec.Issues.IssuesRepository -> CodeMySpec.Issues.Issue
- CodeMySpec.Issues.IssuesRepository -> CodeMySpec.Repo
- CodeMySpec.Issues.IssuesRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Knowledge -> CodeMySpec.Environments
- CodeMySpec.Knowledge -> CodeMySpec.Users
- CodeMySpec.McpServers -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers -> CodeMySpec.AgentTasks
- CodeMySpec.McpServers -> CodeMySpec.Architecture
- CodeMySpec.McpServers -> CodeMySpec.Auth
- CodeMySpec.McpServers -> CodeMySpec.BddRules
- CodeMySpec.McpServers -> CodeMySpec.Components
- CodeMySpec.McpServers -> CodeMySpec.Configurations
- CodeMySpec.McpServers -> CodeMySpec.Embeddings
- CodeMySpec.McpServers -> CodeMySpec.Files
- CodeMySpec.McpServers -> CodeMySpec.Issues
- CodeMySpec.McpServers -> CodeMySpec.Knowledge
- CodeMySpec.McpServers -> CodeMySpec.Paths
- CodeMySpec.McpServers -> CodeMySpec.Permissions
- CodeMySpec.McpServers -> CodeMySpec.Personas
- CodeMySpec.McpServers -> CodeMySpec.Projects
- CodeMySpec.McpServers -> CodeMySpec.PublicUrl
- CodeMySpec.McpServers -> CodeMySpec.Qa
- CodeMySpec.McpServers -> CodeMySpec.Questions
- CodeMySpec.McpServers -> CodeMySpec.Repo
- CodeMySpec.McpServers -> CodeMySpec.Requirements
- CodeMySpec.McpServers -> CodeMySpec.Rules
- CodeMySpec.McpServers -> CodeMySpec.Sessions
- CodeMySpec.McpServers -> CodeMySpec.Stories
- CodeMySpec.McpServers -> CodeMySpec.Tags
- CodeMySpec.McpServers -> CodeMySpec.Users
- CodeMySpec.McpServers.Architecture.ArchitectureMapper -> CodeMySpec.Components.Component
- CodeMySpec.McpServers.Architecture.ArchitectureMapper -> CodeMySpec.McpServers.Formatters
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph -> CodeMySpec.Components
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph -> CodeMySpec.McpServers.Architecture.ArchitectureMapper
- CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.ArchitectureServer -> CodeMySpec.McpServers.Architecture.Tools.AnalyzeStories
- CodeMySpec.McpServers.ArchitectureServer -> CodeMySpec.McpServers.Architecture.Tools.ValidateDependencyGraph
- CodeMySpec.McpServers.Components.ComponentsMapper -> CodeMySpec.McpServers.Formatters
- CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.ContextStatistics -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.ContextStatistics -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ContextStatistics -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.DeleteComponent -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.DeleteComponent -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.DeleteComponent -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.ListComponents -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.ListComponents -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ListComponents -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.OrphanedContexts -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.OrphanedContexts -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.OrphanedContexts -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign -> CodeMySpec.McpServers.Components.Tools.ShowArchitecture
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.ReviewContextDesign -> CodeMySpec.Stories
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.ShowArchitecture -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.StartContextDesign -> CodeMySpec.Components
- CodeMySpec.McpServers.Components.Tools.StartContextDesign -> CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Components.Tools.StartContextDesign -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Components.Tools.StartContextDesign -> CodeMySpec.Stories
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.ArchitectureHealthSummary
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.ContextStatistics
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.CreateComponent
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.DeleteComponent
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.GetComponent
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.ListComponents
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.OrphanedContexts
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.ReviewContextDesign
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.ShowArchitecture
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.StartContextDesign
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Components.Tools.UpdateComponent
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Stories.Tools.ListStories
- CodeMySpec.McpServers.ComponentsServer -> CodeMySpec.McpServers.Stories.Tools.SetStoryComponent
- CodeMySpec.McpServers.GoogleAds.Tools -> CodeMySpec.Google.Ads
- CodeMySpec.McpServers.GoogleAdsServer -> CodeMySpec.McpServers.GoogleAds.Tools
- CodeMySpec.McpServers.Personas.PersonasMapper -> CodeMySpec.McpServers.Formatters
- CodeMySpec.McpServers.Personas.PersonasMapper -> CodeMySpec.Personas.Persona
- CodeMySpec.McpServers.Personas.PersonasMapper -> CodeMySpec.Personas.PersonaStory
- CodeMySpec.McpServers.Personas.Tools.CreatePersona -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Personas.Tools.CreatePersona -> CodeMySpec.Personas
- CodeMySpec.McpServers.Personas.Tools.LinkPersonaToStory -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Personas.Tools.LinkPersonaToStory -> CodeMySpec.Personas
- CodeMySpec.McpServers.Stories.StoriesMapper -> CodeMySpec.McpServers.Formatters
- CodeMySpec.McpServers.Stories.Tools.CreateStories -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.CreateStories -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.CreateStories -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.CreateStory -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.CreateStory -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.CreateStory -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.DeleteCriterion -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.Tools.DeleteCriterion -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.DeleteCriterion -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.DeleteStory -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.DeleteStory -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.DeleteStory -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.GetStory -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.GetStory -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.GetStory -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.ListStories -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.ListStories -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.ListStories -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.ListStoryTitles -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.ListStoryTitles -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.ListStoryTitles -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.SetStoryComponent -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.SetStoryComponent -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.SetStoryComponent -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.StartStoryInterview -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.StartStoryInterview -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.StartStoryInterview -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.StartStoryReview -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.StartStoryReview -> CodeMySpec.McpServers.Validators
- CodeMySpec.McpServers.Stories.Tools.StartStoryReview -> CodeMySpec.Stories
- CodeMySpec.McpServers.Stories.Tools.UpdateCriterion -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.McpServers.Stories.Tools.UpdateCriterion -> CodeMySpec.McpServers.Stories.StoriesMapper
- CodeMySpec.McpServers.Stories.Tools.UpdateCriterion -> CodeMySpec.McpServers.Validators
- CodeMySpec.Notifications -> CodeMySpec.Auth
- CodeMySpec.Notifications -> CodeMySpec.Repo
- CodeMySpec.Notifications -> CodeMySpec.Users
- CodeMySpec.Oauth -> CodeMySpec.Repo
- CodeMySpec.Permissions -> CodeMySpec.Auth
- CodeMySpec.Permissions -> CodeMySpec.Repo
- CodeMySpec.Permissions -> CodeMySpec.Sessions
- CodeMySpec.Permissions -> CodeMySpec.Users
- CodeMySpec.Personas -> CodeMySpec.Personas.Persona
- CodeMySpec.Personas -> CodeMySpec.Personas.PersonaStory
- CodeMySpec.Personas -> CodeMySpec.Personas.PersonasRepository
- CodeMySpec.Personas -> CodeMySpec.Projects
- CodeMySpec.Personas -> CodeMySpec.Repo
- CodeMySpec.Personas -> CodeMySpec.Stories
- CodeMySpec.Personas -> CodeMySpec.Users.Scope
- CodeMySpec.Personas.Persona -> CodeMySpec.Personas.PersonaStory
- CodeMySpec.Personas.Persona -> CodeMySpec.Projects.Project
- CodeMySpec.Personas.Persona -> CodeMySpec.Stories.Story
- CodeMySpec.Personas.PersonaStory -> CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonaStory -> CodeMySpec.Stories.Story
- CodeMySpec.Personas.PersonasRepository -> CodeMySpec.Personas.Persona
- CodeMySpec.Personas.PersonasRepository -> CodeMySpec.Personas.PersonaStory
- CodeMySpec.Personas.PersonasRepository -> CodeMySpec.Repo
- CodeMySpec.Personas.PersonasRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Problems -> CodeMySpec.Components
- CodeMySpec.Problems -> CodeMySpec.Projects
- CodeMySpec.Problems -> CodeMySpec.Repo
- CodeMySpec.Problems -> CodeMySpec.Tests
- CodeMySpec.Problems -> CodeMySpec.Users
- CodeMySpec.Problems.Problem -> CodeMySpec.Projects.Project
- CodeMySpec.Problems.ProblemConverter -> CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemRenderer -> CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemRepository -> CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemRepository -> CodeMySpec.Repo
- CodeMySpec.ProjectCoordinator -> CodeMySpec.AgentTasks
- CodeMySpec.ProjectCoordinator -> CodeMySpec.Components
- CodeMySpec.ProjectCoordinator -> CodeMySpec.Environments
- CodeMySpec.ProjectCoordinator -> CodeMySpec.Paths
- CodeMySpec.ProjectSync.FileWatcherServer -> CodeMySpec.Components
- CodeMySpec.ProjectSync.FileWatcherServer -> CodeMySpec.Components.HierarchicalTree
- CodeMySpec.ProjectSync.FileWatcherServer -> CodeMySpec.Stories
- CodeMySpec.ProjectSync.FileWatcherServer -> CodeMySpec.Users.Scope
- CodeMySpec.ProjectUsers -> CodeMySpec.Projects
- CodeMySpec.Projects -> CodeMySpec.Auth
- CodeMySpec.Projects -> CodeMySpec.GitHub
- CodeMySpec.Projects -> CodeMySpec.Oauth
- CodeMySpec.Projects -> CodeMySpec.Repo
- CodeMySpec.Projects -> CodeMySpec.Users
- CodeMySpec.Provisioning.Cloudflare -> CodeMySpec.Integrations
- CodeMySpec.Provisioning.Hetzner -> CodeMySpec.Integrations
- CodeMySpec.Provisioning.Hetzner -> CodeMySpec.ProjectSecrets
- CodeMySpec.Provisioning.Repository -> CodeMySpec.Git
- CodeMySpec.Provisioning.Repository -> CodeMySpec.GitHub
- CodeMySpec.Provisioning.Repository -> CodeMySpec.Integrations
- CodeMySpec.Provisioning.Repository -> CodeMySpec.Projects
- CodeMySpec.Provisioning.Resend -> CodeMySpec.Integrations
- CodeMySpec.Qa -> CodeMySpec.AgentTasks
- CodeMySpec.Qa -> CodeMySpec.Issues
- CodeMySpec.Qa -> CodeMySpec.Repo
- CodeMySpec.Qa -> CodeMySpec.Sessions
- CodeMySpec.Qa -> CodeMySpec.Stories
- CodeMySpec.Qa -> CodeMySpec.Users
- CodeMySpec.Questions -> CodeMySpec.Accounts
- CodeMySpec.Questions -> CodeMySpec.Projects
- CodeMySpec.Questions -> CodeMySpec.Repo
- CodeMySpec.Questions -> CodeMySpec.Stories
- CodeMySpec.Questions -> CodeMySpec.Users
- CodeMySpec.Release -> CodeMySpec.Utils
- CodeMySpec.Requirements -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.Requirements -> CodeMySpec.AgentTasks
- CodeMySpec.Requirements -> CodeMySpec.BddRules
- CodeMySpec.Requirements -> CodeMySpec.Components
- CodeMySpec.Requirements -> CodeMySpec.Configurations
- CodeMySpec.Requirements -> CodeMySpec.Documents
- CodeMySpec.Requirements -> CodeMySpec.Environments
- CodeMySpec.Requirements -> CodeMySpec.Files
- CodeMySpec.Requirements -> CodeMySpec.Issues
- CodeMySpec.Requirements -> CodeMySpec.Paths
- CodeMySpec.Requirements -> CodeMySpec.Personas
- CodeMySpec.Requirements -> CodeMySpec.Problems
- CodeMySpec.Requirements -> CodeMySpec.Projects
- CodeMySpec.Requirements -> CodeMySpec.Qa
- CodeMySpec.Requirements -> CodeMySpec.Questions
- CodeMySpec.Requirements -> CodeMySpec.Repo
- CodeMySpec.Requirements -> CodeMySpec.Sessions
- CodeMySpec.Requirements -> CodeMySpec.Stories
- CodeMySpec.Requirements -> CodeMySpec.Users
- CodeMySpec.Requirements -> CodeMySpec.Utils
- CodeMySpec.Requirements.PersonasChecker -> CodeMySpec.Documents
- CodeMySpec.Requirements.PersonasChecker -> CodeMySpec.Environments
- CodeMySpec.Requirements.PersonasChecker -> CodeMySpec.Personas
- CodeMySpec.Requirements.PersonasChecker -> CodeMySpec.Users.Scope
- CodeMySpec.Requirements.Requirement -> CodeMySpec.Components.Component
- CodeMySpec.Requirements.Requirement -> CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Requirement -> CodeMySpec.Sessions.SessionType
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Components.Component
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Files.File
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Issues
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Problems.Problem
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Requirements.Preloader
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Stories.Story
- CodeMySpec.Requirements.RequirementCalculator -> CodeMySpec.Users.Scope
- CodeMySpec.Requirements.RequirementDefinition -> CodeMySpec.Sessions.SessionType
- CodeMySpec.Requirements.RequirementDefinitionData -> CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Resources -> CodeMySpec.Configurations
- CodeMySpec.Resources -> CodeMySpec.Projects
- CodeMySpec.Resources -> CodeMySpec.Provisioning
- CodeMySpec.Resources -> CodeMySpec.Servers
- CodeMySpec.Resources.Inventory -> CodeMySpec.Provisioning
- CodeMySpec.Rules -> CodeMySpec.Environments
- CodeMySpec.Rules -> CodeMySpec.Paths
- CodeMySpec.Servers -> CodeMySpec.Provisioning.Hetzner
- CodeMySpec.Servers.Containers -> CodeMySpec.AccountSecrets
- CodeMySpec.Servers.Containers -> CodeMySpec.Environments
- CodeMySpec.Sessions -> CodeMySpec.Accounts
- CodeMySpec.Sessions -> CodeMySpec.AgentTasks
- CodeMySpec.Sessions -> CodeMySpec.Components
- CodeMySpec.Sessions -> CodeMySpec.Projects
- CodeMySpec.Sessions -> CodeMySpec.Repo
- CodeMySpec.Sessions -> CodeMySpec.Users
- CodeMySpec.Sessions.Session -> CodeMySpec.Sessions.SessionType
- CodeMySpec.Sessions.SessionType -> CodeMySpec.AgentTasks
- CodeMySpec.StaticAnalysis -> CodeMySpec.Code
- CodeMySpec.StaticAnalysis -> CodeMySpec.Compile
- CodeMySpec.StaticAnalysis -> CodeMySpec.Components
- CodeMySpec.StaticAnalysis -> CodeMySpec.Configurations
- CodeMySpec.StaticAnalysis -> CodeMySpec.Documents
- CodeMySpec.StaticAnalysis -> CodeMySpec.Environments
- CodeMySpec.StaticAnalysis -> CodeMySpec.Files
- CodeMySpec.StaticAnalysis -> CodeMySpec.Paths
- CodeMySpec.StaticAnalysis -> CodeMySpec.Problems
- CodeMySpec.StaticAnalysis -> CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour -> CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.AnalyzerBehaviour -> CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.Analyzers.Credo -> CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.Analyzers.Credo -> CodeMySpec.Problems.ProblemConverter
- CodeMySpec.StaticAnalysis.Analyzers.Credo -> CodeMySpec.Projects.Project
- CodeMySpec.StaticAnalysis.Analyzers.Credo -> CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.Analyzers.Sobelow -> CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.Analyzers.Sobelow -> CodeMySpec.StaticAnalysis.AnalyzerBehaviour
- CodeMySpec.StaticAnalysis.Analyzers.Sobelow -> CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment -> CodeMySpec.Documents
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment -> CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment -> CodeMySpec.Projects.Project
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment -> CodeMySpec.Users.Scope
- CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment -> CodeMySpec.Utils.Paths
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.Projects.Project
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.StaticAnalysis.AnalyzerBehaviour
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.StaticAnalysis.Analyzers.Credo
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.StaticAnalysis.Analyzers.Sobelow
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.StaticAnalysis.Analyzers.SpecAlignment
- CodeMySpec.StaticAnalysis.Runner -> CodeMySpec.Users.Scope
- CodeMySpec.Stories -> CodeMySpec.AcceptanceCriteria
- CodeMySpec.Stories -> CodeMySpec.Accounts
- CodeMySpec.Stories -> CodeMySpec.Components
- CodeMySpec.Stories -> CodeMySpec.Issues
- CodeMySpec.Stories -> CodeMySpec.Projects
- CodeMySpec.Stories -> CodeMySpec.Repo
- CodeMySpec.Stories -> CodeMySpec.Stories.StoriesRepository
- CodeMySpec.Stories -> CodeMySpec.Stories.Story
- CodeMySpec.Stories -> CodeMySpec.Tags
- CodeMySpec.Stories -> CodeMySpec.Users.Scope
- CodeMySpec.Stories.StoriesRepository -> CodeMySpec.Accounts.Account
- CodeMySpec.Stories.StoriesRepository -> CodeMySpec.Projects.Project
- CodeMySpec.Stories.StoriesRepository -> CodeMySpec.Repo
- CodeMySpec.Stories.StoriesRepository -> CodeMySpec.Stories.Story
- CodeMySpec.Stories.StoriesRepository -> CodeMySpec.Users.Scope
- CodeMySpec.Stories.Story -> CodeMySpec.Components.Component
- CodeMySpec.Tags -> CodeMySpec.Projects
- CodeMySpec.Tags -> CodeMySpec.Repo
- CodeMySpec.Tags -> CodeMySpec.Stories.Story
- CodeMySpec.Tags -> CodeMySpec.Tags.StoryTag
- CodeMySpec.Tags -> CodeMySpec.Tags.Tag
- CodeMySpec.Tags -> CodeMySpec.Tags.TagRepository
- CodeMySpec.Tags -> CodeMySpec.Users.Scope
- CodeMySpec.Tests.TestResult -> CodeMySpec.Tests.TestError
- CodeMySpec.Tests.TestRun -> CodeMySpec.Tests.TestResult
- CodeMySpec.Tests.TestRun -> CodeMySpec.Tests.TestStats
- CodeMySpec.UserPreferences -> CodeMySpec.Accounts
- CodeMySpec.UserPreferences -> CodeMySpec.Projects
- CodeMySpec.UserPreferences -> CodeMySpec.Repo
- CodeMySpec.UserPreferences -> CodeMySpec.Users
- CodeMySpec.Users -> CodeMySpec.Accounts
- CodeMySpec.Users -> CodeMySpec.ClientUsers
- CodeMySpec.Users -> CodeMySpec.Environments
- CodeMySpec.Users -> CodeMySpec.Integrations
- CodeMySpec.Users -> CodeMySpec.Mailer
- CodeMySpec.Users -> CodeMySpec.Projects
- CodeMySpec.Users -> CodeMySpec.Repo
- CodeMySpec.Users -> CodeMySpec.UserPreferences
- CodeMySpec.Utils -> CodeMySpec.Accounts
- CodeMySpec.Utils -> CodeMySpec.Components
- CodeMySpec.Utils -> CodeMySpec.Paths
- CodeMySpec.Utils -> CodeMySpec.Projects
- CodeMySpec.Utils -> CodeMySpec.Repo
- CodeMySpec.Utils -> CodeMySpec.Sessions
- CodeMySpec.Utils -> CodeMySpec.Stories
- CodeMySpec.Utils -> CodeMySpec.Users
- CodeMySpec.Utils.Paths -> CodeMySpec.Paths
- CodeMySpec.Validation -> CodeMySpec.AgentTasks
- CodeMySpec.Validation -> CodeMySpec.BddSpecs
- CodeMySpec.Validation -> CodeMySpec.Configurations
- CodeMySpec.Validation -> CodeMySpec.FileEdits
- CodeMySpec.Validation -> CodeMySpec.Files
- CodeMySpec.Validation -> CodeMySpec.Problems
- CodeMySpec.Validation -> CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Validation -> CodeMySpec.Sessions
- CodeMySpec.Validation -> CodeMySpec.StaticAnalysis
- CodeMySpec.Validation -> CodeMySpec.Tests
- CodeMySpec.Validation -> CodeMySpec.Users
- CodeMySpec.Validation -> CodeMySpec.Validation.TaskEvaluator
- CodeMySpec.Validation.TaskEvaluator -> CodeMySpec.Components
- CodeMySpec.Validation.TaskEvaluator -> CodeMySpec.Sessions
- CodeMySpec.Validation.TaskEvaluator -> CodeMySpec.Sessions.SessionType
- CodeMySpec.Validation.TaskEvaluator -> CodeMySpec.Utils
- CodeMySpec.WorkingCopies -> CodeMySpec.Agents
- CodeMySpec.WorkingCopies -> CodeMySpec.Analysis
- CodeMySpec.WorkingCopies -> CodeMySpec.Components
- CodeMySpec.WorkingCopies -> CodeMySpec.Devices
- CodeMySpec.WorkingCopies -> CodeMySpec.Encrypted.Binary
- CodeMySpec.WorkingCopies -> CodeMySpec.Environments
- CodeMySpec.WorkingCopies -> CodeMySpec.Files
- CodeMySpec.WorkingCopies -> CodeMySpec.Problems
- CodeMySpec.WorkingCopies -> CodeMySpec.Projects
- CodeMySpec.WorkingCopies -> CodeMySpec.Repo
- CodeMySpec.WorkingCopies -> CodeMySpec.Stories
- CodeMySpec.WorkingCopies -> CodeMySpec.Users
- CodeMySpec.Workspaces -> CodeMySpec.Environments
- CodeMySpec.Workspaces -> CodeMySpec.Projects
- CodeMySpecLocalWeb.Hooks.SessionStartController -> CodeMySpec.Sessions
- CodeMySpecWeb.AccountLive.Components.MembersList -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Components.Navigation -> CodeMySpec.Authorization
- CodeMySpecWeb.AccountLive.Form -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Index -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Invitations -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Invitations -> CodeMySpec.Authorization
- CodeMySpecWeb.AccountLive.Invitations -> CodeMySpec.Invitations
- CodeMySpecWeb.AccountLive.Manage -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Manage -> CodeMySpec.Authorization
- CodeMySpecWeb.AccountLive.Members -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Members -> CodeMySpec.Authorization
- CodeMySpecWeb.AccountLive.Picker -> CodeMySpec.Accounts
- CodeMySpecWeb.AccountLive.Picker -> CodeMySpec.UserPreferences
- CodeMySpecWeb.AgentConversationLive -> CodeMySpec.Conversations
- CodeMySpecWeb.AgentConversationLive -> CodeMySpecWeb.ChatComponents
- CodeMySpecWeb.AgentConversationLive.Index -> CodeMySpec.Conversations
- CodeMySpecWeb.AgentConversationLive.Show -> CodeMySpec.Conversations
- CodeMySpecWeb.AgentConversationLive.Show -> CodeMySpecWeb.ChatComponents
- CodeMySpecWeb.AgentProgressLive -> CodeMySpec.Requirements
- CodeMySpecWeb.AgentProgressLive -> CodeMySpec.Sessions
- CodeMySpecWeb.AgentProgressLive -> CodeMySpec.TaskHelp
- CodeMySpecWeb.AppLive -> CodeMySpec.Accounts
- CodeMySpecWeb.AppLive -> CodeMySpec.Projects
- CodeMySpecWeb.AppLive -> CodeMySpec.Users
- CodeMySpecWeb.AppLive.Overview -> CodeMySpec.Accounts
- CodeMySpecWeb.AppLive.Overview -> CodeMySpec.Projects
- CodeMySpecWeb.AppLive.Overview -> CodeMySpec.UserPreferences
- CodeMySpecWeb.AppLive.Overview -> CodeMySpec.Users.Scope
- CodeMySpecWeb.AuthorLive -> CodeMySpec.Content
- CodeMySpecWeb.ChatComponents -> CodeMySpec.Conversations
- CodeMySpecWeb.ChatComponents -> CodeMySpecWeb.CoreComponents
- CodeMySpecWeb.ChatComponents -> CodeMySpecWeb.Markdown
- CodeMySpecWeb.CmsUsersController -> CodeMySpec.CmsUsers
- CodeMySpecWeb.ContentController -> CodeMySpec.Content
- CodeMySpecWeb.ContentSyncController -> CodeMySpec.Content
- CodeMySpecWeb.EpicsLive -> CodeMySpec.Epics
- CodeMySpecWeb.EpicsLive -> CodeMySpec.Stories
- CodeMySpecWeb.EpicsLive -> CodeMySpec.Users.Scope
- CodeMySpecWeb.InboxLive -> CodeMySpec.Conversations
- CodeMySpecWeb.InboxLive -> CodeMySpecWeb.ChatComponents
- CodeMySpecWeb.IntakeLive -> CodeMySpec.Intake
- CodeMySpecWeb.IntakeLive -> CodeMySpec.Stories
- CodeMySpecWeb.IntakeLive -> CodeMySpec.Users
- CodeMySpecWeb.IntakeLive -> CodeMySpec.Workspaces
- CodeMySpecWeb.IntegrationsController -> CodeMySpec.Integrations
- CodeMySpecWeb.IntegrationsController -> CodeMySpec.Users
- CodeMySpecWeb.InvitationsLive.Accept -> CodeMySpec.Invitations
- CodeMySpecWeb.InvitationsLive.Accept -> CodeMySpec.Users
- CodeMySpecWeb.InvitationsLive.Components.PendingInvitations -> CodeMySpec.Invitations
- CodeMySpecWeb.InvitationsLive.Form -> CodeMySpec.Invitations
- CodeMySpecWeb.IssuesController -> CodeMySpec.Issues
- CodeMySpecWeb.IssuesLive -> CodeMySpec.Issues
- CodeMySpecWeb.IssuesLive.Index -> CodeMySpec.Issues
- CodeMySpecWeb.IssuesLive.Show -> CodeMySpec.Issues
- CodeMySpecWeb.LlmsTxtController -> CodeMySpec.Content
- CodeMySpecWeb.MailboxLive -> CodeMySpec.Mail
- CodeMySpecWeb.NotificationController -> CodeMySpec.Notifications
- CodeMySpecWeb.OAuthController -> CodeMySpec.Oauth
- CodeMySpecWeb.PermissionController -> CodeMySpec.Notifications
- CodeMySpecWeb.PermissionLive.Show -> CodeMySpec.Notifications
- CodeMySpecWeb.PersonasLive -> CodeMySpec.Personas
- CodeMySpecWeb.PersonasLive -> CodeMySpec.Stories
- CodeMySpecWeb.PersonasLive -> CodeMySpec.Users.Scope
- CodeMySpecWeb.PreviewLive.Show -> CodeMySpec.Workspaces
- CodeMySpecWeb.PreviewLive.Show -> CodeMySpecWeb.PreviewComponents
- CodeMySpecWeb.ProjectController -> CodeMySpec.Projects
- CodeMySpecWeb.ProjectLive.Form -> CodeMySpec.Projects
- CodeMySpecWeb.ProjectLive.Index -> CodeMySpec.Projects
- CodeMySpecWeb.ProjectLive.Picker -> CodeMySpec.Projects
- CodeMySpecWeb.ProjectLive.Picker -> CodeMySpec.UserPreferences
- CodeMySpecWeb.ProjectLive.Show -> CodeMySpec.Projects
- CodeMySpecWeb.ProjectUsersLive.Index -> CodeMySpec.ProjectUsers
- CodeMySpecWeb.ProvisioningLive -> CodeMySpec.Configurations
- CodeMySpecWeb.ProvisioningLive -> CodeMySpec.Provisioning
- CodeMySpecWeb.PushSubscriptionController -> CodeMySpec.Notifications
- CodeMySpecWeb.ResendWebhookController -> CodeMySpec.Mail
- CodeMySpecWeb.ResourceLive.Index -> CodeMySpec.Resources
- CodeMySpecWeb.ServerLive.Index -> CodeMySpec.Servers
- CodeMySpecWeb.ServerLive.Show -> CodeMySpec.Provisioning
- CodeMySpecWeb.ServerLive.Show -> CodeMySpec.Servers
- CodeMySpecWeb.SitemapController -> CodeMySpec.Content
- CodeMySpecWeb.Tasks.TaskQueueLive -> CodeMySpec.Projects
- CodeMySpecWeb.Tasks.TaskQueueLive -> CodeMySpec.Requirements
- CodeMySpecWeb.Tasks.TaskQueueLive -> CodeMySpec.Users
- CodeMySpecWeb.UploadController -> CodeMySpec.Uploads
- CodeMySpecWeb.UserLive.CheckEmail -> CodeMySpec.Users
- CodeMySpecWeb.UserLive.Login -> CodeMySpec.Users
- CodeMySpecWeb.UserLive.Registration -> CodeMySpec.Users
- CodeMySpecWeb.UserLive.Settings -> CodeMySpec.Integrations
- CodeMySpecWeb.UserLive.Settings -> CodeMySpec.Users
- CodeMySpecWeb.UserPreferenceLive.Form -> CodeMySpec.UserPreferences
- CodeMySpecWeb.UserSessionController -> CodeMySpec.Users
