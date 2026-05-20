# Signup Funnel Leak — CRO + Strategy-Alignment Pass

*Filed 2026-05-19 from a diagnostic session on the 9-day signup drought.
Originally bundled five stories. **Story A (release-crash hotfix) and the
out-of-scope GA4 backend-events workstream are now shipped** — see the
handoff notes below. This issue is now four CRO / strategy-alignment
fixes (B–E) that all trace back to the 2026-05-07 marketing revert not
fully shipping on codemyspec.com surfaces.*

---

## Handoff — what's already done (2026-05-19 session)

### Story A — `Mix.env()` release crash ✅ SHIPPED

- **Fix:** `lib/code_my_spec_web/live/app_live/overview.ex:486` — `Mix.env()`
  call removed entirely (commit `77010e72`, deployed to prod).
- **Regression-prevention lint:** `test/release_safety_test.exs` fails CI
  if `Mix.env()` ever appears in `lib/` again (whitelists known string
  templates). This replaces the per-file Credo check the original story
  asked for; it covers all of `lib/`, not just `lib/code_my_spec_web/`.
- **Activation-rung BDD coverage:** the Wallaby e2e signup tests cover
  exactly the failure mode that hid the crash — a fresh user completes
  signup, lands on `/app`, the account-rung form renders without 500.
  See `test/e2e/signup_email_test.exs`. The original story asked for a
  spex-flavored equivalent; the Wallaby test is the stronger version
  because it drives a real browser through the full path that crashed.

### GA4 over-firing / backend-reported events ✅ SHIPPED

The "out-of-scope" GA4 false-positive cleanup (separate workstream per
the original issue) is now done:

- `:sign_up` dispatches server-side from the only authoritative signal:
  a `users` row insert. `Users.register_user/1` tags it
  `method: "magic_link"`; `Users.find_or_register_oauth_user/2` tags it
  `method: "oauth_<provider>"` only on the `:new` branch. Returning
  users (`:existing`, integration relink, email auto-link) never
  redispatch.
- `:registration_email_sent` moved to server-side dispatch from the
  registration LV `save` handler.
- `just_confirmed` flash-sniffing in `overview.ex` is gone, along with
  the JS gtag `sign_up` branch in the SignUpTracking hook.
- `integrations_controller.ex` now sends both new + returning OAuth
  users to `/app` (was: only new users to `/app`, returning users to
  `/app/users/settings`). Unifies the post-login landing surface.
- GA4 MP wiring: `config/runtime.exs` reads `GA4_MEASUREMENT_ID` +
  `GA4_MP_API_SECRET` from `envs/<env>.env`. Test/dev/prod each have
  their own stream. Prod secret deployed via
  `./scripts/deploy-secrets.sh prod`.
