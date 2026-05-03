# Demo Video Embed

**Priority:** High (gated on John's recording schedule)
**Area:** Site-wide — homepage hero, product page, methodology page
**Status:** Pre-production. Script and decisions complete (`market_my_spec/.code_my_spec/marketing_projects/demo-video/`). Recording pending.

## Why This Exists

The homepage and product page have static placeholders (mockup-code block, screenshot ideas) where a real demo video belongs. A video is the single most credible product visual for a dev tool — it shows the workflow running, including the QA money shot where a bug is caught that all unit tests passed. The full marketing project for this lives in `market_my_spec/.code_my_spec/marketing_projects/demo-video/` with the script, technical decisions, and hosting plan locked in.

This task tracks the embed work on the codemyspec.com side: where the video lands, how it's served, what fallbacks exist.

## Locked Decisions

1. Two cuts: short (60-90s, silent + captions, hero embed) and medium (3-5 min, narrated walkthrough, product page + YouTube). See `demo-video/decisions.md` and `demo-video/script-medium.md`.
2. Hosting: YouTube primary + self-hosted MP4 on Cloudflare R2 for the homepage embed.
3. Demo project: MetricFlow.
4. Recording: Screen Studio.

## User Stories

### Story 1: Short hero cut autoplays on the homepage

**As a** first-time visitor landing on codemyspec.com,
**I want** to see a short looping demo of the workflow above the fold,
**So that** I understand what the product does without reading or scrolling.

**Acceptance criteria:**
- Given the short hero cut (60-90s) is published to Cloudflare R2
- When a visitor loads the homepage
- Then the video autoplays muted with loop enabled in the hero section
- And captions are baked into the video (no track selection needed)
- And a poster frame is set for the loading state
- And the video does not regress LCP or cause CLS
- And on mobile, the video is responsive and stays within the viewport
- And the existing mockup-code block placeholder is replaced (not appended)

### Story 2: Medium cut on the product page

**As a** visitor on the CodeMySpec product page,
**I want** to watch the full narrated walkthrough,
**So that** I can evaluate the workflow in detail before signing up.

**Acceptance criteria:**
- Given the medium cut (3-5 min) is published to YouTube
- When a visitor scrolls to the product page hero (or designated video section)
- Then a YouTube embed renders with a click-to-play interaction (not autoplay)
- And the embed includes a poster frame from the video
- And the embed does not block page interactivity
- And lazy-loading is enabled so the embed doesn't fetch until visible

### Story 3: Methodology page links to the medium cut

**As a** visitor on the methodology page who has read about the six-phase process,
**I want** to watch it run in practice,
**So that** I see the methodology applied, not just described.

**Acceptance criteria:**
- Given the medium cut is published
- When a visitor reaches the methodology page
- Then a "Watch it run" link or embed appears in or after the relevant section
- And clicking the link opens the video (YouTube embed or modal — TBD)
- And the placement does not disrupt the existing reading flow

### Story 4: Video assets have proper SEO and social metadata

**As a** social media visitor sharing a CodeMySpec link,
**I want** the link preview to feature the demo video thumbnail,
**So that** the share is visually compelling and click-worthy.

**Acceptance criteria:**
- Given the demo videos are published
- When the homepage and product page are crawled by social platforms (Twitter, LinkedIn, Slack, etc.)
- Then OG meta tags reference the video thumbnail and a video URL where supported
- And `og:video`, `og:video:type`, and related tags are present per Open Graph spec
- And Twitter card meta tags are configured for video preview

## Non-Functional Requirements

- **Performance:** Video assets must be optimized. Hero video must not block first paint. Use H.264 + AAC for MP4, target <2MB for the short cut.
- **Accessibility:** Captions on both cuts. Transcript available on the product page (or linked).
- **No autoplay with sound:** Hero video is muted. Medium cut is click-to-play.
- **Fallback:** If video fails to load (network, blocked), a static poster frame renders.

## Open Questions for Three Amigos

1. Cloudflare R2 vs. inline video tag with the YouTube embed for hero — does R2 cost too much at scale? Recommendation: R2 for hero (fast, no third-party reliance for above-the-fold), YouTube for everything else.
2. Should the hero video have a "Watch full demo" CTA that scrolls to or links to the medium cut? Recommendation: yes, small text link below the video.
3. Methodology page placement — embed inline at the top, or link from a specific section? Recommendation: link from after "The Method" intro section, embed inline only if data shows users prefer it.

## Definition of Done

- All 4 stories pass acceptance criteria.
- Both video cuts are published and embedded in their target locations.
- Performance budget unchanged or improved.
- Social shares feature the video thumbnail across major platforms.
- The placeholder mockup-code block on the homepage is replaced by the short cut.

## Dependencies

- John records raw footage of MetricFlow workflow (per `demo-video/script-medium.md`).
- Editing for short and medium cuts.
- Cloudflare R2 bucket configured.
- YouTube channel ready (`@codemyspec`).
