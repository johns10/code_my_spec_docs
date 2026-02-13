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

### AgentTasks
**context**

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

### Components
**context**

### Content
**context**

### ContentAdmin
**context**

### ContentSync
**context**

### Documents
**context**



### Environments
**context**



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

### Integrations
**context**

### Invitations
**context**

### LocalServer
**context**

### Mailer
**context**

### McpServers
**context**

MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

Dependencies:
- CodeMySpec.Sessions
- CodeMySpec.Components
- CodeMySpec.Stories

### Problems
**context**

### ProjectCoordinator
**context**

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

### Tests
**context**

### Transcripts
**context**

### UserPreferences
**context**

### Users
**context**

### Utils
**context**

### Validation
**context**



Dependencies:
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Problems
- CodeMySpec.Validation.Pipeline
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Validation.TaskEvaluator
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Transcripts.ClaudeCode.FileExtractor

### Vault
**context**


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

### UpdateStory
**module**

