# QA Brief — Story 968: My project's preview has an address

## Tool

web

## Auth

Test against `https://dev.codemyspec.com`, **not** `http://localhost:4000`.

This is not a preference. The preview lives on `preview-<copy-id>.codemyspec.com`
and a generated app sets `SameSite=Lax`. No browser sends a Lax cookie into a
cross-site frame, so a preview framed from `localhost:4000` renders and is
session-less on every request — its login page renders, sets a cookie that never
comes back, and redirects to itself forever. Nothing errors, and it reads as the
framed app being broken. Testing from localhost produces a false failure.

Magic link, via the shared dev mailbox:

    # 1. Request a link
    open https://dev.codemyspec.com/users/log-in
    # fill #login_form_magic_email, submit .btn-secondary.btn-outline

    # 2. Find YOUR message — the mailbox is shared and the newest link may be
    #    somebody else's. Match on the recipient address, not on recency.
    curl -s http://127.0.0.1:4000/dev/mailbox
    curl -s http://127.0.0.1:4000/dev/mailbox/<id> | grep -oE '/users/log-in/[A-Za-z0-9_-]+'

    # 3. Follow the link. It lands on /app.

## Seeds

None. This story is tested against a real project with a real provisioned
tunnel, because the thing under test is a real Cloudflare record and a real
process — a seeded row proves nothing about either.

Two subjects, and both are needed for criterion 2969:

- **A founder's own checkout:** `Broken Oaths`, project
  `49760b8b-6472-41e2-b05d-c5c97acaee99`, copy `c8eda3e8-…`.
- **A visitor's hosted app:** boot one with `Workspaces.boot/1` against the
  Docker runner. It generates, onboards and provisions itself in ~60s.

Tear down anything you boot: remove the container, delete the Cloudflare tunnel
AND its DNS record, and delete the scratch project through
`Projects.delete_project/2`. A CNAME left pointing at a deleted tunnel answers
530, which reads as "the app is down" to the next person who finds it.

## What To Test

- **The address exists and is reachable from the UI (2961, 2965).** Navigate
  `/app/projects` → the project → "Working copies" in the nav. The main copy's
  row shows its preview host. Follow it from the nav rather than typing the
  path; a copy with no route to it is not one the founder has.
- **The pane frames the real app (2969).** Open the project's agent
  conversation, expand the `Preview` panel. The visitor's actual app renders
  inside it, not an empty state. Confirm the same for a hosted instance — both
  are reached at `preview-<copy-id>.codemyspec.com` over the copy's own tunnel.
- **The framed app holds a session (2969).** This is the criterion that has
  failed silently before, so test it directly: read the framed app's session
  cookie, reload the outer page, re-open the panel, read it again. **Identical
  means the browser sent it** — Phoenix reused the session rather than minting
  one. A changed value means the cookie is being stored and not sent, which is
  the cross-site failure and looks like nothing at all.
- **Only the main copy claims the preview (2962).** The row for the main copy
  shows an address; a non-main copy shows none. Check the response header too:
  `frame-ancestors` must name exactly one origin, on the same registrable
  domain as the preview. `x-frame-options` must be absent, not rewritten — it
  has no single-origin syntax.
- **Restarting does not lose it (2963).** Restart the app and confirm the tunnel
  comes back **from `.cms_harness.json`**, not from a process that was already
  running. Check the log for `Registered tunnel connection` and the address for
  200. For a hosted instance, `docker start` re-runs the entrypoint; do not kill
  the BEAM inside the container to test this — it is PID 1, so you stop the
  container and measure teardown instead of what you meant to.
  Afterwards run `pgrep -fl cloudflared` and confirm no orphan was left.
- **Re-onboarding is idempotent (2967).** Run onboarding a second time and
  confirm the tunnel id is unchanged. A new id means a second tunnel was created
  and the first is stranded — a real record nobody holds the secret for.
- **Onboarding asks rather than makes (2966).** Confirm the checkout holds no
  Cloudflare credential of ours: `.cms_harness.json` should carry the tunnel's
  own secret and nothing that could create another one.
- **Recording keeps what was there (2964).** Note every key in
  `.cms_harness.json` before onboarding and confirm all of them survive it.

## Result Path

`.code_my_spec/qa/968/result.md`

## Setup Notes

`mix harness.onboard` needs **both** `--server-url` and a deploy key to request
a preview. Missing either returns `:none`, which is also the correct answer for
a worktree and is therefore silent. From client_utils 0.1.37 the key is read
from `.cms_harness.json` automatically and a run that asks for nothing reports
which argument was missing; before that, four consecutive runs reported success
and wrote nothing.

The generated app defaults `PORT` to 4100, not 4000. The devbox exports
`PORT=4000` so the container's published port matches; anywhere else, check what
the app actually bound before concluding the tunnel is at fault.
