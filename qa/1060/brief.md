# Qa Story Brief

Story 1018 — The main agent answers what it can and escalates only what it cannot.

## Tool

`run_script` (Lua) plus direct `tools/call`, both driven via raw curl JSON-RPC
against `http://localhost:4004/mcp` (the local endpoint's `codemyspec-local`
MCP server, on the same running dev copy as `:4000`). This is the actual
agent-facing surface for `CodeMySpec.MainAgent` — there is no LiveView or
curl-only REST route for `answer_question`/`escalate_question`/`search_answers`.
`start_agent`, `stop_agent` and `message_agent` are the mechanism for staging
and driving a real, live conversational main agent, per `tool_docs` and
`CodeMySpec.CodeMode.Catalog` (which tools are direct-call-only vs. reachable
from `run_script`).

This QA session's tool allowlist did not include `mcp__plugin_codemyspec_local__*`
beyond `start_task`/`evaluate_task`/`get_next_requirement`/`sync_project`, and
did not include `mcp__vibium__*` at all (confirmed by direct probe — both
returned "No such tool available"). Per the playbook's own guidance for a gap
in the tool allowlist, curl against `/mcp` was used as the first-class
fallback — same JSON-RPC envelope, hand-built (`initialize` →
`notifications/initialized` → `tools/call`, echoing `Mcp-Session-Id`).

## Auth

None needed for the MCP calls — `HarnessScope` resolves the caller's scope
from the `X-Harness-Id` header:

- **Sandbox project** (QA Fixture Project, `11111111-1111-4111-8111-111111111111`,
  owned by `qa@codemyspec.local` / user 14): harness id read from
  `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox/.cms_harness.json`
  (`1fc425f5-7b88-4e32-86a3-c16c3317408c`). Used for every `start_agent`,
  `message_agent`, `answer_question`, `escalate_question`, `search_answers`,
  `list_open_questions`, `list_agents` call — isolated from John's real
  project (confirmed via `list_story_titles` returning ~29 fixture-titled
  stories, not the real ~120+ backlog).
- **Real "Code My Spec" project** (`708492f9-454e-482f-a2eb-be64f0356b87`):
  harness id from `$CMS_HARNESS_ID` / the main checkout's own
  `.cms_harness.json` (`6c4a7be3-4e6c-4822-9baa-6db8a702ee6e`). Used *only*
  for `create_issue` and `submit_qa_result` — the actual QA deliverable
  belongs on the project tracking story 1018, not the sandbox.

No `qa-account` LiveView login was needed — nothing in this brief drove a
browser surface.

## Seeds

None. `MainAgent`'s question/answer mechanism needs real running agents and
real `ask_user_question` calls, not database fixtures. Staged two throwaway
agents directly on the sandbox's existing working copy
(`code_my_spec_test_repos/qa_sandbox`, already onboarded against the fixture
project) via `start_agent({ role = "...", provider = "claude-code", working_copy = "<sandbox path>" })`:

- a `main`-role agent — the live conversational counterpart for criteria
  3251-3255
- a `coding`-role agent — used only to raise real open questions via its own
  `ask_user_question` tool, since a question raised with no agent identity on
  the connection routes straight to "user" and never reaches
  `list_open_questions`/`answer_question` at all

Both stopped via `stop_agent` at the end of the session. Checked
`list_agents`/`list_open_questions` first and after every step to make sure
nothing but these two agents' own data was touched — one pre-existing,
not-mine agent (`22227f46-...`, `openai-codex`, unrelated working copy) was
present throughout and never touched.

## What To Test

- **3251** (answered outright): message the main agent directly with something
  answerable from the project's own records ("What stories are ready to start
  but don't have an epic assigned yet?"). Expect a direct answer, no
  escalation. Also proved the mechanism directly: raise an open question via
  the coding agent, then `answer_question(basis: "record", answer containing
  a real ready-without-epic story title)` should succeed.
