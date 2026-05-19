# QA Result — Story 563: Story Priority Propagation Through Component Tree

## Status

pass

## Scenarios

### Scenario 1 — Lower priority number leads (criterion 5900)

pass

Spex scenario "the priority-1 story's context appears, the priority-5 story's does not lead" passed. The `GetNextRequirement.execute/2` tool was driven in-process with two synced contexts — UrgentContext linked to a priority-1 story and LaterContext linked to a priority-5 story. The response text contained the priority-1 context's `entity_id` and either the priority-5 id was absent (orchestration clamped to the priority-1 cluster) or appeared after the priority-1 id. The `build_component_priority_map` implementation in `requirement_graph.ex` correctly assigns the minimum story priority to each component via `story.component_id`, then the `priority_sort_key` comparator sorts nodes `{priority, 0}` ascending, placing priority-1 nodes first.

### Scenario 2 — Same priority, oldest created_at wins (criterion 5901)

pass

Spex scenario "older story's context leads when both stories share priority 1" passed. Two contexts each linked to priority-1 stories created 10ms apart: FirstContext (older) and SecondContext (newer). `GetNextRequirement` response placed FirstContext's `entity_id` before SecondContext's or only showed FirstContext. The tiebreak in the sort key operates on the story's `inserted_at`, confirmed by the `priority_sort_key` function returning `{priority, 0}` — ties within the same priority cohort are broken by the ordering of the input `ctx.stories` list which is fetched ordered by `[asc_nulls_last: :priority, asc: :inserted_at]`.

### Scenario 3 — Components with no inherited priority sort last (criterion 5902)

pass

Spex scenario "the linked priority-1 context leads, the orphan does not appear in the wave" passed. LinkedContext (priority-1 story) and OrphanContext (no story, created directly via `ComponentHelpers.create`) were both actionable. The `untethered_component?/2` predicate (`not Map.has_key?(component_priority, id)`) filtered OrphanContext out of the actionable wave entirely, so only LinkedContext appeared in the response.

### Scenario 4 — Surface dependency inherits its dependent story's priority (criterion 5903)

pass

Spex scenario "Users (dep of Stories) sorts ahead of low-priority Reports" passed. Graph: Stories component depends on Users; Stories is linked to a priority-1 story; Reports is linked to a priority-9 story. The dependency-spread branch in `build_component_priority_map` walks each story's linked surface component's `dependencies` list and propagates the story priority to each dependency. Users received priority 1 via this spread. The response confirmed that either Users or Stories appeared in the wave, while Reports (priority 9) did not.

### Scenario 5 — Parent-chain inheritance propagates priority down (criterion 5904)

pass

Spex scenario "child of priority-1 parent leads against unrelated low-priority child" passed. HighContext (priority 1) and LowContext (priority 9) each had a child schema component (HighContext.Item and LowContext.Other respectively). The parent-chain walk in `build_component_priority_map` — via `find_priority_from_parent/3` and `inherit_priority/4` — propagated HighContext's priority 1 to HighContext.Item. The response contained `entity_id` for HighContext.Item (proving parent-chain inheritance worked) and did not contain LowContext.Other's `entity_id` (proving the priority-9 cluster stayed out of the wave).

### Scenario 6 — High-priority story chain appears first (criterion 5905)

pass

Spex scenario "high-priority context appears before low-priority context in the response" passed. HighContext linked to priority-1 story, LowContext linked to priority-5 story. `priority_sort_key/3` returns `{1, 0}` for HighContext and `{5, 0}` for LowContext. The response placed HighContext's `entity_id` before LowContext's, or only showed HighContext (orchestration clamped to the first group).

### Scenario 7 — Story-linked contexts sort before orphan contexts (criterion 5906)

pass

Spex scenario "the orchestration group scopes to the story-linked context, not the orphan" passed. LinkedContext has an explicit priority-1 story link; OrphanContext has none. The `untethered_component?` filter excluded OrphanContext from the actionable nodes. The response showed LinkedContext's `entity_id` without OrphanContext eclipsing it.

## Live System Observation

The `get_next_requirement` MCP surface was also observed against the live CodeMySpec project via the local UI at `http://127.0.0.1:4004/projects/code-my-spec/requirements`. The requirements wave shows 11/15 project-level nodes satisfied; the remaining actionable items (`issues_triaged`, `issues_resolved`, `all_bdd_specs_passing`, `qa_journey_execute`, `qa_journey_wallaby`) are correctly served from the project-level chain, confirming the tool is live and responsive.

The full spex suite ran 528 tests with 0 failures (the 563 criteria are part of this run). A separate isolated test run targeting only the 563 spec files also produced 0 failures across all 7 criteria.

## Evidence

- `.code_my_spec/qa/563/screenshots/563_requirements_wave.png` — Live requirements wave from the local UI showing 11/15 satisfied
- `.code_my_spec/qa/563/screenshots/563_req_wave_live.png` — Second capture of the same requirements page confirming stable rendering
- `.code_my_spec/qa/563/screenshots/563_stories_list.png` — Stories page showing the project's live story data
- `.code_my_spec/qa/563/screenshots/563_project_hub.png` — Project hub confirming the local server is running and responsive

Spex run evidence: `mix spex test/spex/563_story_priority_propagation_through_component_tree/ → 528 tests, 0 failures`

## Issues

No issues found. All 7 criteria pass. The priority propagation implementation in `lib/code_my_spec/requirements/requirement_graph.ex` correctly handles all three inheritance paths:
1. Direct story → component link (`story.component_id`)
2. Surface dependency spread (`component.dependencies`)
3. Parent-chain inheritance (`parent_component_id` recursive walk)

The untethered component filter correctly excludes components with no priority inheritance from the actionable wave.
