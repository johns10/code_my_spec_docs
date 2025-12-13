# CodeMySpec.Specs.FunctionParser

**Type**: logic

Parse Functions section AST into Function embedded schema structs.

## Functions

### from_ast/1

```elixir
@spec from_ast(ast :: list()) :: [Function.t()]
```

Parse Functions section AST into Function structs.

**Process**:
1. Group AST by H3 headers (function names with arity like "build/1")
2. For each function group:
   - Extract function name from H3
   - Find first paragraph as description
   - Find elixir code block as spec (extract code content, not metadata)
   - Find **Process**: bold header and extract following content as process
   - Find **Test Assertions**: bold header and extract list items as test assertions
3. Return list of Function structs

**Test Assertions**:
- from_ast/1 extracts function name from H3
- from_ast/1 extracts description from paragraph
- from_ast/1 extracts spec from elixir code block
- from_ast/1 extracts process steps from **Process**: section
- from_ast/1 extracts test assertions list from **Test Assertions**: section
- from_ast/1 handles functions with missing optional fields
- from_ast/1 handles multiple functions in single AST
- from_ast/1 returns empty list for empty AST