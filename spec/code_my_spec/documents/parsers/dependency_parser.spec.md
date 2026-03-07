# CodeMySpec.Documents.Parsers.DependencyParser

## Type

other

Parse Dependencies section AST into a list of module name strings.

This module extracts dependency module names from markdown list AST structures (both unordered and ordered lists). It recursively extracts text content from list items, handling nested inline formatting elements like strong, em, and code tags.

## Dependencies

(none)

## Functions

### from_ast/1

Parse a markdown AST containing a dependencies list and return a list of module name strings.

```elixir
@spec from_ast(list()) :: [String.t()]
```

**Process**:
1. Traverse the AST looking for unordered list (ul) or ordered list (ol) elements
2. For each list found, extract list item (li) elements
3. For each list item, recursively extract text content using `extract_text/1`
4. Handle nested formatting tags (strong, em, code) by extracting their text content
5. Join multiple text elements with spaces and trim whitespace
6. Filter out empty strings from the result
7. Return flat list of module name strings

**Test Assertions**:
- returns empty list for empty AST
- extracts module names from unordered list
- extracts module names from ordered list
- handles nested strong tags within list items
- handles nested em tags within list items
- handles nested code tags within list items
- handles mixed text and inline elements
- filters out empty list items
- trims whitespace from extracted text
- ignores non-list elements in AST
