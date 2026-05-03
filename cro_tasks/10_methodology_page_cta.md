# Methodology Page Conversion Path

**Priority:** Medium
**Area:** Methodology page — conversion
**Status:** Todo

## Why This Exists

The methodology page is the highest-engagement content on the site (7+ minute average sessions, including a 77-minute session from a key prospect). Readers reach it pre-skeptical and leave it pre-sold. But the page's CTA is only at the very bottom — readers who drop off at 70-80% scroll never see it. The fix is to add a CTA where conviction peaks (after the proof section) and consider a sticky bottom bar for deep-scrollers who are still engaged but haven't hit the bottom yet.

## Locked Decisions

1. Primary CTA is "Install the plugin" with the install commands inline (matching the onboarding page pattern). Secondary is "Get started free" → `/users/register`. Tertiary is "Read the case study" → MetricFlow case study.
2. A mid-page CTA appears after "The Proof" section (the MetricFlow stats block).
3. Sticky bottom bar is a follow-on test, not a launch requirement. Build the mid-page CTA first; layer on sticky if data justifies.

## User Stories

### Story 1: Mid-page CTA after the proof section

**As a** visitor reading the methodology page who has just finished "The Proof" section,
**I want** a clear next step inline,
**So that** I don't have to scroll past five more sections to convert when conviction is highest.

**Acceptance criteria:**
- Given a visitor on `/methodology`
- When they scroll past "The Proof" section (MetricFlow stats block)
- Then a CTA block renders directly after that section
- And the block contains a primary "Install the plugin" CTA with install commands visible
- And a secondary "Read the case study" link to the MetricFlow case study
- And the block is visually distinct from surrounding content (background, border, or callout treatment)
- And the existing bottom-of-page CTA remains in place (this is additive)

### Story 2: Bottom CTA hierarchy aligns with messaging strategy

**As a** visitor who reads the methodology page to the end,
**I want** the bottom CTA to lead with "Install the plugin" and offer "Get started free" as the secondary path,
**So that** the strongest signal (install the actual product) is the primary action, with signup as the alternative.

**Acceptance criteria:**
- Given a visitor scrolling to the bottom of `/methodology`
- When they reach the final CTA block
- Then "Install the plugin" is the primary CTA (visually prominent, with install commands)
- And "Get started free" is a secondary CTA linking to `/users/register`
- And "Read the case study" is a tertiary CTA linking to the MetricFlow case study
- And the visual hierarchy makes the primary CTA obvious at a glance

### Story 3: Sticky bottom CTA bar (test, not launch requirement)

**As a** visitor scrolling deep into the methodology page,
**I want** a small persistent CTA at the bottom of the viewport,
**So that** I don't have to scroll back up or all the way down to take action.

**Acceptance criteria:**
- Given a visitor on `/methodology`
- When they scroll past 30% of the page depth
- Then a small sticky bar appears at the bottom of the viewport
- And the bar contains "Get started free" and "Install the plugin" buttons
- And the bar is dismissible (close button) and remembers dismissal for the session
- And the bar does not appear on mobile viewports below a defined breakpoint (the screen is too cramped)
- And this story is gated behind data: ship the mid-page CTA first; only build the sticky bar if methodology page conversion still has headroom after Story 1 lands

## Non-Functional Requirements

- **No popup-style aggression:** Audience is senior engineers who hate popups. The mid-page CTA is inline, not a modal. The sticky bar (if built) is dismissible and small.
- **Mobile parity:** Mid-page CTA must render cleanly on mobile. The sticky bar is desktop-only intentionally.
- **Performance:** No layout shift from CTAs. Reserve space if needed.

## Open Questions for Three Amigos

1. Where exactly does "The Proof" section end on the current methodology page? Need a precise insertion point in the template.
2. What's the visual treatment of the mid-page CTA? Match the existing dark-card pattern? Use the orange accent color? Recommendation: match existing card pattern, use orange for the primary button.
3. The sticky bar — if we build it, what's the dismissal persistence (session, localStorage, never-show-again)? Recommendation: session-only.

## Definition of Done

- Stories 1 and 2 pass acceptance criteria and ship.
- Story 3 is documented but gated on conversion data after Stories 1 and 2 launch.
- A returning visitor who reads to the end and a deep-scroller who drops at 75% both have a clear conversion path that didn't exist before.