- Tests: `test/code_my_spec/users/signup_analytics_test.exs` (6
  telemetry-contract assertions including "dispatch failure does not
  crash signup") + `test/code_my_spec/analytics/google_analytics_test.exs`
  (cassette-backed real-round-trip to `/mp/collect`, api_secret scrubbed).

Commit refs: `b11c6b77` (analytics migration), `54f473c1` (OAuth
redirect unification), `77010e72` (Mix.env fix), `e8511514` (Wallaby
suite + release-safety guard).

### Wallaby e2e signup suite ✅ SHIPPED

The 9-day drought happened in part because no end-to-end test exercised
the post-callback signup render. That's now covered:

- `test/e2e/signup_email_test.exs` — magic-link signup, full path
- `test/e2e/signup_github_test.exs` — real github.com login → callback
- `test/e2e/signup_google_test.exs` — Google equivalent (skip-when-unset)

Runs via `mix test --only e2e`. Excluded from default `mix test` to keep
the regular suite fast.

---

## ⚠️ TESTING GUIDANCE FOR THIS WORK

**Both of these test groups MUST keep passing after Stories B/C/D/E:**

1. **`mix test --only e2e`** — the Wallaby signup tests assert against
   the actual rendered surfaces of `/users/register`, the magic-link
   email body, and `/app`. Story B rewrites register-page copy. If your
   copy changes break a selector or text the e2e test looks for,
   **update the test**, don't work around it. The test is the contract
   that prevents the next 9-day drought.

2. **`mix test`** (default suite) — the release-safety guard
   (`test/release_safety_test.exs`) and the analytics contract tests
   (`signup_analytics_test.exs`) must stay green. None of B/C/D/E
   should touch `Users.register_user`, `Users.find_or_register_oauth_user`,
   `Analytics.dispatch`, or anything under `lib/code_my_spec/analytics/`.

3. **The retired-phrases regression spec** that Stories B and D ask
   you to build is the durable infrastructure. Build it once, apply it
   across all marketing surfaces (`/users/register`, `/`,
   `/products/code-my-spec`, FAQ, anywhere else). Source the retired
   phrases from `marketing/06_messaging.md` "Phrases to retire,
   permanently" — either parse at compile time or maintain a synced
   module attribute with a CI check.

4. **For Story C (login restructure):** if you remove or restructure
   form fields, update `test/code_my_spec_web/live/user_live/login_test.exs`
   AND check that `test/code_my_spec_web/controllers/user_session_controller_test.exs`
   still passes (password POST endpoint behavior unchanged; UI just
   stops surfacing it).

5. **For Story E (MMS page deletion):** verify `mix test` still passes
   and `curl -I https://codemyspec.com/products/market-my-spec` returns
   `301` with `Location: https://marketmyspec.com`.

---

## TL;DR (remaining work)

The 9-day signup drought had multiple causes. The release crash and the
analytics contamination are fixed. What remains is the marketing-copy /
CRO drift from the 2026-05-07 strategy revert that never fully shipped:

1. ~~**`Mix.env()` crash in a prod release**~~ — ✅ shipped (handoff above)
2. **`/users/register` hero uses retired-phrases-list copy** from
   `marketing/06_messaging.md`. (Story B)
3. **`/users/log-in` has three competing auth methods at near-equal
   visual weight** — the page got 5× more first-time traffic than the
   register page on 5/18 with 0% conversion. (Story C)
4. **Homepage carries the same retired-phrase problem** in three
   different places (hero, subhead, Section 03 heading). The 5/07
   revert was partial. (Story D)
5. **`/products/market-my-spec` is a full MMS sales page** living on
   codemyspec.com when strategy says MMS lives at marketmyspec.com.
   (Story E)

---

## Diagnostic evidence (so the agent doesn't have to re-derive this)

### Funnel data, 2026-05-18

| Metric | Value | Notes |
|---|---|---|
| Sessions | 105 | +33% vs Sunday (record day) |
| Total users | 84 | |
| New users (GA4) | 57 | |
| Pageviews | 321 | |
| Traffic from Reddit | 59% | 49 sessions tagged `reddit/comment` + 9 referral |
| `/users/log-in` pageviews | 74 (16 unique users) | 5× more traffic than register page |
| `/users/register` pageviews | 15 (9 unique users) | |
| GA4 `sign_up` events | 7 events / 4 users | False positives — **fixed** in handoff above |
| **Actual new User rows created in prod** | **0** | Verified via `Repo.all(CodeMySpec.Users.User)` |

### Prod User table state (verified 2026-05-19)

```
Total users: 56
Most recent before today: shickcoong777@gmail.com, 2026-05-10 06:33 UTC, OAuth
Most recent today (post-diagnostic): johns10davenport@gmail.com, 2026-05-19 23:24 UTC, OAuth
```

The 9-day gap was real. OAuth-flow technical layer works (DB writes
succeed). With Story A fixed, the remaining bottleneck is upstream of
OAuth: visitors aren't completing the flow because of retired marketing
copy + login page friction.

---

## Files in scope

| Path | Story | Change shape |
|---|---|---|
| `lib/code_my_spec_web/live/user_live/registration.ex` | B | Replace hero copy + supporting bullet |
| `lib/code_my_spec_web/live/user_live/login.ex` | C | Restructure auth method hierarchy |
| `lib/code_my_spec_web/components/layouts.ex` | C + E | Nav CTA copy + MarketMySpec links |
| `lib/code_my_spec_web/controllers/page_html/home.html.heex` | D + E | Hero + section heading + Section 02 MMS card link |
| `lib/code_my_spec_web/controllers/page_html/market_my_spec.html.heex` | E | DELETE entirely |
| `lib/code_my_spec_web/router.ex` | E | Add 301 redirect for `/products/market-my-spec` |

## Files explicitly out of scope

- `lib/code_my_spec_web/live/app_live/overview.ex` — Story A done; do
  not re-touch.
- `lib/code_my_spec/users.ex`,
  `lib/code_my_spec_web/controllers/integrations_controller.ex`,
  `lib/code_my_spec_web/live/user_live/registration.ex#save` analytics
  dispatch, `lib/code_my_spec/analytics/**` — backend-reported events
  workstream done; do not re-touch the dispatch sites or the analytics
  module surface.
- `lib/code_my_spec_web/controllers/user_session_controller.ex` —
  password POST endpoint behavior unchanged; Story C just stops
  surfacing it in the UI.
- `lib/code_my_spec_web/live/content_live/pages/market_my_spec.ex` —
  this is the **case study** at `/case-studies/market-my-spec`, not MMS
  marketing. It's CMS recursion proof ("the engineering harness built
  MMS"). Stays as-is.
- `/products/code-my-spec` Phoenix lens audit — already owned by
  `08_plan.md` Month 1 exit criteria as separate work.
- MetricFlow proof reference on register page
  (`registration.ex:62-68`) — separate strategic decision (MetricFlow
  isn't publicly launched yet); flag for follow-up but don't touch in
  this story.

## Strategy references (agent should read these before designing changes)

- `marketing/05_positioning.md` — canonical phrases for Lens A
  (engineer-founder) and Lens B (Phoenix), competitive frame, "what
  positioning does NOT say."
- `marketing/06_messaging.md` — by-persona messaging, **retired
  phrases section** (source of truth for what NOT to use), proof
  inventory.
- `marketing/08_plan.md` — Month 1 + Month 2 exit criteria, what's
  already owned where.

**Critical retired phrases (verbatim from `06_messaging.md` "Phrases to retire, permanently"):**

> - "Run your business — marketing, engineering, ops — from one terminal" (the 4/27 platform-as-wedge headline).
> - "Platform of harnesses for the founder doing every job" (the 4/27 hero — reverted to "platform of harnesses for the engineer-founder shipping a real product").

These two phrases (or close paraphrases of them) appear on both the
register page and the homepage. Eliminating them is the core of
Stories B and D.

---

## Story B — `/users/register` hero copy refresh

### Problem

Current hero on `lib/code_my_spec_web/live/user_live/registration.ex:23-27`:

```heex
<h1 class="font-display text-4xl ...">
  Run your business —
  <span class="text-primary">marketing, engineering, ops</span>
  — from <span class="bg-primary/15 px-1">one terminal</span>.
</h1>
```

This is the **literal retired phrase** from `06_messaging.md`. Reddit
traffic from r/ClaudeAI / r/elixir is currently landing on 4/27
platform-as-wedge copy that explicitly contradicts current positioning.

### Acceptance criteria

1. Replace the hero with one of the canonical Lens A engineer-founder
   phrases from `05_positioning.md`. **Recommended default (ship without
   testing):**

   > **"If your AI-generated codebase is starting to slip, this is the harness that holds it together."**

   This matches Reddit-funnel intent (r/ClaudeAI methodology threads
   are the dominant traffic source) and is the canonical Lens A hook
   in the positioning doc.

   Alternative phrases (pick one if the recommended doesn't fit the
   visual):
   - "Lovable builds the demo. CodeMySpec builds the app you can still maintain in two years."
   - "Prompting is praying. Verification is a guarantee."

2. Review the subhead (`registration.ex:29-31`) and three bullets
   (`registration.ex:33-56`) for alignment with the new hero. Current
   state:
   - Subhead "A Claude Code plugin platform. One harness per domain.
     Bring your own Claude. Bring your own keys. We don't markup
     tokens." — **on-strategy, keep.**
   - First bullet "One plugin model. One brand. Marketing, engineering,
     ops as a system — not chat windows." — **residual
     platform-as-wedge framing, replace.** Suggested: an
     engineer-founder-aligned bullet pulling from `06_messaging.md`
     VP-CMS-1 (codebase won't rot) — e.g., "Architecture stays clean
     as AI volume goes up. Specs, contexts, decisions — the boundaries
     the harness enforces."
   - Second bullet "Passwordless from day one." — **on-strategy,
     keep.**
   - Third bullet "Built in the open, in the order I needed them." —
     **on-strategy, keep.**

3. **Regression-prevention spec (shared with Stories D and E):** add a
   test that asserts no rendered marketing surface contains any phrase
   from the `06_messaging.md` "Phrases to retire, permanently" list.
   Either parse the retired-phrases list at test compile time, OR
   maintain a `@retired_phrases` module attribute synced with the doc.
   Apply to `/users/register`, `/`, `/products/code-my-spec`, FAQ, any
   other marketing-surface LiveView. **This is the linter that
   prevents marketing strategy from quietly drifting back into the
   codebase.** Build once, reuse across surfaces.

4. **e2e impact:** if your hero text changes the selector or copy that
   `test/e2e/signup_email_test.exs` asserts (it currently checks
   `h2 "Get started."`), update the test to match the new content.
   Don't break the test as a side effect.

5. **QA pass:** agentic browser pass on `/users/register` — verify
   rendering, no retired phrases, CTAs functional, OAuth buttons still
   primary.

---

## Story C — `/users/log-in` restructure (OAuth-primary, drop password form)

### Problem

`lib/code_my_spec_web/live/user_live/login.ex` currently renders three
competing auth methods of near-equal visual weight:

1. **Magic-link form** with primary "Log in with email →" button (lines 37-56)
2. **OAuth buttons** GitHub + Google as outline buttons, secondary visual weight (lines 58-84)
3. **Separate password form** with TWO buttons "Log in and stay logged in" + "Log in only this time" (lines 88-116)

Six visible CTAs, no clear path. Yesterday's data: `/users/log-in` got
74 pageviews from 16 unique users with zero conversion to product
activation. The page is receiving 5× more first-time traffic than
`/users/register` and has the worst conversion shape on the site.

### Acceptance criteria

1. **Restructure auth method hierarchy.** Target shape:
   - **Primary:** "Continue with GitHub" — full-width primary button,
     dominant visual weight (use the same chamfered + glowing treatment
     the register page uses on `registration.ex:88-101`)
   - **Secondary:** "Continue with Google" — full-width secondary
     button (match register page styling)
   - **Divider:** "or send a login link"
   - **Magic-link form:** single email field + one button ("Email me a
     login link")
   - **Password form:** **drop entirely.**

2. **Password form rationale for dropping:** of the 56 users currently
   in prod, the vast majority have `has_password: false` (OAuth
   signups). Password is dead surface area. If retention is a concern,
   hide behind a `<details>` disclosure labeled "Advanced login
   options" rather than rendering inline. Recommend dropping outright.

3. **Local mail adapter alert (lines 27-35) — keep.** Conditional
   render is correct.

4. **Header subcopy:** simplify to match the new hierarchy. "Don't
   have an account? Sign up" subtitle link is fine.

5. **BDD spec updates:**
   - `test/code_my_spec_web/live/user_live/login_test.exs` (or
     equivalent) — update UI assertions. OAuth buttons should be
     visually prominent (assert presence + primary class). Magic-link
     form remains functional. Password form assertions removed (or
     moved to disclosure-state assertions).
   - `test/code_my_spec_web/controllers/user_session_controller_test.exs`
     — password POST endpoint behavior unchanged; UI just no longer
     surfaces it.

6. **Nav CTA copy change (`layouts.ex:280` and `:371`):** "Register" →
   "Get started" in both desktop and drawer nav. "Log in" stays for
   now (visual hierarchy demotion is a separate decision).

7. **QA pass:** agentic browser pass on `/users/log-in` — verify
   OAuth-primary visual hierarchy, magic-link still works end-to-end,
   password form gone or hidden.

---

## Story D — Homepage hero + section heading revisions

### Problem

`lib/code_my_spec_web/controllers/page_html/home.html.heex` is
**partially-reverted** — the Section 03 two-audience framing (Solo
technical founder + Elixir agency) matches the 5/07 strategy
correctly, but three other places still carry 4/27 platform-as-wedge
language:

| Line | Current | Issue |
|---|---|---|
| 14-16 | "Run your entire software business **from your terminal.**" | Effectively the retired "Run your business — marketing, engineering, ops — from one terminal" with one comma fewer. Same hero, lightly disguised. |
| 18 | "platform of harnesses for the **technical** founder shipping a real product" | Should be "**engineer-founder**" per `05_positioning.md` canonical phrase. |
| 156-157 | "Built for the **founder doing every job.**" | Literal use of the retired "platform of harnesses for the founder doing every job" hero. |
| 70-76 | "Technical founders aren't running a smaller version of a software company. You're running every department of one." | "Every department of one" framing is residual platform-as-wedge. Needs reframe around the engineer-and-agency audience. |

### Acceptance criteria

1. **Replace homepage hero (lines 13-19).** Use the canonical phrasing
   from `05_positioning.md`:

   > **"CodeMySpec is a platform of harnesses for the engineer-founder shipping a real product. Build it. Market it. Support it. Each harness is a Claude Code plugin that turns one of those jobs from chat-window vibes into a system with a cadence."**

   That's the full canonical phrase. Suggested H1 + lead split:
   - **H1:** "Ship a real product. Hold the codebase together." (or
     pull from Lens A: "If your AI-generated codebase is starting to
     slip, this is the harness that holds it together.")
   - **Lead paragraph:** the canonical platform sentence verbatim.

   Craft call — the harness sentence is long; agent picks H1 / lead
   split that reads naturally without losing the canonical phrasing.

2. **Subhead/intro (line 18):** replace "technical founder" with
   "engineer-founder." Single word change but the positioning doc is
   explicit about this distinction.

3. **Section 03 heading (lines 156-157):** replace "Built for the
   founder doing every job." Suggested: "Built for engineers shipping
   product." OR pull from `06_messaging.md` engineer-founder lens
   phrases. Specific copy is a craft call — anything that's not the
   retired phrase.

4. **Section 01 "the_frame" body (lines 70-76):** reframe to lead with
   the engineer-and-agency audience and the harness as the discipline
   that keeps work compounding. Pull from `06_messaging.md` VP-CMS-1
   (codebase won't rot) framing. Specific copy is a craft call.

5. **The same retired-phrases regression spec from Story B applies
   here** — the lint check should cover the homepage template AND all
   marketing LiveViews/templates, not just the register page.

6. **QA pass:** agentic browser pass on `/` — verify no retired
   phrases anywhere, hero renders correctly, Section 03 two-audience
   framing intact (don't touch what's working).

---

## Story E — Delete `/products/market-my-spec`, 301 redirect to marketmyspec.com

### Problem

`lib/code_my_spec_web/controllers/page_html/market_my_spec.html.heex` is
currently ~560 lines of full MMS sales copy living on codemyspec.com —
hero, three skills cards (`/marketing-strategy`, `/daily-plan`,
`/marketing-stack`), 6-phase flow, industries grid, 17-recipe
directory, proof section, two-harness comparison, FAQ, install CTA.

Per `marketing/05_positioning.md` revision 2026-05-07:

> `/products/market-my-spec` becomes a thin reference page that points to **marketmyspec.com**. MarketMySpec is a sister product; its full positioning lives on its own domain.

Per `marketing/06_messaging.md`:

> MMS messaging — VP-MMS-1 through VP-MMS-5 from the 4/27 doc, the marketing-as-system pitch, the cross-industry adaptive proof points, founder-venue messaging — moves to **marketmyspec.com's messaging doc** when its strategy is set up.

**Strategy override (decided 2026-05-19):** the "thin reference page"
approach from the strategy docs is being overridden. Cleaner direction:
**delete the page entirely + 301 redirect to marketmyspec.com.** Less
to maintain, no risk of stale MMS copy creeping back in. marketmyspec.com
is live; if anyone wants to tune the MMS pitch, that's where it happens.

### Acceptance criteria

1. **Delete `lib/code_my_spec_web/controllers/page_html/market_my_spec.html.heex`**
   plus any controller action that renders it.

2. **Replace the route with a 301 permanent redirect to
   `https://marketmyspec.com`.** Either:
   - Phoenix router-level redirect (`get "/products/market-my-spec",
     PageController, :market_my_spec_redirect` with a minimal
     controller action that returns `redirect(conn, external:
     "https://marketmyspec.com") |> put_status(:moved_permanently)`),
     OR
   - Plug-level redirect in the router.

   **Why 301 and not 404:** the page is indexed in GSC and has
   accumulated impressions. A redirect preserves link equity and lets
   external backlinks / bookmarks resolve usefully.

3. **Update all internal links pointing at `/products/market-my-spec`
   to point directly at `https://marketmyspec.com`:**
   - `lib/code_my_spec_web/components/layouts.ex:264` — nav Products
     submenu MarketMySpec link
   - `lib/code_my_spec_web/components/layouts.ex:354` — drawer nav
     MarketMySpec link
   - `lib/code_my_spec_web/controllers/page_html/home.html.heex:126` —
     Section 02 harness card "See MarketMySpec" link
   - `lib/code_my_spec_web/controllers/page_html/home.html.heex:399`
     (approximate) — `<.install_card harness="marketmyspec"
     brief_url=...>` — verify and update if it points at
     `/products/market-my-spec`
   - `grep -rn '/products/market-my-spec' lib/ priv/` — replace every
     remaining reference

4. **External links use `target="_blank" rel="noopener noreferrer"`**
   so visitors don't lose codemyspec.com context.

5. **Do not touch**
   `lib/code_my_spec_web/live/content_live/pages/market_my_spec.ex`
   (the case study at `/case-studies/market-my-spec`). That page
   documents how the engineering harness built MMS — it's CMS
   recursion proof, not MMS marketing. Different surface, different
   intent, stays.

### Verification

- `curl -I https://codemyspec.com/products/market-my-spec` returns
  `HTTP/1.1 301 Moved Permanently` with `Location:
  https://marketmyspec.com`
- Visiting any "MarketMySpec" link from the homepage nav or Section 02
  lands directly on marketmyspec.com (one hop, not two)
- `grep -rn '/products/market-my-spec' lib/ priv/` returns only the
  redirect handler itself
- The `/case-studies/market-my-spec` page is untouched

### Strategy doc follow-up (post-ship)

The current `marketing/05_positioning.md` and `08_plan.md` Month 1
exit criteria both say "reduce to thin reference page pointing to
marketmyspec.com." After shipping this story, update both strategy
docs to reflect the cleaner approach — "thin reference page" → "301
redirect to marketmyspec.com." Otherwise the docs will drift back into
a stale recommendation the next time someone audits.

This is a marketing-repo edit
(`/Users/johndavenport/Documents/github/code_my_spec_marketing/`), not
a code-repo edit. Flag for John; don't bundle into this PR.

---

## Recommended shipping order

1. **Stories B + D together** — both are retired-phrase removal +
   share the regression-prevention lint. One PR, one round of QA. The
   retired-phrases spec is the durable infrastructure piece — build it
   once in this PR, reuse forever.
2. **Story C** — own PR. Login restructure has its own test surface
   and visual QA pass.
3. **Story E** — own PR. Page deletion + redirect + link updates. Easy
   to verify with `curl` + grep, but worth isolating so a single PR
   diff makes the change reviewable.

Total: 3 PRs (Story A already shipped). B+D, C, E can run in parallel.

---

## Why all four are still in one issue file

All four trace back to the 2026-05-07 marketing revert not fully
shipping on the codemyspec.com surfaces. Bundling them as one issue
keeps the diagnostic context intact (what we measured, why we know
this is the problem, what's in/out of scope). The agent breaks them
into separate stories / PRs per the shipping order above; the issue
itself is the shared brief.

---

## Out-of-scope items (re-stated for clarity)

- **`/products/code-my-spec` Phoenix lens audit** — `08_plan.md` Month
  1 exit criteria, separate work.
- **MetricFlow proof reference on register page
  (`registration.ex:62-68`)** — MetricFlow isn't publicly launched.
  Removing the reference is a separate strategic call; flag for
  follow-up.
- **Case study page (`/case-studies/market-my-spec`)** — stays. CMS
  recursion proof, not MMS marketing.
- **Strategy doc updates** to reflect the "delete + redirect" approach
  in Story E — marketing-repo work, not code-repo work. Flag for John
  separately.
- **Re-touching the Story A or analytics work shipped in the 2026-05-19
  session** — see handoff notes at top. Tests guard it; don't drift
  back into those surfaces.
