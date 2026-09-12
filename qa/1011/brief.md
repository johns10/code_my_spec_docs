# Qa Story Brief — 1011: The main agent sees every open question and message across its working copies

## Tool

curl (MCP `tools/call` against the local endpoint) for every MainAgent surface, plus a short `web` pass for the person's notifications view.

## Auth

This story's real surface is MCP tools scoped by harness, not a page a browser logs into for most of it. Do everything against the **sandbox project**, never the real CodeMySpec project — several of these tools write real, hard-to-reverse state (questions, escalations, staffed agents).

1. Sandbox harness id (already onboarded per `.code_my_spec/qa/plan.md`):
   ```
   SANDBOX=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
   ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SANDBOX/.cms_harness.json" | head -1 | cut -d'"' -f4)
   ```
2. Initialize an MCP session against it once, keep the `Mcp-Session-Id` for every subsequent call:
   ```
   curl -s -X POST http://localhost:4004/mcp -H "Content-Type: application/json" \
     -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $ID" \
     -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"qa","version":"1.0"}}}' -D -
   # then, using the Mcp-Session-Id header from the response:
   curl -s -X POST http://localhost:4004/mcp -H "Content-Type: application/json" \
     -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $ID" -H "Mcp-Session-Id: <id>" \
     -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}'
   ```
3. Most of story 1053's tools (`list_open_questions`, `escalate_question`, `answer_question`, `search_answers`, `list_agent_work`, `create_working_copy`, `message_agent`, `offboard_working_copy`, `list_agents`) are **script-only** — not mounted on `/mcp` directly. Call them through `tools/call` with `name: "run_script"` and a Lua `script` body, e.g.:
   ```json
   {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"run_script","arguments":{"script":"local r, e = list_open_questions({}); if r == nil then return \"failed: \" .. e.message end; return r"}}}
   ```
   `ask_user_question`, `stop_agent`, and `check_answer` ARE mounted directly and are called with `name` set to the tool itself; attribute the call to a specific agent with an `X-Agent-Id: <agent uuid>` header.
4. For the one page-based criterion (3267), log in as **qa@codemyspec.local** — but see the Setup Notes below before escalating anything while logged in or scripted against this project: it does not land where you expect.

## Seeds

No seed script needed beyond what's already onboarded. To get three distinctly-attributed agents to test against, spin up a disposable working copy on the sandbox and have each staffed agent ask one real, cheap question:

```
tools/call run_script: create_working_copy({ label = "qa-1011-probe" })
```
This staffs three real agents — coding, product, qa — on a fresh git worktree under the sandbox. Read back their ids and roles with `list_agent_work({})`.

For each agent, drive a real `ask_user_question` call with a tightly-scoped instruction so it costs one cheap turn instead of a real work session:
```
tools/call run_script: message_agent({ agent_id = "<id>", message = "Call the ask_user_question tool exactly once, with title \"<x>\" and one question \"<y>\" with options A and B. Do not do anything else. After calling it, stop." })
```
**When you are done, `offboard_working_copy({ working_copy_id = "<id>" })`** to stop the agents and discard the checkout row. The worktree directory itself is left on disk — that's normal — and can be pruned by hand later.

## What To Test

- **3260 / 3266** — with three staffed agents each asked a question, call `list_open_questions({})`. Each entry must name the question text, the asking agent's id and role, and the checkout it was raised on.
- **3261** — call `list_open_questions` from the **main** sandbox checkout's harness scope (not the probe copy's) and confirm questions raised on the probe copy still appear. The listing is project-wide, not copy-scoped.
- **3262** — `answer_question({ question_id, answer, basis = "record" })` one of the three (the answer text must contain a real story title — get one from `ready_stories_without_epic({})`). Re-run `list_open_questions` and confirm it's gone while the other two remain.
- **3263** — `stop_agent({ agent_id })` on one of the three agents (that has NOT been answered), then `list_open_questions` again. Its question must still be listed, now showing the agent as `stopped`.
- **3264** — `escalate_question({ question_id, reason })` on one of the remaining questions. `list_open_questions` should now show two sections — "Needs your attention" and "Waiting on the user" — with the escalated one in the second, not gone and not still in the first.
- **3269** — as the asking agent (curl with `X-Agent-Id` set to it), call `check_answer({ question_id })` on the escalated-but-unanswered question. Expect "still waiting on the user," not an answer and not silence.
- **3268** — answer the escalated question (see Setup Notes — do this via `answer_question` with a real `basis`, not by actually escalating to a live human inbox), then re-run `check_answer` as the asking agent. Expect the literal answer text back.
- **3265** — needs a running **main**-role agent on the project so a delivered question shows up as an orchestrator action on its conversation. **Not achievable with the tools exposed to QA** — `create_working_copy`'s staffing only produces coding/product/qa. See Setup Notes.
- **3267** — log in as qa@codemyspec.local, visit `/app/notifications`, and separately `/app/questions/:id` for a question id you escalated. See Setup Notes for why this account is not currently a safe or reliable target.

## Result Path

Findings are filed live via `create_issue` as you find them; final verdict via `submit_qa_result`. No result.md — the harness doesn't read it.

## Setup Notes

**Do not escalate a question against the sandbox project expecting it to land on qa@codemyspec.local.** The sandbox's harness (and every local harness on this dev box) authenticates with the single shared deploy key in `envs/dev.env`, which resolves to the real account owner (`johns10@gmail.com`, user id 1) — not the QA fixture user. `escalate_question`/`ask_user_question` write `question_requests.user_id` from that resolved scope, so **any escalated question — regardless of which project it's nominally on — lands in the real production owner's real `/app/notifications` inbox.** Confirmed 2026-09-12 by checking `question_requests` directly after escalating on the sandbox harness. This is the same class of leak already tracked as issue `08d4d7bd` (there, `ask_user_question` specifically); this session confirms it also applies to `escalate_question`.

Two consequences for whoever runs this brief next:
- If you escalate anything for real, **close it immediately** with `answer_question({ question_id, answer, basis = "record" })` (any real story title in the answer text satisfies the check) — this calls the exact same `Notifications.answer_question_request/2` the human inbox's own answer form calls, so it cleanly removes the entry from the real owner's UI. Verify with a read-only `psql -qtA code_my_spec_dev -c "select status from question_requests where id = '<id>';"` — expect `answered`.
- **3267 cannot be verified against qa@codemyspec.local as things stand.** Testing it for real means putting a live entry in the actual product owner's actual inbox, which needs his sign-off, not a QA session's own judgement call. Treat this criterion as `partial` unless that consent is obtained, or unless someone fixes the sandbox's account isolation first.

For 3265, no exposed tool creates a lone main-role agent on a throwaway working copy. Either accept `partial` here too, or (with the project owner's buy-in) exercise it against a checkout that already runs a main agent.
