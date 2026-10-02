# QA Brief — Story 843: Notifications inbox lists Claude's questions and approvals

## Tool

web

## Auth

The inbox is per-user and one criterion is about *not* seeing another user's
requests, so this needs **two** accounts. Do not reuse the operator's own
session — a QA run logs it out.

1. `http://localhost:4000/users/register` — register `qa-notif-a@codemyspec.local`.
2. `http://localhost:4000/dev/mailbox` — take the newest `/users/log-in/<token>` link
   and navigate to it. The mailbox is shared: check the recipient before clicking, or
   you will be logged in as whoever else is testing.
3. Create an account and a project through the onboarding forms.
4. Repeat for `qa-notif-b@codemyspec.local`. Keep both user ids —
   `SELECT id, email FROM users WHERE email LIKE 'qa-notif-%'`.

Isolation is checked by seeding B's requests and reading A's inbox, so you only
need to be *logged in* as A. B never has to log in.

## Seeds

There is no seed script. Requests are created by an agent calling `ask_user` or
by the Claude Code permission hook, neither of which a QA run can drive, so seed
`question_requests` and `permission_requests` directly with
`psql -qtA code_my_spec_dev`. Take a `pg_dump` of both tables first and delete
the seeded rows when finished.

`questions` is a JSONB array and its options are **`{"label": …}` maps**, not
strings — the form renders `opt["label"]` and raises on a bare string. That is
the shape `AskUserQuestion` actually sends.

Seed against user A:

| Row | Fields | Covers |
|---|---|---|
| Pending question | `status: 'pending'`, one question with two options | 1977, 1980 |
| Answered question | `status: 'answered'`, `answers` populated, **older** `inserted_at` | 1978 |
| Expired question | `status: 'expired'` | 1982 |
| Pending permission | `tool_name: 'Bash'`, `tool_input: {"command": …}` | 1978 (mixed kinds) |

Seed against user B: one pending question and one pending permission request. These
must never appear in A's inbox (1981).

## What To Test

Logged in as A, at 375 × 812 — the badge lives in the navbar and the inbox is a
list, both of which are where phone width bites.

- `/app/notifications` — every seeded A row is listed. Each carries
  `data-test="notification"` with `data-id`, `data-kind` and `data-status`.
  Nothing of B's is present, by id (1977, 1981).
- The pending question and the pending permission both sort **above** the answered
  one, and each shows its own status badge. Compare positions by reading the
  `data-id` order out of the DOM, not by eye (1978).
- The navbar badge carries `data-test="notification-badge"` with `data-count`.
  Read the count, then insert a new pending question for A **from a second psql
  session while the page stays open** — the count must go up with no reload.
  Answer it and the count must come back down (1979). Both directions: a badge
  that counts up and never down keeps claiming work that is done.
- Click the pending question. It must land on a page that can take the answer and
  show which question is being asked. Submit, return to `/app/notifications`, and
  the item must now read `answered` (1980).
- Open the expired question. It must still be listed as `expired`, and its page
  must offer no submit control (1982). A form that submits into a run nobody is
  waiting on takes an answer and does nothing with it.

## Result Path

Findings go to `create_issue` as they are found and the attempt goes to
`submit_qa_result`. Screenshots to `.code_my_spec/qa/843/screenshots/`.

## Setup Notes

`:4000` serves the **main checkout**, not a worktree. A fix made in a worktree is
not on the page until it is pushed and the main checkout fast-forwarded.

The live-badge check is the one that cannot be faked from a single browser tab:
the update has to arrive over PubSub while the page is open. Inserting through
`psql` does **not** broadcast — it writes the row and nothing tells the LiveView.
Drive it through the app instead, or accept that the browser can only confirm the
count is right at load and say so in the observation rather than claiming a live
update was seen. Spex 1979 covers the live path properly, and it does so by
breaking the subscription to prove the assertion can fail.

Rule `4de65cf3` says an inbox item opens "where that item can be answered in
context — for a question an agent asked, the conversation it was asked in".
Only the non-harness half has a criterion (1980); `to_item/1` points both kinds
at the standalone page. Do not test the conversation deep-link — it is not built
and has no scenario.
