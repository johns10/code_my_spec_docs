# Qa Story Brief

## Tool

curl (against http://127.0.0.1:4000) + `mix spex` for the
in-process LiveView contract layer

## Auth

Unauth probes: no auth. For full post-auth form interaction
(deferred unless spex fail): seed via
`mix run priv/repo/qa_seeds.exs` and log in at
http://127.0.0.1:4000/users/log-in with `qa@codemyspec.local` /
`qa-password-123!`.

## Seeds

`mix run priv/repo/qa_seeds.exs` (idempotent).

## What To Test

External-surface probes via curl against port 4000:

- Unauthenticated GET /app → 302 + `location: /users/log-in`
  (criterion 5399).

In-process LiveView contract verification:

- `mix spex --pattern "test/spex/606_*/*.exs"` — 6 criteria
  exercised via the real LiveView mount + redirect chain.
  Covers: zero-account create form (5513), valid submission
  creates + activates (5514), invalid submission re-renders with
  errors (5516), has-accounts-no-active auto-assigns first
  (5517), returning-with-active skips entirely (5518).

## Result Path

.code_my_spec/qa/606/result.md

## Setup Notes

Submission landed via the new `submit_qa_result` MCP tool —
attempt_id `a55a50c3-e4f9-4202-b82d-65718bfcaa32`. The full
post-auth form interactions (5513–5518) require an authenticated
session against the hosted endpoint, covered by the spex layer.
