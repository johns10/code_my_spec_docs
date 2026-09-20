# Qa Story Brief — Story 1007: An agent is told only about work for its own role

Rewritten 2026-09-20 against this story's current criteria (3199, 3200, 3202,
3203, 3226) and the current mechanism. The story's routing logic lives in
`CodeMySpec.Agents.Work` (`consider_project/2`, `request_turn_if_runnable/3`,
`graph_work?/2`) now, not the retired `wake_roles/3`/`wake_project_roles/2`
this brief previously named — read `lib/code_my_spec/agents/work.ex` first.

## Tool

`run_script` (MCP Lua sandbox) plus the direct tools `start_analysis` and
`qa_as_agent.sh` (for the identity hop). No browser/Vibium coverage needed —
every criterion here is an MCP-tool-surface claim, not a `:browser`-pipeline
page. (Vibium's own MCP connection was down this session regardless.)

## Auth

None required for the MCP surface. `run_script`/`start_analysis` authenticate
as this Claude Code session against the harness on this worktree
(`9f77b922-9810-4b49-931d-b073012bc317`).

For the role-routing criteria (3199/3200), calls must be made **as a specific
agent** on the wake-fixture project, via
`.code_my_spec/qa/scripts/qa_as_agent.sh <agent-id> <tool> '<json>'` with
`QA_WORKTREE=/Users/johndavenport/Documents/github/math_test_project` (that
directory's `.cms_harness.json` names the fixture's harness id,
`56f5bf62-9cf8-400d-abcd-6c796afd3437` — the default `QA_WORKTREE` in the
script points at *this* worktree's own harness and would silently call as an
agent on the wrong project).

## Seeds

Re-run immediately before measuring anything — these agent rows get reaped to
`:stopped` within seconds of any harness report, so a stale "seeded this
morning" is not evidence of anything:

```
mix cms.seed priv/repo/qa_wake_seed.exs
```

This refreshes 4 canonical agents on `math_test_project` (project
`d7f466a1-591e-4f36-8319-42633f59411e`, working copy
`56f5bf62-9cf8-400d-abcd-6c796afd3437`) to `status=running, continuous=true`,
clears stale reservations/tasks, and leaves one story
(`Adding two numbers gives their sum`) routed to that copy:

| role | id | notes |
|---|---|---|
| coding | `25d67c11-f590-4e8e-a00d-6d3fb6bf08eb` | has real coding-role backlog history |
| coding | `59596b8a-1a5d-44b8-8f38-9bf1b570442d` | second coding lane |
| main | `4e98e2a8-f674-4a10-9592-a1468e4b64ac` | |
| product | `e9dce99a-9512-457d-b613-3baa49c387a7` | |

**No qa-role agent exists on this fixture, deliberately** (its own moduledoc:
so story 1004's "QA work waiting does not wake the coding agent" keeps its
premise). Do not add one — this fixture is shared with every other concurrent
QA session in this run; a persistent change to it can corrupt another
session's in-flight before/after measurement. See Setup Notes.

Before trusting any push-routing result, confirm the fixture's harness is
actually connected (`curl -s localhost:4004/health | grep -A6
math_test_project` → `connected: true, onboarded: true, watching: true`) —
`dispatch_message/3` calls the transport before recording, so an unheld copy
makes a push silently undeliverable rather than absent.

`heard_count` for an agent = `conversation_messages` rows with `role =
'operator'` on that agent's conversation — read directly via psql
(read-only, safe, does not touch the live server):

```sql
select c.agent_id, a.role, count(*) filter (where cm.role = 'operator') as heard_count
from conversations c
join agents a on a.id = c.agent_id
left join conversation_messages cm on cm.conversation_id = c.id
where c.project_id = 'd7f466a1-591e-4f36-8319-42633f59411e'
group by c.agent_id, a.role;
```

## What To Test

**Criterion 3202** (any agent may run a spex, whoever was told about it):
```
QA_WORKTREE=.../math_test_project qa_as_agent.sh <coding-agent-id> start_analysis '{"source":"spex"}'
```
Expect "Started spex…", no role-based refusal text.

**Criterion 3203 / 3226** (looking is allowed, being pushed is not; the read
is not gated by role; the refusal-if-any is not the notification mechanism):
1. File a probe issue with `scope: "qa"` via `run_script` as any agent on the
   fixture (`create_issue({...})`).
2. Confirm via the psql query above that no coding agent's `heard_count`
   changed — filing an issue is not a graph input and pushes nothing.
3. As a **coding** agent (a different role from the filer), call
   `list_issues({})` and `get_issue({issue_id=...})` — expect the issue back
   in full, and grep the combined response text for
   `role|not your|qa agent|permission|not allowed` — none should appear.
4. Dismiss the probe issue afterwards (`dismiss_issue`) — it has no product
   value once read.

**Criterion 3199 / 3200** (role-scoped push routing — the story's central
pair, and the devops-has-no-role default): the underlying mechanism is
`Work.graph_work?/2`, which calls `Requirements.actionable_for_role(scope,
agent.role)` — a plain map-filter on `RequirementDefinitionData`'s per-node
`role:` field, with no special-casing anywhere for any particular role name
(confirmed by reading `lib/code_my_spec/requirements/requirement_graph.ex`
`actionable_for_role_from/4` and `lib/code_my_spec/requirements/
requirement_definition_data.ex`, where every project-level node — including
what would become `devops_setup`/`release` under `devops: :on` — is tagged
`role: :main`, since `:devops` is not in `Agent`'s role enum
`[:main, :product, :coding, :qa]`).

Live-exercise the *filter* itself (the exact input to the push decision) by
calling `get_next_requirement` as two different roles on the fixture right
after a re-seed, with nothing else touched in between:

```
qa_as_agent.sh <coding-agent-id> get_next_requirement '{}'   # -> "Nothing for this role... belongs to other roles"
qa_as_agent.sh <product-agent-id> get_next_requirement '{}'  # -> sees personas_complete
```

This is a live, per-role discrimination of the identical function the push
path uses, on the current graph state, immediately reproducible.

**What this does not reach live, and why:** a full push-delta demonstration
for the *literal* QA role or a *literal* devops-enabled state needs either (a)
a qa-role agent on this shared fixture — declined, see Seeds — or (b) toggling
`Configurations.update(%{devops: ...})` through `ConfigurationLive`
(`/app/projects/:id/configuration`), which requires the **hosted** endpoint
(port 4000) — this box's `:4004` answers as the light harness
(`CmsHarness.Web.Endpoint`, confirmed via `curl localhost:4004/app/...` ->
`Phoenix.Router.NoRouteError` naming `CmsHarness.Web.Router`), which has no
local data plane. The hosted route needs a real login (magic link via the
shared `/dev/mailbox` — `qa@codemyspec.local` has no password set) and an
account-picker step, both carrying real collision risk while 6+ other QA
sessions share the same browser and mailbox this run. Treat 3199/3200's
literal push-delta as spex-covered
(`criterion_3199_..._spex.exs`, `criterion_3200_..._spex.exs`) — corroborate
with `start_analysis({source="spex"})` on this worktree, never substitute.

See issue `bdbb663d` (prior pass) and its 2026-09-20 follow-up filed this
session for the full history of this gap and what changed today.

## Result Path

Findings via `create_issue` as found. Final outcome via
`submit_qa_result(task_id: "3757a085-83e9-4546-9adb-b21c5dfdd004", …)`. No
result.md — the DB attempt is canonical.

## Setup Notes

- `math_test_project`'s harness on this box is the **light harness**
  (`CmsHarness.Web.Endpoint`) — MCP works (`/mcp` proxy) but there is no
  local LiveView surface for it here. All testing here is MCP/API surface,
  never browser, for this project.
- This fixture (`math_test_project`) is shared with every other concurrently
  running QA session in this run (main, qa-1004, qa-1005, qa-1009, qa-1011,
  qa-1012, qa-1017, qa-896 were all active alongside this pass). Re-seeding is
  sanctioned and expected before each measurement; adding new persistent
  agents or firing new graph-changing events (`create_story`,
  `Configurations.update`) on it is not, unless the scenario genuinely needs
  it and the risk to concurrent sessions has been weighed — prefer reading
  what the fixture already holds over perturbing it further.
- `create_issue`/`list_issues`/`get_issue`/`dismiss_issue`/`start_analysis`
  called through `qa_as_agent.sh` on the fixture operate on
  `math_test_project`'s own issue/analysis store, not the real CodeMySpec
  project's — safe to use freely there.
