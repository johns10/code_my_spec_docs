# Inline CTA Drafts — Top 3 Blog Posts

Filed 2026-05-23 from the funnel-leak diagnosis. **Critical leak:** 98.7% of engaged prod traffic (78 of 79 sessions on 5/22) never reaches `/users/register`. Blog posts engage deeply (425s avg on `the-harness-layer`, 375s on `transcript-derived-memory`) but the path from "engaged reader" to "registered user" is structurally broken.

The harness-layer post already has the upgraded HTML treatment with two inline CTAs (mid-post tagline card + install card). This file drafts equivalent treatment for the next three highest-engagement posts.

**Voice constraints (per `marketing/.code_my_spec/knowledge/tone-guide.md`):** direct, opinionated, terminal-aware, anti-hype, anti-button. Engineer audience. Bare URLs over "Get Started" CTAs. Hyperlinks on noun phrases. Short opinionated taglines, not promises.

**Tracking:** all new inline CTAs use `utm_medium=inline` to distinguish from the existing `utm_medium=signature` (end-of-post signature). Lets us read which placement converts after 7-14 days.

---

## Post 1 — `/blog/ai-agent-skill-trajectory`

**Engagement:** 24 sessions / 42% / 88s avg (top traffic, shorter reads — visitors are scanning the framework).

**Structural shape:** Trajectory framework, Level 0 → Level 4.

### Best inflection: end of Level 2 (Context Engineering), before Level 3 (Harness Engineering) begins

This is the cleanest CMS moment in the entire post — it's literally the conceptual pivot from "the layer most teams operate in" to "the layer CodeMySpec operates in." A reader hitting this point is exactly the prospect to convert.

### Snippet to insert (paste before the Level 3 H2)

```html
<aside class="my-12 max-w-[64ch] font-mono text-[14px] leading-relaxed">
  <div class="border-l-2 border-primary/40 pl-5">
    <p class="text-base-content/90">
      Context engineering is the last optimization that lives in your prompt.
      <br>
      Harness engineering is the first one that doesn't.
    </p>
    <p class="mt-3 text-base-content/70">
      I build a Phoenix harness called
      <a
        href="/products/code-my-spec?utm_source=blog&utm_medium=inline&utm_campaign=ai-agent-skill-trajectory"
        class="text-base-content underline decoration-primary/60 underline-offset-4 hover:text-primary hover:decoration-primary"
      >CodeMySpec</a>
      that sits at Level 3. Below: the trajectory continues.
    </p>
  </div>
</aside>
```

**Rationale:** The reader has just absorbed why Level 2 is the ceiling. The tagline names what's next; the noun-phrase link offers the product as the worked example. No "try it now" energy; reads as authorial context.

### Optional second placement: end of "What to Do About It"

If the post ends with a "do this" section, a small install-card following it lands cleanly:

```html
<aside class="mt-10 max-w-[64ch] font-mono text-[13px] leading-relaxed text-base-content/70">
  <p>If your Level 3 jump is the path you want to take:</p>
  <div class="mt-3 pl-4 border-l border-primary/20">
    <a
      href="/users/register?utm_source=blog&utm_medium=inline-code&utm_campaign=ai-agent-skill-trajectory"
      class="text-base-content underline decoration-primary/60 underline-offset-4 hover:text-primary hover:decoration-primary"
    >https://codemyspec.com/users/register</a>
  </div>
  <div class="mt-3 pl-4 border-l border-primary/20">
    <p>/plugin marketplace add Code-My-Spec/plugins</p>
    <p>/plugin install codemyspec@codemyspec</p>
  </div>
</aside>
```

Skip if the existing signature already covers this moment.

---

## Post 2 — `/blog/cli-agents-compared-2026`

**Engagement:** 13 sessions / 62% / 111s avg. Tool-comparison readers — evaluator-mode. Already has a "The CodeMySpec Angle" section at the end.

**Structural shape:** Intro → comparison table → detailed comparison (6 sub-sections) → Who Should Use What → CodeMySpec Angle → Sources.

### Best inflection: after the detailed comparison (section 6), before "Who Should Use What"

The reader has just absorbed six tool comparisons. They're saturated on "what's different about these tools" and about to be told "which one is for you." Inserting a frame-shift here primes them to consider the harness layer as a separate axis.

### Snippet to insert (paste before "Who Should Use What" H2)

```html
<aside class="my-12 max-w-[64ch] font-mono text-[14px] leading-relaxed">
  <div class="border-l-2 border-primary/40 pl-5">
    <p class="text-base-content/90">
      All six tools sharpen the session.
      <br>
      Harnesses compound across sessions.
    </p>
    <p class="mt-3 text-base-content/70">
      Which tool you pick matters less than whether you're running a
      <a
        href="/products/code-my-spec?utm_source=blog&utm_medium=inline&utm_campaign=cli-agents-compared-2026"
        class="text-base-content underline decoration-primary/60 underline-offset-4 hover:text-primary hover:decoration-primary"
      >harness</a>
      above them. Below: which CLI fits which shape.
    </p>
  </div>
</aside>
```

**Rationale:** Comparison-shoppers default to "pick the best tool"; the tagline reframes the decision. The harness link gives them a third axis to think about. Drops the reader into "Who Should Use What" with a sharper frame.

### Optional second placement: inside the existing "CodeMySpec Angle" section

If that section currently links once at the bottom, consider adding a code-block install moment inline within the section so the install path is reachable mid-explanation, not just at the end. Same install card snippet as Post 1.

---

## Post 3 — `/blog/transcript-derived-memory`

