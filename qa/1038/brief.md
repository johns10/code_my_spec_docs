# QA Brief — Story 982: The agent I run gets its tools without paying for a catalogue

## Tool

`mcp__plugin_codemyspec_local__run_script` / `tool_docs` (this session's own
code-mode tools, called directly), plus `start_agent` / `stop_agent` to mint
disposable role-typed agents, plus `.code_my_spec/qa/scripts/qa_spine.sh` and
`qa_code_mode.sh` (already-written scripts for the predecessor stories 970/971)
run over `curl` against `http://localhost:4004/mcp`. No browser: this story
has no page. Everything it claims is about what a *running agent* holds and
what a script it runs can reach, and both are asked of the machine directly.

vibium's MCP server was not connected this session; not needed for this
story, since there is no LiveView surface for it to drive.

## Auth

None for the harness surface — `LocalOnly` + harness id. This session already
carries a valid `X-Harness-Id` via its own MCP connection (`.cms_harness.json`
in this worktree, harness `9f77b922-...`, project `708492f9-...`). For a
fresh shell against `:4004/mcp` directly:

```
python3 -c "import json;print(json.load(open('.cms_harness.json'))['harness_id'])"
```

then `X-Harness-Id: <id>`, `Accept: application/json, text/event-stream`,
handshake `initialize` -> `notifications/initialized` -> `tools/call`.

