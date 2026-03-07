# CodeMySpec.Specs.SpecParser

## Type

logic

Parse markdown AST into Spec embedded schema structs.

## Functions

### parse/1

```elixir
@spec parse(file_path :: String.t()) :: {:ok, Spec.t()} | {:error, term()}
```

Parse a spec markdown file into a Spec struct.

**Process**:
1. Read the markdown file
2. Parse markdown to AST using Earmark
3. Call from_ast/1 with the AST
4. Return result

**Test Assertions**:
- parse/1 reads file and parses to Spec
- parse/1 returns error for missing file
- parse/1 returns error for invalid markdown

### from_markdown/1

```elixir
@spec from_markdown(markdown_content :: String.t()) :: {:ok, Spec.t()} | {:error, term()}
```

Parse markdown content string into a Spec struct.

**Process**:
1. Parse markdown content to AST using Earmark
2. Call from_ast/1 with the AST
3. Return result

**Test Assertions**:
- from_markdown/1 parses markdown string into Spec
- from_markdown/1 returns error for invalid markdown

### from_ast/1

```elixir
@spec from_ast(ast :: list()) :: {:ok, Spec.t()} | {:error, term()}
```

Parse Earmark AST into a Spec struct.

**Process**:
1. Extract module name from H1 header
2. Extract type from **Type**: bold field after H1
3. Extract description from body text between H1 and first H2
4. Group content by H2 sections (Delegates, Functions, Dependencies, Fields)
5. Parse Delegates section into list of strings
6. Call FunctionParser.from_ast/1 for Functions section
7. Parse Dependencies section into list of strings
8. Call FieldParser.from_ast/1 for Fields section
9. Build and return Spec struct

**Test Assertions**:
- from_ast/1 extracts module name from H1 header
- from_ast/1 extracts type from **Type** field
- from_ast/1 extracts description from body text
- from_ast/1 parses Delegates section into list of strings
- from_ast/1 calls FunctionParser for Functions section
- from_ast/1 parses Dependencies section into list of strings
- from_ast/1 calls FieldParser for Fields section
- from_ast/1 handles missing optional sections gracefully
- from_ast/1 returns error for missing H1 header
- from_ast/1 builds valid Spec struct