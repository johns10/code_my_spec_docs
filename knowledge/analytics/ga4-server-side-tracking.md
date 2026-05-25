# GA4 Server-Side Tracking via the Measurement Protocol

Practical reference for sending `page_view` (and other) events server-side from
an Elixir/Phoenix plug straight to GA4's Measurement Protocol (MP) endpoint. The
problem this feeds: a `(not set)` hostName bucket full of zero-session,
zero-engagement page_views (bot / health-check / monitoring traffic) polluting
the dashboard, plus a ratio like 330 page_views → 7 session_start → 1
user_engagement.

Endpoint (production): `POST https://www.google-analytics.com/mp/collect`
with `?measurement_id=G-XXXX&api_secret=YYYY` in the query string. Body is JSON
with a top-level `client_id` and an `events` array. MP is **stateless and
fire-and-forget**: it does not inherit anything the browser tracked, returns
`204` regardless of payload validity (no error feedback on the prod endpoint),
and de-dupes nothing for you.

---

## 1. hostName / page_location — why path-only lands in `(not set)`

GA4 has **no separate hostName field** in the MP payload. The `hostName`
dimension is **derived by GA4 parsing the host out of the `page_location` event
param**. `page_location` must be the **full absolute URL** — protocol + host +
path + query (`https://app.example.com/foo?x=1`). If you send only a path
(`/foo`) or omit `page_location`, GA4 cannot parse a host, so `hostName` resolves
to `(not set)`. MP hits do **not** inherit `page_location` / host from any
client-side session — whatever the server omits is simply absent.

Canonical `page_view` param set GA4 expects (all live under
`events[].params`):

- `page_location` — full URL **(required for hostName + page path/query
  dimensions)**.
- `page_title` — the document title.
- `page_referrer` — full referrer URL; feeds referral attribution. Optional but
  recommended.

Fix for the `(not set)` bucket: build `page_location` from
`conn.scheme`, the `Host` header (validated — see §3), `conn.request_path`, and
`conn.query_string`, never just the path. A bad/absent host is itself a strong
bot signal (real browsers send a sane `Host`).

---

## 2. Sessions & engagement — the two params that make hits "count"

Two event params, sent **inside `events[].params`** on every event, determine
whether a hit registers as a session and as engagement:

- `session_id` — an identifier (commonly a unix timestamp or stored session
  token) that ties events into one session. A **new** `session_id` value
  creates a new session; you do **not** need to send the reserved `session_start`
  event yourself — GA4 emits `session_start` when it sees a session_id it hasn't
  counted for that client_id within the session window.
- `engagement_time_msec` — engagement time in milliseconds for the event. A
  non-zero value (e.g. `"100"`) is what flips a hit into an **engaged** event /
  produces `user_engagement`. Without it, engagement-derived metrics stay 0.

Events sent **without** these still land in some reports but contribute nothing
to Realtime, Engaged sessions, Average engagement time, or session_start counts.
That is almost certainly the cause of the observed
**330 page_views / 7 session_start / 1 user_engagement** skew: the page_views
arrive, but most carry no `session_id` and no `engagement_time_msec`, so they
never spawn a session or engagement. Google explicitly says: to get activity in
standard + Realtime reports, include **both** `session_id` and
`engagement_time_msec` on the event params.

Caveat: a **randomly regenerated** `session_id` per request is also harmful — it
fragments sessions and can blank out source/medium (→ `(not set)` traffic
source). Keep one session_id stable across a visitor's request burst.

---

## 3. Bot / non-human filtering for server-side MP

**Key finding: GA4's built-in IAB/ABC "International Spiders & Bots" filtering
is effectively a non-factor for our MP hits.** That filter works by matching the
**User-Agent string** of the incoming hit. On the prod MP endpoint there is no
reliable way to forward the original visitor's User-Agent into the hit (the v2
MP does not honor a `User-Agent` for IAB filtering the way the client tag does),
so MP "ghost" hits routinely **bypass** the IAB list — bots that POST MP hits,
and our own server firing on bot requests, sail straight through. Practitioners
are unanimous that the IAB list is necessary-but-insufficient and that
**server-side, you must filter before dispatching the hit.** Do not rely on GA4
to clean this up downstream.

So the decision is **denylist vs allowlist on the inbound request's
User-Agent** (and other request signals), applied in the plug *before* we POST
to MP.

