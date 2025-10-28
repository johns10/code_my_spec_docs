# Sync

## Purpose

Agnostic content synchronization pipeline that processes filesystem content into attribute maps. Accepts a directory path, discovers content files (non-recursive), processes them through appropriate parsers and processors, and returns a list of attribute maps. These maps can be consumed by either Content or ContentAdmin changesets.

**Architecture Philosophy**: Sync is the foundational data processing layer that is completely agnostic to how the data is stored. It does NOT handle database operations, multi-tenant scoping, transactions, or broadcasting. The caller decides how to use the attribute maps.

## Public API

```elixir
# Core Processing
@spec process_directory(directory :: String.t()) :: {:ok, [content_attrs()]} | {:error, term()}

# Type Definition
@type content_attrs :: %{
  required(:slug) => String.t(),
  required(:content_type) => :blog | :page | :landing | :documentation,
  required(:content) => String.t(),
  required(:processed_content) => String.t() | nil,
  required(:parse_status) => :success | :error,
  optional(:parse_errors) => map() | nil,
  optional(:title) => String.t(),
  optional(:protected) => boolean(),
  optional(:publish_at) => DateTime.t(),
  optional(:expires_at) => DateTime.t(),
  optional(:meta_title) => String.t(),
  optional(:meta_description) => String.t(),
  optional(:og_image) => String.t(),
  optional(:og_title) => String.t(),
  optional(:og_description) => String.t(),
  optional(:metadata) => map()
}
```

## Execution Flow

### Main Processing Pipeline

1. **Directory Validation**: Verify directory exists and is readable
2. **File Discovery**: Scan directory (flat, non-recursive) for content files (*.md, *.html, *.heex)
3. **File Processing Loop**: For each discovered file:
   - Read file contents from filesystem
   - Parse metadata from sidecar YAML file via MetaDataParser
   - Determine file type from extension
   - Route to appropriate processor (MarkdownProcessor/HtmlProcessor/HeexProcessor)
   - Merge metadata + processor result into attribute map
   - Handle MetaDataParser errors by wrapping in attribute format
4. **Return Result**: `{:ok, [attrs]}` with list of attribute maps

### File Discovery

1. **Pattern Matching**: Use `Path.wildcard/2` with flat patterns (no `**` recursion):
   - `#{directory}/*.md` - Markdown files
   - `#{directory}/*.html` - HTML files
   - `#{directory}/*.heex` - HEEx template files
2. **Path Collection**: Collect all matching absolute file paths from directory root only
3. **Metadata Filter**: Only include files that have corresponding `.yaml` sidecar files
4. **Deduplication**: Remove any duplicate paths
5. **Sorting**: Sort paths alphabetically for consistent processing order

### File Processing

1. **File Reading**: Read file contents via `File.read!/1`
2. **Metadata Parsing**:
   - Construct metadata file path by replacing content extension with `.yaml`
   - Call `MetaDataParser.parse_metadata_file/1`
   - Handle `{:error, _}` by marking parse_status as :error
3. **Content Type Routing**: Based on file extension:
   - `.md` → `MarkdownProcessor.process/2`
   - `.html` → `HtmlProcessor.process/2`
   - `.heex` → `HeexProcessor.process/2`
4. **Attribute Assembly**: Combine metadata + processed content into attributes map with:
   - slug, content_type, content, processed_content
   - parse_status (:success | :error)
   - parse_errors (map or nil)
   - SEO fields from metadata
   - timestamp fields from metadata
5. **Error Handling**: Catch all errors, populate `parse_errors` map, continue processing other files

## Implementation Notes

### What Sync Does

- Reads files from filesystem
- Parses metadata (YAML sidecar files)
- Processes content (Markdown, HTML, HEEx)
- Returns generic attribute maps
- Tracks parse errors in returned data

### What Sync Does NOT Do

- Create database records
- Handle multi-tenant scoping (no account_id/project_id)
- Manage transactions
- Broadcast PubSub events
- Delete existing records
- Validate business rules

