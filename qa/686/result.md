# Qa Result

**Story:** 686 — AI-Assisted Story Management
**Date:** 2026-05-18
**Tester:** Claude Code QA Agent

## Status

partial

## Scenarios

### SC-1: Agent creates a story (criterion 5907)

pass

Executed `Stories.create_story/2` via the domain layer (same code path as the `create_story` MCP tool). Story id=746 created with title "QA-686-SC1 Agent Creates Story" in the QA Fixture Project. Verified via `Stories.list_story_titles/1` — story appears in the list. Browser navigation to `/projects/qa-fixture-project/stories/746` confirms the title and description are rendered.

Screenshot: `.code_my_spec/qa/686/screenshots/sc1_story_created.png`

### SC-2: Agent updates a story (criterion 5908)

pass

Created story id=747 "QA-686-SC2 Original Title". Called `Stories.update_story/3` with new title "QA-686-SC2 Updated Title" and description "Updated description SC2". Re-fetched via `Stories.get_story/2` — updated values confirmed. Old title "QA-686-SC2 Original Title" absent from the fetched record. Browser shows "QA-686-SC2 Updated Title" and "Updated description SC2".

Screenshot: `.code_my_spec/qa/686/screenshots/sc2_story_updated.png`

### SC-3: Agent deletes a story with cascade (criterion 5909)

fail

Created story id=748 with a linked persona, a BDD rule (via `BddRules.create_rule/3`), and a linked issue. Deleted via `Stories.delete_story/2`.

Results:
- Story 748: no longer fetchable (nil) — PASS
- BDD rules: 0 remaining after delete (cascade worked) — PASS
- Issue `c54ab8ff-fe00-4124-a52a-a5036e985113`: survives with `story_id=748` (NOT cleared) — FAIL

The acceptance criterion states "issues remain with story_id cleared". The `issues` migration defines `story_id` as a plain integer with no `ON DELETE SET NULL` behavior. The `delete_story` domain function does not explicitly clear `issue.story_id` before or after deleting the story. The issue survives (correct) but retains the deleted story's id (incorrect per AC).

### SC-4: Agent adds a criterion (criterion 5910)

pass

Created story id=749. Called `AcceptanceCriteria.create_criterion/3` with description "Given the agent adds a criterion, when I read the story, then the criterion is visible". Criterion id=6476 created successfully. `AcceptanceCriteria.list_story_criteria/2` returns the criterion. Browser at `/projects/qa-fixture-project/stories/749` shows criterion in the Acceptance criteria section.

Screenshot: `.code_my_spec/qa/686/screenshots/sc4_criterion.png`

### SC-5: Agent creates and applies a tag (criterion 5912)

pass

Created story id=750. Called `Tags.add_tag/3` with tag name "qa-686-sc5-test-tag" (creates if missing). Tag applied successfully. Re-fetched story — tag appears in `story.tags`. `Tags.list_project_tags/1` includes "qa-686-sc5-test-tag". Browser at `/projects/qa-fixture-project/stories/750` shows tag badge.

Screenshot: `.code_my_spec/qa/686/screenshots/sc5_tagging.png`

### SC-6: Agent starts a story interview session (criterion 5913)

pass

Called `StoryInterview.command/2` with scope set to QA sandbox project. Returns `{:ok, prompt}` with 1286 chars. Prompt contains:
- "Product Manager" — PASS
- "bare user stories" — PASS

The prompt instructs the agent to act as an expert Product Manager and develop acceptance criteria from bare user stories. Session is created and ready for PM to join.

### SC-7: Agent starts a Three Amigos session (criterion 5914)

pass

Created story id=752 "QA-686-SC7 Three Amigos Session". Called `ThreeAmigos.command/2` with `%{entity_id: to_string(story.id)}`. Returns `{:ok, prompt}` containing:
- "Three Amigos" — PASS
- Story title "QA-686-SC7 Three Amigos Session" — PASS
- Reference to `story_id: 752` and MCP tool context — PASS

Note: The prompt references the playbook (`priv/knowledge/three_amigos/workflow.md`) for specific tool names rather than listing `add_rule`/`add_scenario` inline. This is intentional design — the session is ready for rule and scenario capture per the acceptance criterion.

### SC-8: Agent runs full Three Amigos workflow (criterion 5915)

pass

Created story id=753. Executed complete workflow:
1. `Personas.create_persona/2` — persona "QA SC8 Product Owner" (slug: qa-686-sc8-product-owner)
2. `Personas.link_persona_to_story/3` — persona linked to story 753
3. `BddRules.create_rule/3` — rule id=`c2a4f5e3-bac4-4e43-a997-2540e76ab139` "System enforces auth on story creation"
4. `AcceptanceCriteria.create_criterion/3` — criterion id=6477 linked to rule via rule_id
5. `Questions.create_question/3` — question id=`5022b198-76f0-4dd7-99f4-44f0a3f2543d` "What happens when the agent auth token expires mid-session?"

