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

## Dependencies

- Ecto.Schema
- Ecto.Changeset
- CodeMySpec.Projects.Project
