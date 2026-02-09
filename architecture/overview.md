# Architecture Overview

## Root Components

### AddCriterion
**module**


## Root Components

### AddSimilarComponent
**module**


## Root Components

### ClearStoryComponent
**module**


## CodeMySpec

### CodeMySpec
**context**

### AcceptanceCriteria
**context**



Dependencies:
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story

### AccessGrant
**module**

### AccessToken
**module**

### Accounts
**context**

The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

Dependencies:
- CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Users.Scope
- CodeMySpec.Accounts.Member
- CodeMySpec.Authorization
- CodeMySpec.Accounts.Account
- CodeMySpec.Accounts.MembersRepository

### Analytics
**module**

### Application
**module**

### Application
**context**

### Architecture
**context**

A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides projectors that create documentation artifacts (mermaid diagrams, component hierarchies, namespace trees) written to the repository and synchronized with current project state during full syncs.

Dependencies:
- CodeMySpec.Users.Scope
- CodeMySpec.Components

### ArchitectureDesign
**module**

### ArchitectureReview
**module**

### Authorization
**context**

### BddSpecs
**context**



Dependencies:
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story
- CodeMySpec.Stories

### Binary
**module**

### Bogus
**context**

### ClientUsers
**context**

### Code
**context**



### Compile
**context**

### ComponentCode
**module**



Dependencies:
- CodeMySpec.Utils
- CodeMySpec.Tests
- CodeMySpec.Rules
- CodeMySpec.Environments
- CodeMySpec.Components

### ComponentSpec
**module**

Agent task module for generating component specification documents via Claude Code slash commands.

Dependencies:
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Utils
- CodeMySpec.Components.Component
- CodeMySpec.Rules
- CodeMySpec.Environments

### ComponentTest
**module**

Dependencies:
- CodeMySpec.Utils
- CodeMySpec.Components.Component
- CodeMySpec.Tests
- CodeMySpec.Rules
- CodeMySpec.Compile
- CodeMySpec.Quality
- CodeMySpec.Environments
- CodeMySpec.Components

### Components
**context**

### Content
**context**

### ContentAdmin
**context**

### ContentSync
**context**

### ContextComponentSpecs
**module**

Agent task for designing a context and all its child components through orchestrated subagent workflow.

Dependencies:
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ContextSpec
- CodeMySpec.Environments

### ContextDesignReview
**module**

### ContextImplementation
**module**



Dependencies:
- CodeMySpec.Requirements

### ContextSpec
**module**



Dependencies:
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Utils
- CodeMySpec.Rules
- CodeMySpec.Environments
- CodeMySpec.Components
- CodeMySpec.Stories

### DesignUi
**module**



Dependencies:
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Environments

### DevelopContext
**module**

Orchestrates the full lifecycle of a context from specification through implementation.

Dependencies:
- CodeMySpec.AgentTasks.ComponentSpec
- CodeMySpec.Utils
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.ContextSpec
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.Environments
- CodeMySpec.AgentTasks.ContextDesignReview

### Documents
**context**



### Environments
**context**



### EvaluateAgentTask
**module**

### Field
**module**

Embedded schema representing a schema field.

### FieldParser
**module**



### FileEdits
**context**

### Function
**module**

Embedded schema representing a function from a spec.

### FunctionParser
**module**



### Git
**context**

### GitHub
**context**

### ImplementLiveView
**module**



Dependencies:
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.AgentTasks.ComponentCode
- CodeMySpec.AgentTasks.LiveViewCode
- CodeMySpec.AgentTasks.ComponentTest
- CodeMySpec.Environments
- CodeMySpec.AgentTasks.LiveViewTest

### Integrations
**context**

### Invitations
**context**

### LiveViewCode
**module**



Dependencies:
- CodeMySpec.Tests
- CodeMySpec.Rules
- CodeMySpec.Environments
- CodeMySpec.Components

### LiveViewSpec
**module**



