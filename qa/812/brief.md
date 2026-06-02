# QA Brief — Story 812: Analytics Tracking and Traffic Filtering

## Tool

web (Vibium MCP browser tools) for browser-pipeline pages (port 4000); curl for the `/api/browser/analytics/event` endpoint

## Auth

The browser-pipeline tests target public marketing pages (`/`, `/users/register`) that do not require authentication.

For the analytics event API endpoint, a CSRF token is required. Obtain it from a browser session:

1. Navigate to `http://127.0.0.1:4000/` with the browser
2. Capture the CSRF meta tag value from the page HTML
3. Use the CSRF token in the `x-csrf-token` header for curl calls to `/api/browser/analytics/event`

The QA seeds script at `mix run priv/repo/qa_seeds.exs` creates `qa@codemyspec.local` / `qa-password-123!` if authenticated access to `/app` is needed.

## Seeds

No story-specific seeds required. The analytics surface is public (marketing pages, register page, browser API endpoint).

```
mix run priv/repo/qa_seeds.exs
```

Run seeds only if testing authenticated paths (onboarding, `/app` install step).

## What To Test

### Scenario 1: Root layout has no gtag.js (criterion 6517)

- Navigate to `http://127.0.0.1:4000/`
- Inspect the page HTML source
- Assert: no `<script src="...googletagmanager.com/gtag/js...">` tag in the HTML
- Assert: no inline `gtag(...)` calls in the HTML

### Scenario 2: window.GA_MEASUREMENT_ID never set in browser (criterion 6518)

- Navigate to `http://127.0.0.1:4000/`
- Inspect the rendered HTML for `window.GA_MEASUREMENT_ID` — must be absent
- Inspect `assets/js/app.js` source for `GA_MEASUREMENT_ID` references — must be absent
- Assert: no `gtag(...)` calls in app.js

### Scenario 3: Click events route through analytics API, not gtag (criterion 6520)

- Inspect `assets/js/app.js` source
- Assert: `fireCopyEvent` function POSTs to `/api/browser/analytics/event` (not gtag)
- Assert: `cta_click` handler POSTs to `/api/browser/analytics/event`
- Assert: no `gtag(...)` calls anywhere in app.js

### Scenario 4: GA4 measurement ID in server config only (criterion 6521)

- Search `lib/code_my_spec_web/`, `assets/js/`, `assets/css/` for `G-[A-Z0-9]{7,}` pattern
- Assert: any matches exist only in `config/` or `priv/` directories

### Scenario 5: page_view dispatches on every browser-pipeline pageload (criterion 6498)

- Navigate to `http://127.0.0.1:4000/`
- Verify `CodeMySpecWeb.Plugs.PageView` is in the router's browser pipeline
- Confirm the plug dispatches `:page_view` via `Analytics.dispatch/3`
- Source inspection: `lib/code_my_spec_web/plugs/page_view.ex` and router `plug CodeMySpecWeb.Plugs.PageView`

### Scenario 6: page_view originates from server plug, never from gtag (criterion 6519)

- Navigate to `http://127.0.0.1:4000/` with a browser user-agent
- Inspect response HTML — assert no `gtag('event', 'page_view', ...)` calls present
- Confirm the page_view plug (server-side) is the only dispatch path (verified via source)

### Scenario 7: Known-bot / empty-signal requests are filtered (criterion 6501)

- Source inspection: `lib/code_my_spec_web/plugs/page_view.ex`
- Confirm `@bot_patterns` includes `bot`, `crawler`, `spider`, `scraper`, `headlesschrome`
- Confirm `dispatch?/1` returns false when UA is a bot pattern
- Confirm `dispatch?/1` returns false when both UA and Referer are empty

### Scenario 8: Homepage hero install card fires install_command_copy (criterion 6502)

- Navigate to `http://127.0.0.1:4000/`
- Inspect page HTML for `.copy-btn[data-event-name="install_command_copy"][data-event-location="homepage_hero"]`
- Capture CSRF token, then POST to the analytics API:
  ```
  curl -s -X POST http://127.0.0.1:4000/api/browser/analytics/event \
    -H "content-type: application/json" \
    -H "x-csrf-token: <csrf_token>" \
    -d '{"name":"install_command_copy","params":{"location":"homepage_hero","harness":"codemyspec"}}'
  ```
- Assert: response is `{"status":"ok"}`

### Scenario 9: All four install-card placements fire with the right location (criterion 6503)

- Inspect source for all copy-btn placements:
  - `home.html.heex` — `homepage_hero`
  - `code_my_spec.html.heex` — `product_page_top`, `product_page_final`
  - `marketing_components.ex` — component with `@location` attribute
- Navigate to each page via Vibium and confirm copy buttons have the correct `data-event-location`

### Scenario 10: Register page mount dispatches :view_register_page (criterion 6504)

- Navigate to `http://127.0.0.1:4000/users/register` via Vibium
- Source inspection: `lib/code_my_spec_web/live/user_live/registration.ex` line with `connected?(socket)` → `Analytics.dispatch(:view_register_page)`
- Assert: the dispatch fires on connected LiveView mount

### Scenario 11: /api/browser/analytics/event endpoint responds correctly (criteria 6502, 6503, 6506)

- POST a valid event and assert `{"status":"ok"}` response
- POST with invalid event name and assert `{"error":"invalid event name"}` + 400 response
- POST with missing event name and assert `{"error":"missing event name"}` + 400 response

## Result Path

`.code_my_spec/qa/812/result.md`

## Setup Notes

Most of these tests are source-inspection or lightweight HTTP probes — no complex auth flows needed. The implementation is largely complete for the R6 "no gtag" criteria (6517-6521): the root layout has no gtag script, app.js uses the analytics API, and the PageView plug is wired in the browser pipeline.

Tests relying on the GA Measurement Protocol cassette (criteria 6498, 6499, 6500, 6501, 6504) use in-process spex patterns with `ReqCassette`. The QA surface for these is: (1) source inspection to confirm the plug/dispatch is in place, and (2) live HTTP probes confirming the endpoint responds correctly.

Screenshots should be saved to `.code_my_spec/qa/812/screenshots/` (copy from `~/Pictures/Vibium/` after capture).
