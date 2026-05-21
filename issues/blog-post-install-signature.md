# Blog Post Install Signature — End-of-Post CTA

*Filed 2026-05-20 from a CRO audit follow-up on dev.codemyspec.com. The 5/19 signup-funnel-leak-and-release-crash sweep shipped 5 stories but deferred blog inline CTAs to "next sprint." This is that sprint — the simplest possible version, scoped down to fit the dev audience.*

---

## Why

Reddit-driven traffic is the dominant content surface for codemyspec.com — 49 sessions tagged `reddit/comment` on 2026-05-18 (~59% of total traffic). The harness-layer blog post in particular was the #1 UTM-tracked destination in prod analytics history (199 views).

**Current state:** blog posts have zero inline conversion path. Visitors finish reading and have to navigate back to the nav or footer to find an action. The CRO audit on 2026-05-20 surfaced this as the highest-leverage unshipped fix from the original sweep.

**This story:** add a template-level end-of-post signature block that acknowledges the signup gate honestly and provides install commands. Subtle. Dev-audience-appropriate. No marketing styling.

---

## Critical audience constraint

This is a **senior Phoenix engineer / agency tech lead / technical founder** audience. They read aggressive end-of-post CTAs as marketing smell — once they hit "GET STARTED NOW WITH OUR REVOLUTIONARY HARNESS!" the entire post loses credibility retroactively. Worst case, the post becomes a r/ChatGPTCoding meme for being a sales piece dressed as content.

The signature block must:

- Read as the author telling you what they use, not a sales pitch
- Use mono / terminal-styled commands (devs prefer copy-pasteable commands over buttons)
- Be honest about the signup gate — don't promise a smooth install if signup is required
- Sit below the article body, not interrupt flow
- Use plain text + monospace, no marketing styling
- Be template-level (every post gets it) so it reads as author signature, not as per-post pitch

---

## Files in scope

Locate the canonical blog post render path. Likely candidates:
- `lib/code_my_spec_web/live/blog_live/` (LiveView)
- `lib/code_my_spec_web/controllers/blog_html/` (controller-rendered HEEx)
- A shared blog-post template / component

Add the signature block to the template so it fires on every published post automatically. Don't modify individual blog post markdown / content files.

---

## Acceptance criteria

### 1. Content — ship exactly this copy

```
─────────────────────────────────────────────────────────

I built this with CodeMySpec — the harness I work in.
Sign up (free, no card) then install:

    https://codemyspec.com/users/register?utm_source=blog&utm_medium=signature&utm_campaign=post-cta

    /plugin marketplace add Code-My-Spec/plugins
    /plugin install codemyspec@codemyspec

— John
```

