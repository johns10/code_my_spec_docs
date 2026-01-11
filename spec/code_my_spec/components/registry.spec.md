# Components.Registry

Central registry containing all component type-specific metadata and behavior definitions.
Provides the authoritative source for component type characteristics including requirements,
display properties, workflow rules, and validation logic.

## Dependencies

- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.RequirementDefinitionData
- CodeMySpec.Components.Component

## Functions

### get_type/1

Returns the type definition for a given component type, including requirements, display properties, and workflow configuration.

```elixir
@spec get_type(Component.component_type()) :: type_definition()
```

**Return Type**:
```elixir
@type type_definition :: %{
  requirements: [RequirementDefinition.t()],
  display_name: String.t(),
  description: String.t(),
  document_type: String.t(),
  icon: String.t() | nil,
  color: String.t() | nil
}
```

**Process**:
1. Look up the component type in the type definitions map
2. If found, return the type definition with requirements, display_name, description, document_type, icon, and color
3. If not found, return a default definition with unknown display_name and default requirements

**Test Assertions**:
- returns type definition for "genserver" type with GenServer display name
- returns type definition for "context" type with Context display name and context-specific requirements
- returns type definition for "coordination_context" type with context_spec document type
- returns type definition for "schema" type with schema-specific requirements (no test requirements)
- returns type definition for "repository" type with Repository display name
- returns type definition for "task" type with Task display name
- returns type definition for "registry" type with Registry display name
- returns type definition for "behaviour" type with behaviour-specific requirements
- returns type definition for "other" type with Other display name
- returns default type definition with "Unknown" display_name for nil type
- returns default type definition for unrecognized type string
- type definitions include icon and color fields
- context types include review_file and hierarchy requirements
- schema type excludes test_file and tests_passing requirements

### get_requirements_for_type/1

Returns the list of requirement definitions for a given component type.

```elixir
@spec get_requirements_for_type(Component.component_type()) :: [RequirementDefinition.t()]
```

**Process**:
1. Call get_type/1 to retrieve the type definition
2. Extract and return the requirements list from the type definition

**Test Assertions**:
- returns default requirements for "genserver" type
- returns context-specific requirements for "context" type including children_designs and review_file
- returns context-specific requirements for "coordination_context" type
- returns schema-specific requirements for "schema" type (spec_file, schema_spec_valid, implementation_file only)
- returns default requirements for "repository" type
- returns default requirements for "task" type
- returns behaviour-specific requirements for "behaviour" type (no test requirements)
- returns default requirements for unknown types
- all returned requirements are valid RequirementDefinition structs