**The mechanism that actually matters for this story — read before testing
scoping (3018/3020/3021):** `run_script` and `run_browser_script` both take an
optional `agent_id` argument in their own MCP schema ("the agent running
this... its row says which tools it carries"). That argument, not an
`X-Agent-Id` HTTP header, is what a real internally-spawned agent's own tool
call carries (`CmsHarness.Agents.Tools.RunScript.arguments/2` embeds
`agent_id` into the run_script call's JSON arguments, not a header) and it is
what the server actually checks role-scoping against.

`.code_my_spec/qa/scripts/qa_as_agent.sh` opens a *separate* ad-hoc MCP
session and sets `X-Agent-Id` as a connection header. That mechanism is real
and correct for the asker surface (`ask_user_question`, `check_answer`,
`list_user_questions`) — it is what `Plugs.AgentScope` reads for
`frame.assigns[:agent_id]` — but it does **not** get threaded into
`run_script`'s own role-based tool dispatch. Using it to test 3020 gives a
false positive: the delete goes through with no refusal, because the identity
never reached the layer that checks it. Use the `agent_id` parameter on
`run_script` directly instead. (I made this mistake once this pass, filed a
critical issue on the false reading, caught it on retest, and dismissed the
issue with the corrected repro — see Issues below.)

## Seeds

None needed beyond what already exists. Disposable stories for the delete-scoping
test are created and deleted in-line with `create_story`/`delete_story` via
`run_script` — see What To Test.

## What To Test

**3014 — a tool the agent was never handed is still callable**
- `.code_my_spec/qa/scripts/qa_code_mode.sh` — confirms a moved tool
  (`list_story_titles`/`list_stories`) is unreachable as a direct `tools/call`
  (helpful redirect message, not "Unknown tool") and fully reachable via
  `run_script({ script = "return list_stories({...})" })`.

**3015 — the agent carries two tools and can reach a hundred**
- `.code_my_spec/qa/scripts/qa_spine.sh` against this worktree — reads this
  session's own `tools/list`. Confirm the "unscriptable" tools (start_agent,
  stop_agent, promote, promote_sync, etc.) refuse when called *from inside* a
  script ("cannot be called from a script... call it directly"), so nothing
  carried directly is a duplicate path into what a script could already reach.
- `tool_docs({})` reports "120 tools are callable from a script."

**3016 — ten tool calls cost one trip**
- One `run_script` call with a `for _ = 1, 10 do list_story_titles({}) end`
  loop; assert the single reply says `10`.

**3017 — a browser is no extra tools, not eighty-five**
- Confirm no `browser_*` name appears in this session's own `tools/list`
  (qa_spine.sh output).
- Confirm all 85 `browser_*`/`page_clock_*` names ARE listed by
  `tool_docs({ search = "..." })` under "call these from `run_browser_script`."

**3018 — a script reaches its own project and no other**
- No provisioning needed — the dev DB already holds five projects with
  stories (`select id, title, project_id from stories where project_id !=
  '<this project>' limit 3;` finds a cross-project id in one query). Do NOT
  use `start_agent` against another project's *working copy* to try to build
  a second scope — that path answers "the root you named has not joined this
  project from this machine" and silently resolves to this project anyway.
  Instead: start a normal agent scoped to *this* project, and call
  `get_story`/equivalent against an id you know belongs to a different
  project's row.
- Confirmed: `run_script({ agent_id = "<this-project-agent>", script = "return get_story({story_id=\"903\"})" })`
  (903 = "New Player Spawns in World", project `49760b8b-...`) refused with
  "Story not found. Verify the story ID exists using list_stories." — same
  for `908` (same project) and `1027` (Math Test Project,
  `d7f466a1-...`). None of the three refusals contain the other story's title
  or the other project's id. Positive control: `get_story({story_id="970"})`
  (this project's own story) returns full content normally, so the check is
  a real boundary, not a blanket failure.

**3019 — a page of a browser does not become the whole turn**
- `run_script` returning a raw 10,000- and 20,000-char string: comes back
  whole, unmodified (below the cap — correct).
- `run_script` returning a raw 100,000-char string: comes back cut at 24,000
  bytes with `\n\n[truncated — the answer was longer than 24000 characters]`
  appended, matching `CodeMySpec.CodeMode.cap/1` exactly.
- This was previously failing on this exact path (issue `b9632bba`, "the
  server tool it calls through does not [cap]... that is the tool a Claude
  Code session reaches") — now fixed; `run_script.ex` delegates to the shared
  `CodeMySpec.CodeMode.max_answer_bytes/0`/`cap/1`. `run_browser_script.ex`
  and `call_mcp_server.ex` still hardcode their own `24_000` literal instead
  of sharing the constant — same value today, but exactly the kind of
  duplication the `run_script.ex` comment says caused `b9632bba` in the first
  place. Not filed (no current behavioral bug), but worth a maintenance note.

**3020 — a QA agent cannot delete the story it is testing**
- `start_agent({ role = "qa", working_copy = <this worktree> })` → agent id.
- `create_story` a disposable story via your own `run_script`, note its id.
- `run_script({ agent_id = "<qa-agent-id>", script = "return delete_story({ story_id = \"<id>\" })" })`
  → must refuse, naming both the tool and the role:
  `"delete_story is not a tool a qa agent carries..."`
- `list_story_titles` immediately after (as the same agent or your own
  session) → the story must still be present.
- **Do not test this via `qa_as_agent.sh`'s `X-Agent-Id` header** — see Auth
  above.

**3021 — the main agent reaches everything**
- `start_agent({ role = "main", ... })`. `tool_docs({})` shows the same full
  120-tool catalogue as everyone else — the catalogue itself is not
  role-filtered (documentation is always visible to any caller; the
  restriction is enforced at dispatch time inside `run_script`, which is what
  3020 exercises). What "reaches everything" means concretely is that no tool
  refuses this role at dispatch — spot-check with the same `delete_story`
  call scoped to the `main` agent's id and confirm it goes through.

Clean up every agent you start (`stop_agent`) and every disposable story you
create (`delete_story`) before submitting.

## Result Path

There is no `result.md` in this workflow version — findings go through
`create_issue` as discovered, and the pass is closed with one
`submit_qa_result` call carrying `scenarios` + `issue_ids`. (The `result.md`
file from a prior attempt at this path is stale; ignore it.)

## Setup Notes

Tested against the dev harness/server for this worktree (harness
`9f77b922-9810-4b49-931d-b073012bc317`, project
`708492f9-454e-482f-a2eb-be64f0356b87`) on 2026-09-20, app reported as
v2.0.78 at `http://localhost:4000`.

**The single biggest trap in this story's QA is the identity mechanism.**
`qa_as_agent.sh` is the right tool for the asker surface (story 1009/1052) and
the wrong one for code-mode role scoping (this story). Two different
identity paths exist on this machine — an HTTP header the server's
`Plugs.AgentScope` reads, and a JSON argument the `run_script`/
`run_browser_script` tools read — and they are not the same mechanism.
Getting this backwards produces a real, reproducible-looking "critical"
security defect (an agent that should be refused a delete instead deletes
the row) that evaporates on retest with the correct mechanism. I filed and
then dismissed exactly that issue this pass (see Issues) — read the
dismissal reason before re-investigating this area, and always retest a
scoping refusal both ways before trusting either result.

Known and previously filed (do not re-file): `ebc5586d` (vibium should be a
package prerequisite), `b9632bba` (result cap — now fixed on the `run_script`
path, confirmed above), `02b03d04`, `44e30f90` (fixed in `acb6009f`).

**Correction from the first pass:** I originally reported 3018 as blocked by
an environment gap (no second project joined on this box) and filed that as
`db2c7ff5`. The team lead corrected this — the dev DB already has five
projects with stories, so no provisioning was ever needed, just a
cross-project story id (see 3018 above). Retested and passed; `db2c7ff5` is
dismissed with the corrected repro attached. Don't re-derive either mistake:
`qa_as_agent.sh`'s header is wrong for scoping tests (see Auth above), and a
second *project* for cross-project checks doesn't need a second *working
copy* — any other row in `stories`/`projects` will do.