### Denylist (block known non-humans, send everything else)

Drop the hit when the UA matches known non-human agents:
`curl`, `Wget`, `python-requests`, `Go-http-client`, `Java/`, `okhttp`,
`GoogleHC/` (Google health check), `kube-probe`, `Pingdom`, `UptimeRobot`,
`StatusCake`, generic `*bot*`/`*crawler*`/`*spider*`, Cloudflare/uptime probes,
and empty/missing UA. Also denylist by **path** (`/health`, `/healthz`,
`/up`, `/metrics`, `/favicon.ico`, `/robots.txt`) and by missing/invalid `Host`.

- Pro: lets through edge-case real browsers and new/odd legit clients.
- Con: never complete — new scrapers and headless browsers mimicking
  `Mozilla/5.0` slip through; requires ongoing maintenance.

### Allowlist (only send for browser-shaped UAs)

Only dispatch when the UA looks like a real browser: starts with `Mozilla/`
**and** contains a rendering-engine/browser token
(`Gecko`, `WebKit`, `AppleWebKit`, `Chrome`, `Safari`, `Firefox`, `Edg`). Reject
everything else.

- Pro: collapses the entire health-check / monitoring / scripted-client tail in
  one rule; near-zero maintenance; directly fixes the zero-session pollution
  because those agents (`Go-http-client`, `GoogleHC`, `curl`, probes) are **not**
  `Mozilla/`-prefixed.
- Con: well-behaved non-browser legit clients are excluded; sophisticated bots
  that spoof a full `Mozilla/...Chrome...` UA still pass (but those are exactly
  what no UA rule catches, and they're the minority of the observed pollution).

### Practitioner recommendation

For a Phoenix plug whose pollution is dominated by **honestly-self-identifying**
infra traffic (health checks, monitors, curl, Go HTTP clients, Cloudflare
probes), the **allowlist (browser-UA gate) is the recommended primary filter**:
the offending agents are not browser-shaped, so a `Mozilla/` + engine-token gate
removes them wholesale with minimal upkeep, and it fails *closed* (unknown →
not tracked) which keeps the dashboard clean. Layer a small **denylist** on top
for the rare browser-UA-spoofing bot and to short-circuit obvious paths
(`/health`, `/metrics`, bad `Host`). The combined posture — allowlist gate plus
denylist sweep, both *before* the MP POST — is the consensus best practice;
GA4's IAB filtering should be treated as a backstop, not the mechanism.

---

## 4. client_id — anonymous pageviews without collapsing all users

`client_id` is a **required top-level field** and is GA4's primary identity for
unauthenticated visitors. It must vary per visitor:

- **Never** use a constant string like `"anonymous"` / `"server"` — that
  collapses every visitor into a single GA4 "user", destroying user/session
  counts and attribution.
- Preferred: reuse the **browser's `_ga` cookie** client_id when present (format
  `GA1.1.<X>.<Y>` → the client_id is the `<X>.<Y>` tail), so server hits stitch
  to the same user as any client tag.
- No cookie / pure server context: **generate a UUIDv4** (or the legacy `X.Y`
  format, two random 32-bit ints) and **persist it for the visitor** — e.g. set
  it in a first-party cookie or session so subsequent requests reuse the same
  client_id. A fresh client_id every request makes every pageview a new
  one-event user (another way to get the 1-engagement / many-pageview skew).
- If a stable user identifier exists (logged-in user), a SHA-256 hash of it
  yields a deterministic, consistent client_id for that user.

Goal: client_id stable per visitor, varied across visitors.

---

## 5. Other server-side MP gotchas for a per-request page_view plug

- **IP / geo via `ip_override`**: MP does **not** read the request's TCP source
  IP. Without help, all geo is blank or resolves to the server/datacenter. Send
  the visitor IP as **`ip_override`** (top-level) so GA4 derives geography; the
  IP need only geolocate to the right region. There is also a structured
  `user_location` (city / region_id / country_id / subcontinent_id /
  continent_id) which **takes precedence** over `ip_override` when both are sent.
- **`timestamp_micros`** (top-level): set it to the request time (unix micros)
  so events aren't all stamped at delivery time, especially if dispatch is
  queued/batched. MP rejects events older than ~72h.
