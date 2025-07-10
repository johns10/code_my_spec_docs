# ProjectSetup Module

## Purpose
Business logic module that orchestrates the complete Phoenix project setup process, abstracting implementation details from the Oban job.

## Public API
```elixir
# Main Setup Orchestration
@spec setup_project(Project.t()) :: {:ok, Project.t()} | {:error, setup_error()}
@spec setup_project(Project.t(), callback_fn()) :: {:ok, Project.t()} | {:error, setup_error()}

# Custom Types
@type setup_error :: :temp_dir_failed | :phx_new_failed | :deps_failed | :auth_failed | :compile_failed | :test_failed | :git_init_failed | :git_push_failed
@type callback_fn :: (Project.t(), project_status() -> :ok)
```

## Function Descriptions

### Setup Project
The main setup function coordinates the entire project setup process from start to finish. It executes each step in sequence, updating the project status after each successful operation and handling failures appropriately.

The two-arity version accepts a callback function that is called after each status update. This allows the Oban job to handle job-specific concerns while keeping the core business logic separate.

The setup process includes:
- Creating a temporary directory using Briefly
- Generating a new Phoenix application with `mix phx.new`
- Installing dependencies with `mix deps.get`
- Setting up authentication with `mix phx.gen.auth`
- Compiling the project with `mix compile`
- Running tests with `mix test`
- Initializing git and committing all files
- Pushing to the specified GitHub repositories

Status updates are broadcast via Phoenix PubSub after each step to provide real-time feedback to users monitoring the setup progress.

## Internal Implementation

The module contains private functions for each individual setup step:
- Creating temporary directories
- Executing mix commands
- Managing git operations
- Handling status updates and broadcasting

These implementation details are not exposed in the public API, allowing the module to change its internal structure without affecting callers.

## Error Handling Strategy
Each setup step can fail independently, and the module provides specific error atoms for each failure type. When a step fails, the setup process stops and the project status is set to `:failed` with the appropriate error information.

The module doesn't handle retries directly - that responsibility belongs to the Oban job layer. This separation allows the business logic to focus on the setup process while the job layer handles operational concerns.

## Dependencies
- **Briefly**: Temporary directory creation and management
- **System Commands**: Executing mix, git, and other shell commands
- **Projects.Repository**: Database operations for project updates
- **Phoenix.PubSub**: Status broadcasting for real-time updates
- **File System**: Directory and file operations during setup

## Usage Patterns
The ProjectSetup module is primarily called by the ProjectSetupJob but can also be used directly for testing or manual setup operations. The module is designed to be stateless and functional, making it easy to test and reason about.

```elixir
# Called by Oban job with callback
ProjectSetup.setup_project(project, &handle_status_update/2)

# Called directly without callback
ProjectSetup.setup_project(project)
```