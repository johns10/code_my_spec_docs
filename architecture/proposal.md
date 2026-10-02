# Architecture Proposal: Code My Spec

## Contexts

### CodeMySpec.Accounts

- **Type:** context
- **Description:** Multi-tenant accounts with members and invitations. Account creation is a manual first step in the /app onboarding wizard; auth no longer auto-provisions accounts.
- **Stories:** 606, 607

### CodeMySpec.AgentTasks

- **Type:** context
- **Description:** Specialized task modules — codegen, QA, research, integration planning, three amigos, persona research, spex boundary readiness, architecture design, ADRs, component spec / test, BDD specs — that build agent prompts and evaluate output. Each task is a child module surfaced via the local MCP tools server.
- **Stories:** 70, 76, 78, 80, 124, 460, 559, 597, 598, 608, 668, 669, 670, 677

### CodeMySpec.Configurations

- **Type:** context
- **Description:** Per-project local quality-gate settings (`require_specs`, `require_reviews`, `require_unit_tests`). Filters the requirement graph without breaking edges or producing vacuous actionable nodes.
- **Stories:** 553, 671

### CodeMySpec.Content

- **Type:** context
- **Description:** Generator-output rendering surface dropped into deployed client apps. Receives content pushes from ContentAdmin, persists locally, renders `/blog/:slug`, `/pages/:slug`, `/landing/:slug`, `/documentation/:slug` honoring publish_at/expires_at and tag filters.
- **Stories:** 703, 713

### CodeMySpec.ContentAdmin

- **Type:** context
- **Description:** Editorial ingest layer on the SaaS — fresh-clone-per-sync from `docs_repo`, markdown + YAML frontmatter parsing, parse-status visibility, scheduling, image handling, push trigger to deployed Content clients.
- **Stories:** 702

### CodeMySpec.Documents

- **Type:** context
- **Description:** Document-spec validation infrastructure backing spec/QA/integration document type checks. Internal layer consumed by Validation; not user-facing.

### CodeMySpec.Files

- **Type:** context
- **Description:** Filesystem-to-DB projection of tracked project files. Stores path, role, mtime, fingerprint, validity, owning component. Drives auto-embedding (project_knowledge + hex_doc roles) so semantic_search reflects current disk state.
- **Stories:** 127, 687, 688, 689

### CodeMySpec.Git

- **Type:** context
- **Description:** Git CLI wrapper used for content sync (fresh-clone-per-sync from project docs_repo). Internal dependency of ContentAdmin; not user-facing.

### CodeMySpec.Issues

- **Type:** context
- **Description:** Project issues — automated QA failures, user-reported bugs, requirements-change feedback, framework-scoped agent friction. Triage moves bug+QA items into the work queue; requirements-change items trigger story review.
- **Stories:** 599, 600, 709, 728

### CodeMySpec.McpServers

- **Type:** context
- **Description:** MCP tool surfaces — Stories, Components, Architecture, Issues, Tasks, Personas, Requirements, BddRules, Knowledge, Bootstrap. Each sub-namespace exposes Anubis tools that the agent calls from Claude Code.
- **Stories:** 682, 690, 711, 715

### CodeMySpec.Personas

- **Type:** context
- **Description:** Project-scoped personas (proto / qualitative / statistical). Identity + metadata in DB; research text lives on disk at `.code_my_spec/personas/<slug>/`. Linked to stories via `persona_stories`.
- **Stories:** 560

### CodeMySpec.Projects

- **Type:** context
- **Description:** Per-project records (id, name, local_path, docs_repo, account_id). Project creation from /app's wizard sets the new project active; the local app resolves scope from `local_path` against the current working directory.
- **Stories:** 62, 604, 701

### CodeMySpec.Requirements

- **Type:** context
- **Description:** Requirement graph — dependency-aware definitions linking stories, components, and tasks. Computes satisfaction from Files + Problems. `next_actionable_project` returns the highest-priority unsatisfied node whose prerequisites are met. Priority propagates transitively down the component tree.
- **Stories:** 561, 562, 563, 717

### CodeMySpec.Sessions

- **Type:** context
- **Description:** Agent session lifecycle — tasks, sub-agents, hand-offs, stuck-state detection, evaluation. Filesystem-backed sessions under `.code_my_spec/sessions/` with status tracking.
- **Stories:** 538, 704

### CodeMySpec.StaticAnalysis

