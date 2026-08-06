# QA Brief — Story 972: My blog publishes from my repo to my own bucket

## Tool

web

## Auth

Magic link as the owner (`johns10@gmail.com`).

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, with the
`content` option enabled.

**As seeded it cannot publish, and that is useful**: `content_bucket`,
`client_api_url` and `deploy_key` are all null, which is exactly the state the
refusal criteria (8039, 8058) are about. Test those first, before configuring
anything.

To reach the publishing criteria (8035, 8036, 8038) the project needs all three
set **and** a deployed site to pull the content — story 966's deploy path, which
does not work yet.

## What To Test

URL: `http://127.0.0.1:4000/app/projects/<id>/provisioning` and the project's
content page.

Reachable on an unconfigured project:

- **Publishing is one command, not a checklist (8034)** — `mix cms.content.publish`
  from the CLI, or a single `[data-test="publish-button"]` in the UI. Confirm
  neither requires a preceding step by hand.
- **The pipeline is proven end to end before it is called done (8039)** — run the
  content step with the trigger unconfigured. It must refuse *before* uploading:
  "Publishing is not configured — content_bucket, client_api_url, deploy_key
  missing." Uploading first and failing at the trigger would leave content in a
  bucket nothing pulls from.
- **A lost trigger is reported, not swallowed (8058)** — same refusal. Also check
  `ContentPublishing.trigger_client/2`'s fallback returns `{:error, ...}` naming
  the missing fields, and that `ContentLive` renders it via
  `[data-test="publish-error"]` rather than a success with a nil sync id.

Needs a configured project and a live site:

- **The published files are in Sam's storage (8035)** — list the content bucket
  with his own S3 credentials after a publish.
- **The post appears on the live site (8036)** — fetch `/blog/:slug` on the
  deployed host.
- **Content that does not verify is left unserved (8038)** — publish a blob whose
  checksum does not match the manifest; the client must refuse to serve it.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Sync is trigger-only.** There is no reconciliation pass, no retry, no sweep that
notices the site is stale. That is why the refusal criteria matter more here than
they would elsewhere: an unconfigured trigger is indistinguishable from a working
publish unless something checks, so "reports success having done nothing" is the
failure this story is built to prevent.

**The moduledoc's warning about a swallowed trigger is stale** (issue `69b16515`).
It says `trigger_client/2` returns `{:ok, %{sync_id: nil}}` for an unconfigured
project; it now returns an error naming the missing fields. Do not add a second
guard for a case that is already handled.

**`mix phx.routes` and `mix test` both wedge the running dev server** — they
recompile the dev environment and take the compile lock, after which every route
500s until restart. `mix run` is safe.

**Vibium can drop its BiDi session mid-run** (`failed to navigate: BiDi error`).
Recover with `vibium daemon stop`, then log in again — the session cookie does not
survive.
