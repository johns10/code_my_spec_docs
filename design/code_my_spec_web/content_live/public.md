# Content Public LiveView

## Purpose
Public-facing content display for blog posts, pages, and landing pages. Renders published content using template-based layouts with SEO optimization. Supports both public and protected (authenticated) content.

## Routes

### Public Content
- `/blog/:slug` - Blog posts
- `/pages/:slug` - Pages
- `/landing/:slug` - Landing pages

### Protected Content (requires authentication)
- `/private/blog/:slug` - Protected blog posts
- `/private/pages/:slug` - Protected pages
- `/private/landing/:slug` - Protected landing pages

## Context Access
- `CodeMySpec.Content.get_content_by_slug!(scope, slug, content_type)` - Get published content
- `CodeMySpec.Content.list_published_content(scope, content_type)` - For related content
- `CodeMySpec.Content.get_content_tags(scope, content)` - Get tags

## LiveView Structure

### Mount
- Get slug and content_type from params
- Determine if protected route (`:live_action == :private_*`)
- Load content by slug and type
- Verify content is published (check publish_at/expires_at)
- If protected route, verify user is authenticated
- Load tags
- Set page title and meta tags from content
- Return 404 if content not found or not published

### Assigns
- `:content` - Content struct
- `:tags` - List of tags
- `:template` - Template name from content or "default"
- `:related_content` - Optional: list of related content by type/tags

### Events
None (static content display)

### Template Structure

**SEO Headers** (in `<head>`)
- `<title>` from `meta_title` or `title`
- `<meta name="description">` from `meta_description`
- Open Graph tags from `og_title`, `og_description`, `og_image`
- Canonical URL

**Template Router**
Delegate to template component based on `content.template`:
```elixir
case content.template do
  "default" -> <.default_template content={@content} tags={@tags} />
  "article" -> <.article_template content={@content} tags={@tags} />
  "tutorial" -> <.tutorial_template content={@content} tags={@tags} />
  _ -> <.default_template content={@content} tags={@tags} />
end
```

**Default Template**
- Content header:
  - Title
  - Published date (if blog)
  - Tags (as clickable badges)
- Main content area:
  - Render `processed_content` as HTML
  - Or render HEEx template dynamically
- Footer:
  - Share buttons (optional)
  - Related content (optional)

## Publishing Logic

Content is visible when:
1. `parse_status == :success`
2. `publish_at` is nil OR `publish_at <= now`
3. `expires_at` is nil OR `expires_at > now`

Otherwise return 404.

## Protected Content Access

For `/private/*` routes:
1. Check if user is authenticated
2. If not authenticated, redirect to login with return path
3. If authenticated, display content
4. Content's `protected` field provides additional layer (can be checked in queries)

## Template System

Templates are Phoenix Components in `CodeMySpecWeb.ContentLive.Templates`:

```elixir
defmodule CodeMySpecWeb.ContentLive.Templates do
  use Phoenix.Component

  attr :content, :map, required: true
  attr :tags, :list, default: []

  def default_template(assigns) do
    ~H"""
    <article class="prose">
      <h1><%= @content.title %></h1>
      <%= raw(@content.processed_content) %>
    </article>
    """
  end

  def article_template(assigns) do
    # Blog post with sidebar, author info, etc.
  end

  def tutorial_template(assigns) do
    # Tutorial with table of contents, code blocks, etc.
  end
end
```

## HEEx Content Rendering

For content with `.heex` files where `processed_content` is nil:
1. Render `raw_content` as HEEx template at request time
2. Use Phoenix.LiveView.HTMLEngine to compile template
3. Provide assigns: `content`, `tags`, etc.
4. Cache compiled template (optional optimization)

## Route Structure in Router

```elixir
# Public content
scope "/", CodeMySpecWeb do
  pipe_through [:browser, :put_content_scope]

  live "/blog/:slug", ContentLive.Public, :blog
  live "/pages/:slug", ContentLive.Public, :page
  live "/landing/:slug", ContentLive.Public, :landing
end

# Protected content
scope "/private", CodeMySpecWeb do
  pipe_through [:browser, :require_authenticated_user, :put_content_scope]

  live "/blog/:slug", ContentLive.Public, :private_blog
  live "/pages/:slug", ContentLive.Public, :private_page
  live "/landing/:slug", ContentLive.Public, :private_landing
end
```

## Scope Handling

The `:put_content_scope` plug should:
1. Determine which account/project owns the content
2. Set appropriate scope for content queries
3. This likely comes from application config or subdomain routing

## Data Flow
1. User navigates to `/:content_type/:slug`
2. Mount loads content by slug and type
3. Verify content is published (time-based rules)
4. If protected route, verify authentication
5. Render content using appropriate template
6. Display with SEO metadata

## Security
- Time-based publishing (respect publish_at/expires_at)
- Authentication required for `/private/*` routes
- No editing or modification (read-only)
- Content's `protected` field can be additional filter
- Rate limiting (via plug/config)
- XSS protection (Phoenix.HTML.raw is safe for processed HTML)

## Performance
- Cache published content aggressively
- Use CDN for static content
- Consider ETag/Last-Modified headers
- Preload related content if needed
- Template compilation caching for HEEx

## SEO Optimization
- Server-side rendering (LiveView initial render)
- Semantic HTML structure
- Meta tags from content metadata
- Proper heading hierarchy
- Alt text for images
- Canonical URLs
- Sitemap generation (separate feature)
