# QA Story Brief — 1083: Each story gets its design when it is picked up

## Tool

`call_mcp_server` (code mode, via `run_script`) for criteria 1720-1723; `web` (Vibium browser) for criterion 1724.

## Auth

App under test: this worktree's own instance at http://127.0.0.1:60642 (CodeMySpecWeb.Endpoint, serving commit d0d7268f). Isolated database (code_my_spec_dev_wc_ad7d67d6) — a full copy containing story 1083 and project 708492f9-454e-482f-a2eb-be64f0356b87 ("Code My Spec"). Mutations here do not touch the real shared backlog.

MCP calls go to /mcp/harness (forwards to CodeMySpec.McpServers.LocalServer). Requires an OAuth bearer token plus X-Project-ID:

    psql -d code_my_spec_dev_wc_ad7d67d6 -c "select token from oauth_access_tokens where resource_owner_id=1 and revoked_at is null and inserted_at + (expires_in || ' seconds')::interval > now() order by inserted_at desc limit 1;"

**evaluate_task on a component_linked/ArchitectureDesign task additionally needs X-Harness-Id** (fixed by commit 68fbc0897, issue ed28189c — resolved and verified this session). Without it, scope.environment is nil and evaluate_task always answers :no_environment. Use this worktree's own harness id: 38ae2924-bc1b-4d32-8a34-41df09ae64ad.

Only get_next_requirement, sync_project, start_task, evaluate_task, cancel_task are direct LocalServer tools, called via call_mcp_server with that tool name directly. Everything else (create_story, update_story, set_story_component, create_component, get_story) is reached by nesting: tool = "run_script", arguments = { script = "return create_story({ ... })" }.

**A freshly created story produces no component_linked requirement until it is released**: `create_story` alone is not enough — follow it with `update_story({ story_number = N, ready_for_dev = true })`, or start_task answers "Requirement component_linked not found for story <id>" even though the story exists.

Browser (criterion 1724): log in as the project owner via the magic-link flow against this instance's own (unshared) mailbox.

1. browser_navigate to http://127.0.0.1:60642/users/log-in, fill user[email] with johns10@gmail.com, submit.
2. browser_navigate to http://127.0.0.1:60642/dev/mailbox, open the newest message, extract the /users/log-in/:token link (rewrite host to 127.0.0.1:60642 if minted against a different host).
3. browser_navigate to that link.
4. If landed on /app/accounts/picker or /app/projects/picker, choose "Code My Spec" / the project.

## Seeds

No seed script needed. This copy already has project 708492f9 and story 1083. Create fixtures through the MCP surface (create_story, update_story(ready_for_dev: true), create_component, set_story_component — all via run_script). Use a distinguishing title prefix ("QA 1083"/"QA 1083 Retest") so fixtures are easy to tell apart from real backlog items.

Fixtures from this session: stories 1090 (G, linked to existing Qa1083BillingLive), 1091 (H, left unlinked), 1092 (I, linked to existing Qa1083BillingLive), 1093 (J, linked to newly-created Qa1083ReportsLive). Earlier session's fixtures 1088/1089 and component Qa1083Billing still present and still valid.

**Do not set_active_story on harness 38ae2924** — its team's active story is the real story 1083 (this project's own live coding/QA work, visible via a project-scope get_next_requirement call showing 1083's real ComponentCode wave). Story/component-scoped tools (start_task/evaluate_task/set_story_component with a session_id, not an agent_id) never touch team/active-story state, so they're safe; GetNextRequirement with a story_number for an inactive story is not — that's criterion 1721's blocker, unchanged by this session's fix.

## What To Test

- **1720** — Fresh stories G (1090) and H (1091), released. start_task(component_linked, story, G). set_story_component(G, CodeMySpecWeb.Qa1083BillingLive). evaluate_task(task_id, session_id). Assert: "ArchitectureDesign: Passed"; get_story(G) shows the component; get_story(H) shows none. **Verified passing this session.**
- **1721** — Verified passing this session using the sandbox fixture (plan.md, "A safe fixture for story-scoped gating"). This worktree's own DB copy of project 11111111 had no story 34/35 yet, so built them fresh over this instance's /mcp/harness (X-Project-ID: 11111111-1111-4111-8111-111111111111, X-Harness-Id: 1fc425f5-7b88-4e32-86a3-c16c3317408c): create_story ×2 (34 "QA1721 Linked", 35 "QA1721 Unlinked"), update_story(ready_for_dev=true) ×2, set_active_story(story_number=34) (reusing the sandbox's existing stopped coding agent as the team). get_next_requirement(story_number=34) reached that story's own scope ("Status: blocked ... Sync this working copy" — a separate, unrelated gate); get_next_requirement(story_number=35) correctly refused with "Story 35 is not this working copy's team's active story (34)...". Real project's own team untouched throughout.
- **1722** — Fresh story I (1092), released, existing component already present (Qa1083BillingLive, count 1320 before). start_task, set_story_component(I, Qa1083BillingLive), evaluate_task. Assert: "Passed"; I links to it; component count unchanged (1320 after). **Verified passing this session.**
- **1723** — Fresh story J (1093), released, no "Reports" component yet. start_task, create_component(Qa1083Reports/CodeMySpecWeb.Qa1083ReportsLive/liveview), set_story_component(J, it), evaluate_task. Assert: "Passed"; component count 1320→1321; J links to the new component. **Verified passing this session.**
- **1724** — After linking a story to a component, log in as the owner and navigate to /app/projects/708492f9-454e-482f-a2eb-be64f0356b87/architecture. Assert: the linked component's module name appears. **Already verified passing in the prior attempt (screenshot `.code_my_spec/qa/1083/screenshots/60642_architecture.png`); unaffected by this session's fix, not re-run.**

## Result Path

QA completion is recorded via submit_qa_result (DB-backed attempt) — there is no result.md file.

## Setup Notes

This is the third pass on this story. The first (`cfd27ad1`) was blocked on issue `ed28189c` (:no_environment via /mcp/harness, fixed by commit 68fbc0897). The second (`cfd27ad1`'s successor) retested 1720/1722/1723 end-to-end and passed them, but found no safe fixture for 1721 (issue `a73d27f0`). That issue is now resolved: a sandbox fixture for the team active-story gate exists (plan.md). This pass rebuilt it fresh in this worktree's own DB copy and 1721 now passes too. All five criteria pass.
