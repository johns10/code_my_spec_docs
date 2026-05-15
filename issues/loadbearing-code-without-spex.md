# Load-Bearing Code Without Spex — Gap Audit

Surveyed: 47 stories, 44 spex story-dirs, all top-level contexts under
`lib/code_my_spec/`, all 80 MCP tools, all LiveView/channel surfaces.
Method: cross-referenced spex aliases + route hits + tool/LV/channel
inventory + module LOC as load-bearing proxy. Ranked by blast radius if
the surface broke.

## Story-level criterion gaps (for the record)

Already known and out of scope for this issue, but listed so they aren't
re-discovered:

- Story 600 (Requirements Review) — 7 criteria, 0 rules, 0 scenarios, 0
  spex. Blocked on Three Amigos; criteria are pre-rule brain-dump.
- Story 702 (ContentAdmin — editorial ingest) — 0 criteria. Three Amigos
  pending. Replaces legacy 112/113/118/119.
- Story 703 (Content — generator-output rendering surface) — 0 criteria.
  Three Amigos pending. Replaces legacy 116 + parts of 118/119.
- Story 709 (Agent administers project issues) — criteria 6216, 6217
  missing spex.
- Story 538 (LLM Agent Autonomous Task Execution) — criterion 6238
  missing spex (stuck-detection counter reset).

The rest of this issue is about **load-bearing code lacking any spex
coverage**, ranked by tier.

---

## Tier 1 — Harness loop critical (agent can't bootstrap)

The surfaces the agent must hit on day 1. Silent failure here blocks
every downstream story.

| Surface | Why load-bearing | Coverage |
|---|---|---|
| `init_project` MCP tool | Bootstrap entry — sets `Project.local_path`, anchors `WorkingDirScope` | None |
| `list_projects` MCP tool | Pre-init step — agent picks which project to link | None |
| `sync_project` MCP tool | Forces full projection rebuild; failure leaves graph out of sync | None |
| `install_claude_md`, `install_agents_md`, `install_rules` MCP tools | Bootstrap scaffolding — drops the files this whole system reads from | None |
| `InitLive` (`lib/code_my_spec_local_web/live/init_live.ex`) | Local UI for project init | None |

Story 124 (Project Setup) covers step-state rendering but does not drive
these MCP tools end-to-end through their surface.

---

## Tier 2 — Architecture & graph admin (700+ LOC modules behind them)

Every spec/code/test flows through these. Modules behind the surfaces
are huge (`architecture/proposal.ex` 974 LOC, `requirement_graph.ex` 998
LOC) but the agent-facing surfaces are uncovered.

| Surface | Coverage gap |
|---|---|
| `show_architecture`, `show_architecture_overview` MCP tools | Architect's reading surfaces — only `ExecuteProposal` is covered |
| `orphaned_contexts` MCP tool | Post-execution gate that Story 70's criterion 5871 mentions but doesn't exercise the tool itself |
| `validate_dependency_graph` MCP tool | Integrity check — would catch silent graph corruption |
| `analyze_stories`, `analyze_story_linkage` MCP tools | Project-wide story↔component analysis |
| `show_requirement`, `show_component_requirements`, `show_story_requirements` MCP tools | Graph debugging surfaces |
| `start_context_design`, `review_context_design` MCP tools | Story 78 covers *output* validation, not these *entry points* |

---

## Tier 3 — Content cluster (matches 702/703)

~900 LOC across `content_sync.ex` + `content_sync/sync.ex` + the
`content_admin/` and `content/` contexts is completely unspec'd.

| Surface | LOC | Coverage |
|---|---|---|
| `lib/code_my_spec/content_sync.ex` + `content_sync/sync.ex` | ~900 | None |
| `lib/code_my_spec/content_admin.ex` + `content_admin/*` | sizable | None |
| `lib/code_my_spec/content.ex` + `content/*` | sizable | None |
| `CodeMySpecWeb.ContentAdminLive.{Index,Show}` | UI | None |
| Front-stage Content render routes (`/blog/:slug`, `/pages/:slug`, `/landing/:slug`, `/documentation/:slug`) | UI | None |

ContentAdmin (server-side ingest + push) is the tractable half. Content
render is the harder half because it ships as generator output into a
client app, so spex must drive the generator and a synthesized client.

---

## Tier 4 — Agent bookkeeping (single-tool wins, low cost each)

These exist, the agent calls them, and they have zero behavioral
coverage. Each is one spex file. None are new behavior — just no
contract pinned.

