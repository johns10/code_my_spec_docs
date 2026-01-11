# CodeMySpec.ContentSync.MetaDataParser

Parses sidecar YAML files to extract structured metadata for content files.

Reads YAML metadata files and validates they contain required fields (title, slug, type).
Returns success tuples with parsed metadata maps using atom keys for known fields, or
error tuples with detailed error information for missing files, invalid YAML syntax, or
malformed structure. Unknown fields are preserved with string keys.

## Dependencies

- YamlElixir

## Functions

### parse_metadata_file/1

Parses a YAML metadata file and returns structured metadata.

```elixir
@spec parse_metadata_file(file_path :: String.t()) ::
        {:ok, metadata()} | {:error, error_detail()}
```

**Process**:
1. Read file contents from the provided file path
2. If file not found, return error tuple with type :file_not_found
3. Parse YAML content using YamlElixir
4. If YAML parsing fails, return error tuple with type :yaml_parse_error
5. Validate parsed content is a map with required keys (title, slug, type)
6. If validation fails, return error tuple with type :invalid_structure
7. Convert known field keys to atoms, preserve unknown fields as string keys
8. Return success tuple with metadata map

**Test Assertions**:
- successfully parses minimal required fields (title, slug, type)
- returns map with atom keys for required fields
- successfully parses all standard fields (meta_title, meta_description, og_image, etc.)
- successfully parses tags as list
- parses datetime strings without conversion
- successfully parses metadata with null values
- allows missing optional fields
- preserves unknown fields in the metadata map
- keeps unknown fields as string keys
- accepts 'blog' content type
- accepts 'page' content type
- accepts 'landing' content type
- accepts custom content types
- parses protected flag as true
- parses protected flag as false
- returns error tuple when file doesn't exist
- returns structured error with all required fields (type, message, file_path, details)
- returns error for malformed YAML with unclosed quote
- accepts YAML with tab characters (YamlElixir is lenient)
- returns error for empty YAML file
- returns error when title is missing
- returns error when slug is missing
- returns error when type is missing
- returns error when all required fields are missing
- returns error when YAML is a list instead of map
- returns error when YAML is a scalar value
- handles very long string values
- handles unicode characters in metadata
- handles multiline string values
- handles empty string values for required fields
- handles special characters in slug
- handles very deeply nested custom fields
- handles empty tags list
- handles large number of tags (100+)
- parses ISO 8601 datetime strings
- handles datetime with timezone offset
- handles date-only strings
- parses metadata file with .yaml extension
- works with absolute file paths
- works with relative file paths
- parsing the same file multiple times returns identical results
- file not found errors have consistent structure
- yaml parse errors have consistent structure
- invalid structure errors have consistent structure
- does not execute code in YAML
- handles potentially malicious strings safely (XSS, SQL injection strings stored as-is)
