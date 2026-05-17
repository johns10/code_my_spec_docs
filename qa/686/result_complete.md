# Qa Result

Story 686 — AI-Assisted Story Management. Tests the MCP tool surface for story/persona/Three Amigos/issue triage tooling.

## Status

pass

## Scenarios

### SC-1: Agent creates a story (criterion 5907)

pass

Executed via `mix spex` running the BDD spec directly against the MCP tool module
(`CreateStory.execute/2` + `ListStoryTitles.execute/2`). The spec creates a story with
title "Driver onboarding" and asserts it appears in `list_story_titles`. Test passed in
10.8ms. Also verified the local web UI at `http://127.0.0.1:4003/projects/code-my-spec/stories`
renders stories correctly with all expected controls (Three Amigos, Gherkin, Edit, Delete).

Evidence: `.code_my_spec/qa/686/screenshots/686_stories_list.png`

### SC-2: Agent updates a story (criterion 5908)

pass

BDD spec calls `UpdateStory.execute/2` with new title/description, then `GetStory.execute/2`
to verify the change. Asserts new title ("Renamed title") appears, new description
("Revised description") appears, and old title ("Original title") is absent. Test passed
in 16.0ms.

### SC-3: Agent deletes a story with cascade (criterion 5909)

pass

BDD spec creates a sibling story, a doomed story with a linked persona, a rule, and a
linked issue. Calls `DeleteStory.execute/2`. Verifies: sibling still in list, deleted story
absent, `list_rules` returns "No rules on this story", and `get_issue` confirms the issue
persists with its story link cleared. All assertions pass.

### SC-4: Agent adds a criterion (criterion 5910)

pass

BDD spec creates a story, calls `AddCriterion.execute/2` with description "Driver completes
the welcome screen", then `GetStory.execute/2`. Asserts the criterion text appears in the
story output. Test passed.

### SC-5: Agent creates and applies a tag (criterion 5912)

pass

BDD spec creates a story, calls `TagStories.execute/2` with a unique tag name
(`epic:onboarding-<unique_integer>`). Tags are auto-created on first use. Asserts tag
appears in `ListProjectTags.execute/2` output and in `GetStory.execute/2` output. Test passed.

### SC-6: Agent starts a story interview session (criterion 5913)

pass

BDD spec calls `StartStoryInterview.execute/2` with no params. Asserts response contains
"Product Manager" and matches `~r/produce a set of\s+bare user stories/`. Test passed in
9.9ms. Unit test in `start_story_interview_test.exs` also verified: response contains the
story title and handles empty projects with "No stories currently exist" message.

### SC-7: Agent starts a Three Amigos session (criterion 5914)

pass

BDD spec creates a story, calls `StartThreeAmigosSession.execute/2` with the story_id.
Asserts response contains "Three Amigos", references the story title, and mentions
add_rule/add_scenario/persona tools. Test passed in 9.0ms. Local web Three Amigos page
at `/projects/code-my-spec/stories/601/three-amigos` verified to render correctly with
rules panel, scenarios, and questions sidebar.

Evidence: `.code_my_spec/qa/686/screenshots/686_three_amigos_page.png`

### SC-8: Agent runs full Three Amigos workflow (criterion 5915)

pass

BDD spec creates a story, creates a persona, links persona to story via
`LinkPersonaToStory.execute/2`, adds a rule via `AddRule.execute/2`, adds a scenario via
`AddScenario.execute/2`, then parks a question via `AddQuestion.execute/2`. Verifies:
`list_rules` returns the rule statement, `list_questions` returns the question, and
`get_story_gherkin` renders both the rule and scenario body in Gherkin format. All
assertions pass.

### SC-9: Accept issue as requirements change (criterion 5916)

pass

BDD spec creates an issue and a story, calls `AcceptIssue.execute/2` with
`category: "requirements_change"` and `story_id`. Asserts response confirms acceptance
with "requirements_change" category. Then calls `GetIssue.execute/2` and asserts issue
shows "accepted" status and the story_id link. Test passed.

Note: `sync_resolution_to_remote/2` runs in a background Task that fails in test/dev
environments (no OAuth client configured). This is a non-fatal background error — the
primary call succeeds and the issue state is correctly persisted locally. See Issues
section.

### SC-10: Accept issue as bug without story link (criterion 5917)

pass

BDD spec creates an issue, calls `AcceptIssue.execute/2` with `category: "bug"` and no
story_id. Asserts response confirms "accepted" and "bug". Then `GetIssue.execute/2` asserts
"accepted" status, "bug" category, and no `Story: \d+` pattern. Test passed.

### SC-11: Dismiss an issue with reason (criterion 5918)

pass

BDD spec creates an issue and an unrelated story, calls `DismissIssue.execute/2` with a
reason string. Asserts response confirms "dismissed". Then `GetIssue.execute/2` asserts
"dismissed" status and the reason text "Duplicate of the earlier welcome-screen report".
Also verifies the unrelated story is unchanged via `ListStoryTitles.execute/2`. Test passed.

## Evidence

- `.code_my_spec/qa/686/screenshots/686_local_project_hub.png` — local web project hub at port 4003
- `.code_my_spec/qa/686/screenshots/686_stories_list.png` — stories list showing full CRUD UI controls
- `.code_my_spec/qa/686/screenshots/686_three_amigos_page.png` — Three Amigos session page for story 601
- Test run: `mix spex` — 497 tests, 0 failures (includes all 11 story 686 BDD spex tests)
- Test run: `mix test test/code_my_spec/mcp_servers/stories/ test/code_my_spec/mcp_servers/issues/ test/code_my_spec/mcp_servers/personas/` — 70 tests, 0 failures

## Issues

### Background Task crashes silently on issue resolution sync in test and dev

#### Severity
INFO

#### Scope
APP

#### Description

When `accept_issue` or `dismiss_issue` resolves an issue, `Issues.sync_resolution_to_remote/2`
fires in a background Task. In test and dev environments (where no OAuth client is
configured), this Task crashes with:

```
(DBConnection.OwnershipError) cannot find ownership process for #PID<...>
```
followed by:
```
CodeMySpec.Auth.OAuthClient.get_active_client_user/0
...
CodeMySpec.Issues.sync_resolution_to_remote/2
```

The primary issue resolution succeeds (local state is correct), but the error log is noisy
and could mask other issues. In production (with a valid OAuth token), the sync should
succeed. No functional regression observed in QA. Recommend either guarding the Task with
`OAuthClient.authenticated?/0` before attempting the sync, or catching the error within
the Task to log it at debug level instead of letting the process crash.
