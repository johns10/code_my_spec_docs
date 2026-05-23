# Analytics Tracking and Traffic Filtering

**Story owner:** John (CodeMySpec)
**Filed:** 2026-05-23
**Status:** 5 of 9 rules shipped, 4 open

## Story

**As the owner of CodeMySpec, I want to track user traffic and key events, filtering out unwanted traffic on the backend, so I can read the funnel end-to-end without prod cross-checks.**

The funnel-establishment work that's been running across the last two weeks has produced a working but partial pipeline. This story unifies it: 9 rules cover the complete analytics tracking surface. 5 are already shipped (the implementation is real; the scenarios are reference). 4 remain open and constitute the work in scope for closing this story.

## Out of scope

- Funnel-level CRO work on specific pages (`/`, `/products/code-my-spec`). Those are page-level concerns tracked in separate issues.
- Marketing copy / messaging changes. Tracked in `signup-funnel-leak-and-release-crash.md` (Stories B/D/E).
- New activation events not currently fired by the application. When new events get added in the future, add a new scenario under Rule 2.

## Existing reference

- `ga4-missing-signup-event-trace.md` — Rules 1, 3, 8 supporting context.
- `ga4-register-custom-dimensions.md` — Rule 5 supporting context (closed).
- `ga4-bot-referral-exclusion-filter.md` — Rule 7 supporting context (to be reframed/closed in favor of this story).
- `signup-funnel-leak-and-release-crash.md` — Story A/A2 (analytics dispatch + Wallaby e2e) already shipped, see Rule 1.

---

## Rule 1 — Server-side dispatch is the authoritative signal for signup events

**Why it matters:** Browser-side gtag fires were contaminated by the OAuth flash bug, double-firing on returning logins. Server-side dispatch from authoritative DB inserts is the only contract we can verify.

**Status:** ✅ Shipped (commit `b11c6b77`, deployed prod fly v196 on 2026-05-20).

### Scenarios

```
Scenario: New magic-link signup dispatches sign_up
  Given a visitor with no existing user row
  When they submit the magic-link form on /users/register
  Then Users.register_user/1 inserts a new users row
  And :sign_up dispatches via telemetry with method: "magic_link" and user_id: <new id>
  And :registration_email_sent dispatches after deliver_login_instructions/2 returns {:ok, _}

Scenario: New OAuth signup (:new branch) dispatches sign_up
  Given a visitor with no provider identity matching their OAuth login
  And no existing user row matching their OAuth email
  When they complete the OAuth callback
  Then Users.find_or_register_oauth_user/2 returns {:ok, user, :new}
  And :sign_up dispatches with method: "oauth_<provider>" and user_id: <new id>

Scenario: Returning OAuth login does NOT redispatch sign_up
  Given an existing user with a provider identity match
  When they complete the OAuth callback
  Then Users.find_or_register_oauth_user/2 returns {:ok, user, :existing}
  And no :sign_up event dispatches

Scenario: OAuth email-auto-link branch does NOT redispatch sign_up
  Given an existing user with a matching email but no provider identity
  When they complete the OAuth callback for a new provider
  Then the integration is linked silently
  And no :sign_up event dispatches
  And the silence is documented at the dispatch site
```

---

## Rule 2 — Activation events fire at well-defined moments

**Why it matters:** Activation events define the funnel between register-page-view and CLI-connected. Each event should fire exactly once per user-intent at a deterministic application moment.

**Status:** ✅ Mostly shipped. All 11 events defined in `lib/` are wired. Coverage gap: page_view reliability on mobile-app webviews (see Rule 9).

### Scenarios

