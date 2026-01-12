# CodeMySpec.Documents

**Type**: context

Context for managing document parsing, validation, and creation from markdown content. Provides a centralized registry for document type definitions, convention-based section parsers, and validation against structured document schemas. Documents are parsed into structured data with type-specific schemas for functions, fields, and components.

## Functions

### create_dynamic_document/2

Creates and validates a document from markdown content against a document type definition.

```elixir
@spec create_dynamic_document(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Look up document definition from Registry using document_type
2. Parse markdown content using MarkdownParser
3. Validate required sections are present (supports OR logic for alternative sections)
4. Validate no disallowed additional sections exist (unless wildcard allowed)
5. Return document map with sections and type, or error on validation failure

**Test Assertions**:
- returns {:ok, document} with parsed sections for valid markdown
- returns {:error, reason} when required sections are missing
- supports OR logic for alternative required sections (e.g., "delegates OR functions")
- returns {:error, reason} when disallowed sections are present
- allows any sections when allowed_additional_sections is "*"
- parses sections using convention-based parsers (functions -> FunctionParser, fields -> FieldParser)

## Components

### CodeMySpec.Documents.Registry

Central registry for document type definitions including section requirements, descriptions, and specifications used for AI-generated design documents. Provides definitions for spec, schema, context_spec, and dynamic_document types with their required/optional sections and section descriptions.

### CodeMySpec.Documents.MarkdownParser

Generic markdown parser that extracts H2 sections into a map. Supports pluggable section parsers via convention where section name maps to parser module (e.g., "functions" -> FunctionParser). Falls back to text extraction when no parser exists.

### CodeMySpec.Documents.DocumentSpecProjector

Projects document definitions from Registry into markdown specifications for AI-generated design documents. Generates formatted markdown with required and optional section documentation.

### CodeMySpec.Documents.Function

Embedded schema representing a function from a spec document. Contains name, description, spec, process, and test_assertions fields for structured function documentation.

### CodeMySpec.Documents.Field

Embedded schema representing a schema field. Contains field name, type, required status, description, and constraints for structured field documentation.

### CodeMySpec.Documents.SpecComponent

Embedded schema representing a component reference from a context design document. Contains module_name and description for components listed in the Components section.

### CodeMySpec.Documents.Parsers.FunctionParser

Parses Functions section AST into Function embedded schema structs. Extracts function name from H3 headers, description, elixir spec, process steps, and test assertions.

### CodeMySpec.Documents.Parsers.FieldParser

Parses Fields section table AST into Field embedded schema structs. Extracts table headers and data rows to create structured Field schemas.

### CodeMySpec.Documents.Parsers.ComponentParser

Parses Components section AST into SpecComponent structs. Extracts module names from H3 headings and descriptions from paragraph content.

### CodeMySpec.Documents.Parsers.DependencyParser

Parses Dependencies section AST into a list of module name strings. Extracts items from unordered or ordered lists.

## Dependencies

- Earmark
- Inflex
- Ecto