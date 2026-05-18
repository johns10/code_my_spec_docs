# Qa Story Brief

## Tool

mix spex (internal spex test runner — all four criteria use conn-based assertions, no browser/HTTP surface)

## Auth

No auth required. The spex test suite uses `Phoenix.ConnTest.build_conn()` internally and the Swoosh test adapter to capture magic-link emails. No session setup needed before running.

## Seeds

No seed scripts required. The `given_ :registered_user_with_magic_link` shared given in each spex creates a fresh user via the registration LiveView within the test context.

## What To Test

- Run all four spex files for story 601 with:
  `mix spex test/spex/601_email_registration_logs_the_user_in_via_magic_link/`
- Criterion 5489: Magic link click confirms and logs in directly — assert 302 response and `user_token` session set, no intermediate confirmation screen
- Criterion 5490: Successful magic link auth redirects to `/app` — assert redirect target is exactly `/app`
- Criterion 5491: Repeated magic link authentication is idempotent — assert second magic link for the same email also 302s to `/app` and session resolves to a valid user (settings page returns 200)
- Criterion 5492: Expired magic link does not confirm or log in — assert no `user_token` in session and redirect to a page showing "invalid" or "expired" message

## Result Path

`.code_my_spec/qa/601/result.md`
