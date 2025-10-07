# Content Show LiveView (Administrative)

## Purpose
Administrative detail view for individual content items. Displays both raw and processed content, metadata, parse status, and SEO information. View-only interface for monitoring synced content.

## Route
`/content/:id`

## Context Access
- `CodeMySpec.Content.get_content!(scope, id)` - Get content by ID
- `CodeMySpec.Content.get_content_tags(scope, content)` - Get associated tags
- `CodeMySpec.Content.delete_content(scope, content)` - Optional: delete content

## LiveView Structure

### Mount
- Load content by ID from params
- Verify content belongs to scope
- Load associated tags
- Subscribe to content PubSub for this specific content
- Set page title to content title or slug

### Assigns
- `:content` - Content struct
- `:tags` - List of associated tags
- `:show_raw` - Boolean toggle for raw vs processed view (default: false)

### Events
- `toggle-view` - Toggle between raw and processed content display
  - Update `:show_raw` assign
  - Re-render content display section
- `delete` - Delete content
  - Confirm action
  - Call `delete_content/2`
  - Navigate back to index
  - Show flash: "Content deleted. Will re-sync on next Git sync."
- `back` - Navigate back to `/content`

### PubSub Handlers
- `{:updated, content}` when content.id matches - Reload content
- `{:deleted, content}` when content.id matches - Navigate to index with flash
- `{:sync_completed, _}` - Reload content (may have changed)

### Template

**Header**
- Back button to `/content`
- Title: content.title or content.slug
- Content type badge
- Parse status badge

**Metadata Section**
- **Slug**: `content.slug`
- **Content Type**: Badge (blog/page/landing)
- **Parse Status**: Badge (success/error/pending)
- **Published**: Formatted date or "Not published" or "Scheduled: DATE"
- **Expires**: Formatted date or "Never"
- **Protected**: Yes/No badge
- **Created**: Formatted timestamp
- **Updated**: Formatted timestamp

**Parse Errors Section** (if parse_status == :error)
- Red alert box
- Heading: "Parse Errors"
- Display `content.parse_errors` as formatted JSON or list
- Message: "Fix these errors in the Git repository and re-sync"

**SEO Metadata Section** (collapsible)
- **Meta Title**: content.meta_title
- **Meta Description**: content.meta_description
- **OG Title**: content.og_title
- **OG Description**: content.og_description
- **OG Image**: content.og_image (show as image preview if present)

**Tags Section**
- Display tags as badges
- Empty state: "No tags"

**Content Display Section**
- Toggle buttons: "Processed" | "Raw"
- If `:show_raw`:
  - Display `content.raw_content` in code block with syntax highlighting
- Else:
  - If `content.processed_content` is present:
    - Render `content.processed_content` as HTML (Phoenix.HTML.raw)
  - Else if content is HEEx:
    - Message: "HEEx templates are rendered at request time. View raw to see template."
  - Else:
    - Message: "No processed content available"

**Actions Section**
- "Delete Content" button (red, with confirmation)
- "View Public" link (if published, opens `/:content_type/:slug` or `/private/:content_type/:slug`)

### Status Badges
Same as index page:
```elixir
# Content Type
:blog -> "bg-blue-100 text-blue-800"
:page -> "bg-green-100 text-green-800"
:landing -> "bg-purple-100 text-purple-800"

# Parse Status
:success -> "bg-green-100 text-green-800"
:error -> "bg-red-100 text-red-800"
:pending -> "bg-yellow-100 text-yellow-800"

# Protected
true -> "bg-orange-100 text-orange-800"
false -> "bg-gray-100 text-gray-800"
```

## Data Flow
1. User clicks content row in index page
2. Navigate to `/content/:id`
3. Mount loads content and tags
4. User can toggle between raw/processed views
5. User can see all metadata and parse status
6. If errors, user sees detailed error information
7. User can delete content (optional)

## Security
- Require authenticated user
- Verify scope access on mount
- Verify content belongs to scope
- Permission-based delete action
- Raw content display is admin-only (already scoped to authenticated users)

## Performance
- Single content load on mount
- Subscribe to specific content updates only
- No heavy processing (content already parsed during sync)
