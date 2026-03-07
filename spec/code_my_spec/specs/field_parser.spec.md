# CodeMySpec.Specs.FieldParser

## Type

logic

Parse Fields section table AST into Field embedded schema structs.

## Functions

### from_ast/1

```elixir
@spec from_ast(ast :: list()) :: [Field.t()]
```

Parse Fields section table into Field structs.

**Process**:
1. Find table element in AST
2. Extract headers from thead (Field, Type, Required, Description, Constraints)
3. Extract data rows from tbody
4. For each row, map columns to Field struct attributes using headers
5. Return list of Field structs

**Test Assertions**:
- from_ast/1 extracts table headers from thead
- from_ast/1 parses each tbody row into Field struct
- from_ast/1 maps column values to correct field attributes
- from_ast/1 handles tables with all columns
- from_ast/1 handles tables with missing optional columns
- from_ast/1 returns empty list for empty tbody
- from_ast/1 returns empty list when no table found in AST