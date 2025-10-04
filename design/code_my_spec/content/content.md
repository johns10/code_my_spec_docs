# Content Schema

## Purpose

Ecto schema representing content entities (blog posts, pages, landing pages) with comprehensive lifecycle management fields including publishing schedules, expiration dates, protection flags, SEO metadata, and flexible JSONB storage. Enforces multi-tenant isolation through account_id and project_id foreign keys while supporting content state tracking via parse_status and error logging.

## Field Documentation

| Field             | Type     | Required | Description                                                          |
| ----------------- | -------- | -------- | -------------------------------------------------------------------- |
| slug              | string   | yes      | URL-safe identifier unique per content_type within project           |
| content_type      | string   | yes      | Content category: "blog", "page", or "landing"                       |
| raw_content       | string   | yes      | Raw content source (Markdown, HTML, etc)                             |
| processed_content | string   | no       | Cached rendered HTML for performance                                 |
| protected         | boolean  | no       | Whether content requires authentication (default: false)             |
| project_id        | integer  | yes      | Foreign key for multi-tenant project isolation                       |
| account_id        | integer  | yes      | Foreign key for multi-tenant account isolation                       |
| publish_at        | datetime | no       | When content becomes visible (null = immediate)                      |
| expires_at        | datetime | no       | When content becomes hidden (null = never)                           |
| parse_status      | string   | no       | Processing state: "pending", "success", "error" (default: "pending") |
| parse_errors      | map      | no       | Error details when parse_status = "error"                            |
| meta_title        | string   | no       | SEO page title (max 60 chars)                                        |
| meta_description  | string   | no       | SEO meta description (max 160 chars)                                 |
| og_image          | string   | no       | Open Graph image URL for social sharing                              |
| og_title          | string   | no       | Open Graph title for social sharing                                  |
| og_description    | string   | no       | Open Graph description for social sharing                            |
| metadata          | map      | no       | Flexible JSONB field for custom attributes (default: {})             |

## State Transitions

### Sync Status Flow
- **pending** → Content created, awaiting processing
- **success** → Content processed and ready for display
- **error** → Processing failed, parse_errors contains details

### Content Lifecycle States
- **Draft**: publish_at in future or null with parse_status = "pending"
- **Published**: publish_at <= now AND (expires_at > now OR expires_at null) AND parse_status = "success"
- **Scheduled**: publish_at in future AND parse_status = "success"
- **Expired**: expires_at <= now

## Business Rules

1. **Slug Uniqueness**: Slugs must be unique within the combination of content_type and project_id (enforced by database constraint)
2. **Expiration Logic**: If both publish_at and expires_at are set, expires_at must be after publish_at
3. **Error Tracking**: When parse_status is "error", parse_errors must contain diagnostic information
4. **Multi-Tenancy**: All content must belong to both an account and project for proper isolation
5. **Protection Flag**: Protected content is returned by queries but access enforcement happens at LiveView layer
6. **Content Type Values**: Only "blog", "page", and "landing" are valid content_type values

## Associations

- **belongs_to :project** - Content is scoped to a single project
- **belongs_to :account** - Content is scoped to a single account
- **many_to_many :tags** - Content can have multiple tags through ContentTag join table (on_replace: :delete for sync operations)

## Database Indexes

Required indexes for query performance:
- Unique index on `[slug, content_type, project_id]`
- Index on `[account_id, project_id]` for multi-tenant queries
- Index on `[publish_at, expires_at]` for lifecycle queries
- Index on `[parse_status]` for status filtering
- Index on `[content_type]` for type filtering