**Engagement:** 5 sessions / 40% / 375s avg. **Deep readers.** Smaller cohort but spending 6+ minutes — the kind of evaluator we want.

**Structural shape:** Definition → How it works → What it looks like in the wild → When it works → When it breaks → How to pair it → Honest verdict.

This post is *your* take on the transcript-memory category, and CodeMySpec is positioned as the alternative (structured artifacts, not transcripts). The existing CTA after "honest verdict" is right at the end.

### Best inflection: between "How to pair it with other categories" and "The honest verdict"

The reader has just absorbed how transcripts integrate with other memory approaches. They're primed to hear your verdict. Inserting the CMS comparison here reads as the natural setup for the "honest verdict" that follows.

### Snippet to insert (paste before "The honest verdict" H2)

```html
<aside class="my-12 max-w-[64ch] font-mono text-[14px] leading-relaxed">
  <div class="border-l-2 border-primary/40 pl-5">
    <p class="text-base-content/90">
      Your transcripts are your memory until they aren't.
      <br>
      For software engineering, structured artifacts get there first.
    </p>
    <p class="mt-3 text-base-content/70">
      <a
        href="/products/code-my-spec?utm_source=blog&utm_medium=inline&utm_campaign=transcript-derived-memory"
        class="text-base-content underline decoration-primary/60 underline-offset-4 hover:text-primary hover:decoration-primary"
      >CodeMySpec</a>
      takes the latter approach: BDD spex, bounded contexts, persisted decision records. Below: when each one is the right call.
    </p>
  </div>
</aside>
```

**Rationale:** Validates transcript-derived as a real pattern (your established voice on this post — Reddit comment from yesterday made the same move). Names CodeMySpec as the alternative. The "below: when each one is the right call" tees up the honest verdict without spoiling it.

### Optional second placement: top of post, after the lede

A small footnote-style aside near the top of the post for readers in evaluation mode:

```html
<p class="mt-4 max-w-[64ch] font-mono text-[13px] italic text-base-content/60">
  (If you want the artifact-based alternative I describe at the end, it's
  <a
    href="/users/register?utm_source=blog&utm_medium=inline-aside&utm_campaign=transcript-derived-memory"
    class="text-base-content underline decoration-primary/60 underline-offset-4 hover:text-primary"
  >codemyspec.com/users/register</a>
  — free, no card.)
</p>
```

Skip if it feels too eager at the top of an analysis-mode post. The deep readers will reach the mid-post CTA naturally.

---

## What to apply, in priority order

1. **Post 1 main snippet** (Level 2 → Level 3 transition) — highest leverage. Top-traffic post, cleanest CMS-aligned inflection.
2. **Post 2 main snippet** (after detailed comparison, before Who Should Use What) — high leverage; reframes the comparison-shopper decision.
3. **Post 3 main snippet** (before "honest verdict") — fewer readers but deeper engagement; perfect ICP.
4. (Optional) Post 1's install card after "What to Do About It" — only if the existing signature isn't catching scanners.
5. (Optional) Post 2's mid-section install code in "CodeMySpec Angle" — only if section currently reads as a single link at the end.
6. (Optional) Post 3's top aside — only if Post 3's main snippet underperforms after 14 days.

## UTM scheme summary

| Snippet | `utm_medium` | `utm_campaign` |
|---|---|---|
| Existing end-of-post signature (all posts, unchanged) | `signature` | `post-cta` |
| Post 1 main inline | `inline` | `ai-agent-skill-trajectory` |
| Post 1 install card | `inline-code` | `ai-agent-skill-trajectory` |
| Post 2 main inline | `inline` | `cli-agents-compared-2026` |
| Post 3 main inline | `inline` | `transcript-derived-memory` |
| Post 3 top aside | `inline-aside` | `transcript-derived-memory` |

After 7-14 days the `utm_medium=inline` vs `utm_medium=signature` ratio reveals which placement converts. Cut whichever underperforms in the next sweep.

## Notes for the engineer applying these

- The HTML uses Tailwind classes consistent with `install_signature` in `lib/code_my_spec_web/components/layouts.ex:414`. Font-mono, primary-color borders, no buttons.
- Paste each snippet into the post's `processed_content` field in the DB (or whatever content-admin surface manages it) at the named insertion point.
- After applying, verify the post renders without breaking the prose layout — the `<aside>` block sits in-flow with `my-12` margin.
- If a post uses a different `prose` container, the `max-w-[64ch]` may not be necessary; remove if it overflows.
- The `register?utm_*` URLs preserve the existing query param convention seen in `install_signature`. Don't change the param keys.

## What this doesn't address

- **Homepage `/` engagement (29% / 4s avg)** — separate CRO task. The homepage is not in scope here.
- **`/products/code-my-spec` engagement (0% / 224s)** — receives traffic from these inline CTAs but its own page-level CRO is separate.
- **The register page form itself** — not in scope until Leak A (this task) produces 10+ register-page visits to read field-level signal from.
- **The activation gap (`first_cli_connect` = 0 across all 56 prod users)** — separate story. Filing under the analytics-tracking-and-traffic-filtering MRD or a new onboarding-CRO ticket.

## Acceptance

This task closes when:

1. The three main snippets are inserted into Posts 1-3 via the content admin.
2. The next daily analytics snapshot shows at least one new `register_page_view` traceable via `utm_medium=inline` parameters.
3. After 7-14 days, the `utm_medium=inline` register-page conversion is compared to `utm_medium=signature` baseline. Whichever performs better informs the next sweep across the remaining blog posts.
