# QA Story Brief

## Tool
web

## Auth
Start in a clean browser session. The registration and magic-link routes are public; do not sign in first. Use the fresh address `qa601-resume-20261007-a9c2@codemyspec.local` for this run.

## Seeds
No seed command: create the test user through the registration UI so the scenarios exercise the real public flow. Use only this fresh email; request fresh links for repeated-login checks.

## What To Test
- Visit `http://127.0.0.1:60642/users/register`, register `qa601-resume-20261007-a9c2@codemyspec.local`, and verify the page confirms the link was sent. Open `http://127.0.0.1:60642/dev/mailbox`, locate the latest message for that address, verify its text and HTML bodies contain a visible `/users/log-in/<token>` link, and navigate to that link on port 60642. Criterion 263: expect direct login and no intermediate “Confirm and stay logged in” screen.
- On the same link flow, verify successful authentication lands on `/app` (criterion 264). Record the final URL and visible page state.
- Request a second fresh magic link for the same registered address from `/users/log-in`, open it, then visit `/app/users/settings`. Criterion 265: expect the same account to remain authenticated and settings to return normally, with no duplicate-user or broken-session behavior.
- Exercise an expired magic link if a genuinely expired token can be obtained without modifying the database or reusing a spent input. Criterion 266: expect no authenticated session and a redirect to a login page showing an invalid/expired message and a way to request another link.

## Result Path
`.code_my_spec/qa/601/` (screenshots); submit the canonical result through `submit_qa_result` (no result.md).

## Setup Notes
Test only `http://127.0.0.1:60642` (this copy serves bdd464d77). `/health` reported `pending_migrations: []`. The QA seed instructions require the dev server to be stopped before running the seed; the app is running, and registration itself creates the needed fresh user. Capture screenshots at initial registration, mailbox message, and post-login state under `.code_my_spec/qa/601/screenshots/`.