```
Scenario: Register-page view fires server-side
  Given a visitor lands on /users/register
  When the LiveView mounts with connected?(socket) == true
  Then :view_register_page dispatches via Analytics.dispatch(..., :server)

Scenario: OAuth button click fires browser-side
  Given a visitor on /users/register
  When they click the GitHub OAuth button
  Then gtag fires the event "oauth_github_clicked"
  And :registration_path_chosen fires with method: "github"

Scenario: Install command copy fires with harness and location
  Given a visitor on / or /products/code-my-spec
  When they click the copy button on any install_card
  Then gtag fires "install_command_copy" with data-event-name attribute
  And the event carries harness: <name> and location: <site> parameters
  And the event is queryable by both custom dimensions in GA4

Scenario: First CLI connection fires server-side
  Given a registered user with no prior CLI connection
  When their CLI WebSocket joins cli_channel for the first time
  Then :first_cli_connect dispatches with user_id: <id>
  And subsequent CLI connections from the same user do NOT redispatch

Scenario: Onboarding panel view fires server-side
  Given a user who has just completed signup
  When they land on /app and the onboarding panel renders
  Then :onboarding_panel_viewed dispatches with user_id: <id>

Scenario: Install step copy fires per-step
  Given a user viewing the install wizard
  When they copy a step's command
  Then :install_step_copied dispatches with step: <name> and user_id: <id>
```

---

## Rule 3 — GA4 events are deterministically traceable from server logs

**Why it matters:** Without structured dispatch logs, missing events (Hypothesis B in `ga4-missing-signup-event-trace.md`) require manual prod log archaeology. With them, every dispatch decision leaves a `grep mp_status=` trail.

**Status:** ✅ Shipped 2026-05-23 (other agent).

### Scenarios

```
Scenario: Successful MP delivery logs structured success
  Given a server-side dispatched event reaches the GoogleAnalytics handler
  When the MP HTTP POST returns 200 or 204
  Then the log emits at INFO level
  And the log contains event=<name> user_id=<id> mp_status=200

Scenario: Non-2xx MP response logs structured failure
  Given a server-side dispatched event reaches the GoogleAnalytics handler
  When the MP HTTP POST returns a non-2xx response
  Then the log emits at WARNING level
  And the log contains event=<name> user_id=<id> mp_status=<status>

Scenario: HTTP transport error logs structured failure
  Given a server-side dispatched event reaches the GoogleAnalytics handler
  When the HTTP adapter raises or returns {:error, _}
  Then the log emits at WARNING level
  And the log contains event=<name> user_id=<id> mp_status=:http_error|:raised|:threw

Scenario: Missing API secret logs structured skip
  Given the GA4_MP_API_SECRET is not configured
  When an event reaches the handler
  Then the log emits at WARNING level
  And the log contains event=<name> mp_status=skipped
  And no HTTP POST is attempted
```

---

## Rule 4 — Browser-side gtag uses environment-appropriate measurement ID

**Why it matters:** `lib/code_my_spec_web/components/layouts/root.html.heex:83` hardcodes `gtag('config', 'G-EHBYEW52MM')` — the prod measurement ID — into every served HTML across every environment. Local dev (127.0.0.1) and staging (dev.codemyspec.com) pollute the prod GA4 property. The env-specific `GA4_MEASUREMENT_ID` from `envs/<env>.env` is only consumed by the server-side Measurement Protocol handler, not by the client-side gtag config.

**Status:** 📋 Open. Engineering work required.

### Scenarios

```
Scenario: Prod host uses prod measurement ID
  Given a visitor on codemyspec.com
  When the page renders
  Then gtag is configured with the prod measurement ID (G-EHBYEW52MM)
  And events fire to the prod GA4 property

Scenario: Staging host uses staging measurement ID
  Given a visitor on dev.codemyspec.com
  When the page renders
  Then gtag is configured with the staging measurement ID (G-4M2Y8WF7S8 or similar)
  And events fire to a non-prod GA4 stream

Scenario: Local dev host uses dev measurement ID or none
  Given a developer hitting localhost or 127.0.0.1
  When the page renders
  Then gtag is configured with the dev measurement ID OR not configured at all
  And no events fire to the prod GA4 property

Scenario: Measurement ID comes from runtime config
  Given the application boots
  When the root template renders
  Then the gtag config value is read from Application.get_env(:code_my_spec, :ga4_client_id)
  And the runtime config sources that value from env!("GA4_CLIENT_MEASUREMENT_ID", :string)
```

---

## Rule 5 — Custom dimensions are queryable for slice reads

