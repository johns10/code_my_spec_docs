# CodeMySpec.BddSpecs.Spec

## Type

schema (non-persisted)

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
