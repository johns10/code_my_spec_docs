# Qa Result

**Story:** 686 — AI-Assisted Story Management
**Date:** 2026-05-18
**Tester:** Claude Code QA Agent (MCP surface, via real local server on port 4004)

## Status

fail

## Scenarios

### SC-1: Agent creates a story (criterion 5907)

pass

Called `create_story` MCP tool with title "QA5907 Driver Onboarding" and description. Story ID 769 returned. Called `list_story_titles` — confirmed "QA5907 Driver Onboarding" appears in the list.

Evidence: `.code_my_spec/qa/686/responses/ac5907_create_story.json`, `.code_my_spec/qa/686/responses/ac5907_list_story_titles.json`

### SC-2: Agent updates a story (criterion 5908)

pass

Called `create_story` (story ID 778), then `update_story` with title "Renamed title" and description "Revised description." Confirmed in SQLite: `stories` table row 778 has `title = "Renamed title"`. MCP `get_story` response shows updated title and description; old title absent.

Evidence: `.code_my_spec/qa/686/responses/ac5908_create.json`, `.code_my_spec/qa/686/responses/ac5908_update_story.json`, `.code_my_spec/qa/686/responses/ac5908_get_story.json`

### SC-3: Agent deletes a story with cascade (criterion 5909)

fail

Created sibling story (ID 770), doomed story (ID 771), persona (id `17fa26b4`), linked persona to story 771, added rule, created issue (ID `745fae09`) linked to story 771. Called `delete_story` on story 771.

Results:
- `list_story_titles`: sibling story present (pass), doomed story absent (pass)
- `list_rules` for story 771: returns "No rules on this story yet" (cascade pass)
- `get_issue` for `745fae09`: issue still exists (pass) BUT still shows `**Story:** 771` (fail)

Direct SQLite query confirms: `issues` row `745fae09` has `story_id = 771` — not cleared. The `delete_story` implementation does not nilify `story_id` on linked issues and the FK column has no `ON DELETE SET NULL` constraint.

Evidence: `.code_my_spec/qa/686/responses/ac5909_create_doomed.json`, `.code_my_spec/qa/686/responses/ac5909_delete_story.json`, `.code_my_spec/qa/686/responses/ac5909_list_after_delete.json`, `.code_my_spec/qa/686/responses/ac5909_list_rules_after_delete.json`, `.code_my_spec/qa/686/responses/ac5909_get_issue_after_delete.json`

### SC-4: Agent adds a criterion (criterion 5910)

pass

Called `create_story` (ID 772), then `add_criterion` with "Driver completes the welcome screen". `get_story` response for story 772 contains the criterion text.

Evidence: `.code_my_spec/qa/686/responses/ac5910_add_criterion.json`, `.code_my_spec/qa/686/responses/ac5910_get_story.json`

### SC-5: Agent creates and applies a tag (criterion 5912)

pass

Called `create_story` (ID 773), `list_project_tags` (1 pre-existing tag), `tag_stories` with unique tag `epic:onboarding-qa-71595`. `list_project_tags` now includes the new tag. `get_story` response for story 773 contains the tag.

Evidence: `.code_my_spec/qa/686/responses/ac5912_list_tags_before.json`, `.code_my_spec/qa/686/responses/ac5912_tag_stories.json`, `.code_my_spec/qa/686/responses/ac5912_list_tags_after.json`, `.code_my_spec/qa/686/responses/ac5912_get_story.json`

### SC-6: Agent starts a story interview session (criterion 5913)

pass

Called `start_story_interview`. Response contains "Product Manager" and matches `produce a set of bare user stories` instruction.

Evidence: `.code_my_spec/qa/686/responses/ac5913_start_story_interview.json`

### SC-7: Agent starts a Three Amigos session (criterion 5914)

pass

Called `create_story` (ID 774, title "AC5914 Three Amigos Story"), then `start_three_amigos_session` with `story_id: "774"`. Response contains "Three Amigos", references "AC5914 Three Amigos Story", and mentions `add_rule`/`add_scenario`/`persona`.

Evidence: `.code_my_spec/qa/686/responses/ac5914_start_three_amigos.json`

### SC-8: Agent runs full Three Amigos workflow (criterion 5915)

pass

Created story (ID 775), persona (`47842feb`), linked persona, added rule "Drivers must have a verified phone number.", added scenario (happy_path), parked question "Does verification time out after 24 hours?"

- `list_rules` for story 775: returns the rule statement (pass)
- `list_questions` for story 775: returns the parked question (pass)
- `get_story_gherkin` for story 775: contains rule statement and "the account is marked verified" scenario body (pass)

Evidence: `.code_my_spec/qa/686/responses/ac5915_add_rule.json`, `.code_my_spec/qa/686/responses/ac5915_add_scenario.json`, `.code_my_spec/qa/686/responses/ac5915_add_question.json`, `.code_my_spec/qa/686/responses/ac5915_list_rules.json`, `.code_my_spec/qa/686/responses/ac5915_list_questions.json`, `.code_my_spec/qa/686/responses/ac5915_get_story_gherkin.json`

