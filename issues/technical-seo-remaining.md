# Technical SEO — Remaining Issues

Audit performed 2026-03-26. Items 1-5 from the original audit are resolved.

## Open

### 6. Blog index title is just "Blog" (Low)
The `/blog` page title is "Blog" with no branding or keyword context. Should be something like "Blog - CodeMySpec" or "AI Development Insights | CodeMySpec".

**Fix:** Set `page_title` in the `ContentLive.Index` mount.

### 7. Methodology page has no canonical URL (Low)
The `/methodology` hardcoded page doesn't assign `canonical_url`. It should set `https://codemyspec.com/methodology`.

**Fix:** Add `canonical_url: "https://codemyspec.com/methodology"` to the methodology copy metadata, or assign it in mount.

### 8. No og:image on any page (Low)
No content has an OG image set. Social sharing shows no thumbnail. Needs a default OG image and per-page overrides via the existing `og_image` field on content.

**Fix:** Add a default OG image fallback in `root.html.heex` (e.g., site logo or branded card). Set per-content OG images via the content admin SEO metadata fields.

### 9. Homepage title could be stronger (Low)
Currently "CodeMySpec — Keep Your Architecture, Let AI Do the Typing". This is decent but long (60 chars). Could be tightened for search click-through.

### 10. Google Fonts render-blocking CSS (Low)
The Google Fonts stylesheet loads synchronously. Consider using `font-display: swap` (already in URL) with a `media="print" onload="this.media='all'"` pattern for non-blocking loading.

### 11. No hreflang tags (Very Low)
Only relevant if targeting multiple languages in the future.

## Resolved

- ~~1. Homepage missing meta description~~ — Fixed: added via `home_copy.exs` meta map
- ~~2. Homepage missing OG tags~~ — Fixed: og:title, og:description now set
- ~~3. Duplicate H1 on content pages~~ — Fixed: `strip_leading_h1/1` removes markdown H1 from processed_content
- ~~4. Wrong canonical URL on /pages/ routes~~ — Fixed: `@content_type_paths` map corrects atom-to-path mapping
- ~~5. No structured data (JSON-LD)~~ — Fixed: Article schema on blog posts, WebPage on other content, WebSite on homepage
- ~~4b. www does not redirect to non-www~~ — Fixed: Cloudflare Page Rule, 301 `www.codemyspec.com/*` → `codemyspec.com/$1`
