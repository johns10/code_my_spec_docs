# Project Schema

## Purpose
Represents a Phoenix application project with GitHub integration and setup status tracking.

## Schema Definition
```elixir
defmodule CodeMySpec.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "projects" do
    field :name, :string
    field :description, :string
    field :code_repo, :string
    field :docs_repo, :string
    field :status, Ecto.Enum, values: [:created, :setup_queued, :initializing, :deps_installing, :setting_up_auth, :compiling, :testing, :committing, :ready, :failed]
    field :setup_error, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :code_repo, :docs_repo, :status, :setup_error])
    |> validate_required([:name])
    |> validate_project_name()
    |> validate_repo(:code_repo)
    |> validate_repo(:docs_repo)
    |> unique_constraint(:name)
    |> unique_constraint(:code_repo)
    |> unique_constraint(:docs_repo)
  end

  defp validate_project_name(changeset) do
    changeset
    |> validate_length(:name, min: 1, max: 100)
  end

  defp validate_repo(changeset, field) do
    changeset
    |> validate_format(field, ~r/^https:\/\/github\.com\/[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+$/, message: "must be a valid GitHub repository URL")
  end
end
```

## Field Specifications

### Required Fields
- **name**: Project identifier and Phoenix app name
  - Type: `string`
  - Constraints: 1-100 characters
  - Unique across all projects
  - Converted to snake_case when generating Phoenix app name

### Optional Fields
- **description**: Project description
  - Type: `string`
  - Optional field for project documentation
  - Used for display purposes in UI

- **code_repo**: GitHub repository URL
  - Type: `string`
  - Format: `https://github.com/username/repository`
  - Unique across all projects
  - Used for git remote origin setup

- **docs_repo**: GitHub repository URL
  - Type: `string`
  - Format: `https://github.com/username/repository`
  - Unique across all projects
  - Used for git remote origin setup

### Status Fields
- **status**: Current project setup status
  - Type: `Ecto.Enum`
  - Values: `:created`, `:setup_queued`, `:initializing`, `:deps_installing`, `:setting_up_auth`, `:compiling`, `:testing`, `:committing`, `:ready`, `:failed`
  - Tracks progress through setup pipeline
  - Used for UI status display and job management

- **setup_error**: Error message for failed setups
  - Type: `string`
  - Optional field, populated when status is `:failed`
  - Contains human-readable error description

## Validation Rules

### Project Name Validation
- Length between 1-100 characters
- Must be unique across all projects
- Accepts any characters, converted to snake_case for Phoenix app generation

### GitHub Repository Validation
- Must be valid GitHub HTTPS URL format
- Pattern: `https://github.com/username/repository`
- Must be unique across all projects
- Repository must be accessible for git operations

## Database Constraints
- Primary key: UUID (`binary_id`)
- Unique constraints on `name` and `code_repo`
- Foreign key type: `binary_id` for consistency
- Timestamps with UTC timezone

## State Transitions
```
:created � :setup_queued � :initializing � :deps_installing � :setting_up_auth � :compiling � :testing � :committing � :ready
                                    �
                                :failed (from any state)
```

## Usage Examples
```elixir
# Create new project
attrs = %{name: "my_app", code_repo: "https://github.com/user/my_app"}
changeset = Project.changeset(%Project{}, attrs)

# Update status during setup
Project.changeset(project, %{status: :deps_installing})

# Mark as failed with error
Project.changeset(project, %{status: :failed, setup_error: "Mix deps.get failed"})
```