| Group | Uncovered tools |
|---|---|
| Component management | `update_component`, `delete_component`, `get_component`, `create_components` (bulk), `clear_story_component` |
| Criterion / rule management | `update_criterion`, `link_criterion_to_rule`, `delete_rule` |
| Persona management | `update_persona`, `get_persona`, `delete_persona`, `unlink_persona_from_story` |
| Story bookkeeping | `list_stories` (only `list_story_titles` is covered), `create_stories` (bulk) |
| Triage | `triage_issues` (bulk entry — only individual triage tools covered) |

---

## Tier 5 — Local web UI (the developer's eyes on the system)

Spex routes hit `/app`, `/app/projects*`, `/app/issues`,
`/app/accounts/picker`, `/app/users/settings`, plus
`/projects/:name/files` (local). Everything else in the local app is
dark.

| Local LiveView | Purpose | Coverage |
|---|---|---|
| `architecture_live` | Local architecture viewer | None |
| `requirements_live` | Graph viewer | None |
| `configuration_live` | Project config UI (`require_specs` etc.) | None — Story 553 hits behavior, not the UI |
| `sessions_live` | Session list | None |
| `problems_live` | Problem inspector | None |
| `markdown_browser_live` | Knowledge browser | None — Story 690 covers MCP side only |
| `story_live/{form,index,show,gherkin,scheduler,import,three_amigos}` | Story management UI | None |
| `personas_live/{index,show,form_component}` | Persona UI | None |
| `auth_live` | Local auth flow | None |

---

## Tier 6 — Multi-user account ceremony

Anything past solo founder use is dark.

| Surface | Coverage |
|---|---|
| `account_live/{manage,members,invitations,form}` | None |
| `invitations_live/{accept,form}` | None |
| `user_preference_live/form` | None |

---

## Tier 7 — Channels (real-time surfaces)

| Channel | Coverage |
|---|---|
| `CliChannel` | Covered by 698 + 701 |
| `UserSocket` | Covered transitively |
| `IssuesChannel` | None |
| `SessionChannel` | None |
| `PermissionChannel` | None — `tap_out` covers the tool, but the channel that delivers the approval isn't exercised |

---

## Tier 8 — Internal modules without a story or surface

Heavy and load-bearing but they don't show up in any story's surface.
For each, the question is: should this have a story (we're missing a
requirements entry) or is it pure infra?

| Module | LOC | Read |
|---|---|---|
| `documents/registry.ex` | 1449 | Document spec registry — every validator depends on it. No story owns it; referenced by Stories 80, 460, 668. Worth a dedicated story. |
| `environments/cli/tmux_adapter.ex` | 476 | CLI agent execution backbone. No story. |
| `agent_tasks/qa_app.ex` | 446 | Full-app QA orchestration. Story 668 covers *planning* QA, not running it. |
| `agent_tasks/qa_story.ex` | 482 | Per-story QA orchestration. Same gap as qa_app. |
| `static_analysis/analyzers/spec_alignment.ex` | 631 | Test-spec alignment validator. Hit by 127's 5937, but many branches uncovered. |
| `auth/oauth_client.ex` | 405 | OAuth client (consumer side). Story 602 hits the callback; the client wrapping isn't exercised. |
| `git`, `git_hub.ex`, `google/` | varies | Used by ContentAdmin (git pull) + OAuth (GitHub/Google). Coverage piggybacks on those clusters' state. |
| `notifications/` | small | Notification dispatch — no story. |
| `code/compile.ex` | — | Compile orchestration — hit transitively via stop hook spex. |

---

## Recommended order

Ranked by (load-bearing × no coverage × cost-to-write):

1. **Bootstrap MCP tools** (`init_project`, `list_projects`,
   `sync_project`, three `install_*`) — ~6 spex files, single scenarios,
   each pins a verbal-contract behavior.
2. **Tier 4 bookkeeping tools** — ~14 spex files, mechanical, covers
   existing built code.
3. **Architecture admin tools** (`show_*`, `orphaned_contexts`,
   `validate_dependency_graph`, `analyze_*`) — ~7 spex files, pins the
   read paths the architect uses every session.
4. **ContentAdmin** (story 702) — needs Three Amigos first, but
   tractable.
5. **`documents/registry.ex`** — needs a new story; the single biggest
   unowned module in the repo.
6. **Local LiveView surfaces** (configuration, requirements, sessions,
   story_live/*) — the developer can't trust the local UI today.
7. **Channels** (`IssuesChannel`, `SessionChannel`, `PermissionChannel`)
   — three spex files for real-time correctness.
8. **Content** (story 703) — last; generator-shape complexity.
9. **Multi-user ceremony** — only matters at the second seat.

The cheap-but-load-bearing wins are #1, #2, #3 — roughly 27 spex files
that cover the spine of the harness.