### SC-9: Accept issue as requirements change (criterion 5916)

pass

Created story (ID 776) and issue (`a15fd4ea`, no story link). Called `accept_issue` with `category: requirements_change` and `story_id: 776`. Response: "Issue accepted: 'Welcome step omits a confirmation' (ID: a15fd4ea) [requirements_change] → Story 776". `get_issue` shows `Status: accepted | **Category:** requirements_change | **Story:** 776`.

Evidence: `.code_my_spec/qa/686/responses/ac5916_create_issue.json`, `.code_my_spec/qa/686/responses/ac5916_accept_issue.json`, `.code_my_spec/qa/686/responses/ac5916_get_issue.json`

### SC-10: Accept issue as bug without story link (criterion 5917)

pass

Created issue (`86a12d5d`). Called `accept_issue` with `category: bug`, no `story_id`. Response: "Issue accepted: 'Stop hook stalls on retry' (ID: 86a12d5d) [bug]". `get_issue` shows accepted status, bug category, no story reference.

Evidence: `.code_my_spec/qa/686/responses/ac5917_create_issue.json`, `.code_my_spec/qa/686/responses/ac5917_accept_issue.json`, `.code_my_spec/qa/686/responses/ac5917_get_issue.json`

### SC-11: Dismiss an issue with reason (criterion 5918)

pass

Created story (ID 777) and issue (`cfac77dc`). Called `dismiss_issue` with reason "Duplicate of the earlier welcome-screen report." Response confirms dismissal. `get_issue` shows dismissed status and the exact reason text. `list_story_titles` confirms story 777 still exists unchanged.

Evidence: `.code_my_spec/qa/686/responses/ac5918_create_issue.json`, `.code_my_spec/qa/686/responses/ac5918_dismiss_issue.json`, `.code_my_spec/qa/686/responses/ac5918_get_issue.json`, `.code_my_spec/qa/686/responses/ac5918_list_story_titles.json`

## Evidence

- `.code_my_spec/qa/686/responses/ac5907_create_story.json` — create_story MCP response (ID: 769)
- `.code_my_spec/qa/686/responses/ac5907_list_story_titles.json` — list showing new story
- `.code_my_spec/qa/686/responses/ac5908_update_story.json` — update_story MCP response
- `.code_my_spec/qa/686/responses/ac5908_get_story.json` — get_story showing renamed title
- `.code_my_spec/qa/686/responses/ac5909_delete_story.json` — delete_story MCP response
- `.code_my_spec/qa/686/responses/ac5909_get_issue_after_delete.json` — issue still has story_id set (bug evidence)
- `.code_my_spec/qa/686/responses/ac5910_add_criterion.json` — criterion added successfully
- `.code_my_spec/qa/686/responses/ac5912_tag_stories.json` — tag applied to story
- `.code_my_spec/qa/686/responses/ac5913_start_story_interview.json` — interview prompt response
- `.code_my_spec/qa/686/responses/ac5914_start_three_amigos.json` — Three Amigos prompt response
- `.code_my_spec/qa/686/responses/ac5915_get_story_gherkin.json` — Gherkin with rule and scenario
- `.code_my_spec/qa/686/responses/ac5916_accept_issue.json` — requirements_change acceptance
- `.code_my_spec/qa/686/responses/ac5917_accept_issue.json` — bug acceptance without story link
- `.code_my_spec/qa/686/responses/ac5918_dismiss_issue.json` — dismissal with reason

## Issues

### Story delete does not clear issue story_id

#### Severity
HIGH

#### Description
When `delete_story` is called, linked issues retain the deleted story's `story_id` instead of having it set to nil. The acceptance criterion for story 686 states: "rules are removed but issues remain with story_id cleared."

Reproduction (confirmed via MCP tools against local server + SQLite direct query):
1. Create story (ID 771)
2. Create issue linked to story 771 (`create_issue` with `story_id: 771`)
3. Call `delete_story` with `story_id: 771`
4. Call `get_issue` — response shows `**Story:** 771` (not cleared)
5. Direct SQLite query confirms: `issues.story_id = 771` (not nil)

Root cause: `issues.story_id` is defined as a plain integer column with no FK `ON DELETE SET NULL`. The `StoriesRepository.delete_story/2` calls `PaperTrail.delete/2` with no pre/post nilification of linked issues.

Expected: `issue.story_id = nil` after story deletion
Actual: `issue.story_id` retains the deleted story's integer ID

Fix options:
- Add a migration to convert `issues.story_id` to a proper `references(:stories, on_delete: :nilify_all)` FK (requires schema type change from `:integer` to `:id`)
- Alternatively, explicitly update all linked issues in `StoriesRepository.delete_story/2` before deleting the story
