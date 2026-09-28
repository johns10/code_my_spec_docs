# Story 823 (#686) "AI-Assisted Story Management": retire changes

Apply after stories 1076 ("Criteria are added, reworded and retired, never deleted") and 1077 ("A spec file names its criterion by number") are built.

Rule: stories and criteria are retired, never deleted. Numbers are per project and are never reused.

## Criterion changes

| Criterion | Change |
|---|---|
| 1801 "Agent deletes a story with rules and linked issues, rules are removed but issues remain with story_id cleared" | Reword: "Agent retires a story; it leaves the backlog and the graph, its criteria retire with it, and linked issues keep their link" |
| 1802 "Agent adds a criterion, criterion appears on the story" | Move to story 1076. It is criterion CRUD. `move_criterion` keeps its number. |
| new | "A retired story's number is never given to another story" |
| new | "Updating a story leaves its criteria untouched" |

## Why "updating a story leaves its criteria untouched"

MCP `update_story` rebuilds `criteria` through `cast_assoc(on_replace: :delete)` (`lib/code_my_spec/mcp_servers/stories/tools/update_story.ex:98-128`). Every unverified criterion is deleted and recreated with a new id. That is how story 1100's criteria went from 4999–5006 to 4073–4080 and lost their specs. After this change, criteria change only through the criterion tools.

## Code this implies

- `delete_story` becomes a retire. The delete tool, the LiveView action and `Stories.delete_story` are affected.
- `stories_repository.ex` `next_number/1`: the comment that accepts number reuse after a delete no longer applies, because nothing is deleted.
- Retired stories drop out of the backlog, the graph and `list_story_titles`. They stay readable by number.
- Linked issues keep `story_id`. Today it is cleared on delete.
