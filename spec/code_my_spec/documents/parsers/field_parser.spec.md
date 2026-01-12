# CodeMySpec.Documents.Parsers.FieldParser

**Type**: other

Parse Fields section table AST into Field embedded schema structs.

This module extracts field definitions from markdown table AST structures and converts them into `CodeMySpec.Documents.Field` embedded schema structs. It handles the standard field table format with columns for Field, Type, Required, Description, and Constraints.

## Dependencies

- CodeMySpec.Documents.Field

## Functions

### from_ast/1

Parse a markdown AST containing a fields table and return a list of Field structs.

```elixir
@spec from_ast(list()) :: [Field.t()]
```

**Process**:
1. Search the AST for a table element matching `{"table", _, _, _}`
2. If no table found, return empty list
3. Extract headers from the `thead` section, normalizing to lowercase
4. Extract data rows from the `tbody` section
5. For each data row, zip column values with headers to create a map
6. Normalize the map keys to match Field schema attributes (field, type, required, description, constraints)
7. Load each normalized map into a Field struct using `Ecto.embedded_load/3`

**Test Assertions**:
- extracts table headers from thead
- parses each tbody row into Field struct
- maps column values to correct field attributes
- handles tables with all columns (Field, Type, Required, Description, Constraints)
- handles tables with missing optional columns (description, constraints can be nil)
- returns empty list for empty tbody
- returns empty list when no table found in AST