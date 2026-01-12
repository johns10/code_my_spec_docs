# CodeMySpec.Documents.MarkdownParser

**Type**: other

Generic markdown parser that extracts H2 sections into a map with support for pluggable convention-based section parsers.

## Delegates

None

## Functions

### parse/1

Parses markdown content into a map of section names to content. H2 headings become section keys (lowercased), and all content between H2 headings becomes the section value. Sections with matching parsers are parsed into structured data; others are extracted as plain text.

```elixir
@spec parse(String.t()) :: {:ok, map()} | {:error, String.t()}
```

**Process**:
1. Parse markdown content using Earmark.Parser.as_ast/1
2. If parsing fails, return error tuple with failure message
3. Reduce over AST nodes to extract sections:
   - Skip H1 headings (finalize previous section if any)
   - Use H2 headings as section keys (lowercased, trimmed)
   - Accumulate content between H2 headings
4. For each section, look up a convention-based parser by section name
5. If parser exists, call parser_module.from_ast/1 on section content
6. If no parser exists, fall back to text extraction
7. Return {:ok, sections_map}

**Test Assertions**:
- extracts H2 sections into map with section names as keys
- lowercases section keys
- extracts content between H2 headings
- skips H1 heading
- handles empty sections
- returns error for invalid markdown
- uses FunctionParser for 'functions' section
- uses FieldParser for 'fields' section
- handles multiple functions in functions section
- falls back to text for sections without parsers
- handles mixed sections with and without parsers
- extracts ordered lists as formatted text
- parses dependencies from unordered lists
- parses components into SpecComponent structs
- handles code blocks within sections
- handles markdown with only H1
- handles empty markdown
- handles multiple paragraphs in a section
- trims whitespace from section content
- parses complete spec document with functions and delegates
- parses schema spec with fields

## Dependencies

- Earmark.Parser
- Inflex
- CodeMySpec.Documents.Parsers.FunctionParser
- CodeMySpec.Documents.Parsers.FieldParser
- CodeMySpec.Documents.Parsers.ComponentParser
- CodeMySpec.Documents.Parsers.DependencyParser