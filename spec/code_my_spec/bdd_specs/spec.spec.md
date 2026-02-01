# CodeMySpec.BddSpecs.Spec

**Type**: schema (non-persisted)

Struct representing a parsed BDD specification file. Contains metadata about the spec including its name, source file path, and parsed scenarios. Optionally links to story and criterion IDs derived from file naming conventions. Used as the primary data structure for spec analysis and rendering.

## Fields

| Field        | Type              | Required   | Description                                      | Constraints                               |
| ------------ | ----------------- | ---------- | ------------------------------------------------ | ----------------------------------------- |
| name         | string            | Yes        | Name of the spec from the spex macro            |                                           |
| description  | string            | No         | Optional description from spex metadata          |                                           |
| file_path    | string            | Yes        | Absolute path to the source .exs file            |                                           |
| story_id     | integer           | No         | Story ID extracted from directory naming pattern | Derived from `{story_id}_*/` directory    |
| criterion_id | integer           | No         | Criterion ID from filename pattern               | Derived from `criterion_{id}_spex.exs`    |
| tags         | list(atom)        | No         | Tags from spex metadata                          | Default: empty list                       |
| scenarios    | list(Scenario.t)  | Yes        | List of parsed scenario structs                  | Default: empty list                       |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.BddSpecs.Scenario

## Functions

### changeset/2

Builds a changeset for creating or validating a Spec struct with the given attributes.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast name, description, file_path, story_id, criterion_id, tags, and scenarios from the input map
2. Validate that name and file_path are required
3. Cast embedded scenarios using Scenario.changeset/2

**Test Assertions**:
- returns valid changeset when name and file_path are provided
- returns invalid changeset when name is missing
- returns invalid changeset when file_path is missing
- allows nil for description, story_id, criterion_id
- casts scenarios as embedded schemas
- sets default empty list for tags when not provided
- sets default empty list for scenarios when not provided

### new/1

Constructs a new Spec struct from parsed attributes.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Apply changeset/2 with the provided attributes
2. Extract and return the data from the changeset if valid
3. Raise if changeset is invalid

**Test Assertions**:
- returns Spec struct with all fields populated
- raises when required fields are missing
- populates scenarios list from nested scenario data
- defaults tags to empty list when not provided
