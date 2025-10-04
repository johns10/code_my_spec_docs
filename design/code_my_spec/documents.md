---
component_type: "context"
session_type: "design"
---

# Documents Context

## Overview
The Documents context provides the public API for creating and managing design documents from markdown content. It serves as the central orchestration point for parsing markdown specifications and converting them into validated document structures.

## Scope
This context operates without scope parameters as it deals with document creation from markdown content rather than persisted data access.

## Public API

### Document Creation

#### create_component_document/3
Creates a document from markdown content based on component type.

**Parameters:**
- `markdown_content` (String.t()) - The markdown string to parse
- `component_type` (atom()) - Component type (`:context`, `:coordination_context`, `:schema`, etc.)
- `scope` (struct() | nil) - Optional scope for validation (default: nil)

**Returns:**
- `{:ok, document}` - Successfully created document struct
- `{:error, changeset}` - Validation or parsing errors

**Behavior:**
- Routes to appropriate document module based on component type
- Delegates markdown parsing to type-specific parser
- Validates parsed attributes through document changeset
- Returns validated embedded schema or error changeset

### Type Resolution

#### get_document_module_for_component_type/1
Determines the appropriate document module for a component type.

**Parameters:**
- `component_type` (atom()) - The component type to resolve

**Returns:**
- Module name for the corresponding document type

**Behavior:**
- Central source of truth for component type ’ document type mapping
- Returns default ComponentDesign module for unmapped types
- Supports context, coordination_context, and schema types

## Component Type Mapping

The context maintains the authoritative mapping:
- `:context` ’ `ContextDesign`
- `:coordination_context` ’ `ContextDesign`
- `:schema` ’ `SchemaComponentDesign`
- Default ’ `ComponentDesign`

## Dependencies

### Document Modules
- `CodeMySpec.Documents.ComponentDesign` - Default document type
- `CodeMySpec.Documents.ContextDesign` - Context-specific documents
- `CodeMySpec.Documents.SchemaComponentDesign` - Schema-specific documents

### Parser Modules
Each document type requires a corresponding parser module following the convention:
`DocumentModule` + `"Parser"` (e.g., `ContextDesignParser`)

## Error Handling

All errors are returned as `{:error, changeset}` tuples:
- Parser errors are wrapped in changesets with document-level errors
- Validation errors return the failing changeset directly
- Missing parser errors include descriptive messages

## Integration Points

This context is used by:
- Session orchestrators for document creation during design sessions
- Validation workflows requiring document structure verification
- Any component requiring markdown-to-document conversion
