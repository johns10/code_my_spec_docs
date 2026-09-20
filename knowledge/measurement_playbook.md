# Measurement Playbook

How analytics actually works on codemyspec.com — for adding a new tracked
event without re-breaking something already fixed once. First draft
2026-09-12, after the CTA-tracking gap (Rules 10-12) and Clarity (task 15)
shipped. Revisit once Rules 4/7/8/9 (below) land.

## Two dispatch patterns — pick the right one

**Server-side (`CodeMySpec.Analytics.dispatch/3`)** — the authoritative
signal for anything with real business value: `sign_up`,
`registration_email_sent`, `first_cli_connect`, `onboarding_panel_viewed`,
`lead_captured`-style events. Fires from the actual state change (a DB
insert, a channel join), not from a client event that might not fire or
might fire twice. See `lib/code_my_spec/analytics.ex`.

```elixir
Analytics.dispatch(:some_event, %{user_id: user.id}, :server)
```

Never put PII (raw email, name) in the payload — GA4 forbids it. Pass an
internal ID instead, same as `:sign_up` passes `user_id`, not the email.

**Browser-side, delegated click handler (`assets/js/app.js`)** — for CTA
clicks specifically. One `document.addEventListener("click", ...)` on
`<a[href]>`, fires `cta_click`. Catches two cases:

1. **Explicit** — `data-event-label="cta-<purpose>-<location>"` on the
   anchor. Use this for anything not already covered by case 2.
2. **Implicit** — hrefs matching `/users/register*` or
   `/products/code-my-spec*`. Free tracking for markdown-authored links;
   don't rely on it for anything else.

**If you add a new CTA and don't label it, it produces zero events with no
error anywhere.** This is exactly the defect that shipped silently after
the July CTA redesign and took an external diagnostic to surface (Rules
10-11). Label every new conversion link on the way in, not after someone
notices the funnel has a hole.

### The click handler also fights a race condition

`gtag.js` is deferred to first interaction on most pages (see below), which
is also the moment a CTA click navigates away. Without help, a fast
click-through can unload the page before the event actually sends. The
handler (`assets/js/app.js`) holds same-tab navigation open with
`event_callback` + a 300ms timeout fallback; new-tab clicks (modifier keys,
middle-click, `target="_blank"`) are untouched. Don't remove this to
"simplify" the handler — it's load-bearing (Rule 12).

## gtag.js load timing — a deliberate trade-off, not a bug

`root.html.heex` defers `gtag.js` to first interaction / 3.5s idle
everywhere except `/users/register` (eager, because `GaClientId` wants the
`_ga` cookie present immediately on a direct signup landing). This trades
some bounce-rate measurement accuracy for a 2026-07-10 TBT win (desktop TBT
was 390ms before). **Don't "fix" this by reverting to eager load** — that
reopens a solved performance problem. If bounce data looks off, that's the
known cost; Rule 12 already mitigates the worst failure mode (lost CTA
events), which was the actual urgent part.

Microsoft Clarity (`root.html.heex`, task 15) follows the same deferred
pattern, prod-only (`envs/prod.env` → `runtime.exs` →
`:code_my_spec, :clarity_project_id`). Adding a new third-party script?
Defer it the same way unless something concrete depends on it loading
early (state that dependency in a comment, the way the register-page
carve-out does).

## CSP: check this before adding any third-party script

`lib/code_my_spec_web/plugs/csp.ex` is an **enforcing** policy — an
unlisted domain doesn't error, it silently drops the request. Clarity took
three separate directives (`script-src`, `connect-src` with a wildcard
subdomain, `font-src data:`) before it actually worked; verify a new
vendor's documented CSP requirements before shipping, don't guess from the
script tag alone.

## UTM taxonomy

Reddit links use exactly one of two forms going forward (see
`cro_tasks/17_reddit_playbook_and_utm_convention.md`):
`utm_source=reddit&utm_medium=comment` (founder comments) or
`utm_source=reddit&utm_medium=social` (native posts). Historical data is
not normalized retroactively.

## Known-open gaps (don't re-diagnose these — they're already scoped)

From `.code_my_spec/issues/analytics-tracking-and-traffic-filtering.md`:

- **Rule 4** — `gtag('config', ...)` hardcodes the prod measurement ID in
  `root.html.heex` regardless of environment; dev/staging traffic pollutes
  the prod GA4 property.
- **Rule 7** — Reddit mobile-app (`android-app://...` referrer) and
  UTM-stripped web traffic bucket into `(not set)/(not set)` instead of
  attributing to Reddit.
- **Rule 8** — no daily reconciliation between prod DB inserts and GA4
  `sign_up` counts; a silent MP delivery failure (the actual root cause
  found in `ga4-missing-signup-event-trace.md`) only surfaces via manual
  cross-check today.
- **Rule 9** — `page_view` doesn't reliably fire on mobile-webview /
  app-deeplink sessions, so some sessions show an empty landing page and
  can't be diagnosed.

## The seven defects an external CRO diagnostic found, and what was
## actually true

Kept here because a future audit will likely re-find some of these from
GA4 data alone, without code access, same as this one did:

| Diagnostic finding | Actually true (2026-09-12) |
|---|---|
| `sign_up` re-fires on returning OAuth (D2) | False. Fixed May 2026 (Rule 1). Diagnostic guessed a cause for an undercount that was really silent MP delivery failures (Rule 3). |
| `(not set)` source on ~26/68 sign-ups (D3) | Fixed independently by `GaClientId` (story 812), which post-dates the analytics story this playbook lives next to. |
| `/product` unreachable on mobile (IA) | False. Already flat in the mobile drawer. |
| CTA clicks untracked (D1/D7) | True — fixed same day (Rules 10-11). |
| `gtag.js` lazy-load inflates bounce (D5) | True, but deliberate (see above). |
| Reddit UTM taxonomy split 5 ways (D4) | True — process fix, not code (see `cro_tasks/17`). |
| GSC impression spike is AI fan-out, not real CTR (D6) | Correct as flagged — don't scope title/meta rewrites against it. |

**The lesson, not just the table:** an outside diagnostic working from
analytics data alone cannot tell "already fixed" from "still broken," or
"deliberate trade-off" from "oversight." Cross-check every finding against
the actual code and the existing issue history before queuing work from
one — about half of this diagnostic's P1 list was already resolved or
intentional.
