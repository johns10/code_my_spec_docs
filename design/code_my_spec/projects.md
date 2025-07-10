# Projects Context

## Purpose
Manages CRUD operations for Phoenix application projects and orchestrates their setup process using background jobs with GitHub integration.

## Entity Ownership
- **Project**: Core entity representing a Phoenix application project with GitHub repositories
- **ProjectSetupJob**: Oban job that handles project creation, setup, and GitHub integration
- **ProjectSetup**: Business logic module for orchestrating setup process
- **StatusBroadcaster**: Real-time status update broadcasting

## Public API
```elixir
# CRUD Operations
@spec create_project(project_attrs()) :: {:ok, Project.t()} | {:error, Ecto.Changeset.t()}
@spec get_project(String.t()) :: {:ok, Project.t()} | {:error, :not_found}
@spec update_project(String.t(), map()) :: {:ok, Project.t()} | {:error, :not_found | :invalid_attrs}
@spec delete_project(String.t()) :: :ok | {:error, :not_found}
@spec list_projects() :: [Project.t()]

# Project Setup
@spec setup_project(Project.t()) :: {:ok, Oban.Job.t()}
@spec cancel_setup(String.t()) :: :ok | {:error, :not_found | :already_completed}

# Real-time Subscriptions
@spec subscribe_to_project(String.t()) :: :ok | {:error, term()}
@spec subscribe_to_all_projects() :: :ok | {:error, term()}
@spec unsubscribe_from_project(String.t()) :: :ok
@spec unsubscribe_from_all_projects() :: :ok

# Custom Types
@type project_attrs :: %{
  name: String.t(),
  code_repo: String.t(),
  docs_repo: String.t()
}

@type project_status :: :created | :setup_queued | :initializing | :deps_installing | :setting_up_auth | :compiling | :testing | :committing | :ready | :failed
```

## State Management Strategy
### Project Creation Flow
- Creates project record in database with `:created` status and GitHub repo URLs
- Enqueues Oban job for setup, updates status to `:setup_queued`
- Job uses Briefly to create temporary directory for project setup
- Updates project status as it progresses through each step
- Uses Phoenix PubSub to broadcast status changes to UI
- Commits final project to GitHub repositories (code and docs)
- Oban handles retries and failure recovery automatically

### Temporary Directory Management
- Uses Briefly library to create temporary working directory
- Automatically cleans up temporary files after completion
- Isolates project creation from main application filesystem

## Component Diagram
```
Projects Context
├── Projects.Project (Schema)
|   ├── name, code_repo, docs_repo, status
|   └── timestamps
├── Projects.Repository (Data Access)
|   ├── CRUD operations
|   ├── Status management
|   └── Query functions
├── Projects.ProjectSetupJob (Oban.Worker)
|   ├── Job configuration
|   └── Callback handling
├── Projects.ProjectSetup (Business Logic)
|   ├── Briefly temp directory creation
|   ├── Mix phx.new command
|   ├── Mix deps.get command
|   ├── Mix phx.gen.auth command
|   ├── Mix compile command
|   ├── Mix test command
|   ├── Git commit and push
|   └── Status updates
└── Projects.StatusBroadcaster (PubSub)
    ├── Project status broadcasting
    └── Subscription management
```

## Dependencies
- **Oban**: Background job processing and retry logic
- **Briefly**: Temporary directory creation and cleanup
- **Phoenix.PubSub**: Real-time status updates
- **System Commands**: Mix, Git commands for project operations
- **GitHub**: Repository integration for project hosting
- **Database**: Project metadata persistence
- **Projects.Repository**: Data access layer for project operations
- **Projects.ProjectSetup**: Business logic for setup orchestration
- **Projects.StatusBroadcaster**: Real-time update broadcasting

## Execution Flow
1. **Create Project**: Store project record with `:created` status and GitHub repo URLs
2. **Queue Setup**: Enqueue `ProjectSetupJob`, update status to `:setup_queued`
3. **Job Starts**: Create temporary directory with Briefly, update status to `:initializing`
4. **Run phx.new**: Execute `mix phx.new` command in temp directory
5. **Install Dependencies**: Update status to `:deps_installing`, run `mix deps.get`
6. **Setup Auth**: Update status to `:setting_up_auth`, run `mix phx.gen.auth`
7. **Compile**: Update status to `:compiling`, run `mix compile`
8. **Test**: Update status to `:testing`, run `mix test`
9. **Git Integration**: Update status to `:committing`, initialize git, commit all files
10. **Push to GitHub**: Push initial commit to specified GitHub repositories (code and docs)
11. **Complete**: Update status to `:ready` or `:failed`, broadcast final status
12. **Cleanup**: Briefly automatically cleans up temporary directory
13. **Retry Logic**: Oban automatically retries failed jobs with exponential backoff