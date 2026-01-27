# CodeMySpec.BddSpecs.Parser

**Type**: module

Parses Spex DSL source files into structured Spec data using Elixir AST analysis. Reads spec files, converts to quoted expressions, and walks the AST to extract spex, scenario, given_, when_, and then_ macro calls. Returns Spec structs with all scenarios and steps populated. Does not execute specs - only extracts structure for analysis and rendering.
