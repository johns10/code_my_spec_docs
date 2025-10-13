# Content Schema

## Purpose

Ecto schema representing published content entities (blog posts, pages, landing pages) for public viewing in deployed applications. This is the clean, production-ready schema without validation or multi-tenant fields. Content can be accessed by authenticated users (with scope) for private content, or by anonymous users (nil scope) for public content.

**Note**: This is distinct from ContentAdmin which handles validation/preview with multi-tenant scoping. Content is the final published form.

## Field Documentation

| Field             | Type     | Required | Description                                                          |
| ----------------- | -------- | -------- | -------------------------------------------------------------------- |
| slug              | string   | yes      | URL-safe identifier unique per content_type                          |
| title             | string   | no       | Display title for the content                                        |
| content_type      | string   | yes      | Content category: "blog", "page", "landing", or "documentation"      |
| content           | string   | yes      | Rendered HTML/HEEx ready for display                                 |
| protected         | boolean  | no       | Whether content requires authentication (default: false)             |
| publish_at        | datetime | no       | When content becomes visible (null = immediate)                      |
| expires_at        | datetime | no       | When content becomes hidden (null = never)                           |
| meta_title        | string   | no       | SEO page title (max 60 chars)                                        |
| meta_description  | string   | no       | SEO meta description (max 160 chars)                                 |
| og_image          | string   | no       | Open Graph image URL for social sharing                              |
| og_title          | string   | no       | Open Graph title for social sharing                                  |
| og_description    | string   | no       | Open Graph description for social sharing                            |
| metadata          | map      | no       | Flexible JSONB field for custom attributes (default: {})             |

**Fields NOT in this schema**:
- NO `account_id` or `project_id` (single-tenant per deployment)
- NO `parse_status` or `parse_errors` (validation happens in ContentAdmin)
- NO `raw_content` or `processed_content` separation (just `content`)

## Content Lifecycle States

- **Published**: publish_at <= now AND (expires_at > now OR expires_at null)
- **Scheduled**: publish_at in future
- **Expired**: expires_at <= now

## Business Rules

1. **Slug Uniqueness**: Slugs must be unique within content_type (enforced by database constraint)
2. **Expiration Logic**: If both publish_at and expires_at are set, expires_at must be after publish_at
3. **Protected Content**:
   - If protected = false: accessible to all visitors (nil scope works)
   - If protected = true: requires authentication (scope required)
4. **Content Type Values**: Only "blog", "page", "landing", and "documentation" are valid content_type values

## Associations

- **many_to_many :tags** - Content can have multiple tags through ContentTag join table (on_replace: :delete)

## Database Indexes

Required indexes for query performance:
- Unique index on `[slug, content_type]`
- Index on `[publish_at, expires_at]` for lifecycle queries
- Index on `[content_type]` for type filtering
- Index on `[protected]` for access control queries

## Publishing Flow

Content is NOT synced from ContentAdmin. Instead:

1. **Validate in ContentAdmin**: Developer syncs from Git to ContentAdmin for validation/preview
2. **Publish Action**: Developer clicks "Publish" which triggers:
   - Fresh pull from GitHub repository
   - Process content files (markdown → HTML, parse metadata, etc.)
   - POST to `/api/content/sync` endpoint
3. **Content Endpoint**: Receives processed content and stores in Content table

This ensures Content always comes from source of truth (Git), not from ContentAdmin preview data.
