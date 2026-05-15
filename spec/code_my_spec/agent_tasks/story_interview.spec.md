# CodeMySpec.AgentTasks.StoryInterview

## Type

skill

## Intent

Run a guided story interview or review session with the Product
Manager. Two modes:

- **`interview`** — develop bare user stories through PM questioning.
- **`review`** — evaluate completeness and quality of existing stories.

Mode comes from `session_type`: `"story_interview"` → interview,
`"story_review"` → review.

Acceptance criteria, rules, and scenarios are NOT produced here.
Those come later via Three Amigos / Example Mapping per story. This
task captures the human persona, the goal, and the business value.

## Done signal

- **Interview mode**: `StoriesChecker.exist?/2` returns true (≥1
  story exists on the project).
- **Review mode**: always `:valid`. Review is an inspection pass
  with no graph gate.

## Dispatch shape

`componentless_task` — project-scoped. Surfaces from the requirement
graph as `stories_exist` (id 15, `validation_type: :manual`), gated
by `personas_complete` (id 13).

## Out of scope

- Acceptance criteria — Three Amigos per story.
- Rules and scenarios (Given/When/Then) — Three Amigos.
- Edge cases and failure modes — Three Amigos.
- Persona research artifacts — `persona_research`.
- Story-to-component linking — `architecture_design`.

## Failure modes the agent should avoid

- Writing technical-persona stories ("As a system...", "As an API...")
  in interview mode.
- Writing acceptance criteria during this session.
- Producing too many overlapping stories — pragmatic, well-scoped
  beats many small overlapping ones.
- Reviewing acceptance criteria in review mode — flag but don't
  author.

## Resources

Required input:
- The active project.
- Existing stories on the project — `Stories.list_project_stories/1`.
- The PM in conversation. Human-in-the-loop.

Required reading:
- `priv/knowledge/story_interview/workflow.md` — both modes' procedures,
  story quality rules, MCP tool usage.

Produced (via MCP tools, not files):
- New story records via `create_story` (interview).
- Updated story records via `update_story` (interview or review).

## Tools

- **`create_story`** — persist a new story.
- **`update_story`** — revise an existing story.
- **`list_stories`** / **`list_story_titles`** — enumerate stories.
- **`get_story`** — full detail by id.

## Dependencies

- CodeMySpec.Requirements.CheckerResult
- CodeMySpec.Requirements.StoriesChecker
- CodeMySpec.Stories
