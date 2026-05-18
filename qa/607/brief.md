# Qa Story Brief

## Tool

curl (against http://127.0.0.1:4000) + `mix spex` for the
in-process LiveView contract layer

## Auth

For unauthenticated probes: no auth. The `user_return_to` cookie
is set on first guarded-route visit and read after login.

For authenticated post-signup probes (deferred unless spex fail):
seed via `mix run priv/repo/qa_seeds.exs` and use the magic-link
login at http://127.0.0.1:4000/users/log-in with
`qa@codemyspec.local` / `qa-password-123!`.

## Seeds

`mix run priv/repo/qa_seeds.exs` (idempotent).

## What To Test

External-surface probes via curl against port 4000:

- Unauthenticated GET /app → 302 + `user_return_to=/app` cookie
- Unauthenticated GET /app/projects → 302 +
  `user_return_to=/app/projects` cookie
- Unauthenticated GET /app/accounts/picker → 302 +
  `user_return_to=/app/accounts/picker` cookie

In-process LiveView contract verification:

- `mix spex --pattern "test/spex/607_*/*.exs"` — all 8 criteria
  exercised via the real `UserAuth.fetch_current_scope_for_user`
  + `live_session` redirect chain. Covers post-signup landing,
  stale return_to overwrite, zero-account / single-account /
  multi-account paths, and the direct-picker-visit path.

## Result Path

.code_my_spec/qa/607/result.md

## Setup Notes

Story 607 covers the post-signup redirect chain — most criteria
depend on account count + `user_return_to` state, which is hard
to probe with one-shot curl. The spex layer is the contract; my
curl probes confirm the surface is reachable and pre-auth gating
works.

This QA pass exercises the new `submit_qa_result` MCP tool
(replacing the file-rename evaluator). The dogfooding here doubles
as a smoke test for the new tool surface.