Dependencies:
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Utils
- CodeMySpec.Components.Component
- CodeMySpec.Rules
- CodeMySpec.Environments
- CodeMySpec.Components

### LiveViewTest
**module**



Dependencies:
- CodeMySpec.Tests
- CodeMySpec.Rules
- CodeMySpec.Compile
- CodeMySpec.StaticAnalysis
- CodeMySpec.Environments
- CodeMySpec.Components

### LocalServer
**context**

### Mailer
**context**

### ManageImplementation
**module**

Master agent task that orchestrates the full implementation lifecycle of a project. Provides the master prompt that drives the agent through an iterative loop:

Dependencies:
- CodeMySpec.BddSpecs
- CodeMySpec.Environments
- CodeMySpec.BddSpecs.Spex

### McpServers
**context**

MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

Dependencies:
- CodeMySpec.Sessions
- CodeMySpec.Components
- CodeMySpec.Stories

### Problems
**context**



Dependencies:
- CodeMySpec.Repo
- CodeMySpec.Projects

### ProjectCoordinator
**context**

### ProjectSetup
**module**



Dependencies:
- CodeMySpec.Environments

### ProjectSetupWizard
**context**

### ProjectSync
**context**

Public API for orchestrating synchronization of the entire project from filesystem to database and maintaining real-time sync via file watching.

### Projects
**context**

### Quality
**context**



Dependencies:
- CodeMySpec.Utils
- CodeMySpec.Components
- CodeMySpec.Code

### RefactorModule
**module**

Agent task for guiding interactive refactoring sessions with Claude Code. Routes to component or context-specific refactoring based on the component type.

### Release
**context**

### Repo
**context**

### Requirements
**context**

Manages component requirement checking, persistence, and workflow queries. Requirements are computed from checker modules and persisted for efficient UI queries.

### Rules
**context**

### Sessions
**context**



Dependencies:
- CodeMySpec.Sessions.SessionStack
- CodeMySpec.Environments
- CodeMySpec.Sessions.SessionsRepository

### Spec
**module**

Embedded schema representing a parsed spec file.

### SpecParser
**module**



### StartAgentTask
**module**

### StaticAnalysis
**context**



Dependencies:
- CodeMySpec.Problems
- CodeMySpec.Users.Scope
- CodeMySpec.Projects

### Stories
**context**



Dependencies:
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Users.Scope
- CodeMySpec.Stories.RemoteClient
- CodeMySpec.Stories.Story
- CodeMySpec.Stories.StoriesRepository

### Tags
**context**



Dependencies:
- CodeMySpec.Tags.TagRepository
- CodeMySpec.Tags.Tag
- CodeMySpec.Users.Scope
- CodeMySpec.Tags.StoryTag
- CodeMySpec.Stories.Story

### TaskContext
**module**

### TaskMarker
**module**

### Tests
**context**

### TrackEdits
**module**

### Transcripts
**context**

### UserPreferences
**context**

### Users
**context**

### Utils
**context**

### ValidateEdits
**module**

A Claude Code stop hook handler that validates files edited during an agent session. When Claude stops, this hook retrieves edited files from session state (populated by the TrackEdits post-tool-use hook), categorizes them by analyzer type, runs validators in sequence, and returns actionable feedback so Claude can fix issues before the session terminates.

Dependencies:
- CodeMySpec.Documents
- CodeMySpec.BddSpecs
- CodeMySpec.Tests
- CodeMySpec.FileEdits
- CodeMySpec.Compile
- CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemRenderer

### Validation
**context**

Validates files edited during Claude Code sessions.

### Vault
**context**

### WriteBddSpecs
**module**



Dependencies:
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.BddSpecs
- CodeMySpec.Environments
- CodeMySpec.Components
- CodeMySpec.Stories


## CodeMySpecWeb

### CodeMySpecWeb
**context**

### Accept
**module**

### AccountsBreadcrumb
**module**

### ChangesetJSON
**context**

### Confirmation
**module**

