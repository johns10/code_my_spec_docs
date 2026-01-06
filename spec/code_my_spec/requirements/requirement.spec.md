# CodeMySpec.Requirements.Requirement

Embedded schema representing a component requirement instance with its satisfaction status. Created from RequirementDefinition templates and tracks runtime satisfaction state. Supports both boolean pass/fail via satisfied field and incremental quality scoring (0.0 to 1.0) for nuanced requirement assessment.

## Fields

| Field          | Type         | Required   | Description                                  | Constraints                      |
| -------------- | ------------ | ---------- | -------------------------------------------- | -------------------------------- |
| name           | string       | Yes        | Requirement identifier                       |                                  |
| artifact_type  | enum         | Yes        | Category for UI grouping                     | See artifact_type enum           |
| description    | string       | Yes        | Human-readable requirement description       |                                  |
| checker_module | CheckerType  | Yes        | Module that validates this requirement       |                                  |
| satisfied_by   | SessionType  | No         | Module that can satisfy this requirement     |                                  |
| satisfied      | boolean      | Yes        | Current satisfaction status                  | Determined by score >= threshold |
| score          | float        | No         | Quality score from 0.0 (fail) to 1.0 (pass)  | Range: 0.0-1.0                   |
| checked_at     | utc_datetime | No         | Timestamp of last requirement check          |                                  |
| details        | map          | Yes        | Additional contextual information from check | Default: %{}, includes errors    |
| component_id   | binary_id    | Yes        | Associated component                         | References components.id         |
| inserted_at    | utc_datetime | Yes (auto) | Creation timestamp                           | Auto-generated                   |
| updated_at     | utc_datetime | Yes (auto) | Last update timestamp                        | Auto-generated                   |

**artifact_type enum**:
- `:specification` - Spec files and validity
- `:review` - Review files
- `:code` - Implementation files
- `:tests` - Test files, test status
- `:dependencies` - Dependency satisfaction checks
- `:hierarchy` - Child component checks

## Functions

### ok/0

Creates a passing requirement result with perfect score.

```elixir
@spec ok() :: t()
```

**Process**:
1. Create new Requirement struct
2. Set satisfied to true
3. Set score to 1.0
4. Set details to empty map
5. Return requirement

**Test Assertions**:
- returns requirement with satisfied true
- returns requirement with score 1.0
- returns requirement with empty details map
- returns requirement with empty errors list

### error/1

Creates a failing requirement result with the given errors.

```elixir
@spec error([String.t()]) :: t()
```

**Process**:
1. Create new Requirement struct
2. Set satisfied to false
3. Set score to 0.0
4. Store errors list in details map
5. Return requirement

**Test Assertions**:
- returns requirement with satisfied false
- returns requirement with score 0.0
- stores errors in details map
- accepts list of error strings
- handles empty error list

### partial/2

Creates a requirement result with a custom score and errors for partial satisfaction scenarios.

```elixir
@spec partial(float(), [String.t()]) :: t()
```

**Process**:
1. Validate score is between 0.0 and 1.0
2. Create new Requirement struct
3. Set satisfied based on score threshold (e.g., >= 0.7)
4. Set score to provided value
5. Store errors list in details map
6. Return requirement

**Test Assertions**:
- accepts valid score between 0.0 and 1.0
- rejects score less than 0.0
- rejects score greater than 1.0
- sets satisfied true when score >= threshold
- sets satisfied false when score < threshold
- stores errors in details map
- stores score value correctly

### from_spec/2

Creates a requirement instance from a RequirementDefinition template with computed satisfaction status.

```elixir
@spec from_spec(RequirementDefinition.t(), Component.t()) :: t()
```

**Process**:
1. Extract checker module from requirement_definition
2. Call checker.check/3 with requirement_definition, component, and opts
3. Extract score from check result (defaults to 1.0 if satisfied, 0.0 if not satisfied)
4. Determine satisfied by comparing score to requirement_definition.threshold (score >= threshold)
5. Convert requirement name atom to string
6. Build Requirement struct with fields from requirement_definition (artifact_type, description, checker, satisfied_by)
7. Set satisfied based on score threshold comparison
8. Set score from check result
9. Set checked_at to current UTC time
10. Set details from check result
11. Return new Requirement struct

**Test Assertions**:
- creates requirement from definition with satisfied true when score >= threshold
- creates requirement from definition with satisfied false when score < threshold
- uses threshold from requirement definition
- sets satisfied true when score equals threshold
- sets satisfied false when score is below threshold
- includes score from checker result
- defaults score to 1.0 when checker returns satisfied without score
- defaults score to 0.0 when checker returns not satisfied without score
- sets checked_at to current time
- copies artifact_type from requirement definition
- copies description from requirement definition
- copies checker module from requirement definition
- copies satisfied_by from requirement definition
- converts name atom to string
- includes check result details in requirement

### changeset/2

Creates a changeset for inserting or updating a requirement.

```elixir
@spec changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast all requirement fields from attrs map (including score and artifact_type)
2. Validate required fields: name, artifact_type, description, checker_module, satisfied
3. Validate score is between 0.0 and 1.0 if provided
4. Apply unique constraint on [component_id, name] combination

**Test Assertions**:
- accepts valid attributes with all required fields
- rejects changeset when name is missing
- rejects changeset when artifact_type is missing
- rejects changeset when description is missing
- rejects changeset when checker_module is missing
- rejects changeset when satisfied is missing
- allows optional satisfied_by field
- allows optional score field
- allows optional checked_at field
- allows optional details field
- validates score is between 0.0 and 1.0
- rejects score less than 0.0
- rejects score greater than 1.0
- validates unique constraint on component_id and name
- accepts valid artifact_type values
- rejects invalid artifact_type values

### update_changeset/2

Creates a changeset for updating requirement satisfaction status and score only.

```elixir
@spec update_changeset(t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast only status-related fields: satisfied, score, checked_at, details
2. Validate required field: satisfied
3. Validate score is between 0.0 and 1.0 if provided
4. Return changeset (does not modify name, artifact_type, description, or checker fields)

**Test Assertions**:
- accepts valid satisfied status update
- accepts satisfied with score update
- accepts satisfied with checked_at update
- accepts satisfied with details update
- accepts satisfied with score, checked_at, and details
- validates score is between 0.0 and 1.0
- rejects score less than 0.0
- rejects score greater than 1.0
- rejects update when satisfied is missing
- ignores non-status fields (name, artifact_type, checker_module, description)
- preserves existing requirement attributes

### name_atom/1

Returns the requirement name as an atom for pattern matching against Registry definitions.

```elixir
@spec name_atom(t()) :: atom()
```

**Process**:
1. Extract name string from requirement struct
2. Convert to existing atom using String.to_existing_atom/1
3. Return atom

**Test Assertions**:
- converts string name to atom
- only converts to existing atoms (raises for non-existent atoms)
- works with all standard requirement names
- enables pattern matching in case statements

### checker_module/1

Returns the checker module for requirement validation.

```elixir
@spec checker_module(t()) :: module()
```

**Process**:
1. Extract checker_module string from requirement struct
2. Prepend "Elixir." prefix to module string
3. Convert to existing atom using String.to_existing_atom/1
4. Return module atom

**Test Assertions**:
- converts string module name to module atom
- adds Elixir prefix correctly
- only converts to existing modules (raises for non-existent modules)
- works with all registered checker modules
- returns usable module reference for function calls

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Components.Component
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.CheckerType
- CodeMySpec.Sessions.SessionType
- DateTime
