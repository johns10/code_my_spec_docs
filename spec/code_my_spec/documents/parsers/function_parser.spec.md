# CodeMySpec.Documents.Parsers.FunctionParser

## Type

other

Parse Functions section AST into Function embedded schema structs.

This module transforms parsed HTML AST (from spec documents) into structured Function schemas. It groups content by H3 headers representing function signatures, then extracts description, typespec, process steps, and test assertions from each function's content block.

## Functions

### from_ast/1

Parse an AST list representing a Functions section into a list of Function structs.

```elixir
@spec from_ast(list()) :: [Function.t()]
```

**Process**:
1. Group AST elements by H3 headers using reduce, where each H3 starts a new function block
2. Reverse the accumulated functions and their content to maintain document order
3. For each grouped function, parse into a Function struct by extracting:
   - Name from the H3 header text (trimmed)
   - Description from the first paragraph that doesn't start with bold text
   - Typespec from elixir-class code blocks within pre elements
   - Process steps from ordered/unordered list content following **Process**: marker
   - Test assertions from list items following **Test Assertions**: marker
4. Load extracted attributes into Function embedded schema via Ecto.embedded_load/3 with :json loader

**Test Assertions**:
- from_ast/1 extracts function name from H3
- from_ast/1 extracts description from paragraph
- from_ast/1 extracts spec from elixir code block
- from_ast/1 extracts process steps from **Process**: section
- from_ast/1 extracts test assertions list from **Test Assertions**: section
- from_ast/1 handles functions with missing optional fields
- from_ast/1 handles multiple functions in single AST
- from_ast/1 returns empty list for empty AST
- from_ast/1 extracts complete function with all fields

## Dependencies

- CodeMySpec.Documents.Function
