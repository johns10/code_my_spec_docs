# Trace missing `sign_up` event for faturrachman signup (2026-05-21)

Filed 2026-05-22 from the daily analytics snapshot. First post-`b11c6b77` instrumentation gap.

## Problem

The 5/19 commit (`b11c6b77`) moved `:sign_up` to server-side dispatch from authoritative `users` row inserts. The 5/21 daily snapshot found **one missing event**: 2 prod inserts on 5/21, only 1 GA4 `sign_up` event landed.

| ID | Email | Inserted (UTC) | Confirmed at | Path inferred |
|---|---|---|---|---|
| 60 | johns10davenport+1234@gmail.com | 2026-05-21 13:34:52 | 13:35:02 | Magic-link (+suffix John-test, confirmed_at 10s after insert = clicked link) |
| 61 | faturrachman6773@gmail.com | 2026-05-21 15:36:55 | 15:36:55 | OAuth (confirmed_at == inserted_at, auto-confirm pattern) |

Expected GA4 events on 5/21:
- John-test (magic-link): 1 `sign_up` + 1 `registration_email_sent`
- Faturrachman (OAuth `:new` branch): 1 `sign_up`
- **Total expected: 2 `sign_up` + 1 `registration_email_sent`**

Actual GA4 events on 5/21 (all hosts, MP path = hostName empty):
- 1 `sign_up`
- 1 `registration_email_sent`

**Faturrachman's `sign_up` did not appear.**

## Why it matters

If the OAuth `:new` branch silently drops signup events, daily snapshots can't trust GA4 `sign_up` counts without a prod cross-check. The whole point of the 5/19 fix was authoritative dispatch from the only-true-signal (DB insert). One missing event undermines that contract.

## Two hypotheses

### Hypothesis A — OAuth path hit `:existing` via email-auto-link

`Users.find_or_register_oauth_user/2` flow:
1. Look up by `provider + provider_user_id` → if found, `:existing` (silent)
2. Else `find_or_register_by_email` → email match → `:existing` (silent, integration auto-link); no email match → `:new` (dispatches `sign_up`)

If a prior soft-deleted or anonymized row with `email = "faturrachman6773@gmail.com"` exists in the DB, step 2 returns `:existing` and `sign_up` is never dispatched, even though `users` ID 61 is a fresh row in his view (because integration linking creates the relationship without re-inserting).

**Verification:** Query for any `users` row with email matching `faturrachman6773`, including soft-deleted / archived state if those columns exist:

```elixir
import Ecto.Query
q = from u in CodeMySpec.Users.User,
    where: ilike(u.email, "%faturrachman6773%"),
    order_by: u.inserted_at,
    select: {u.id, u.inserted_at, u.email, u.confirmed_at}
CodeMySpec.Repo.all(q)
```

If only ID 61 returns, hypothesis A is ruled out and we go to B.

### Hypothesis B — `GoogleAnalytics` handler dropped the MP delivery

The handler logs and drops on HTTP failure (fire-and-forget per product direction). A transient 4xx/5xx from the GA4 Measurement Protocol endpoint, or a missing/wrong `GA4_MP_API_SECRET`, would silently swallow the event.

**Verification:** Check prod logs around `2026-05-21 15:36:55 UTC` (approximately) for log lines from `CodeMySpec.Analytics.GoogleAnalytics`. Look for anything in the `analytics` or `measurement_protocol` namespace, especially errors or non-204 responses from `/mp/collect`.

```bash
fly logs -a code-my-spec-prod --no-tail 2>&1 | grep -iE "analytics|measurement|mp/collect|google_analytics" | head -50
```

If no log entries appear at the right timestamp, the dispatch may have been attempted but the handler is silent on success too — in which case wrapping the failure-path logs with structured fields is also worth doing.

## Acceptance criteria

1. **Reproduce or rule out Hypothesis A.** Run the Repo query above. Capture the result in this file before moving to fixes.
2. **If A is the cause:** decide product behavior. Two options:
   - **Treat email-auto-link as a real signup event.** Dispatch `:sign_up` with `method: "oauth_<provider>_email_link"` from the `:existing` branch when it was reached via the email-auto-link path (not the provider-identity match). Distinguishes from "actual returning user."
   - **Treat email-auto-link as a returning user.** Document the behavior in `lib/code_my_spec/users.ex` so future audits don't surface this as a bug. Update `signup_analytics_test.exs` with an assertion that the email-auto-link branch is silent.
3. **If B is the cause:** ensure the handler logs both success and failure with structured fields (`event`, `user_id`, `mp_status`). Add a Logger.warning on non-204 responses. Add an alert path (later, separate issue) if MP delivery fails for >N events in a window.
4. **Add a daily reconciliation test or check** (optional, separate ticket): `Repo.all(users since yesterday)` count vs GA4 MP `sign_up` count for the same window. If they diverge by more than the known returning-OAuth slack, alert.

## Out of scope

- Re-touching the `b11c6b77` dispatch surface (`Users.register_user`, `Users.find_or_register_oauth_user`, `Analytics.dispatch`, `lib/code_my_spec/analytics/**`) — the contract tests guard those. Only adjust the silent `:existing` branch behavior or the handler logging, not the upstream dispatch sites.
- Building a real-time alerting layer for MP delivery failures — separate ticket if/when volume justifies.

## Reference

Daily analytics snapshot 2026-05-22 surfaces this gap in detail:
`code_my_spec_marketing/.code_my_spec/knowledge/analytics-snapshots/analytics-snapshot-2026-05-22.md` (sections "Server-side dispatch (5/19 fix) is working" and "Prod-insert vs GA4 reconciliation — 1 missing event on 5/21").

## Status — 2026-05-23

**AC #3 shipped.** `GoogleAnalytics.handle_event/4`, `deliver_via_http/2`, and `HTTPAdapter.post/3` now emit structured `event`/`user_id`/`mp_status` metadata at every decision point:
- Entry to handler (info)
- Skipped delivery on missing config (warning)
- Success delivery (info, mp_status=200)
- Non-2xx (warning, mp_status=<status>)
- HTTP error / raised / threw (warning, mp_status=:http_error/:raised/:threw)

Logfmt picks these up automatically. From the next missed event onward, `grep mp_status= ~/.codemyspec/server.log` (or the prod equivalent) traces the failure unambiguously.

**Still owed (you):**
- AC #1 — Hypothesis A DB query against prod. Local dev DB returned 0 rows for `faturrachman6773`; prod is where the row lives. Run:
  ```elixir
  q = from u in CodeMySpec.Users.User,
      where: ilike(u.email, "%faturrachman6773%"),
      order_by: u.inserted_at,
      select: {u.id, u.inserted_at, u.email, u.confirmed_at}
  CodeMySpec.Repo.all(q)
  ```
- AC #2 — Product decision on email-auto-link branch (dispatch with `method: "oauth_<provider>_email_link"` vs document silent). Deferred until DB query confirms which branch fired.
- AC #4 — Daily reconciliation check. Separate ticket per the original spec.

**Hypothesis B** is now self-tracing via the new structured logs, no further code work needed there.
