# Architecture Overview

## Root Components

### CodeMySpec
**module**

### AcceptanceCriteria
**module**



Dependencies:
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story

### AccessGrant
**module**

### AccessToken
**module**

### Accounts
**module**

The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

Dependencies:
- CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Users.Scope
- CodeMySpec.Accounts.MembersRepository
- CodeMySpec.Accounts.Account
- CodeMySpec.Authorization
- CodeMySpec.Accounts.Member

### AgentTasks
**module**

### Analytics
**module**

### Application
**module**

### Application
**module**

### Architecture
**module**

A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides projectors that create documentation artifacts (mermaid diagrams, component hierarchies, namespace trees) written to the repository and synchronized with current project state during full syncs.

Dependencies:
- CodeMySpec.Users.Scope
- CodeMySpec.Components

### Authorization
**module**

### BddSpecs
**module**



Dependencies:
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Users.Scope
- CodeMySpec.Stories
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story

### Binary
**module**

### Bogus
**module**

### ClientUsers
**module**

### Code
**module**



### Compile
**module**

### Components
**module**

### Content
**module**

### ContentAdmin
**module**

### ContentSync
**module**

### Documents
**module**



### Environments
**module**



### Field
**module**

Embedded schema representing a schema field.

### FieldParser
**module**



### FileEdits
**module**

### Function
**module**

Embedded schema representing a function from a spec.

### FunctionParser
**module**



### Git
**module**

Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations for cloning and pulling repositories using OAuth tokens from the Integrations context.

Dependencies:
- CodeMySpec.Users.Scope
- CodeMySpec.Git.Behaviour
- CodeMySpec.Git.CLI

### GitHub
**module**

### Integrations
**module**

### Invitations
**module**

### LocalServer
**module**

### Mailer
**module**

### McpServers
**module**

MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

Dependencies:
- CodeMySpec.Stories
- CodeMySpec.Sessions
- CodeMySpec.Components

### OAuthClient
**module**

### Paths
**module**

### Problems
**module**



Dependencies:
- CodeMySpec.Projects
- CodeMySpec.Repo

### ProjectCoordinator
**module**

### ProjectSetupWizard
**module**

### ProjectSync
**module**

Public API for orchestrating synchronization of the entire project from filesystem to database and maintaining real-time sync via file watching.

### Projects
**module**

### Quality
**module**



Dependencies:
- CodeMySpec.Code
- CodeMySpec.Utils
- CodeMySpec.Components

### Release
**module**

### Repo
**module**

### Requirements
**module**

Manages component requirement checking, persistence, and workflow queries. Requirements are computed from checker modules and persisted for efficient UI queries.

### Rules
**module**

### Sessions
**module**



Dependencies:
- CodeMySpec.Sessions.SessionStack
- CodeMySpec.Environments
- CodeMySpec.Sessions.SessionsRepository

### Spec
**module**

Embedded schema representing a parsed spec file.

### SpecParser
**module**



### StaticAnalysis
**module**



Dependencies:
- CodeMySpec.Projects
- CodeMySpec.Users.Scope
- CodeMySpec.Problems

### Stories
**module**



Dependencies:
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Users.Scope
- CodeMySpec.Stories.StoriesRepository
- CodeMySpec.Stories.Story

### Strategy
**module**

### Tags
**module**



Dependencies:
- CodeMySpec.Users.Scope
- CodeMySpec.Tags.TagRepository
- CodeMySpec.Tags.StoryTag
- CodeMySpec.Tags.Tag
- CodeMySpec.Stories.Story

### Tests
**module**

The Tests context provides a functional interface for executing ExUnit tests with real-time streaming and structured result parsing. It executes mix test commands asynchronously via Erlang ports, streams JSON-formatted test events, and returns parsed test run data including statistics, failures, and passes.

### Transcripts
**module**

### UserPreferences
**module**

### Users
**module**

### Utils
**module**

### Validation
**module**



Dependencies:
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Validation.TaskEvaluator
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Transcripts.ClaudeCode.FileExtractor
- CodeMySpec.Validation.Pipeline
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Problems

### Vault
**module**


## Root Components

### CodeMySpecWeb
**module**

### Accept
**module**

### AccountsBreadcrumb
**module**

### ChangesetJSON
**module**

### Confirmation
**module**

### ContentSyncController
**module**

### CoreComponents
**module**

### CurrentPathHook
**module**

### Endpoint
**module**

### ErrorHTML
**module**

### ErrorJSON
**module**

### FallbackController
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

### Form
**module**

### Gettext
**module**

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
**module**

### Invitations
**module**

### Layouts
**module**

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
**module**

### OAuthHTML
**module**

### Overview
**module**

### PageController
**module**

### PageHTML
**module**

### PendingInvitations
**module**

### Picker
**module**

### Picker
**module**

### Presence
**module**

### ProjectBreadcrumb
**module**

### ProjectController
**module**

### ProjectCoordinatorController
**module**

### ProjectCoordinatorJSON
**module**

### ProjectScopeOverride
**module**

### Public
**module**

### Registration
**module**

### Router
**module**

### Scheduler
**module**

### SessionChannel
**module**

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
**module**

### StoriesJSON
**module**

### Telemetry
**module**

### TypeaheadComponent
**module**

### UserAuth
**module**

### UserController
**module**

### UserSessionController
**module**

### UserSocket
**module**


## Root Components

### DashboardLive
**liveview**

Dashboard view


## Root Components

### GenerateDemo
**module**


## Root Components

### GetJohns10Token
**module**


## Root Components

### Session
**module**

Ecto schema for agent task sessions. Tracks type (agent task module), agent, environment, execution mode, status lifecycle, and parent/child hierarchy. Scoped by account, project, and user.


## Root Components

### SessionStack
**module**

Filesystem-based session stack that controls stop hook behavior. Each session is a directory under  .code_my_spec/internal/sessions/{session_id}/  with  session.json  metadata and working files. Evaluates sessions by priority on stop hook — blocking the agent until tasks complete. Users can  ls  to see active sessions or  rm -rf  to cancel.


## Root Components

### SessionType
**module**

Custom Ecto type mapping agent task module atoms to string representations. Validates against known agent task modules.


## Root Components

### StructIntrospector
**module**