**The caller is responsible for all database operations and business logic.**

### File Extension Handling

Map file extensions to content processors:

- `.md` → ContentSync.MarkdownProcessor
- `.html` → ContentSync.HtmlProcessor
- `.heex` → ContentSync.HeexProcessor

Unsupported extensions are skipped during file discovery.

### Metadata File Convention

Every content file must have a corresponding metadata file:

- Content: `my-post.md` → Metadata: `my-post.yaml`
- Content: `about.html` → Metadata: `about.yaml`
- Content: `hero.heex` → Metadata: `hero.yaml`

Files without metadata are excluded from the results.

### MetaDataParser Error Handling

MetaDataParser returns `{:error, reason}` unlike processors. Sync wraps these errors:

```elixir
case MetaDataParser.parse_metadata_file(metadata_path) do
  {:ok, metadata} ->
    # Process normally with metadata

  {:error, error_detail} ->
    # Wrap in attribute format
    %{
      slug: generate_error_slug(),
      content_type: :blog,
      content: raw_content,
      processed_content: nil,
      parse_status: :error,
      parse_errors: %{
        error_type: "MetaDataParseError",
        message: error_detail.message,
        details: error_detail
      },
      metadata: %{}
    }
end
```

### Error Isolation Strategy

Individual file errors do NOT abort the sync:

1. **Parse Errors**: Captured in `parse_errors` field, attribute map still returned
2. **Processing Errors**: Set parse_status to :error, include error details
3. **Metadata Errors**: Mark as error, store error details, continue processing

This allows partial syncs to complete successfully with error tracking.

### Directory Path Requirements

The provided directory path must:
- Be an absolute path (not relative)
- Exist on the filesystem
- Be readable by the application process

Invalid directory paths return `{:error, :invalid_directory}` immediately.

### Performance Optimization

**Sequential Processing:**
- Read files sequentially to avoid overwhelming file handles
- All processing happens in memory before returning
- No database I/O within Sync module
- Suitable for typical content volumes in flat directory structure

**Efficient Data Structure:**
- Returns plain maps (not structs)
- Minimal memory overhead
- Ready for batch database operations by caller

## Integration Patterns

### Usage with ContentAdmin (Multi-Tenant Validation)

ContentAdmin is the validation layer in the SaaS platform with multi-tenant scoping:

```elixir
# In FileWatcher or ContentSync orchestration module
def sync_to_content_admin(%Scope{} = scope) do
  directory = get_content_directory(scope)

  with {:ok, attrs_list} <- Sync.process_directory(directory) do
    Repo.transaction(fn ->
      # Delete existing ContentAdmin records for this project
      {:ok, _count} = ContentAdmin.delete_all_content(scope)

      # Add multi-tenant scoping and create records
      admin_attrs_list =
        Enum.map(attrs_list, fn attrs ->
          Map.merge(attrs, %{
            account_id: scope.active_account_id,
            project_id: scope.active_project_id
          })
        end)

      case ContentAdmin.create_many(scope, admin_attrs_list) do
        {:ok, content_admin_list} ->
          # Calculate sync statistics
          result = build_sync_result(content_admin_list)

          # Broadcast to LiveView
          broadcast_sync_completed(scope, result)

          {:ok, result}

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end
end
```

**Key Points:**
- Adds `account_id` and `project_id` for multi-tenant scoping
- Writes to `content_admin` table
- Includes `parse_status` and `parse_errors` fields for validation feedback
- Broadcasts via PubSub for LiveView updates
- Used during development (FileWatcher) and manual "Sync from Git" operations

### Usage with Content (Single-Tenant Production)

Content is the production layer in deployed client appliances (single-tenant):

