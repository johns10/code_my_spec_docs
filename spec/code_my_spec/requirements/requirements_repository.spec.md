# Requirements.RequirementsRepository

Repository module for managing persisted component requirement satisfaction status. Provides CRUD operations for requirements with project-scoped access control. Requirements track the satisfaction state of component design artifacts and support both persistent and in-memory operations.

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Users.Scope
- CodeMySpec.Components.Component
- CodeMySpec.Requirements.Requirement

## Functions

### clear_all_project_requirements/1

Clears all requirements for the entire project. Performs a bulk delete of all requirements associated with components in the project.

```elixir
@spec clear_all_project_requirements(Scope.t()) :: {integer(), nil}
```

**Process**:
1. Query all component IDs for the project from scope
2. Delete all requirements where component_id is in the subquery of project component IDs
3. Return tuple with count of deleted records

**Test Assertions**:

- deletes all requirements for all components in the project
- returns count of deleted requirements
- does not affect requirements in other projects
- returns {0, nil} when no requirements exist

### create_requirement/4

Creates a requirement for a component with optional persistence control.

```elixir
@spec create_requirement(Scope.t(), Component.t(), Requirement.requirement_attrs(), keyword()) ::
        {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
```

**Options**:
- `:persist` - Whether to persist to database (default: true). When false, applies changeset action without database insert.

**Process**:
1. Build changeset from empty Requirement struct with provided attributes
2. Associate the requirement with the component via put_assoc
3. If persist option is true (default), insert into database
4. If persist option is false, apply changeset action without persisting
5. Return success tuple with requirement or error tuple with changeset

**Test Assertions**:

- creates a requirement with valid data
- returns error with invalid data
- associates requirement with component
- persists to database when persist option is true (default)
- skips persistence when persist option is false

### update_requirement/3

Updates an existing requirement's satisfaction status and details.

```elixir
@spec update_requirement(Scope.t(), Requirement.t(), Requirement.requirement_attrs()) ::
        {:ok, Requirement.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply update_changeset to requirement with new attributes
2. Persist updated requirement to database
3. Return success tuple with updated requirement or error tuple with changeset

**Test Assertions**:

- updates requirement with valid data
- returns error with invalid data
- updates satisfaction status
- updates details map

### clear_requirements/3

Clears requirements for a specific component with optional database deletion.

```elixir
@spec clear_requirements(Scope.t(), Component.t(), keyword()) :: Component.t()
```

**Options**:
- `:persist` - Whether to delete from database (default: false). When true, deletes all requirement records for the component.

**Process**:
1. If persist option is true, delete all requirement records for the component from database
2. Clear outgoing_dependencies association on component struct
3. Clear incoming_dependencies association on component struct
4. Return updated component struct

**Test Assertions**:

- deletes requirements from database when persist option is true
- skips database deletion when persist option is false (default)
- clears outgoing_dependencies on returned component
- clears incoming_dependencies on returned component
- returns component struct