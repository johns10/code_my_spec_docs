---
component_type: "context"
session_type: "design"
---

# Documents Context

## Overview
The Documents context provides the public API for creating and validating design documents from markdown content. It parses markdown specifications into structured section maps and validates them against component type requirements defined in the Components.Registry.

## Scope
This context operates without scope parameters as it deals with document creation from markdown content rather than persisted data access.

## Public API

### create_context_document/2
Creates a context design document with full Ecto validation.

**Parameters:**
- `markdown_content` (String.t()) - The markdown string to parse
- `scope` (struct()) - Scope for validating component references

**Returns:**
- `{:ok, %ContextDesign{}}` - Successfully validated Ecto schema
- `{:error, %Ecto.Changeset{}}` - Validation errors

**Behavior:**
- Parses markdown using ContextDesignParser
- Validates through ContextDesign Ecto schema
- Performs scope-based component existence validation
- Returns structured Ecto schema or changeset with errors

### create_dynamic_document/3
Creates a document by validating sections against provided requirements.

**Parameters:**
- `markdown_content` (String.t()) - The markdown string to parse
- `required_sections` (list(String.t())) - List of required section names (e.g., ["purpose", "fields"])
- `opts` (keyword()) - Optional keyword list
  - `:type` - Component type atom to include in result (default: nil)

**Returns:**
- `{:ok, document}` - Map: `%{sections: %{string() => string()}}` (includes `:type` key if provided in opts)
- `{:error, reason}` - String describing error

**Behavior:**
- Parses markdown into sections using MarkdownParser (H2 headings → map keys)
- Validates all required sections present in parsed sections
- Returns map containing all sections (required + any additional sections found)

## Architecture

### Context Documents
Use `create_context_document/2` for context and coordination_context types.
- Ecto embedded schema (ContextDesign) with complex validations
- Embedded components list with module name format validation
- Scope-based component existence checking
- Dependency validation
- Returns structured Ecto schema required for downstream orchestration

### Dynamic Documents
Use `create_dynamic_document/3` for all other component types.
- Simple section map validation
- Caller provides required sections list
- Document structure: `%{sections: %{section_name => content}}` (plus optional `:type` key)
- Lightweight validation - just checks required sections exist
- No dependencies on Components context - caller is responsible for section requirements

## Dependencies

### Internal
- `CodeMySpec.Documents.MarkdownParser` - Parses markdown into section maps
- `CodeMySpec.Documents.ContextDesign` - Ecto schema for context document validation
- `CodeMySpec.Documents.ContextDesignParser` - Parser for context-specific markdown

### External
- `Earmark.Parser` - AST parsing for markdown content

## Validation Rules

### create_dynamic_document/3
1. Parse markdown into sections (H2 headings → section keys)
2. Verify all required sections present in parsed sections
3. Return success with full section map (all sections found in markdown)

### create_context_document/2
1. Parse markdown into sections using ContextDesignParser
2. Map sections to ContextDesign schema fields
3. Apply Ecto changeset validation:
   - Required fields present
   - Embedded components: module name format, fully-qualified validation
   - Dependencies: valid module name format
   - Scope validation: referenced components exist in scope
4. Return validated Ecto struct or changeset with detailed errors

## Error Handling

### create_dynamic_document/3
- Markdown parsing errors: `{:error, "Failed to parse markdown: #{reason}"}`
- Missing sections: `{:error, "Missing required sections: #{list}"}`

### create_context_document/2
- Returns `{:error, %Ecto.Changeset{}}` with field-level validation errors
- Preserves Ecto's error structure for downstream handling

## Integration Points

This context is used by:
- Session orchestrators for document creation during design sessions
- Component validation workflows requiring document structure verification
- Any component requiring markdown-to-structured-data conversion

## Future Extensibility

To add a new component type:
1. Define required sections in the calling context (e.g., Components.Registry)
2. Call `create_dynamic_document/3` with the required sections list
3. No code changes required in Documents context
