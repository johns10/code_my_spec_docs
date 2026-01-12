# CodeMySpec.Documents.Registry

**Type**: other

Central registry for document type definitions including section requirements,
descriptions, and specifications used for AI-generated design documents.

## Functions

### get_definition/1

Retrieves the document definition for a given component type. Returns a map containing
the overview, required sections, optional sections, allowed additional sections, and
section descriptions for generating specification documents.

```elixir
@spec get_definition(String.t()) :: document_definition()
```

**Process**:
1. Accept a component type string (e.g., "spec", "schema", "context_spec", "dynamic_document")
2. Look up the component type in the document definitions map
3. Return the matching definition if found, otherwise return the default spec definition

**Test Assertions**:
- returns default spec definition for unknown component types
- returns schema definition for "schema" component type
- returns context_spec definition for "context_spec" component type
- returns dynamic_document definition for "dynamic_document" component type
- returns spec definition for "spec" component type
- default definition includes required sections with delegates or functions, and dependencies
- schema definition requires fields section
- context_spec definition requires components section
- dynamic_document allows any additional sections with "*" wildcard
- all definitions include section_descriptions map for applicable sections

## Dependencies

- CodeMySpec.Components.ComponentType