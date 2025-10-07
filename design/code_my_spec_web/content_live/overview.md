# Content LiveView Overview

## Purpose
Content display and monitoring system for blog posts, pages, and landing pages. Content is ingested via ContentSync (see `docs/design/code_my_spec/content_sync.md`) from a Git repository. This provides administrative monitoring interfaces and public-facing views for content display.

## Architecture Decision: Read-Only Administrative, Public Display

### Content Source of Truth
Content is managed as flat files (markdown, HTML, HEEx) in a Git repository and synced via ContentSync. The database is a read-only cache from the LiveView perspective. All content modifications happen through Git commits and sync operations.

### Administrative Interface
- **Path**: `/content/*`
- **Purpose**: Monitor synced content, view parse status, trigger manual syncs
- **Access**: Account members with appropriate permissions
- **Features**:
  - Content listing with filters (type, parse status)
  - View individual content details
  - Parse/sync status monitoring
  - Manual delete operations (optional, content will re-sync on next sync)
  - View raw and processed content
  - **No editing** - content is edited in Git repository

### Public-Facing Interface
- **Path**: `/:content_type/:slug` (public content)
- **Path**: `/private/:content_type/:slug` (protected content, requires authentication)
- **Purpose**: Display published content to end users
- **Access**:
  - Public routes: Anyone
  - Private routes: Authenticated users only
- **Features**:
  - Template-based rendering
  - SEO optimization
  - Scheduled publishing (only show published content based on publish_at/expires_at)
  - Route-based access control (public vs private)

## Template System

To support flexible rendering of different content types (blog posts, landing pages, pages), we should add a `template` field to the Content schema:

```elixir
field :template, :string, default: "default"
```

This allows:
- Blog posts to use templates like "article", "tutorial", "changelog"
- Landing pages to use templates like "product", "feature", "marketing"
- Pages to use templates like "docs", "legal", "about"

Templates would be implemented as Phoenix Components in `CodeMySpecWeb.ContentLive.Templates`.

## Content Workflow

1. **Edit**: Developer edits content files in Git repository (markdown/HTML/HEEx)
2. **Commit**: Developer commits and pushes changes to Git
3. **Sync**: ContentSync.sync_from_git/1 pulls latest content and syncs to database
4. **Monitor**: Admin views parse status in ContentLive.Index
5. **Display**: Published content appears on public routes automatically

## Security Considerations

### Administrative Interface
- Verify scope access on mount
- Permission-based action visibility
- View-only operations (no editing)
- Optional delete (content re-syncs on next sync)

### Public Interface
- Respect publish_at/expires_at dates (only show currently published content)
- Route-based protection: `/private/*` requires authentication
- Rate limiting for public access
- Cache published content aggressively
- Protected content flag provides additional layer beyond route
