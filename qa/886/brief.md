# QA Brief — Story 886: The preview points at a real app, over a URL that actually works

## Tool

curl

## Auth

None. Deliberate, and it is one of the claims under test: criterion 2331 says
Sam can send the address to someone else, so a preview that required an account
would fail the story. No login, no headers, no cookies.

## Seeds

No seed script. The preview resolves a workspace from the project id in the
hostname, so the only state that matters is whether a workspace row exists:

    # a project id with no workspace — the "nothing to preview" path
    UUID=$(uuidgen | tr 'A-Z' 'a-z')

The dev server must be running with the preview listener bound:

    lsof -nP -iTCP:4010 -sTCP:LISTEN    # expect the beam listening

## Setup Notes

**The preview listener is on 4010, not 4000.** The main endpoint declares
`socket("/live", Phoenix.LiveView.Socket)` and Phoenix dispatches socket routes
before the plug pipeline, so the endpoint can never serve a preview's LiveView
socket. `CodeMySpecWeb.PreviewListener` exists for that reason.

**Host header, not DNS.** Edge routing for `preview-*` is not built —
cloudflared cannot glob it, since a wildcard must be an entire leftmost label
in both DNS and its ingress. So the address is exercised by sending the Host
header directly. This is a real limitation of the environment, not a shortcut:
it means the DNS half of criterion 2331 is unverifiable here.

**There is no pane.** Nothing in the app renders an iframe. Story 886's own
description defers the pane to story 1000, which does not exist. Criteria 2329
and 2330 have no surface to test — see issue e093722b.

## What To Test

- `curl -i -H "Host: preview-$UUID.codemyspec.com" http://localhost:4010/`
  with a project id that has no workspace → 404 naming the absence, **and**
  carrying `content-security-policy: frame-ancestors ...`. A refusal that
  cannot be framed is a blank box where an explanation should be.
- `curl -H "Host: preview-marketing.codemyspec.com" http://localhost:4010/`
  → refused as not a preview address. The label has to be a project id;
  guessing would let a typo take over a hostname.
- `curl -i http://localhost:4010/` with no preview host → refused, rather than
  serving our own site on the preview port.
- Confirm no `x-frame-options` is ever returned, on any of the above.
- 2324 / 2327 / 2328 / 2331 (proxying, cookies, socket relay, address
  stability): covered by spex against a real HTTP server over a real socket.
  Re-running them is the check — `mix spex --pattern "test/spex/886_*/*_spex.exs"`.
- 2329 / 2330: no surface. Record as blocked, do not mark pass.

## Result Path

Recorded in the DB via `submit_qa_result`; findings via `create_issue`.
