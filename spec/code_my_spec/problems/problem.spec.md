# CodeMySpec.Problems.Problem

**Type**: schema

Schema representing a normalized problem from any analysis or testing tool. Supports both ephemeral (in-memory) usage during sessions and persistent storage for project-level fitness tracking.

## Dependencies

- Ecto.Schema
- Ecto.Changeset

## Fields

| Field       | Type    | Required   | Description                                 | Constraints                                         |
| ----------- | ------- | ---------- | ------------------------------------------- | --------------------------------------------------- |
| id          | integer | Yes (auto) | Primary key                                 | Auto-generated                                      |
| severity    | enum    | Yes        | Problem severity level                      | Values: :error, :warning, :info                     |
| source_type | enum    | Yes        | Category of tool that generated the problem | Values: :static_analysis, :test, :runtime           |
| source      | string  | Yes        | Specific tool name                          | Examples: "credo", "dialyzer", "exunit", "boundary" |
| file_path   | string  | Yes        | Path to file where problem was found        | Relative to project root                            |
| line        | integer | No         | Line number where problem occurs            | Null for file-level problems                        |
| message     | text    | Yes        | Human-readable description of the problem   | No length limit                                     |
| category    | string  | Yes        | Problem classification                      | Examples: "style", "type", "architecture", "test"   |
| rule        | string  | No         | Specific rule/check identifier              | Tool-specific identifier                            |
| metadata    | map     | No         | Additional tool-specific data               | JSON object for extensibility                       |
| project_id  | integer | Yes        | Foreign key to projects table               | References projects.id                              |
| inserted_at | utc_dt  | Yes (auto) | Record creation timestamp                   | Auto-generated                                      |
| updated_at  | utc_dt  | Yes (auto) | Record update timestamp                     | Auto-generated                                      |