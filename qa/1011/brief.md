# QA Brief — Story 885: A pane that shows my app, wherever it happens to be running

## Tool

web

## Auth

Magic link, and the mechanics matter — two attempts failed silently before this
worked:

    vibium go "http://localhost:4000/users/log-in"
    vibium fill "input[type=email]" "<an existing user's email>"
    vibium click "form button"        # NOT eval + requestSubmit()
    vibium go "http://localhost:4000/dev/mailbox"
    # extract the link, then follow it:
    vibium eval "(() => (document.documentElement.outerHTML.match(/users\/log-in\/[A-Za-z0-9_.~-]+/g)||[])[0])()"

Two traps. Driving the form with `requestSubmit()` from `eval` does nothing —
LiveView owns the submit and the click has to be a real one. And the address
must belong to an existing user: this app does not auto-provision, so an
unknown address silently sends nothing and the mailbox stays empty, which looks
identical to mail being broken.

## Seeds

None. The pane reads whatever workspace the active project has. Confirm what
state you are actually testing before asserting anything:

    # what the pane thinks it is showing
    vibium eval "document.querySelector('[data-test=preview-pane]').dataset.state"

## Setup Notes

The dev server must be running the pane route — restart `:4000` if
`/build/preview` 404s rather than 302-ing to the login page.

`vibium frames` is the tool that answers whether the framed app actually
loaded. The pane rendering an `<iframe>` with a plausible `src` proves nothing;
a frame the browser refused reports as `about:blank` and looks, from the
markup, exactly like a working one.

## What To Test

- `/build/preview` while logged out → redirects to `/users/log-in`.
- `/build/preview` logged in → pane renders, `data-state` matches the
  workspace's real state.
- **Load the frame, do not just find it.** `vibium frames` must list the app's
  URL. `about:blank` means the app refused to be framed (2322).
- Click `[data-test=viewport-phone]` → `data-viewport="phone"`, computed width
  390px, and `getComputedStyle(...).transform === "none"` — narrowed, not
  scaled (2321).
- Inside the framed app, click a link that navigates; the top-level
  `window.location.href` must not change (2319).
- With the app framed, the host page's own styling is unaffected (2320).
- No workspace on the project → no pane at all, and nothing implying one is
  coming (2316).

## Result Path

Recorded in the DB via `submit_qa_result`; findings via `create_issue`.
