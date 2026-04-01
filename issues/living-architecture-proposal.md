# Living Architecture Proposal

## Problem

The architecture proposal is currently a one-shot artifact. After initial design, there's no structured way to revise the architecture as stories change or implementation reveals new needs. The `architecture_review` task is read-only and auto-approves. The `architecture_design` task creates from scratch.

Additionally, the prompt incorrectly instructs dual story mapping (stories to both surface AND domain components). Stories should only map to surface components — domain dependencies are resolved from the component graph.

## Design

### Proposal as Living Document

The proposal file (`.code_my_spec/architecture/proposal.md`) becomes the single source of truth for architecture. Two flows:

1. **Initial design** (`architecture_design`) — generates a fresh proposal from stories, agent writes it, stop hook validates and executes
2. **Revise architecture** (rename `architecture_review` → `architecture_revise`) — reprojects current state INTO the proposal format, agent edits it, stop hook diffs against current state and applies changes

### Revise Flow

When the agent starts a revise session:

1. **Command phase:** System reads current components, dependencies, and story links from DB. Projects them into the proposal markdown format. Writes this to `.code_my_spec/architecture/proposal.md` (overwriting). Returns a prompt telling the agent what changed (new stories, orphaned components, etc.) and to edit the proposal.

2. **Agent works:** Reads the proposal, adds/removes/reorganizes components, updates story links, adjusts dependencies. Edits the file directly.

3. **Evaluate phase:** System reads the edited proposal, diffs against current DB state:
   - New components → create spec stubs + DB records
   - Removed components → flag for review (don't auto-delete, warn agent)
   - Changed dependencies → update DB
   - Changed story links → update DB
   - Unchanged components → skip

### Key Detail: Spec Stubs vs Full Specs

The revise flow only creates **spec stubs** (frontmatter + empty sections) for new components. It does NOT require full specs. The stop hook evaluation for this task type should:
- Validate proposal format (same as design)
- Execute the diff (create stubs, update links/deps)
- NOT trigger component-level spec validation

This avoids the stop hook trap where editing a spec stub triggers full spec validation.

### Story Mapping Fix

Stories map ONLY to surface components:
- `liveview`
- `controller`
- `channel`
- `live_context` (if you keep this type)

Remove the "dual mapping" instruction from the prompt. The `Proposal.validate/2` function should reject story mappings to contexts, schemas, repositories, or modules. Dependencies handle the domain side — if `MetricFlowWeb.AccountLive.Members` depends on `MetricFlow.Accounts`, and story 426 is on Members, the system knows Accounts is needed for story 426 through the dependency graph.

### Reprojection

Need a new function (probably in `Architecture` context or a new `ProposalProjector`):

```elixir
def project_current_state(scope) -> String.t()
```

Reads from DB:
- All components grouped by parent (contexts with children)
- All dependencies
- All story-component links
- Formats as the proposal markdown

This is the inverse of `Proposal.from_markdown/2`. Could live alongside the existing projectors in `lib/code_my_spec/architecture/`.

## Files to Change

- `lib/code_my_spec/agent_tasks/architecture_design.ex` — remove dual mapping from prompt, stories only map to surface types
- `lib/code_my_spec/agent_tasks/architecture_review.ex` — rename to `architecture_revise.ex`, implement reproject → edit → diff-execute flow
- `lib/code_my_spec/architecture/proposal.ex` — add validation rejecting story mapping to non-surface types, add `diff_and_execute/3` for incremental updates
- `lib/code_my_spec/architecture/` — new `proposal_projector.ex` to project DB state → proposal markdown
- `lib/code_my_spec/requirements/requirement_definition_data.ex` — update `architecture_designed` to reference revised task if needed
- `CodeMySpec/skills/review-architecture/SKILL.md` — update to use the revise flow

## Validation Approach

The revise task's `evaluate/2` should:
1. Read proposal from disk
2. Parse with `Proposal.from_markdown/2`
3. Validate format (existing validation minus dual-mapping requirement)
4. Diff against current DB state
5. Execute diff (create new stubs, update deps/links, warn about removals)
6. Return `{:ok, :valid}` if diff applied cleanly

## Open Questions

- Should removed components be auto-deleted or just flagged? (Suggest: flag with warning, require explicit deletion)
- Should the reprojected proposal include components that were manually created (not from a proposal)? (Suggest: yes, include everything so the proposal stays complete)
- Should `architecture_design` also reproject if components already exist? (Suggest: yes, merge mode — show existing + let agent add new)
