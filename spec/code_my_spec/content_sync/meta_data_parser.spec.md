# CodeMySpec.ContentSync.MetaDataParser

Parses sidecar YAML files to extract structured metadata for content files.

Reads YAML metadata files and validates they contain required fields (title, slug, type).
Returns success tuples with parsed metadata maps using atom keys for known fields, or
error tuples with detailed error information for missing files, invalid YAML syntax, or
malformed structure. Unknown fields are preserved with string keys.

## Dependencies

- YamlElixir