**Why it matters:** Without registered custom dimensions, custom event parameters are written-but-not-readable in GA4. The install funnel can be sliced by which install-card produced the event only if the dimensions exist.

**Status:** ✅ Shipped 2026-05-23 (via analytics-admin MCP).

### Scenarios

```
Scenario: install_command_copy events queryable by harness dimension
  Given install_command_copy events are firing with harness=<name> param
  When a GA4 report queries customEvent:harness
  Then the dimension is valid and returns event counts grouped by harness

Scenario: install_command_copy events queryable by location dimension
  Given install_command_copy events are firing with location=<site> param
  When a GA4 report queries customEvent:location
  Then the dimension is valid and returns event counts grouped by location
```

(Implementation note: dimensions registered as `properties/508773792/customDimensions/14933011472` and `.../14933188523`.)

---

## Rule 6 — Key activation events surface as conversions in GA4 reports

**Why it matters:** Events that aren't marked as key events don't show up in GA4 conversion reports. The funnel report can't display the activation milestones if they aren't key events.

**Status:** ✅ Shipped 2026-05-23 (via analytics-admin MCP).

### Scenarios

```
Scenario: Each activation event is registered as a key event
  Given an activation event defined in the CMS application
  When GA4 key events are listed
  Then the event appears in the key events list
  And the counting method is ONCE_PER_SESSION

Scenario: Inventory matches the application's dispatched events
  Given the application dispatches N distinct activation events
  When the operator audits GA4 key events
  Then every dispatched activation event maps to a registered key event
```

(Implementation note: as of 2026-05-23, the following are registered as key events: `sign_up`, `view_register_page`, `deep_content_read`, `first_cli_connect`, `install_command_copy`, `registration_email_sent`, `oauth_github_clicked`, `oauth_google_clicked`, `onboarding_panel_viewed`, `install_step_copied`. The `purchase` system default is present but unused. If a new activation event is added in CMS, register it as a key event in the same pass.)

---

## Rule 7 — Real Reddit traffic attributes to Reddit, not `(not set)`

**Why it matters:** Reddit mobile-app users (with `android-app://com.reddit.frontpage/` referrer) and Reddit web users with stripped UTM params end up in the `(not set)/(not set)` bucket with 0% engagement. On 2026-05-22, this bucket was 40% of prod traffic — distorting every funnel ratio. Originally framed as a bot-filter problem; analysis on 2026-05-23 confirmed these are real humans with attribution failures, not bots.

**Status:** 📋 Open. Engineering work required.

### Scenarios

```
Scenario: Reddit mobile-app user attributes as Reddit
  Given a visitor arrives with HTTP referrer "android-app://com.reddit.frontpage/"
  When their session is recorded in GA4
  Then session source maps to "reddit"
  And session medium maps to "social" or "app"
  And the session is NOT bucketed as (not set)/(not set)

Scenario: Reddit web user with stripped UTM attributes as Reddit referral
  Given a visitor arrives with HTTP referrer "https://www.reddit.com/" or "https://reddit.com/"
  And no UTM source/medium params are present
  When their session is recorded in GA4
  Then session source maps to "reddit"
  And session medium maps to "referral"
  And the session is NOT bucketed as (not set)/(not set)

Scenario: Truly direct visitor remains direct
  Given a visitor arrives with empty referrer and no UTM params
  And no Reddit-app or Reddit-web signal
  When their session is recorded in GA4
  Then session source maps to "(direct)"
  And session medium maps to "(none)"

Scenario: UTM-tagged Reddit referral attributes by UTM (existing behavior)
  Given a visitor arrives with utm_source=reddit and utm_medium=comment
  When their session is recorded in GA4
  Then session source maps to "reddit"
  And session medium maps to "comment"

Scenario: Attribution drift is monitored
  Given a day's worth of prod traffic
  When the snapshot reads the source/medium distribution
  Then the (not set)/(not set) bucket holds less than 10% of total sessions
  And a warning surfaces if it exceeds 15%
```

