# Projects Repository

## Purpose
Data access layer for CRUD operations on Project entities, handling database interactions and query logic.

## Public API
```elixir
# CRUD Operations
@spec create_project(project_attrs()) :: {:ok, Project.t()} | {:error, Ecto.Changeset.t()}
@spec get_project(String.t()) :: {:ok, Project.t()} | {:error, :not_found}
@spec get_project_by_name(String.t()) :: {:ok, Project.t()} | {:error, :not_found}
@spec update_project(String.t(), map()) :: {:ok, Project.t()} | {:error, :not_found | Ecto.Changeset.t()}
@spec delete_project(String.t()) :: :ok | {:error, :not_found}
@spec list_projects() :: [Project.t()]

# Project Status Management
@spec update_project_status(String.t(), project_status()) :: {:ok, Project.t()} | {:error, :not_found}
@spec set_project_error(String.t(), String.t()) :: {:ok, Project.t()} | {:error, :not_found}
@spec clear_project_error(String.t()) :: {:ok, Project.t()} | {:error, :not_found}

# Project Queries
@spec list_projects_by_status(project_status()) :: [Project.t()]
@spec count_projects_by_status(project_status()) :: integer()
@spec get_failed_projects() :: [Project.t()]

# Custom Types
@type project_attrs :: %{
  name: String.t(),
  code_repo: String.t(),
  docs_repo: String.t()
}

@type project_status :: :created | :setup_queued | :initializing | :deps_installing | :setting_up_auth | :compiling | :testing | :committing | :ready | :failed
```

## Function Descriptions

### Create Project
Creates a new project record with the provided attributes. Validates the project name uniqueness and GitHub repository URL formats. Sets initial status to `:created` and prepares the project for setup processing.

### Get Project
Retrieves a single project by its UUID. Returns the complete project record if found, including all status and repository information.

### Get Project by Name
Finds a project using its name field. Useful for user-facing operations where projects are identified by their human-readable names rather than UUIDs.

### Update Project
Updates an existing project with new attributes. Can modify any field on the project record including name, repository URLs, and status. Validates changes according to the project schema constraints.

### Delete Project
Removes a project record from the database. Performs a hard delete of the project and all associated data. Used when projects are permanently removed from the system.

### List Projects
Returns all project records in the system. Includes pagination support for large datasets and can be filtered by various criteria.

## Project Status Management

### Update Project Status
Changes the project status to reflect the current state of project setup or processing. Status transitions are tracked to monitor progress through the setup pipeline.

### Set Project Error
Records an error message when project setup fails. Sets the project status to `:failed` and stores the error description for debugging and user feedback.

### Clear Project Error
Removes error information from a project record. Used when retrying failed operations or when errors are resolved.

## Project Queries

### List Projects by Status
Retrieves all projects with a specific status. Commonly used to find projects that need processing or to display projects in different states to users.

### Count Projects by Status
Returns the count of projects in each status category. Useful for dashboard metrics and system monitoring.

### Get Failed Projects
Returns all projects that have failed setup or processing. Used for error reporting and retry operations.

## Error Handling

Repository operations handle standard database errors including:
- **Validation errors** when project attributes don't meet schema requirements
- **Not found errors** when attempting to operate on non-existent projects
- **Constraint violations** when trying to create duplicate projects or violate uniqueness rules
- **Database connection errors** and other infrastructure issues

## Usage Patterns

The repository layer is called by the Projects context to perform database operations. It focuses purely on data access without business logic, allowing the context layer to handle orchestration and business rules.

Status updates are frequent during project setup as the background jobs progress through different phases. Query operations support both user-facing features and administrative tools for monitoring project health.