The `─────` is a horizontal rule (HTML `<hr>` styled with the brand's existing divider treatment, or a thematic break in the brand-zone aesthetic — match what the site already uses elsewhere).

### 2. Styling

- **Font:** monospace for the commands AND the URL (the entire block should feel terminal-styled)
- **No buttons.** No colored CTA backgrounds. No urgency styling. The block should look like an author signature, not a marketing card.
- **Optional:** a minimal chamfered border or signal-top treatment consistent with the brand-zone aesthetic — designer's call. If unsure, lean toward less styling.
- **Horizontal rule** above the block to separate from article body.
- **"— John" sign-off** in regular or italic text. Left-aligned or right-aligned (designer's call, pick one and be consistent).

### 3. Link treatment

- The `codemyspec.com/users/register?utm_source=blog&utm_medium=signature&utm_campaign=post-cta` URL is a regular text link styled with the brand's standard text-link underline. **Not a button.**
- The `/plugin marketplace add ...` and `/plugin install ...` commands are NOT links — they're commands the user copies into Claude Code. Treat them as code, not as CTAs.

### 4. Frequency

Template-level. Every published blog post gets the same signature, automatically. Not configurable per-post in this story (if a post ever needs different handling, that's a future story).

### 5. Retired-phrases regression coverage

The retired-phrases regression spec built in Story B of `signup-funnel-leak-and-release-crash.md` must cover the blog post template now. Add the blog template to the spec's surface list if it isn't already covered.

The signature block content above should clear the retired-phrases check — verify before shipping. The exact phrases ("I built this with CodeMySpec — the harness I work in" / "Sign up (free, no card) then install") are not on the retired list, but the verification is the contract.

### 6. UTM tracking

The signup URL must include the UTM parameters as shown:
```
?utm_source=blog&utm_medium=signature&utm_campaign=post-cta
```

This lets us measure blog → register conversion separately from other signup paths (nav, homepage, methodology page, Reddit comments). Critical for the post-deploy measurement (see below).

### 7. What NOT to ship

- ❌ "GET STARTED" or "Sign up now!" buttons in primary color
- ❌ "Don't miss…" / "Limited time" / urgency framing
- ❌ Newsletter signup widgets
- ❌ Popup / modal anything
- ❌ Mid-article CTA interruptions (this is end-of-post only)
- ❌ Testimonials, social proof badges, stock photos
- ❌ Exclamation points
- ❌ "Join thousands of developers…" — we don't have thousands of developers
- ❌ Any benefit-language ("10x your productivity", "ship faster", "save time")

---

## Verification

1. `mix test` passes including the retired-phrases regression spec
2. Vibium visual pass on a representative blog post in dev — signature block renders at the bottom, monospace styling intact, link is a text link not a button, no colored CTA backgrounds
3. Click the signup link → lands on `/users/register` with UTM parameters preserved in the URL
4. The signature block looks like an author signature, not a marketing CTA — sanity check by reading it as a skeptical Phoenix engineer would

---

## Measurement plan (post-deploy)

Watch the blog → register UTM conversion for 2-3 weeks via GA4 (now reliably tracking via the backend-reported events shipped in the 5/19 sweep):

- **Signal: engineers will sign up when asked honestly** → strong click-through from blog post readers to `/users/register` via the UTM. The format works. Format-2 wins, no further investment needed.
- **Signal: engineers want to install first, ask permission later** → low signup CTR but high traffic on the `/plugin install ...` command lines (measurable via clipboard-copy events if instrumented, or proxied by inbound install attempts). That's the signal to charge the hill on plugin-initiated auth (2-3 week engineering investment).
- **Signal: neither moves** → the content's not converting regardless of the gate. The signature isn't the bottleneck; better content is.

This story's job is to generate that signal cheaply.

---

## Out of scope

- **Plugin-initiated auth / OAuth device flow in the plugin** — separate strategic decision, blocked on data from this story
- **Per-post CTA customization** — template-only for now
- **Mid-article inline product references** — Shape 3 from the audit, defer
- **Related-reads / "you might also like" block** — defer
- **Newsletter signup, email capture, lead-gen** — never for this audience, period
- **Changes to individual blog post markdown content** — template-only

---

## Strategy doc note

The current `marketing/06_messaging.md` P0 CTA says "Install the plugin. Don't gate value behind signup." This story doesn't remove the gate (signup is still required first) — it acknowledges the gate honestly in the CTA shape rather than pretending it doesn't exist.

The strategy doc line is **aspirational, not current product reality.** Two paths forward depending on the measurement data:

1. **If engineers sign up to install** when asked honestly → keep the gate, update the strategy doc to match what's actually true ("Sign up, then install the plugin")
2. **If engineers don't sign up** → invest in plugin-initiated OAuth flow, bring the product into alignment with the aspirational strategy

This story collects the data needed to make that decision. Don't update the strategy doc yet.

---

## Why this is one issue and not bundled with future blog work

The blog template work likely expands later (related-reads, inline references, per-post variants, etc.). Keeping this story scoped down to just the end-of-post signature means:

- Faster ship (one HEEx component, one template change, one regression spec extension)
- Cleaner measurement signal (one variable changed, one conversion metric to watch)
- Lower risk of scope creep into marketing-card territory that the audience would reject

If the data after 2-3 weeks says the signature works, future blog template stories can expand on it. If the data says it doesn't, future stories pivot to plugin-initiated auth instead.