(Implementation note: This may require a Phoenix plug that inspects referrer and injects UTM tags into the request before gtag fires, OR a GA4 channel-grouping rule for the android-app://*reddit* pattern, OR both. Approach selection is part of the implementation scope, not the AC.)

---

## Rule 8 — Daily reconciliation surfaces drift between prod inserts and GA4 sign_up events

**Why it matters:** Even with Rule 3's structured logs, a silent MP delivery failure can produce a divergence that the operator only catches by manually cross-checking prod against GA4 (as we did for faturrachman on 2026-05-21/2026-05-22/2026-05-23). A daily reconciliation removes the need for manual checking.

**Status:** 📋 Open. AC #4 of `ga4-missing-signup-event-trace.md`.

### Scenarios

```
Scenario: Reconciliation runs daily
  Given the daily window (yesterday in app timezone)
  When the reconciliation task runs
  Then it queries Repo.all(users where inserted_at in window)
  And it queries GA4 for sign_up events in the same window (UTC-shifted appropriately)
  And it logs the comparison at INFO level

Scenario: Divergence within slack window is silent
  Given the GA4 sign_up count differs from prod inserts by N
  And N is within the documented returning-OAuth slack (typically 0)
  When the reconciliation completes
  Then no warning is emitted

Scenario: Divergence beyond slack window alerts
  Given the GA4 sign_up count differs from prod inserts by N
  And N exceeds the slack window
  When the reconciliation completes
  Then a Logger.warning emits with the diff value and the affected user IDs
  And the warning includes a hint to grep mp_status= in the structured logs

Scenario: Reconciliation handles GA4 sampling and delay
  Given GA4's event ingestion can lag by up to 24-48 hours
  When the reconciliation runs for "yesterday"
  Then it accounts for the GA4 lag by also reading prior-day reconciliation if available
  And the diff is computed with the most-final-available data
```

---

## Rule 9 — Page_view fires reliably even on mobile-webview / app-deeplink sessions

**Why it matters:** Today's characterization showed sessions with `android-app://com.reddit.frontpage/` referrer landing with **empty landingPagePlusQueryString**. That suggests `page_view` events are not firing on these sessions. Empty landing pages also showed up on direct-referrer visits where page_view should have fired but didn't. Without page_view, GA4 can't compute engagement, attribute the session source, or display the path.

**Status:** 📋 Open (newly surfaced 2026-05-23).

### Scenarios

```
Scenario: Mobile-webview session fires page_view
  Given a visitor arrives via android-app:// or in-app webview
  When the page completes loading
  Then page_view fires within 3 seconds of DOMContentLoaded
  And the GA4 session shows a non-empty landingPagePlusQueryString

Scenario: Direct visitor with empty referrer fires page_view
  Given a visitor arrives with empty referrer
  When the page completes loading
  Then page_view fires
  And the GA4 session shows the path as landingPagePlusQueryString

Scenario: Page_view fire is independent of gtag's measurement ID load timing
  Given gtag is fetched async
  When the script loads after DOMContentLoaded
  Then page_view still fires for the initial page
  And subsequent in-app navigations also fire page_view

Scenario: Bounce diagnosis is achievable from the session record
  Given a visitor session with 0% engagement
  When the operator examines the session in GA4
  Then they can see the actual landing page (not empty)
  And they can determine whether the visitor bounced, didn't engage, or had no events fire
```

---

## Acceptance for closing this story

This story closes when:

1. All 9 rules have scenarios that pass executable verification (BDD spec or equivalent).
2. The 4 open rules (4, 7, 8, 9) have shipped implementations:
   - Rule 4: env-aware gtag measurement ID
   - Rule 7: Reddit-attribution rescue (mobile-app + UTM-stripped)
   - Rule 8: daily reconciliation task
   - Rule 9: page_view fire reliability fixes
3. A subsequent daily analytics snapshot reads the funnel end-to-end without requiring `fly ssh console rpc` cross-checks (Rule 8 + Rule 3 combined).
4. The `(not set)/(not set)` source bucket holds <10% of prod traffic across a 7-day rolling window (Rule 7 verification).

When closed, the existing supporting issue files (`ga4-missing-signup-event-trace.md`, `ga4-bot-referral-exclusion-filter.md`) can be marked superseded by this story. `ga4-register-custom-dimensions.md` is already closed.
