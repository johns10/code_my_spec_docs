# Architecture Overview

## Root Components

### CodeMySpec
**module**

### AcceptanceCriteria
**context**

Dependencies:
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria.AcceptanceCriteriaRepository

### AccessGrant
**module**

### AccessToken
**module**

### Accounts
**module**

The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relationships, role-based permissions, and access control throughout the CodeMySpec platform.

Dependencies:
- CodeMySpec.Accounts.Member
- CodeMySpec.Accounts.Account
- CodeMySpec.Authorization
- CodeMySpec.Accounts.AccountsRepository
- CodeMySpec.Users.Scope
- CodeMySpec.Accounts.MembersRepository

### AgentTasks
**module**

### Analytics
**module**

### Application
**module**

### Architecture
**module**

A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides projectors that create documentation artifacts (mermaid diagrams, component hierarchies, namespace trees) written to the repository and synchronized with current project state during full syncs.

Dependencies:
- CodeMySpec.Components
- CodeMySpec.Users.Scope

### AuthState
**module**

### Authorization
**module**

### BddSpecs
**context**

Dependencies:
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Stories.Story
- CodeMySpec.Stories
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria

### Binary
**module**

### Bogus
**module**

### ClientUsers
**module**

### Code
**context**

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
**context**

### Environments
**logic**

### Field
**module**

Embedded schema representing a schema field.

### FieldParser
**logic**

### FileEdits
**module**

### FrameworkSync
**module**

### Function
**module**

Embedded schema representing a function from a spec.

### FunctionParser
**logic**

### Git
**module**

Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations for cloning and pulling repositories using OAuth tokens from the Integrations context.

Dependencies:
- CodeMySpec.Git.CLI
- CodeMySpec.Git.Behaviour
- CodeMySpec.Users.Scope

### GitHub
**module**

### Integrations
**module**

### Invitations
**module**

### Issues
**context**

Dependencies:
- CodeMySpec.Issues.IssuesRepository
- CodeMySpec.Documents
- CodeMySpec.Issues.Issue
- CodeMySpec.Issues.Projector
- CodeMySpec.Environments
- CodeMySpec.Users.Scope

### Mailer
**module**

### McpServers
**module**

MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality.

Dependencies:
- CodeMySpec.Components
- CodeMySpec.Sessions
- CodeMySpec.Stories

### Notifications
**module**

### OAuthClient
**module**

### Paths
**module**

### PermissionSocket
**module**

### Problems
**context**

Dependencies:
- CodeMySpec.Repo
- CodeMySpec.Projects

### ProjectCoordinator
**module**

### ProjectSetupWizard
**module**

### ProjectSync
**module**

Public API for orchestrating synchronization of the entire project from filesystem to database and maintaining real-time sync via file watching.

### Projects
**module**

### Prompts
**module**

### Quality
**context**

Dependencies:
- CodeMySpec.Components
- CodeMySpec.Utils
- CodeMySpec.Code

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
**context**

Dependencies:
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Environments
- CodeMySpec.Sessions.SessionStack

### Spec
**module**

Embedded schema representing a parsed spec file.

### SpecParser
**logic**

### StaticAnalysis
**context**

Dependencies:
- CodeMySpec.Problems
- CodeMySpec.Users.Scope
- CodeMySpec.Projects

### Stories
**context**

Dependencies:
- CodeMySpec.Stories.Story
- CodeMySpec.Stories.StoriesRepository
- CodeMySpec.Users.Scope
- CodeMySpec.AcceptanceCriteria

### Strategy
**module**

### Tags
**context**

Dependencies:
- CodeMySpec.Tags.TagRepository
- CodeMySpec.Tags.StoryTag
- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- CodeMySpec.Tags.Tag

### TestContext
**context**

Dependencies:
- CodeMySpec.Users.Scope

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
**context**

Dependencies:
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.Problems
- CodeMySpec.Transcripts.ClaudeCode.FileExtractor
- CodeMySpec.Validation.Pipeline
- CodeMySpec.Validation.TaskEvaluator

### Vault
**module**


## Root Components

### CodeMySpecLocalWeb
**module**

### AgentTaskController
**module**

### Application
**module**

### BootstrapController
**module**

### ComponentsRequirementsController
**module**

### CoreComponents
**module**

### Endpoint
**module**

### ErrorHTML
**module**

### ErrorJSON
**module**

### HealthController
**module**

### HomeLive
**module**

### HookController
**controller**

Dependencies:
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions

### Index
**module**

### InitHTML
**module**

### InitLive
**module**

### Layouts
**module**

### LocalOnly
**module**

### LocalScope
**module**

### MarkdownBrowserController
**module**

### MarkdownBrowserLive
**module**

### McpPlug
**module**

### Migrator
**module**

### NextTaskLive
**module**

### NotificationController
**module**

### NotificationHookController
**module**

### PermissionController
**module**

### PostToolUseController
**module**

### PreToolUseController
**module**

### ProjectScope
**module**

### RequirementsController
**module**

### RequirementsGraphController
**module**

### RequirementsLive
**module**

### RequirementsMarkdown
**module**

### Router
**module**

### SessionStartController
**controller**

Dependencies:
- CodeMySpec.Sessions

### SessionsLive
**module**

### Show
**module**

### StopController
**controller**

### StoriesRequirementsController
**module**

### SubagentStopController
**module**

### SyncLive
**module**

### WorkingDir
**module**

### WorkingDirScope
**module**


## Root Components

### CodeMySpecWeb
**module**

### Accept
**module**

### AccountsBreadcrumb
**module**

### Application
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

### MetricFlow
**module**

### Navigation
**module**

### NotificationController
**module**

### OAuthController
**module**

### OAuthHTML
**module**

### Onboarding
**module**

### Overview
**module**

### PageController
**module**

### PageHTML
**module**

### PendingInvitations
**module**

### PermissionChannel
**module**

### PermissionController
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

### ProjectScopeOverride
**module**

### Public
**module**

### PushSubscriptionController
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

### Show
**module**

### SimilarComponentsSelector
**module**

### SitemapController
**module**

### StoriesChannel
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

### GenerateDemo
**module**


## Root Components

### GetJohns10Token
**module**


## Root Components

### SetStoryComponent
**module**


## Root Components

### StructIntrospector
**module**

