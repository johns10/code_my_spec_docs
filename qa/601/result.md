# Qa Result

## Status

pass

## Scenarios

### Scenario 1 — Magic link click logs in directly with no intermediate screen (criterion 5489)

pass

Registered fresh user `qa-601-magic-test@codemyspec.local` at `http://127.0.0.1:4000/users/register`. Filled email field and clicked "Email me a login link". The page redirected to `/users/check-email?email=qa-601-magic-test%40codemyspec.local` confirming the email was sent.

Retrieved magic link from `/dev/mailbox` — token URL: `https://dev.codemyspec.com/users/log-in/JMFLf_NUz9ew54vWYCx0Abo4qtWob2lqhAnM1XCjC-M`. Replaced hostname with `127.0.0.1:4000` and navigated to the local URL.

Result: Browser landed directly at `http://127.0.0.1:4000/app` with flash "User confirmed successfully." — no intermediate screen. Sidebar shows `qa-601-magic-test@codemyspec.local` and "Log out" link. All four onboarding steps visible.

Evidence: `.code_my_spec/qa/601/screenshots/601_s1_after_magic_link_app.png`

### Scenario 2 — Successful magic link auth redirects to /app (criterion 5490)

pass

As observed in Scenario 1, the magic link token URL redirected to exactly `http://127.0.0.1:4000/app`. The controller sets `user_return_to: ~p"/app"` and `UserAuth.log_in_user` follows that return path.

Evidence: `.code_my_spec/qa/601/screenshots/601_s1_after_magic_link_app.png`

### Scenario 3 — Session persists across live_session boundaries (fix from c7b2c6c6)

pass

After magic link login, navigated to `http://127.0.0.1:4000/app/users/settings`. The URL remained at `/app/users/settings` (not redirected to log-in). The Account Settings page rendered with `qa-601-magic-test@codemyspec.local` in the email field, confirming the user is authenticated.

This directly validates commit c7b2c6c6: the `create/2` path now forces `remember_me: "true"` so the persistent `_code_my_spec_key` cookie survives `live_session` boundary crossings (e.g. `/app` → `/app/users/settings`). Prior to the fix, a browser-session-only cookie would be dropped at the boundary and the user would be bounced back to log-in.

Evidence: `.code_my_spec/qa/601/screenshots/601_s1_session_boundary_settings.png`

### Scenario 4 — Repeated magic link auth is idempotent (criterion 5491)

pass

After session expired (browser navigated to blank then back), went to `http://127.0.0.1:4000/users/log-in`. Filled the magic-link form (top form, `#login_form_magic`) with `qa-601-magic-test@codemyspec.local` and clicked "Log in with email →". Flash confirmed: "If your email is in our system, you will receive instructions for logging in shortly."

Retrieved second magic link from `/dev/mailbox` — token URL: `https://dev.codemyspec.com/users/log-in/s5BnyV_YcmMAu7jEq3yCXnBt0aZzBeD13ncUvu4ByGk`. Navigated to the local URL.

Result: Browser landed at `http://127.0.0.1:4000/app` with flash "User confirmed successfully." and user `qa-601-magic-test@codemyspec.local` logged in. Subsequently navigated to `/app/users/settings` — URL remained at settings (not redirected). Session valid.

Evidence: `.code_my_spec/qa/601/screenshots/601_s3_magic_link_requested.png`, `.code_my_spec/qa/601/screenshots/601_s3_second_magic_link_app.png`

### Scenario 5 — Used/invalid magic link does not log in (criterion 5492)

pass

Attempted to reuse the already-consumed first magic link token (`JMFLf_NUz9ew54vWYCx0Abo4qtWob2lqhAnM1XCjC-M`) via browser navigation.

Browser result: Final URL was `http://127.0.0.1:4000/users/log-in`, flash error "The link is invalid or it has expired." visible. User not logged in.

Curl confirmation:
```
> GET /users/log-in/JMFLf_...C-M HTTP/1.1
< HTTP/1.1 302 Found
< set-cookie: _code_my_spec_key=SFMyNTY...invalid flash cookie (no user_token)...
< location: /users/log-in
< HTTP/1.1 200 OK
```
The session cookie set by the 302 contains only the flash error message — no `user_token` field. The user is not authenticated.

Evidence: `.code_my_spec/qa/601/screenshots/601_s4_invalid_token_flash.png`

## Evidence

- `.code_my_spec/qa/601/screenshots/601_register_form.png` — registration form at `/users/register` with magic-link email input
- `.code_my_spec/qa/601/screenshots/601_s1_check_email.png` — "Check Your Email" page after submitting registration, showing next 4 onboarding steps
- `.code_my_spec/qa/601/screenshots/601_s1_after_magic_link_app.png` — `/app` after following magic link: "User confirmed successfully." flash, all 4 onboarding steps, user email in sidebar
- `.code_my_spec/qa/601/screenshots/601_s1_session_boundary_settings.png` — `/app/users/settings` accessible after magic link login (session survived live_session boundary — validates c7b2c6c6 fix)
- `.code_my_spec/qa/601/screenshots/601_s3_magic_link_requested.png` — login page with "If your email is in our system..." flash after requesting second magic link
- `.code_my_spec/qa/601/screenshots/601_s3_second_magic_link_app.png` — `/app` after following second magic link: user still logged in, idempotent
- `.code_my_spec/qa/601/screenshots/601_s4_invalid_token_flash.png` — login page with "The link is invalid or it has expired." flash after reusing a spent token

## Issues

None