### ContentSyncController
**context**

### CoreComponents
**context**

### CurrentPathHook
**module**

### Endpoint
**context**

### ErrorHTML
**context**

### ErrorJSON
**context**

### FallbackController
**context**

### Form
**module**

### Form
**module**

### Form
**module**

### Form
**module**

### Form
**module**

### Form
**module**

### Gettext
**context**

### Import
**module**

### Index
**module**

### Index
**module**

### Index
**module**

### Index
**module**

### Index
**module**

### Index
**module**

### Index
**module**

### IntegrationsController
**context**

### Invitations
**module**

### Layouts
**context**

### Login
**module**

### Manage
**module**

### Members
**module**

### MembersList
**module**

### Methodology
**module**

### Navigation
**module**

### OAuthController
**context**

### OAuthHTML
**context**

### Overview
**module**

### PageController
**context**

### PageHTML
**context**

### PendingInvitations
**module**

### Picker
**module**

### Picker
**module**

### Presence
**context**

### ProjectBreadcrumb
**module**

### ProjectController
**context**

### ProjectCoordinatorController
**context**

### ProjectCoordinatorJSON
**context**

### Public
**module**

### Registration
**module**

### Router
**context**

### Scheduler
**module**

### SessionChannel
**context**

### Settings
**module**

### SetupWizard
**module**

### Show
**module**

### Show
**module**

### Show
**module**

### SimilarComponentsSelector
**module**

### StoriesController
**context**

### StoriesJSON
**context**

### Telemetry
**context**

### TypeaheadComponent
**context**

### UserAuth
**context**

### UserController
**context**

### UserSessionController
**context**

### UserSocket
**context**


## Root Components

### CreateComponent
**module**


## Root Components

### CreateComponents
**module**


## DashboardLive

### DashboardLive
**context**

Dashboard view


## DashboardLive

### DashboardLive
**context**

Dashboard view


## Dashboards

### Dashboards
**context**

Dashboard management

### Dashboard
**module**

Dashboard entity


## Root Components

### DeleteSpec
**module**


## Root Components

### GenerateDemo
**module**


## Root Components

### GetComponent
**module**


## Root Components

### GetJohns10Token
**module**


## Hooks

### Hooks
**context**

It does the damn thing

### TrackEdits
**module**

A Claude Code post-tool-use hook that tracks files edited during an agent session. When Claude uses Write or Edit tools, this hook captures the file path and stores it in session state, building a record of all files modified during the session for later validation.

Dependencies:
- CodeMySpec.Sessions

### ValidateEdits
**module**

A Claude Code stop hook that validates files edited during an agent session. Delegates to `CodeMySpec.Sessions.AgentTasks.ValidateEdits` for the actual validation logic.


## Root Components

### JobStatus
**module**

A status indicator component that displays running background jobs. Subscribes to PubSub events and only shows when jobs are active.


## Session

### Session
**context**

Ecto schema for agent task sessions. Tracks type (agent task module), agent, environment, execution mode, status lifecycle, and parent/child hierarchy. Scoped by account, project, and user.


## SessionStack

### SessionStack
**context**

Filesystem-based session stack that controls stop hook behavior. Each session is a directory under  .code_my_spec/internal/sessions/{session_id}/  with  session.json  metadata and working files. Evaluates sessions by priority on stop hook — blocking the agent until tasks complete. Users can  ls  to see active sessions or  rm -rf  to cancel.


## SessionType

### SessionType
**context**

Custom Ecto type mapping agent task module atoms to string representations. Validates against known agent task modules.


## Root Components

### Sessions
**module**



Dependencies:
- CodeMySpecCli.TerminalPanes
- CodeMySpec.Sessions


## StructIntrospector

### StructIntrospector
**context**


## TerminalPanes

### TerminalPanes
**context**




## Root Components

### UpdateComponent
**module**


## Root Components

### UpdateSpecMetadata
**module**


## Root Components

### UpdateStory
**module**

