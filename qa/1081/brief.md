# Qa Story Brief

## Tool

web

## Auth

Fixture owner (for live spex-drill UAT infra testing): navigate to /users/log-in, fill input[name='user[email]'] with user-46758652@example.com, click "Email me a login link", open /dev/mailbox (newest message to that address), copy the login link, replace its origin with http://127.0.0.1:60642 (this worktree's app port), and navigate to it. Lands on Test Account 17702 / spex drill project.

QA fixture project (no-server / unchecked-state scenarios, cheap and disposable): project id 11111111-1111-4111-8111-111111111111, same magic-link flow with qa@codemyspec.local.

## Seeds

No new seeds needed. Existing fixtures:

- QA Fixture Project 11111111-1111-4111-8111-111111111111 -- telemetry enabled, uat env has placeholder IP 203.0.113.10 (good for no-server/unchecked-state cases only, cannot demonstrate real collection).
- spex drill project bbd970c8-8c99-4918-b6ce-5a888b7fc53c -- the authorized real-infrastructure fixture (question 7c17a233 answered "Use spex drill UAT" -- do not re-ask). Real Hetzner servers at env=uat (178.156.216.165) and env=prod (178.156.185.52), real Cloudflare-owned domain spex-drill.earwitness.app with working DNS A records. Telemetry step on uat is currently errored -- see issue 1e9a9ee0.

## What To Test

- /app/projects/bbd970c8-8c99-4918-b6ce-5a888b7fc53c/console/resources/telemetry?env=uat, Config tab: Retry the telemetry step. It currently fails every time with a generic, swallowed error (issue 1e9a9ee0-f524-47c0-b585-637f8bd7ad50, critical, open). Until that's fixed, none of the live-collection criteria below can be demonstrated: 1708/1851 (collects logs/traces), 1710/1852 (HTTPS/DNS reachable), 1711/1853 (idempotent re-run), 1712/1854 (collector recovery), 1713/1855 (automatic next-deploy tracing), 1714/1856 (shared-host isolation), 1715/1857 (owner read-only query), 1716/1858 (read-only can't write/administer), 1719/1861 (14-day retention purge). Once setup reaches done, work through these in order on this fixture, marking fresh request/log markers per scenario so re-runs don't reuse consumed evidence.
- Same page, Checks tab: confirmed working this round -- unchecked before the first Check click (1718/1860), and after clicking, an honest reachable=false/reads=error/writes=error result that survives reload with its checked_at timestamp intact (1717/1859). No further action needed unless setup starts succeeding, in which case re-check for a healthy result.
- QA Fixture Project's uat environment (placeholder IP, no real server) still correctly stops with an explicit "no server is provisioned" error and never silently succeeds (1709/1835) -- last independently re-verified in the attempt before this one, against this same commit (75645dd02); not re-run this round since the code path (Telemetry.require_server/2) is unchanged and trivial.
- Capture screenshots at initial/success/error states for anything you execute; save to .code_my_spec/qa/1081/screenshots/. File findings immediately via create_issue as you find them.

## Result Path

.code_my_spec/qa/1081/screenshots/

## Setup Notes

Current blocking bug: issue 1e9a9ee0-f524-47c0-b585-637f8bd7ad50 (critical, open) -- CodeMySpec.Provisioning.ClickHouse.run/3's catch-all discards any non-binary error reason and reports only "telemetry setup failed; check the environment and provider configuration". QA has no SSH/server-log access to identify the real failing sub-step (Credentials.prepare, Steps.with_ssh_runner, Stack.install, and Exposure.publish are all candidates -- Cloudflare DNS/zone lookup is probably fine, since this same project's Domain and DNS resources are independently done with real resolving records). Next QA pass: check whether this issue has been resolved before re-attempting the live-collection scenarios; if still open, there is nothing further to test on the live-infra side until it's fixed.

Do not re-ask question 7c17a233 -- it is answered and authorizes deployment, DNS/TLS, collector restart, isolation, and retention tests on the spex-drill fixture.

Prior resolved framework/app issues from earlier attempts (BiDi browser error f35dde6e, invisible/lost health-check results 16357e52 and 246696c5, Phoenix restart blocker 9b190831) are all closed and were not seen again this round.


## Blocked again -- stale app, not the fix

Resumed after issue 1e9a9ee0 was marked resolved (commit e955fe521). The fix is correct on disk, but this worktree's running app at :60642 is still executing the pre-fix compiled module -- 4 separate Retry clicks (with full page navigations and waits up to ~20s between them) all return the byte-identical old error string, which the new code cannot produce. GET /health reports harness_connected: false. Filed as framework issue 9394a9e0-7f99-4283-a2e6-54081b5d8f4d. Next QA pass: confirm this app has been restarted/rebuilt (check /health harness_connected and that a fresh Retry no longer shows the old semicolon-punctuated string) before re-attempting the live-collection scenarios.


## Resumed again -- stale-app blocker cleared, new real blocker found

Confirmed the app at :60642 now serves commit e955fe521: a fresh Retry on uat telemetry setup returns the new colon-punctuated, concatenated error format instead of the old byte-identical semicolon string. Resolved framework issue 9394a9e0 accordingly.

The real underlying failure is now visible: `telemetry setup failed: {:cloudflare_token_unusable, :reauthorize_required}`. This is a genuine infra/credentials problem (the project's Cloudflare API token needs reauthorization), not a code defect -- filed as issue 8fbd68a4-bb07-4c2e-9ac3-35e4e6c16532 (critical). Still blocks the same 9 live-collection criteria. QA has no access to reauthorize the token. Next QA pass: check whether this issue has been resolved before re-attempting the live-collection scenarios.


## Resumed again -- Cloudflare reauthorization did not take effect for this project

Operator reported 8fbd68a4 resolved (Cloudflare reauthorized) and asked to retest. Logged back in as the fixture owner (fresh magic-link token -- the prior token from the last attempt's brief was already consumed/unusable, confirmed a new one was minted and used). On `/app/projects/bbd970c8-8c99-4918-b6ce-5a888b7fc53c/console/resources/telemetry?env=uat`, clicked Retry twice (verified both were real attempts via the Activity tab, which shows two fresh "ran the telemetry step -- user-46758652@example.com" entries, not a cached/stale display) with waits up to 75s for the real SSH/API round trip. Both retries returned the byte-identical error: `telemetry setup failed: {:cloudflare_token_unusable, :reauthorize_required}`.

Checked `/app/projects/bbd970c8-8c99-4918-b6ce-5a888b7fc53c/console/credentials` directly: it shows **Cloudflare: not connected** (and Resend: not connected), with a banner reading "Setup cannot start yet -- still needed: Cloudflare, Resend." This is a project-level OAuth connection ("Connect Cloudflare from your account settings"), not a token value QA can inspect further. So whatever reauthorization the operator performed did not result in this project's Cloudflare connection being live -- the resolution of 8fbd68a4 does not match the current observed state. Filed as issue (see Setup Notes) rather than reopening 8fbd68a4 (no reopen tool available). Still blocks the same 9 live-collection criteria: 1708/1851, 1710/1852, 1711/1853, 1712/1854, 1713/1855, 1714/1856, 1715/1857, 1716/1858, 1719/1861. Next QA pass: confirm Cloudflare shows "connected" on the project's own Credentials page before re-attempting -- don't trust an issue's resolution note alone.
