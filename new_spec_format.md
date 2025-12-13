# Spec Format Template

This document defines the standard sections for writing specs in the `spec/` directory.

Remember, humans will be consuming the specs.
They have small context windows and short attention spans.
Specs should be kept short and to the point. 
Focus on what the module does, not how it does it. 
You shouldn't add sections that aren't specified.

## Title

Title should be H1, and be the fully qualified module name of the components.

Includes a type field, indicating the type of the module.

Body text should be a brief description of what this module does.

```markdown
# CodeMySpec.Contexts.DependencyTree

**Type**: logic

Build nested dependency trees for components by processing them in optimal order using topological sorting.
```

## Delegates

Title should be H2.

List of all functions the module delegates. 

Sample:

```markdown
- list_components/1: Components.ComponentRepository.list_components/1
- get_component/2: Components.ComponentRepository.get_component/2
- ...
```

## Functions

Title should be H2.

List of all PUBLIC functions the module exposes. Does NOT document private functions.

Each function header should be h3, and include be in `{function_name}/{arity}` format.

First there should be a description of what the function does.

Second there should be a markdown block with the function spec.

Third should be a process section that describes what the function should do in order.

Fourth should be a list of test assertions.

Sample:

### build/1

Apply dependency tree processing to all components.
```elixir
@spec build([Component.t()]) :: [Component.t()]
```

**Process**:
1. Topologically sort components to process dependencies first
2. Reduce over sorted components, building a map of processed components
3. For each component, replace flat dependencies with nested versions from processed map
4. Return all processed components sorted by ID

**Test Assertions**:
- build/1 returns empty list for empty input
- build/1 processes components in dependency order

## Dependencies

List of dependencies.

```markdown
- other_module.spec.md
```

## Fields

Only applies to schemas and structs.

Sample:

```markdown
| Field       | Type         | Required   | Description           | Constraints         |
| ----------- | ------------ | ---------- | --------------------- | ------------------- |
| id          | integer      | Yes (auto) | Primary key           | Auto-generated      |
| name        | string       | Yes        | Name field            | Min: 1, Max: 255    |
| foreign_id  | integer      | Yes        | Foreign key           | References table.id |
| association | Association  | No         | Association field     |                     |
| inserted_at | utc_datetime | Yes (auto) | Creation timestamp    | Auto-generated      |
| updated_at  | utc_datetime | Yes (auto) | Last update timestamp | Auto-generated      |
```
