# CodeMySpec.Issues.Issue

## Type

schema

Ecto schema representing a QA issue or braindump item. Issues track defects, improvements, and observations discovered during QA testing or captured from braindump files. Each issue has a severity-based lifecycle (incoming → accepted/dismissed → resolved) and is scoped to an account and project. Issues can be linked to a specific story via story_id.

## Fields

| Field        | Type                                                    | Required   | Description                                 | Constraints                              |
| ------------ | ------------------------------------------------------- | ---------- | ------------------------------------------- | ---------------------------------------- |
| id           | binary_id                                               | Yes (auto) | Primary key (UUID)                          | Auto-generated                           |
| title        | string                                                  | Yes        | Short title describing the issue            | Unique per project + story_id            |
| severity     | enum (:critical, :high, :medium, :low, :info)           | Yes        | Impact severity                             |                                          |
| scope        | enum (:app, :qa, :docs)                                 | No         | Area of the codebase affected               | Default: :app                            |
| description  | string                                                  | Yes        | Detailed description with reproduction info |                                          |
| status       | enum (:incoming, :accepted, :dismissed, :resolved)      | Yes        | Lifecycle status                            | Default: :incoming                       |
| resolution   | string                                                  | No         | Reason for dismissal or description of fix  |                                          |
| story_id     | integer                                                 | No         | Associated story ID                         |                                          |
| source_path  | string                                                  | No         | Path to the artifact that created this issue |                                         |
| project_id   | binary_id                                               | Yes        | Associated project identifier               |                                          |
| account_id   | binary_id                                               | Yes        | Associated account identifier               |                                          |
| inserted_at  | utc_datetime                                            | Yes (auto) | Creation timestamp                          | Auto-generated                           |
| updated_at   | utc_datetime                                            | Yes (auto) | Last update timestamp                       | Auto-generated                           |

## Dependencies

- Ecto.Schema
- Ecto.Changeset
