# CodeMySpec.Problems.Problem

## Type

schema

Schema representing a normalized problem from any analysis or testing tool. Supports both ephemeral (in-memory) usage during sessions and persistent storage for project-level fitness tracking.

## Fields

| Field       | Type         | Required   | Description                                 | Constraints                               |
| ----------- | ------------ | ---------- | ------------------------------------------- | ----------------------------------------- |
| id          | integer      | Yes (auto) | Primary key                                 | Auto-generated                            |
| severity    | enum         | Yes        | Problem severity level                      | Values: :error, :warning, :info           |
| source_type | enum         | Yes        | Category of tool that generated the problem | Values: :static_analysis, :test, :runtime |
| source      | string       | Yes        | Specific tool name (credo, sobelow, etc.)   | Min: 1, Max: 255                          |
| file_path   | string       | Yes        | Path to file where problem was found        | Min: 1                                    |
| line        | integer      | No         | Line number where problem occurs            | Must be > 0 when provided                 |
| message     | string       | Yes        | Human-readable description of the problem   |                                           |
| category    | string       | Yes        | Problem classification (style, type, etc.)  | Min: 1, Max: 255                          |
| rule        | string       | No         | Specific rule/check identifier              |                                           |
| metadata    | map          | No         | Additional tool-specific data               | Default: %{}                              |
| project_id  | binary_id    | Yes        | Foreign key to projects table               | References projects.id                    |
| inserted_at | utc_datetime | Yes (auto) | Record creation timestamp                   | Auto-generated                            |
| updated_at  | utc_datetime | Yes (auto) | Record update timestamp                     | Auto-generated                            |

## Functions

### changeset/2

Builds a changeset for creating or updating a Problem with validation.

```elixir
@spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast all permitted attributes from the input map
2. Validate required fields: severity, source_type, source, file_path, message, category, project_id
3. Validate severity is one of :error, :warning, :info
4. Validate source_type is one of :static_analysis, :test, :runtime
5. Validate source length between 1 and 255 characters
6. Validate file_path has minimum length of 1
7. Validate category length between 1 and 255 characters
8. Validate line number is greater than 0 when provided
9. Add foreign key constraint for project_id

**Test Assertions**:
- accepts valid attributes with all required fields
- accepts problem with optional line number
- accepts problem with optional rule
- accepts problem with optional metadata
- accepts warning severity
- accepts info severity
- accepts test source type
- accepts runtime source type
- uses default source_type when not provided
- accepts nil line number
- accepts nil rule
- accepts nil metadata
- requires severity
- requires source
- requires file_path
- requires message
- requires category
- requires project_id
- rejects invalid severity
- rejects invalid source_type
- rejects nil source 
- rejects source string longer than 255 characters
- rejects nil file_path
- rejects nil category string
- rejects category string longer than 255 characters
- rejects line number less than or equal to zero
- rejects negative line number

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Projects.Project