Verification via list functions: Rules=1, Questions=1, Criteria=1, Persona links=1 — all records present.

Browser at `/projects/qa-fixture-project/stories/753/three-amigos` shows: "1 rules · 0 scenarios · 1 open · IN SESSION" with rule card and question card visible.

Note: The Three Amigos view header shows "0 scenarios" even though criterion 6477 with `rule_id` exists. The criteria count in the Three Amigos header does not count criteria linked via `rule_id` as "scenarios". The data is correct in the DB; only the header display aggregation differs.

Screenshot: `.code_my_spec/qa/686/screenshots/sc8_three_amigos.png`

### SC-9: Accept issue as requirements change (criterion 5916)

pass

Created story id=754 and issue `1c86a48f-65e9-4e74-b968-c8f546f0bc83` "QA-686-SC9 Requirements Change Issue" linked to story 754. Called `Issues.accept_issue/3` with `[category: :requirements_change, story_id: 754]`. Issue status became `accepted`, `story_id=754` confirmed.

Issues list shows "QA-686-SC9 Requirements Change Issue" as accepted/medium.

### SC-10: Accept issue as bug without story link (criterion 5917)

pass

Created issue `6b5bee35-c4ba-416d-8a11-61519ef1a277` "QA-686-SC10 Bug Without Story Link" with no story_id. Called `Issues.accept_issue/3` with `[category: :bug]`. Issue status became `accepted`, `story_id=nil` confirmed (no story reference).

Issues list shows "QA-686-SC10 Bug Without Story Link" as accepted/high.

### SC-11: Dismiss an issue with reason (criterion 5918)

pass

Created issue `f42ef4be-d733-4edc-80b3-33bbc432ff23` "QA-686-SC11 Dismiss With Reason". Called `Issues.dismiss_issue/3` with resolution "Not a real issue — confirmed working as designed". Issue status became `dismissed`, resolution recorded. Issues list shows dismissed status.

Screenshot: `.code_my_spec/qa/686/screenshots/issues_list.png`

## Evidence

- `.code_my_spec/qa/686/screenshots/sc1_story_created.png` — Story 746 visible in browser
- `.code_my_spec/qa/686/screenshots/sc2_story_updated.png` — Story 747 with updated title/description
- `.code_my_spec/qa/686/screenshots/sc4_criterion.png` — Story 749 with criterion in acceptance criteria section
- `.code_my_spec/qa/686/screenshots/sc5_tagging.png` — Story 750 with "qa-686-sc5-test-tag" applied
- `.code_my_spec/qa/686/screenshots/sc8_three_amigos.png` — Story 753 Three Amigos view with rule and question
- `.code_my_spec/qa/686/screenshots/issues_list.png` — Issues list showing accepted/dismissed QA issues
- `.code_my_spec/qa/686/responses/test_run_output.txt` — Full domain-layer test script output

## Issues

### Story delete does not clear issue story_id

#### Severity
HIGH

#### Description
When an agent deletes a story via `delete_story`, any issues previously linked to that story retain the deleted story's id in `issue.story_id`. The acceptance criterion for story 686 states: "rules are removed but issues remain with story_id cleared."

The `issues` table migration (20260306200000_create_issues.exs) defines `story_id` as a plain integer (`add :story_id, :integer`) with no `ON DELETE SET NULL` or `ON DELETE CASCADE`. The `delete_story` function in `Stories` and `StoriesRepository` does not explicitly null out `story_id` on related issues before or after deletion.

Reproduction steps:
1. Create a story (e.g., via `Stories.create_story`)
2. Create an issue linked to that story (`Issues.create_issue` with `story_id: story.id`)
3. Delete the story (`Stories.delete_story`)
4. Fetch the issue — `issue.story_id` still contains the deleted story's integer id

Expected: `issue.story_id = nil` after story delete
Actual: `issue.story_id = <deleted story's id>`

Fix: Either add `ON DELETE SET NULL` to the `story_id` FK in a migration, or explicitly update all linked issues in `StoriesRepository.delete_story` before deleting the story.

### Three Amigos view shows 0 scenarios despite criterion with rule_id existing

#### Severity
LOW

#### Description
The Three Amigos view header shows "0 scenarios" for story 753 even though a criterion (id=6477) exists with `rule_id` set to a valid BDD rule. The domain layer confirms the criterion exists via `AcceptanceCriteria.list_story_criteria`. The Three Amigos UI aggregation for the "scenarios" count does not count criteria linked via `rule_id`.

This is a display inconsistency — the data is correct in the DB, but the count displayed in the Three Amigos header may mislead agents reviewing session completeness.