- **Type:** context
- **Description:** Credo + Sobelow runner stage of the validation pipeline. Internal dependency of Validation.

### CodeMySpec.Stories

- **Type:** context
- **Description:** User stories CRUD, acceptance criteria, tagging, refinement sessions. Both web LiveView UI and MCP tools share the same domain layer so the agent and the PM can manage the bookkeeping interchangeably.
- **Stories:** 686

### CodeMySpec.Tags

- **Type:** context
- **Description:** Story-tag CRUD and project tag listing. Internal dependency of Stories for tag-based grouping.

### CodeMySpec.Tests

- **Type:** context
- **Description:** ExUnit test runner stage of the validation pipeline. Internal dependency of Validation.

### CodeMySpec.Users

- **Type:** context
- **Description:** Email + OAuth identity. Magic-link registration delivers a login link that drops the user at /app where the onboarding wizard takes over.
- **Stories:** 601, 602

### CodeMySpec.Validation

- **Type:** context
- **Description:** Stop-hook validation pipeline — compile → test → Credo → Sobelow → Spex → spec/QA documents — chained on file edits during agent sessions. Surfaces problems back to the agent for fix-in-place.
- **Stories:** 554, 555

### CodeMySpec.Qa

- **Type:** context
- **Description:** Per-story QA attempts with audit-grade event trail. Typed `submit_qa_result` / `list_qa_attempts` / `invalidate_qa_attempt` MCP tools replace file-parsing of result.md; status flips drive `qa_complete` directly from the DB.
- **Stories:** 726, 727

## Surface Components

### CodeMySpecWeb.AppLive

- **Type:** live_context
- **Description:** The `/app` onboarding wizard + overview. Renders the next missing setup step (account creation, then project creation) until both are done; lands returning users with at least one project on the Overview view.
- **Stories:** 603, 605, 700

#### Children

- CodeMySpecWeb.AppLive.Overview (liveview) [Stories: 698]: Dashboard overview with install funnel and live CLI status; replaces wizard for returning users with projects.

### CodeMySpecWeb.ContentAdminLive

- **Type:** live_context
- **Description:** Editorial admin UI for the ContentAdmin context — list and inspect synced content, parse status, schedule pushes.
- **Stories:** 702, 712

### CodeMySpecWeb.IssuesLive

- **Type:** live_context
- **Description:** Project-scope issue browser — list with severity / status filters, per-issue detail with triage actions, link-back to the originating story or QA run.
- **Stories:** 599

### CodeMySpecWeb.PersonasLive

- **Type:** live_context
- **Description:** Project personas index + show, with research links to the on-disk `.code_my_spec/personas/<slug>/` artifacts.
- **Stories:** 560

## Dependencies

- CodeMySpecWeb.AppLive -> CodeMySpec.Accounts
- CodeMySpecWeb.AppLive -> CodeMySpec.Users
- CodeMySpecWeb.AppLive -> CodeMySpec.Projects
- CodeMySpecWeb.ContentAdminLive -> CodeMySpec.ContentAdmin
- CodeMySpecWeb.IssuesLive -> CodeMySpec.Issues
- CodeMySpecWeb.PersonasLive -> CodeMySpec.Personas
- CodeMySpec.AgentTasks -> CodeMySpec.Validation
- CodeMySpec.AgentTasks -> CodeMySpec.Sessions
- CodeMySpec.AgentTasks -> CodeMySpec.Requirements
- CodeMySpec.AgentTasks -> CodeMySpec.Stories
- CodeMySpec.AgentTasks -> CodeMySpec.Issues
- CodeMySpec.AgentTasks -> CodeMySpec.Personas
- CodeMySpec.AgentTasks -> CodeMySpec.Files
- CodeMySpec.AgentTasks -> CodeMySpec.Documents
- CodeMySpec.McpServers -> CodeMySpec.AgentTasks
- CodeMySpec.Validation -> CodeMySpec.Tests
- CodeMySpec.Validation -> CodeMySpec.StaticAnalysis
- CodeMySpec.Validation -> CodeMySpec.Documents
- CodeMySpec.ContentAdmin -> CodeMySpec.Git
- CodeMySpec.ContentAdmin -> CodeMySpec.Content
- CodeMySpec.Stories -> CodeMySpec.Tags
- CodeMySpec.Requirements -> CodeMySpec.Files
