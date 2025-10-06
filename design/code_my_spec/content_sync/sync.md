# Sync

## Purpose

Orchestrates the core content synchronization pipeline from filesystem to database. Accepts a directory path, discovers content files in that directory (non-recursive), processes them through appropriate parsers and processors, and performs atomic database updates. Implements a 'delete all and recreate' strategy where filesystem is the source of truth.

## Public API

```elixir
# Sync Operations
@spec sync_directory(Scope.t(), directory :: String.t()) :: {:ok, sync_result()} | {:error, term()}

# Type Definitions
@type sync_result :: %{
  total_files: integer(),
  successful: integer(),
  errors: integer(),
  duration_ms: integer(),
  content_types: %{blog: integer(), page: integer(), landing: integer()}
}
```

## Execution Flow

### Main Sync Pipeline

1. **Start Timer**: Record start time for duration tracking
2. **Scope Validation**: Verify user can access the account and project
3. **Directory Validation**: Verify directory exists and is readable
4. **Transaction Start**: Begin `Repo.transaction/2` for atomic operation
5. **Content Deletion**: Call `Content.delete_all_content/1` to remove existing content
6. **File Discovery**: Scan directory (flat, non-recursive) for content files (*.md, *.html, *.heex)
7. **File Processing Loop**: For each discovered file:
   - Read file contents from filesystem
   - Parse metadata from sidecar YAML file via MetaDataParser
   - Determine file type from extension
   - Route to appropriate processor (MarkdownProcessor/HtmlProcessor/HeexProcessor)
   - Merge metadata + processor result into content attributes
   - Handle MetaDataParser errors by wrapping in ProcessorResult format
8. **Batch Insert**: Insert all content records via `Content.create_many/2`
9. **Transaction Commit**: Commit if all operations succeed, rollback on any failure
10. **End Timer**: Calculate duration
11. **Broadcast**: Publish `{:sync_completed, sync_result}` via Content context
12. **Result Return**: Return `{:ok, sync_result}` with sync statistics

### File Discovery

1. **Pattern Matching**: Use `Path.wildcard/2` with flat patterns (no `**` recursion):
   - `#{directory}/*.md` - Markdown files
   - `#{directory}/*.html` - HTML files
   - `#{directory}/*.heex` - HEEx template files
2. **Path Collection**: Collect all matching absolute file paths from directory root only
3. **Deduplication**: Remove any duplicate paths
4. **Sorting**: Sort paths alphabetically for consistent processing order

### File Processing

1. **File Reading**: Read file contents via `File.read!/1`
2. **Metadata Parsing**:
   - Construct metadata file path by replacing content extension with `.yaml`
   - Call `MetaDataParser.parse_metadata_file/1`
   - Handle `{:error, _}` by marking parse_status as :error
3. **Content Type Routing**: Based on file extension:
   - `.md` � `MarkdownProcessor.process/2`
   - `.html` � `HtmlProcessor.process/2`
   - `.heex` � `HeexProcessor.process/2`
4. **Attribute Assembly**: Combine metadata + processed content into attributes map with:
   - slug, content_type, raw_content, processed_content
   - parse_status (:success | :error)
   - parse_errors (map or nil)
   - SEO fields from metadata
   - timestamp fields from metadata
5. **Error Handling**: Catch all errors, populate `parse_errors` map, continue processing other files

### Transaction Management

The entire sync operation runs within a single database transaction:

- Delete all existing content for the project
- Process all files and collect attributes
- Insert all content records via batch operation
- Rollback on any database operation failure
- Individual parse errors do NOT rollback transaction (stored as parse_status: :error)

## Implementation Notes

### File Extension Handling

Map file extensions to content processors:

- `.md` � ContentSync.MarkdownProcessor
- `.html` � ContentSync.HtmlProcessor
- `.heex` � ContentSync.HeexProcessor

Unsupported extensions are skipped with warning logged.

### Metadata File Convention

Every content file must have a corresponding metadata file:

- Content: `my-post.md` → Metadata: `my-post.yaml`
- Content: `about.html` → Metadata: `about.yaml`
- Content: `hero.heex` → Metadata: `hero.yaml`

Missing metadata files result in parse_status: :error for that content file.

### MetaDataParser Error Handling

MetaDataParser returns `{:error, reason}` unlike processors. Sync wraps these errors:

```elixir
case MetaDataParser.parse_metadata_file(metadata_path) do
  {:ok, metadata} ->
    # Process normally with metadata

  {:error, error_detail} ->
    # Wrap in ProcessorResult format
    processor_result = %ProcessorResult{
      raw_content: raw_content,
      processed_content: nil,
      parse_status: :error,
      parse_errors: %{
        error_type: "MetaDataParseError",
        message: error_detail.message,
        details: error_detail
      }
    }
end
```

### Error Isolation Strategy

Individual file errors do NOT abort the sync:

1. **Parse Errors**: Captured in `parse_errors` field, record still created
2. **Processing Errors**: Set parse_status to :error, include error details
3. **Metadata Errors**: Mark as error, store error details, continue sync

This allows partial syncs to complete successfully with error tracking.

### Sync Statistics

The `sync_result` map provides detailed statistics:

- `total_files`: Total files discovered
- `successful`: Files with parse_status: :success
- `errors`: Files with parse_status: :error
- `duration_ms`: Time taken for sync operation
- `content_types`: Breakdown by content type (blog, page, landing)

### Directory Path Requirements

The provided directory path must:
- Be an absolute path (not relative)
- Exist on the filesystem
- Be readable by the application process

Invalid directory paths return `{:error, :invalid_directory}` before starting transaction.

### Content Deduplication

The 'delete all and recreate' strategy prevents duplicates:

1. Delete all content for project within transaction
2. Insert new content from filesystem
3. Database constraint prevents duplicate slugs per content_type per project

No need for upsert logic or manual deduplication.

### Concurrency Considerations

**Single Project Sync:**
- Transaction serialization ensures consistency
- Concurrent syncs for same project will queue at transaction level
- Last completed sync wins (due to delete-all strategy)

**Multi-Project Sync:**
- Different projects can sync concurrently
- Scoped to account_id and project_id for isolation

### Performance Optimization

**Batch Operations:**
- Use `Content.create_many/2` for single insert operation
- Process files in memory before database operations
- Single transaction reduces overhead

**File Reading:**
- Read files sequentially to avoid overwhelming file handles
- Suitable for typical content volumes in flat directory structure

### Integration Points

**Called By:**
- `ContentSync.sync_from_git/1` - after cloning/pulling repository
- `ContentSync.FileWatcher` - on file system events in development

**Calls:**
- `Content.delete_all_content/1` - clear existing content
- `Content.create_many/2` - batch insert new content
- `MetaDataParser.parse_metadata_file/1` - extract metadata
- `MarkdownProcessor.process/2` - process markdown
- `HtmlProcessor.process/2` - process HTML
- `HeexProcessor.process/2` - process HEEx templates

### Error Recovery

If sync fails mid-transaction:
1. Transaction automatically rolls back
2. Previous content remains in database
3. Return `{:error, reason}` to caller

This ensures database consistency - partial syncs never leave database in incomplete state.
