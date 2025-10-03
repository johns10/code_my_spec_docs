# Context Design Document

## Purpose

Define the embedded schema and validation logic for Phoenix Context design specifications. Context designs describe the interface layer between web applications and domain logic, grouping related functionality and encapsulating access to data and business logic.

## Public API

### Schema Fields

**Core Documentation Fields:**
- `purpose` - High-level description of the context's responsibility
- `entity_ownership` - Entities managed by this context
- `scope_integration` - How other parts of the system interact with this context
- `public_api` - Public functions exposed by the context
- `state_management_strategy` - How state is managed (optional)
- `execution_flow` - How operations flow through the context (optional)

**Structural Fields:**
- `components` - List of component references with module names, descriptions, and optional tables
- `dependencies` - Array of module names this context depends on
- `other_sections` - Map of additional documentation sections

### Functions

**`changeset/3`**
```elixir
def changeset(context_design, attrs, scope \\ nil)
```
Creates a changeset with validation. When `scope` is provided, validates that referenced components exist in that scope.

**`parse_component_string/1`**
```elixir
def parse_component_string(component_string) :: {:ok, map()} | {:error, :invalid_format}
```
Parses "ModuleName: Description" format into component reference map.

**`parse_dependency_string/1`**
```elixir
def parse_dependency_string(dependency_string) :: {:ok, map()} | {:error, :invalid_format}
```
Parses dependency strings with optional descriptions.

**`required_fields/0`**
Returns list of required field atoms.

**`overview/0`**
Returns overview text for UI/documentation purposes.

**`field_descriptions/0`**
Returns map of field descriptions from FieldDescriptionRegistry.

## Execution Flow

### Validation Pipeline

1. **Cast attributes** - Convert input map to schema fields
2. **Basic validation** - Check required fields
3. **Cast embedded components** - Validate nested component references
4. **Validate dependencies** - Ensure dependency names are valid Elixir module names
5. **Optional component existence check** - When scope provided, verify components exist

### Component Validation

ComponentRef changesets validate:
- Module name format (must be valid Elixir module name)
- Module name must include a period, because the module must include the parent component (context) and be fully qualified
- Description presence and length (1-1500 chars)
- Module name length (1-255 chars)

### Dependency Validation

Dependencies must be:
- Binary strings
- Valid Elixir module name format (start with capital, alphanumeric with dots/underscores)

## Components

### ComponentRef (Embedded Schema)

| Field       | Type   | Required | Description                         |
| ----------- | ------ | -------- | ----------------------------------- |
| module_name | string | Yes      | Fully qualified module name         |
| description | string | Yes      | Component's responsibility          |
| table       | map    | No       | Structured data about the component |

## Dependencies

- `Ecto.Schema` - Schema definition
- `Ecto.Changeset` - Validation and casting
- `CodeMySpec.Documents.FieldDescriptionRegistry` - Field documentation
- `CodeMySpec.Documents.DocumentBehaviour` - Behavior implementation
- `CodeMySpec.Components.get_component_by_module_name/2` - Component existence validation (when scope provided)

## Current Design Decisions

1. **Inline ComponentRef** - ComponentRef is defined as an inline embedded schema rather than a separate module since it's tightly coupled to ContextDesign and not reused elsewhere.

2. **Optional Scope Validation** - Component existence validation is optional (requires scope parameter) to support both draft/import workflows and strict validation in production contexts.

3. **Flexible Other Sections** - The `other_sections` map allows capturing arbitrary documentation sections without schema changes, supporting evolving documentation needs.

4. **Module Name Validation** - Uses regex `~r/^[A-Z][a-zA-Z0-9_.]*$/` to ensure valid Elixir module names, preventing runtime errors from malformed references.

5. **Parser Separation** - Parser logic lives in ContextDesignParser to separate parsing concerns from data validation, though this may be reconsidered for future consolidation.

## Known Issues & Future Considerations

1. **Parser Integration** - Currently uses separate ContextDesignParser module. Consider consolidating parser logic into this module as a protocol implementation or behavior callback.

2. **Table Structure** - Component tables are stored as generic maps with no validation. Consider adding schema validation for common table patterns.

3. **Dependency Descriptions** - Dependencies are stored as simple string arrays, losing any description information parsed by `parse_dependency_string/1`. Consider using embedded schema for richer dependency data.

4. **Validation Context** - Component existence validation requires passing scope through multiple layers. Consider alternative approaches for context-aware validation.