```elixir
# In client appliance's content sync endpoint
def sync_content(directory) do
  with {:ok, attrs_list} <- Sync.process_directory(directory) do
    Repo.transaction(fn ->
      # Delete all existing content (single-tenant, no scoping)
      Content.delete_all_content()

      # Filter to only successfully parsed content
      valid_attrs_list =
        attrs_list
        |> Enum.filter(&(&1.parse_status == :success))
        |> Enum.map(fn attrs ->
          # ContentAdmin has parse_status/parse_errors, Content does not
          # So we only use the successfully parsed content
          Map.take(attrs, [
            :slug, :title, :content_type, :content, :processed_content,
            :protected, :publish_at, :expires_at,
            :meta_title, :meta_description, :og_image, :og_title, :og_description,
            :metadata
          ])
        end)

      case Content.create_many(valid_attrs_list) do
        {:ok, content_list} ->
          {:ok, %{total: length(content_list)}}

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end
end
```

**Key Points:**
- No `account_id`/`project_id` (single-tenant)
- Filters to only `parse_status: :success` content (no errors deployed)
- Writes to `contents` table
- No parse_status/parse_errors fields in Content schema
- Triggered by HTTP POST from SaaS platform when developer clicks "Publish"

### Called By

**Development:**
- `FileWatcher` - watches local filesystem for changes, syncs to ContentAdmin

**SaaS Platform:**
- `ContentSync.sync_to_content_admin/1` - after cloning/pulling Git repository
- Manual "Sync from Git" button in LiveView

**Client Appliances:**
- `Content.sync_content/1` - receives HTTP POST from SaaS platform
- Triggered when developer clicks "Publish" in SaaS platform

### Calls

**Sync Module Dependencies:**
- `MetaDataParser.parse_metadata_file/1` - extract metadata from YAML
- `MarkdownProcessor.process/2` - process markdown files
- `HtmlProcessor.process/2` - process HTML files
- `HeexProcessor.process/2` - process HEEx template files

**No Other Dependencies:**
- Does NOT call any repository modules
- Does NOT call Repo directly
- Does NOT call PubSub
- Pure data processing layer

## Architecture Context

### Two-System Architecture

**ContentAdmin** (SaaS Validation Layer):
- Multi-tenant with account_id/project_id scoping
- Stores in `content_admin` table
- Includes `parse_status` and `parse_errors` fields
- Used for validation and preview in SaaS platform
- Developer sees parse errors immediately during development
- FileWatcher syncs here during local development
- "Sync from Git" button syncs here for preview

**Content** (Client Production Layer):
- Single-tenant, no account/project scoping
- Stores in `contents` table
- No parse_status/parse_errors fields (only valid content deployed)
- Used for serving published content to end users
- Only successfully parsed content gets published
- Receives content via HTTP POST from SaaS when developer clicks "Publish"

**Publishing Flow:**
```
[Dev edits locally] → [FileWatcher detects change] → [Sync.process_directory/1]
                                                            ↓
                                                [Returns attribute maps]
                                                            ↓
                                        [ContentAdmin creates records with scoping]
                                                            ↓
                                            [LiveView shows validation results]
                                                            ↓
                                                [Dev reviews and clicks "Publish"]
                                                            ↓
                                        [SaaS pulls fresh from Git] → [Sync.process_directory/1]
                                                            ↓
                                                [Returns attribute maps]
                                                            ↓
                                        [Filter to parse_status: :success only]
                                                            ↓
                                        [HTTP POST to client /api/content/sync]
                                                            ↓
                                            [Content creates records (no scoping)]
                                                            ↓
                                                [End users see published content]
```

**Key Principle**: ContentAdmin is NEVER copied to Content. Publishing always pulls fresh from Git and processes through Sync.

### Why Agnostic Design?

**Reusability:**
- Same file processing logic for both ContentAdmin and Content
- No duplication of parsing/processing code
- Single source of truth for content transformation

**Testability:**
- Easy to test without database
- Pure functions with clear inputs/outputs
- Mock filesystem, test attribute map generation

**Flexibility:**
- Callers control database operations
- Callers control transaction boundaries
- Callers control broadcasting
- Easy to add new consumers in the future

**Separation of Concerns:**
- Sync: File processing and data transformation
- ContentAdmin: Validation layer with multi-tenant scoping
- Content: Production layer with single-tenant storage
- Each layer has clear responsibilities