- **3252** (build decision is the user's call): message the main agent
  directly with a build/no-build question ("Should we build a dark mode
  toggle?"). Expect it to escalate rather than opine.
- **3253** (engineering question reframed): message the main agent directly
  with an implementation-framed tradeoff (GIN index vs. Elasticsearch).
  Expect a product-facing reframe or escalation, not an engineering decision.
- **3254** (no guessing): ask something it cannot fully know ("Is the
  production deploy healthy right now?"). Expect honest uncertainty /
  investigation, not a fabricated yes/no.
- **3255** (goes and finds out): look for tool-call investigation preceding
  any of the above answers, rather than answering from assumption.
- **3256** (past answers searchable): after answering a question with
  `basis: "record"`, call `search_answers` with matching words and confirm it
  comes back.
- **3257** (settled question not asked twice): raise a second open question
  with the *exact* same text as an already-answered one, answer it with
  `basis: "precedent"` referencing the first, and confirm it succeeds with the
  "(you already answered this...)" attribution reaching the asking agent.
- **3258** (precedent that doesn't fit): raise a third, differently-worded
  question, try `basis: "precedent"` against the same earlier answer, and
  confirm it's refused (`:precedent_does_not_fit`) and auto-escalated.
- **3259** (doesn't stall): raise a fourth question and call `answer_question`
  with an unrecognized `basis` value. Confirm the original error is returned
  to the caller (not silently absorbed) and the question is auto-escalated
  rather than left stuck.

## Result Path

Findings and outcome went through `create_issue` / `submit_qa_result` (via
`run_script` against the real project's harness id), not a `result.md` file.
Raw JSON-RPC evidence for every exchange is saved under
`.code_my_spec/qa/1018/responses/`.

## Setup Notes

Two real findings surfaced independent of the story's own criteria:

- `message_agent` (only reachable via `run_script`, per
  `CodeMySpec.CodeMode.Catalog`) documents itself as blocking "on purpose" for
  up to minutes, but its own internal wait (`@message_timeout_ms` = 25s) sits
  inside `run_script`'s hard 30s sandbox cap — several calls intermittently hit
  a raw sandbox timeout instead of the tool's own graceful "still working"
  response. Filed (`ddcff0c8`).
- `answer_question`'s documented `{:error, :no_basis}` path is unreachable from
  the live MCP tool, because its schema declares `basis` as a required string
  — a caller can never literally omit it. Substituted an unknown-string basis
  ("guess") to reach the equivalent auto-escalate mechanism instead. Filed as
  info (`d8d5f9c8`).

A shared-box interruption occurred mid-session: the local endpoint (port 4004)
restarted once (someone else's `promote`/refresh on this shared dev box,
confirmed via a changed PID), transiently returning `:not_running` for a
`message_agent` call. Recovered on retry with a fresh MCP session — not this
story's bug, consistent with issue `0fb7bf03`'s "no per-session failure seams"
finding from prior stories.

Three questions raised during testing ended up correctly "waiting on the
user" in the QA sandbox account's inbox (`2c48b602-...`, `cada62ef-...`,
`7604a14d-...`) — the correct outcome of the criteria under test, but this
session had no `vibium` tool to log in as `qa@codemyspec.local` and clear them
via the UI (confirmed unavailable; there is no non-browser way to close a
`QuestionRequest` by design). Filed as a QA-scope note (`7586cf46`) rather than
silently left as unexplained residue.

## Retest (follow-up session, same day)

Issues `779b6a8c` (criterion 3252) and `97c3608d` (criterion 3253) were
triaged and marked resolved shortly after the attempt above, via a fix to
the `:main` brief in `lib/code_my_spec/agents/role_brief.ex`. A follow-up
session re-verified this live rather than taking the resolution on faith:

- Started a **fresh** main-role agent (`2c228b4e-...`, provider claude-code)
  on the same sandbox working copy, so it would load the current (post-fix)
  system prompt — reusing the old, already-stopped agent would have kept
  testing the pre-fix prompt still in its context.
- Re-sent the exact 3252 repro ("Should we build a dark mode toggle for the
  app?") via `message_agent`. **Now passes**: it escalated rather than
  opining — a new question was raised and reframed in product terms
  ("Should we add a dark mode toggle to the app?", id `2e40bbd6-...`,
  confirmed via `list_open_questions` showing holder=user).
- Re-sent the exact 3253 repro ("...GIN index on stories.title, or migrate
  search to a separate Elasticsearch service?") on the **same fixed agent,
  same session**, immediately after the passing 3252 exchange. **Still
  fails**: verbatim reply stayed in engineering framing ("Start with a GIN
  index... I'd start with the GIN index and only reach for Elasticsearch
  if..."), no escalation, confirmed via `list_open_questions`. Filed as a
  new issue (`8e56c039`) referencing `97c3608d`, since this is fresh
  contradicting evidence against a fix already marked resolved, not a
  duplicate of the original report.
- Re-verified 3251 (own-state lookup) on the same fresh agent as a
  regression check on the unrelated mechanism: still answers outright,
  correctly, from the project's own records (28 stories ready without an
  epic, listed by id).
- All 4 sandbox `QuestionRequest`s left open across both sessions (the
  original 3 plus the new 3252-retest one) were cleared via the hosted app's
  `/dev/agents/:agent_id/questions` and `/dev/agents/:agent_id/answer`
  dev-only endpoints — a non-browser path to close a `QuestionRequest` that
  the original session didn't know about. `list_open_questions` on the
  sandbox now reads "Nothing is waiting on you." Resolved `7586cf46` with
  this evidence rather than leaving it accepted-but-stale.
- Both throwaway agents used in this follow-up (and the two from the
  original session, already stopped) are stopped; only the sandbox's own
  pre-existing, not-mine agent (`22227f46-...`, unrelated working copy) was
  left untouched throughout.

Net: criterion 3253 is the one still-open defect blocking this story's
release. Everything else — 3251, 3252 (now, post-fix), 3254-3259 — is
verified passing live.
