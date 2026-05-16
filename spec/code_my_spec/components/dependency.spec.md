# CodeMySpec.Components.Dependency

Ecto schema representing a directed dependency relationship between two components.
Models "source depends on target" semantics where the source component requires
the target component to function.

## Fields

| Field               | Type       | Required   | Description                      | Constraints                   |
| ------------------- | ---------- | ---------- | -------------------------------- | ----------------------------- |
| id                  | integer    | Yes (auto) | Primary key                      | Auto-generated                |
| source_component_id | binary_id  | Yes        | Component that has the dependency | References components.id      |
| target_component_id | binary_id  | Yes        | Component being depended upon    | References components.id      |
| inserted_at         | utc_datetime | Yes (auto) | Creation timestamp             | Auto-generated                |
| updated_at          | utc_datetime | Yes (auto) | Last update timestamp          | Auto-generated                |

## Dependencies

- CodeMySpec.Components.Component
