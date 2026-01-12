# CodeMySpec.Documents.DocumentSpecProjector

**Type**: other

Projects document definitions from Registry into markdown specifications for AI-generated design documents. Generates formatted markdown with required and optional section documentation.

## Functions

### project_spec/1

Generates a markdown specification document for a given component type by retrieving its definition from the Registry and formatting it into a structured markdown string.

```elixir
@spec project_spec(String.t()) :: String.t()
```

**Process**:
1. Retrieve the document definition from Registry using the component type
2. Format the component type into a human-readable title (snake_case to Title Case)
3. Build the markdown document with:
   - H1 heading with the formatted type name
   - Overview text from the definition
   - Required sections formatted with H3 headings and descriptions
   - Optional sections formatted similarly (or "None" if empty)
4. Return the complete markdown string

**Test Assertions**:
- returns markdown with formatted title from component type
- includes overview from document definition
- formats required sections with H3 headings
- formats optional sections with H3 headings when present
- returns "None" for optional sections when empty
- retrieves definition from Registry for the given type
- handles unknown component types by using default spec definition

## Dependencies

- CodeMySpec.Documents.Registry
