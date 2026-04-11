# Technical SEO — Remaining Issues

Full audit performed 2026-04-10. All items from the 2026-03-26 audit are resolved.

## Open

### 12. Blog publication dates cluster in a narrow window (Info)
30+ posts published within a 9-day window (April 1-10). While each post is individually well-researched, the temporal pattern could draw manual review attention from Google's quality raters. No code fix — address by spacing future publications.

### 13. Author page could be richer (Low)
The author page has ~350 words of prose with proper Person schema, but could benefit from a list of authored articles and external publication links to strengthen E-E-A-T signals.

### 14. No pricing page or pricing transparency (Low)
The SoftwareApplication schema declares `price: 0` but the site has no pricing page. Users cannot evaluate the product's commercial model.

## Resolved (2026-04-10 Audit)

- ~~6. Blog index title is just "Blog"~~ — Fixed: now "Phoenix AI Development Blog — CodeMySpec"
- ~~7. Methodology page has no canonical URL~~ — Fixed: canonical_url assigned in mount
- ~~8. No og:image on any page~~ — Fixed: og-default.png fallback + per-page OG images for all blog posts
- ~~9. Homepage title could be stronger~~ — Acceptable at 63 chars with good keyword coverage
- ~~10. Google Fonts render-blocking CSS~~ — Fixed: media="print" onload pattern + preload
- ~~11. No hreflang tags~~ — N/A (English only site)
- ~~12. Organization logo SVG in schema~~ — Fixed: switched to logo-300.png for Google rich results
- ~~13. Missing og:site_name~~ — Fixed: added to root layout
- ~~14. Missing favicon link tag~~ — Fixed: added to root layout
- ~~15. Sitemap uses uniform build timestamp~~ — Fixed: uses actual content updated_at/publish_at dates
- ~~16. Sitemap includes inaccessible URL (/pages/control-over-prompts)~~ — Fixed: verification filter added
- ~~17. Hero images ~900KB PNGs~~ — Fixed: converted to WebP (78-93% savings)
- ~~18. Missing Blog schema entity on /blog~~ — Fixed: added Blog entity with publisher reference
- ~~19. Missing ProfilePage schema on /author~~ — Fixed: added ProfilePage entity
- ~~20. Missing @id on MetricFlow Article~~ — Fixed: added @id to case study schema
- ~~21. Docs TechArticle missing proficiencyLevel~~ — Fixed: added proficiencyLevel and articleSection

## Resolved (2026-03-26 Audit)

- ~~1. Homepage missing meta description~~ — Fixed
- ~~2. Homepage missing OG tags~~ — Fixed
- ~~3. Duplicate H1 on content pages~~ — Fixed
- ~~4. Wrong canonical URL on /pages/ routes~~ — Fixed
- ~~5. No structured data (JSON-LD)~~ — Fixed
- ~~4b. www does not redirect to non-www~~ — Fixed
