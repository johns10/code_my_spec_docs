# Homepage Hero Improvements

**Priority:** High
**Area:** Homepage — above the fold
**Status:** Partially done. Mockup-code block in hero handles the "no product visual" gap as a placeholder. Demo video embed remains open (gated on CRO Task 13: Demo Video).

## Why This Exists

The homepage is the canonical first impression. Visitors from Reddit who already know the concept convert; visitors from Google or shared links don't, because the hero is text-only and they can't see what CodeMySpec actually is in 5 seconds. The fix is a real product visual in the hero and tighter problem/insight/solution framing in the supporting columns.

## Locked Decisions

1. The mockup-code block currently in the hero stays as the static placeholder until the demo video ships.
2. Demo video lives behind CRO Task 13 — when complete, embed the short hero cut here.
3. Three-column section reframes to problem/insight/solution per the brand narrative arc in `marketing/05_positioning.md`.

## User Stories

### Story 1: First-time visitors see a product visual above the fold

**As a** first-time visitor landing on codemyspec.com,
**I want** to see what CodeMySpec actually does without scrolling or reading prose,
**So that** I can decide in 5 seconds whether this is relevant to me.

**Acceptance criteria:**
- Given a visitor on a desktop browser viewing the homepage
- When the page loads
- Then a product visual is rendered above the fold (within the hero section)
- And the visual shows real terminal output, install command, or workflow run — not abstract design
- And the visual is positioned below the headline and CTA buttons, visible without scrolling on a 1080p viewport
- And on mobile, the visual is responsive and visible without horizontal scroll

### Story 2: When the demo video ships, replace the static visual

**As a** visitor who lands on the homepage after the demo video is published,
**I want** to see the short hero cut auto-playing (muted, looping) in place of the static mockup,
**So that** I see motion and outcome, not just a frozen terminal.

**Acceptance criteria:**
- Given the demo video short cut (60-90s) is published per CRO Task 13
- When a visitor loads the homepage
- Then the hero visual is the demo video, not the mockup-code block
- And the video autoplays muted with loop enabled
- And the video does not block page interactivity or layout shift
- And a fallback static frame renders if video fails to load

### Story 3: Three-column section reframes to problem/insight/solution

**As a** visitor reading past the hero,
**I want** the three supporting columns to walk me through the narrative arc (problem, insight, solution) explicitly,
**So that** by the bottom of the section I understand why CodeMySpec exists, not just what it does.

**Acceptance criteria:**
- Given a visitor scrolling past the hero
- When they reach the three-column section
- Then column 1 is labeled "The problem" and describes LLMs inventing architecture
- And column 2 is labeled "The insight" and describes engineering discipline still mattering
- And column 3 is labeled "The solution" and describes CodeMySpec as the harness
- And the labels are visually distinct (badge, eyebrow text, or color) so the arc reads as one story, not three independent points
- And copy is sourced from `marketing/05_positioning.md` brand narrative arc

## Non-Functional Requirements

- **Performance:** Hero visual must not regress LCP. Image/video must be optimized (WebP, MP4 with H.264, properly sized).
- **Accessibility:** Static images need alt text. Videos need captions or a text alternative. Three-column section labels readable by screen readers.
- **No layout shift:** Reserve space for the visual so CLS stays at zero.

## Open Questions for Three Amigos

1. If the demo video ships in two cuts (60s short, 3-5min medium), does the homepage show the short cut autoplaying, or a poster frame with click-to-play of the medium? Recommendation: short cut autoplaying.
2. Is there a static screenshot fallback if a visitor blocks autoplay? What does that look like?
3. Three-column copy: rewrite from scratch, or evolve current copy in place? Recommendation: evolve, since current copy is already close.

## Definition of Done

- All 3 stories pass acceptance criteria.
- Mobile and desktop both render the visual cleanly above the fold.
- Three-column section uses the problem/insight/solution framing with the right copy.
- Performance budget unchanged (LCP, CLS within current thresholds).