- **Double-counting with client gtag**: if the page **also** loads `gtag`/GTM
  for the same `page_view`, the server hit and the browser hit both count → ~2x
  page_views and inflated sessions. Pick one source per event, or use a distinct
  event name / a flag (e.g. a custom `traffic_type` or `source` param) and filter
  one out, or share the same `client_id` + `session_id` so GA4 can reconcile.
  For a pure server-side plug with no client gtag, this isn't an issue — but
  confirm gtag isn't also firing `page_view`.
- **Debug / validation endpoint**: validate payloads against
  `https://www.google-analytics.com/debug/mp/collect` (same payload + query
  params). Unlike prod, it returns a JSON body with a
  `validationMessages` array (fieldPath, description, validationCode); an empty
  array means the payload is valid. Events sent here do **not** appear in
  reports. Use it in tests/CI to assert `page_location`, `client_id`,
  `session_id`, and `engagement_time_msec` are well-formed. Prod `/mp/collect`
  always returns `204` and gives **no** validation feedback.
- **Reserved names**: don't hand-send reserved events/params incorrectly;
  `session_start` and `first_visit` are emitted automatically from `session_id`
  / new client_id. `screen_view` is app-streams only — use `page_view` for web.
- **No error feedback in prod**: a malformed prod hit is silently dropped. Treat
  the debug endpoint as the only correctness signal.

---

## Quick implementation checklist for the plug

1. **Filter first** (before any POST): allowlist `Mozilla/` + engine token on
   request UA; denylist health/monitor paths and bad/missing `Host`. Drop → no
   hit.
2. Build **`page_location`** as the full absolute URL (scheme + host + path +
   query).
3. Set a **per-visitor `client_id`** (reuse `_ga` cookie, else persisted UUIDv4).
4. Include a **stable `session_id`** and a non-zero **`engagement_time_msec`** in
   every event's params.
5. Add **`ip_override`** (visitor IP) and **`timestamp_micros`** (request time)
   at top level.
6. Ensure no client-side gtag fires the same `page_view` (avoid double count).
7. Validate the exact payload against **`/debug/mp/collect`** in tests.

---

## Sources

Accessed 2026-05-25.

- Google — Send Measurement Protocol events to Google Analytics:
  https://developers.google.com/analytics/devguides/collection/protocol/ga4/sending-events
- Google — Measurement Protocol (GA4) overview:
  https://developers.google.com/analytics/devguides/collection/protocol/ga4
- Google — Measurement Protocol reference (params incl. ip_override, user_location):
  https://developers.google.com/analytics/devguides/collection/protocol/ga4/reference
- Google — Validate events (`/debug/mp/collect`):
  https://developers.google.com/analytics/devguides/collection/protocol/ga4/validating-events
- Google — Known bot-traffic exclusion (IAB/ABC list):
  https://support.google.com/analytics/answer/9888366
- Stape — Set up GA4 server-side tracking:
  https://stape.io/blog/set-up-ga4-server-side-tracking
- Stape — GA4 bot filtering / spam exclusion:
  https://stape.io/blog/filtering-spam-in-ga4-with-stape-bot-detection-power-up
- Simo Ahava — Session attribution with GA4 Measurement Protocol:
  https://www.simoahava.com/analytics/session-attribution-with-ga4-measurement-protocol/
- Simo Ahava — DebugView with GA4 Measurement Protocol:
  https://www.simoahava.com/analytics/debugview-with-ga4-measurement-protocol/
- Tracking Chef — How to add Session ID to GA4 Measurement Protocol events:
  https://trackingchef.com/google-analytics/how-to-add-session-id-to-ga4-measurement-protocol-events/
- Analytics Mania — How to remove (not set) in GA4 (MP page_location cause):
  https://www.analyticsmania.com/post/not-set-in-google-analytics-4/
- w3tutorials — What should client_id be for GA4 MP server-side events:
  https://www.w3tutorials.net/blog/what-should-the-client-id-be-when-sending-events-to-google-analytics-4-using-the-measurement-protocol/
- Data Journal — GA4 MP: server-side events, sessions & data stitching:
  https://datajournal.datakyu.co/advanced-ga4-measurement-protocol-implementation/
- Analytics Detectives — Why GA4's default bot filtering isn't enough:
  https://analyticsdetectives.com/blog/bot-traffic-and-filtering-in-ga4
- Thyngster — GA4 Measurement Protocol cheatsheet:
  https://www.thyngster.com/ga4-measurement-protocol-cheatsheet/
