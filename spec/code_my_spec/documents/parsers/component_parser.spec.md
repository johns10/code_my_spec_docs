# CodeMySpec.Documents.Parsers.ComponentParser

**Type**: other

Parse Components section AST into SpecComponent structs. Extracts module names from H3 headings and descriptions from paragraphs.

## Dependencies

- CodeMySpec.Documents.SpecComponent

## Functions

### from_ast/1

```elixir
@spec from_ast(ast :: list()) :: [SpecComponent.t()]
```

Parse Components section AST into SpecComponent structs.

**Process**:
1. Group AST elements by H3 headers using `group_by_h3/1`
2. For each group, extract module name from H3 header text (trimmed)
3. Accumulate content elements following each H3 until next H3
4. For each grouped component, call `parse_component/1` to build SpecComponent struct
5. Extract description from first paragraph element in content
6. Load attributes into SpecComponent embedded schema using `Ecto.embedded_load/3`
7. Return list of SpecComponent structs

**Test Assertions**:
- from_ast/1 extracts module name from H3 header
- from_ast/1 extracts description from first paragraph following H3
- from_ast/1 handles H3 with trailing whitespace in module name
- from_ast/1 handles multiple components in single AST
- from_ast/1 handles components with no description paragraph
- from_ast/1 returns empty list for empty AST
- from_ast/1 ignores elements before first H3 header
- from_ast/1 extracts text from nested inline elements (strong, em, code)