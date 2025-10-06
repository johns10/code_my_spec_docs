# MetaDataParser

## Purpose

Parses sidecar `.yaml` files to extract structured metadata for content files. Returns success tuples with parsed metadata maps or error tuples with details when files are missing, contain invalid YAML syntax, or have malformed structure.

**Note:** MetaDataParser returns error tuples `{:error, reason}` unlike processors which always return `{:ok, result}`. The Sync component handles these errors by wrapping them in ProcessorResult format.

## Public API

```elixir
# Metadata Parsing
@spec parse_metadata_file(file_path :: String.t()) :: {:ok, metadata()} | {:error, error_detail()}

# Type Definitions
@type metadata :: %{
  required(:title) => String.t(),
  required(:slug) => String.t(),
  required(:type) => String.t(),
  optional(:publish_at) => DateTime.t() | String.t(),
  optional(:expires_at) => DateTime.t() | String.t(),
  optional(:meta_title) => String.t(),
  optional(:meta_description) => String.t(),
  optional(:og_image) => String.t(),
  optional(:og_title) => String.t(),
  optional(:og_description) => String.t(),
  optional(:tags) => [String.t()],
  optional(:protected) => boolean(),
  optional(String.t()) => any()
}

@type error_detail :: %{
  type: :file_not_found | :yaml_parse_error | :invalid_structure,
  message: String.t(),
  file_path: String.t(),
  details: any()
}
```

## Execution Flow

### Successful Metadata Parse

1. **File Reading**: Read file contents from filesystem using `File.read/1`
2. **YAML Parsing**: Parse YAML using `YamlElixir.read_from_string/1`
3. **Structure Validation**: Verify result is a map with required keys (:title, :slug, :type)
4. **Metadata Return**: Return `{:ok, metadata_map}` with string keys converted to atoms

### Error Handling Flows

#### File Not Found
1. **File Read**: `File.read/1` returns `{:error, :enoent}`
2. **Error Return**: `{:error, %{type: :file_not_found, message: "Metadata file not found", file_path: path, details: nil}}`

#### YAML Parse Error
1. **Parse Attempt**: `YamlElixir.read_from_string/1` returns error tuple
2. **Error Return**: `{:error, %{type: :yaml_parse_error, message: "Invalid YAML syntax", file_path: path, details: error}}`

#### Invalid Structure
1. **Parse Success**: YAML parses but result is not a map
2. **Validation Failure**: Missing required keys or wrong data types
3. **Error Return**: `{:error, %{type: :invalid_structure, message: "Metadata must be a map with required keys", file_path: path, details: result}}`

## Implementation Notes

### File Location Convention

Metadata files follow strict naming convention:
- Content file: `content/posts/my-post.md` → Metadata: `content/posts/my-post.yaml`
- Content file: `content/components/button.heex` → Metadata: `content/components/button.yaml`
- Content file: `content/pages/about.html` → Metadata: `content/pages/about.yaml`

Pattern: Replace content extension with `.yaml`.

### Example Metadata File

```yaml
# content/posts/introducing-elixir.yaml
title: "Introducing Elixir to Your Team"
slug: "introducing-elixir"
type: "blog"
publish_at: "2025-01-15T10:00:00Z"
expires_at: null
meta_title: "Introducing Elixir to Your Team - Best Practices"
meta_description: "Learn how to successfully introduce Elixir to your development team"
og_image: "/images/elixir-team.jpg"
tags:
  - elixir
  - team
  - best-practices
protected: false
```

### DateTime Handling

YAML datetime strings (ISO 8601 format) should be parsed to DateTime structs:
- Accept both DateTime structs and ISO 8601 strings in YAML
- Convert string datetime values to DateTime using `DateTime.from_iso8601/1`
- Handle parsing errors gracefully, including them in error details

### Safety Considerations

**YAML is safe for untrusted content:**
- Pure data format with no code execution
- YamlElixir library safely parses structured data only
- No risk of arbitrary code injection
- Suitable for user-submitted or Git-sourced content

### Error Recovery Strategy

MetaDataParser uses error tuples exclusively - no exception rescuing. All file operations and parsing use functions that return `{:ok, result}` or `{:error, reason}` tuples. This allows ContentSync to:
- Continue processing other files when one file fails
- Store error details in the `parse_errors` field
- Complete the sync operation without aborting the transaction

### Key Conversion

YAML parsers typically return string keys. The parser should:
- Convert string keys to atoms for required/known fields
- Keep unknown keys as strings to prevent atom exhaustion
- Provide consistent map structure for downstream processors