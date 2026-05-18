# Qa Result

## Status

pass

## Scenarios

### spex_contract_full_suite

PASS. `mix spex --pattern "test/spex/607_*/*.exs"` — 8 tests, 0
failures in 0.2s. All 8 criteria exercise the real
`UserAuth.fetch_current_scope_for_user` + `live_session`
redirect chain in-process.

### curl_unauth_app

PASS. `curl -sS -i http://127.0.0.1:4000/app` →
`HTTP/1.1 302 Found` + `Set-Cookie` containing
`user_return_to=/app` in the session payload. Pre-auth gate
behaves as expected.

### curl_unauth_app_projects

PASS. `curl -sS -i http://127.0.0.1:4000/app/projects` →
`HTTP/1.1 302 Found` + `Set-Cookie` containing
`user_return_to=/app/projects`. Guarded zero-account path
stores intent correctly.

### curl_unauth_picker_direct

PASS. `curl -sS -i http://127.0.0.1:4000/app/accounts/picker`
→ `HTTP/1.1 302 Found` + `Set-Cookie` containing
`user_return_to=/app/accounts/picker`. Picker is reachable; its
"direct visit renders picker" contract (criterion 5527) is
enforced at the post-login LiveView mount (verified in-process
by the spex).

### post_signup_redirect_paths

PARTIAL. Full magic-link sign-in → `/app` landing flow was NOT
exercised externally via curl because it requires a cookie-jar
round trip through the magic-link mailbox. The contract is
covered in-process by
`criterion_5519_magic_link_lands_user_on_app_spex` and the
seven other 607 spex files, all green.

## Evidence

- `mix spex --pattern "test/spex/607_*/*.exs"` output:
  `8 tests, 0 failures` in 0.2 seconds.
- curl traces against ports 4000 for the three unauthenticated
  routes above — each returned 302 with the expected
  `user_return_to` cookie.

## Issues

### New MCP tools require local server restart

#### Severity
MEDIUM

#### Scope
QA

#### Description
The dogfooding attempt to submit this QA outcome via the new
`mcp__plugin_codemyspec_local__submit_qa_result` tool returned
`MCP error -32603: Internal error`. The tool is registered on
disk in `lib/code_my_spec/mcp_servers/local_server.ex` and the
client's tool list refreshed via `/mcp` reconnect picked it up,
but the running BEAM on port 4004 was started before the tool
modules existed, so invocation crashes inside the server.
Already filed as framework issue **c2d85309**. Workaround for
this pass: result recorded via the legacy file path; will switch
to MCP submission on the next pass after a server restart.
