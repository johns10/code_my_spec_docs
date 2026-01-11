# CodeMySpec.ContentSync.Sync

Agnostic content synchronization pipeline that processes filesystem content into attribute maps.

Accepts a directory path, discovers content files (non-recursive), processes them through
appropriate parsers and processors, and returns a list of attribute maps. These maps can be
consumed by either Content or ContentAdmin changesets - the caller handles database operations.

Sync is the foundational layer that reads files from filesystem, parses metadata (YAML sidecar
files), processes content (Markdown, HTML), and returns generic attribute maps. It does NOT
create database records, handle multi-tenant scoping, manage transactions, or broadcast events.

## Dependencies

- CodeMySpec.ContentSync.MetaDataParser
- CodeMySpec.ContentSync.MarkdownProcessor
- CodeMySpec.ContentSync.HtmlProcessor
- CodeMySpec.ContentSync.ProcessorResult

## Functions

### process_directory/1

Processes a directory of content files and returns attribute maps ready for changesets.

```elixir
@spec process_directory(directory :: String.t()) :: {:ok, [content_attrs()]} | {:error, :invalid_directory}
```

**Process**:
1. Validate directory exists, is a directory, and is readable
2. Return `{:error, :invalid_directory}` for nil, empty string, nonexistent, or unreadable paths
3. Discover content files (*.md, *.html) in flat directory structure (non-recursive)
4. Filter to only files that have corresponding .yaml sidecar metadata files
5. Sort discovered files alphabetically
6. For each file:
   - Read file contents
   - Parse metadata from sidecar .yaml file using MetaDataParser
   - If metadata parsing fails, build error attributes with parse_status :error
   - Route to appropriate processor based on extension (.md → MarkdownProcessor, .html → HtmlProcessor)
   - Merge metadata and processed content into attribute map
   - Capture any parse errors in parse_status/parse_errors fields
7. Return `{:ok, attrs_list}` with list of attribute maps

**Test Assertions**:
- successfully processes single markdown file
- successfully processes single HTML file
- stores metadata fields correctly (title, meta_title, meta_description, publish_at)
- stores full metadata map with string keys
- successfully processes multiple files of different types
- processes files in alphabetical order
- returns attributes with error status when metadata is invalid
- ignores files without metadata sidecar files
- stores metadata error details in parse_errors field
- returns attributes with error status when HTML has disallowed content
- continues processing when some files have errors
- returns both successful and failed files in result
- returns error when directory does not exist
- returns error when directory path is nil
- returns error when directory path is empty string
- returns error when path is a file not a directory
- successfully handles empty directory
- routes .md files to MarkdownProcessor
- routes .html files to HtmlProcessor
- ignores non-content files (txt, json, js, gitignore)
- discovers files in flat directory structure only (ignores subdirectories)
- handles directory with only metadata files (returns empty list)
- handles files with unicode names
- handles absolute directory paths
- handles directory path with trailing slash
- attributes have all required fields (slug, content_type, raw_content, processed_content, parse_status)
- content_type is an atom (:blog, :page, :landing, :documentation)
- parse_status is an atom (:success, :error)
- does not create any database records
- returns plain maps suitable for changesets (not structs)
- does not require Scope parameter
- processing same directory twice produces same result (idempotent)
- successfully processes directory with many files (50+)
- handles large files efficiently (10,000+ characters)
