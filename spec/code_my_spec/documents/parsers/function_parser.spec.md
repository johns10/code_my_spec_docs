# CodeMySpec.Documents.Parsers.FunctionParser

## Type

other

Parse Functions section AST into Function embedded schema structs.

This module transforms parsed HTML AST (from spec documents) into structured Function schemas. It groups content by H3 headers representing function signatures, then extracts description, typespec, process steps, and test assertions from each function's content block.

## Dependencies

- CodeMySpec.Documents.Function
