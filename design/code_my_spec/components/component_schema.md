# Component Schema

## Purpose
Defines the Ecto schema for Component entities representing Elixir code files within project architecture.

## Schema Definition

```elixir
defmodule CodeMySpec.Components.Component do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias CodeMySpec.Components.Dependency
  alias CodeMySpec.Projects.Project
  alias CodeMySpec.Users.User


  schema "components" do
    field :name, :string
    field :type, Ecto.Enum, values: [:genserver, :context, :coordination_context, :schema, :repository, :task, :registry, :other]
    field :module_name, :string
    field :description, :string
    
    belongs_to :project, Project
    belongs_to :user, User
    
    has_many :outgoing_dependencies, Dependency, foreign_key: :source_component_id
    has_many :incoming_dependencies, Dependency, foreign_key: :target_component_id
    
    has_many :dependencies, through: [:outgoing_dependencies, :target_component]
    has_many :dependents, through: [:incoming_dependencies, :source_component]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(component, attrs, %CodeMySpec.Users.Scope{} = scope) do
    component
    |> cast(attrs, [:name, :type, :module_name, :description])
    |> validate_required([:name, :type, :module_name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:module_name, min: 1, max: 255)
    |> validate_format(:module_name, ~r/^[A-Z][a-zA-Z0-9_.]*$/, message: "must be a valid Elixir module name")
    |> put_scope_associations(scope)
    |> unique_constraint([:name, :project_id])
    |> unique_constraint([:module_name, :project_id])
  end

  defp put_scope_associations(changeset, %{active_project_id: project_id}) do
    changeset
    |> put_assoc(:project_id, project_id)
  end
end
```

## Field Descriptions

### Required Fields
- **name**: Human-readable component name (e.g., "User Context", "Story Repository")
- **type**: Component type from enum (genserver, context, schema, repository, etc.)
- **module_name**: Full Elixir module name (e.g., "CodeMySpec.Accounts.User")

### Optional Fields
- **description**: Brief description of component purpose and responsibilities

### Associations
- **project**: Belongs to project for scoping and isolation
- **user**: Belongs to user who created/owns the component
- **outgoing_dependencies**: Dependencies this component has on other components
- **incoming_dependencies**: Components that depend on this component
- **dependencies**: Convenience association for components this depends on
- **dependents**: Convenience association for components that depend on this

## Validation Rules

### Name Validation
- Required, 1-255 characters
- Unique within project scope

### Module Name Validation  
- Required, 1-255 characters
- Must match Elixir module naming convention (starts with capital letter)
- Unique within project scope
- Regex pattern: `/^[A-Z][a-zA-Z0-9_.]*$/`

### Type Validation
- Must be one of the defined enum values
- Enforced at database and changeset level

### Scope Validation
- Must belong to active project from scope
- Must belong to user from scope
- Enforced through changeset associations

## Database Constraints

### Unique Constraints
- `unique_constraint([:name, :project_id])` - Component names unique per project
- `unique_constraint([:module_name, :project_id])` - Module names unique per project

### Foreign Key Constraints
- `project_id` references projects.id (cascade delete)

## Usage Patterns

### Creating Components
```elixir
attrs = %{
  name: "User Context", 
  type: :context,
  module_name: "CodeMySpec.Accounts.Users",
  description: "Manages user accounts and authentication"
}

changeset = Component.changeset(%Component{}, attrs, scope)
```