# Content Index LiveView (Administrative)

## Purpose
Administrative monitoring of all synced content (blog posts, pages, landing pages) with filtering by type and parse status. View-only interface to inspect synced content from Git repository.

## Route
`/content`

## Context Access
- `CodeMySpec.Content.list_all_content(scope)` - Get all content
- `CodeMySpec.Content.list_content_with_status(scope, filters)` - Filtered content
- `CodeMySpec.Content.delete_content(scope, content)` - Optional: delete content (will re-sync)
- `CodeMySpec.Content.count_by_parse_status(scope)` - Status counts

## LiveView Structure

### Mount
- Load all content for current scope
- Subscribe to content changes via PubSub (`:sync_completed` events)
- Initialize filter state (empty filters = show all)
- Load status counts
- Set page title

### Assigns
- `:streams.content` - Stream of content records
- `:filter_type` - Current content_type filter (nil, :blog, :page, :landing)
- `:filter_status` - Current parse_status filter (nil, :success, :error, :pending)
- `:status_counts` - Map of parse status counts %{success: N, error: N}

### Events
- `filter-type` - Filter by content type
  - Update `:filter_type` assign
  - Reload content with filter
  - Reset stream
- `filter-status` - Filter by parse status
  - Update `:filter_status` assign
  - Reload content with filter
  - Reset stream
- `clear-filters` - Remove all filters
  - Reset filter assigns to nil
  - Reload all content
- `delete` - Delete content (optional)
  - Validate permissions
  - Call `delete_content/2`
  - Remove from stream
  - Show warning: "Content will re-sync on next Git sync"

### PubSub Handlers
- `{:created, content}` - Add to stream
- `{:updated, content}` - Update in stream
- `{:deleted, content}` - Remove from stream
- `{:sync_completed, sync_result}` - Reload entire list and update status counts

### Template
Similar structure to `ProjectLive.Index`:

**Header**
- Title: "Content"
- Action: "Trigger Sync" button (navigates to sync management or triggers sync)

**Status Summary**
- Badge: "✓ X Published" (green)
- Badge: "✗ Y Errors" (red)
- Badge: "⋯ Z Pending" (yellow)

**Filters**
- Type dropdown: All | Blog | Page | Landing
- Status dropdown: All | Success | Error | Pending
- "Clear Filters" button (if any filters active)

**Table**
- Columns:
  - **Title** (or slug if no title)
  - **Slug** (smaller, muted text)
  - **Type** (badge with color)
  - **Status** (badge with icon, mouse over for full error text)
  - **Published** (formatted date or "Scheduled: DATE" or "Draft")
  - **Expires** (formatted date or "Never")
- Row click: Navigate to `/content/:id`
- Actions column:
  - "View" link
  - "Delete" link (with confirmation)

**Empty State**
- When no content: "No content synced yet. Trigger a sync to import content from your Git repository."
- When filters return nothing: "No content matches the selected filters."

### Badge Styles
```elixir
# Content Type
:blog -> "bg-blue-100 text-blue-800"
:page -> "bg-green-100 text-green-800"
:landing -> "bg-purple-100 text-purple-800"

# Parse Status
:success -> "bg-green-100 text-green-800" with "✓"
:error -> "bg-red-100 text-red-800" with "✗"
:pending -> "bg-yellow-100 text-yellow-800" with "⋯"
```

## Data Flow
1. User navigates to `/content`
2. Mount loads all content, subscribes to PubSub
3. User filters by type and/or status
4. User clicks row to view content details
5. ContentSync broadcasts `:sync_completed` when sync finishes
6. List automatically reloads with updated content

## Security
- Require authenticated user
- Verify scope access on mount
- Permission-based delete action (optional feature)
- Delete confirmation dialog

## Performance
- Use streams for large content lists
- PubSub subscription for real-time updates
- Consider pagination if content list grows very large (>1000 items)
