# Three Amigos — Examples

Persona: Solo founder PM'ing their own product. Variable BDD fluency.
Adjacent personas: small-team PM, engineer-as-PM.

Note: "examples" and "scenarios" name the same artifact. This file lists
scenario titles grouped by rule; their Given/When/Then bodies live on
the corresponding `Criterion` records, viewable as a `.feature`-style
rendering in the UI and via MCP tools.

## Rule: Three Amigos is graph-dispatched per story; story is fixed input

- Story is created with no AC; graph surfaces three_amigos_complete for that story as the next actionable requirement
- Agent calls get_next_requirement and receives a Three Amigos task for a specific story
- All criteria for a story are deleted; graph re-surfaces three_amigos_complete for that story
- Story already has ≥1 criterion; graph does not surface three_amigos_complete for it
- PM tries to edit the story description from inside an active session; the edit is blocked

## Rule: Protocol ordering is enforced

- Agent walks the PM through persona linkage → rules → scenarios in order
- Agent ensures a persona is linked first, then asks the PM for the first business rule
- Agent declines when the PM asks it to "skip ahead and just write scenarios"
- Agent attempts to add a scenario before any rule exists; the MCP tool rejects the call
- Agent names a scenario and writes its Given/When/Then body in the same MCP call

## Rule: Persona linkage required

- Agent finds a suitable persona in the account library and links it via persona_stories
- Agent finds no suitable persona, calls add_persona to create a lightweight record, and links it
- Agent links two personas to the story when scenarios cover distinct user roles
- After Three Amigos completes with a newly-added lightweight persona, the next graph requirement is personas_complete to fill in research artifacts
- Agent attempts to add a rule before any persona is linked; the MCP tool rejects the call

## Rule: Each rule needs at least one happy-path and one failure-path scenario

- Agent generates a happy-path and a failure-path scenario for every rule the PM dictates
- PM only volunteers happy-path scenarios; agent surfaces failure-path candidates without being asked
- Agent prompts the PM with "what could go wrong here?" after each rule
- Session readiness blocks completion because one rule has only happy-path scenarios
- Session readiness blocks completion because one rule has only failure-path scenarios

## Rule: Session readiness gate

- All readiness conditions pass; the agent's evaluate marks the session done; downstream graph requirements unblock
- Story has zero personas linked; readiness fails on persona linkage
- Story has zero rules; readiness fails on `rules > 0`
- Story has eleven rules; readiness fails on `rules < 10`; PM is told to slice the story
- Story has more questions than scenarios; readiness fails; story is not ready
- A rule has no scenarios; readiness fails on the happy/failure coverage check
- Multiple conditions fail simultaneously; the stop-hook feedback returns a markdown string listing every failing condition (PersonasChecker pattern)

## Rule: Session state is a persisted domain object; PM and agent share it

- Agent adds a rule via add_rule MCP tool; the blue card appears in the PM's UI within seconds
- PM clicks a rule card in the UI and edits the statement; the change persists and the agent sees the new statement on its next turn
- PM deletes a question card directly from the UI; the row is removed from the Questions table
- PM refreshes the page mid-session; all rules / scenarios / questions are still present
- DB write fails when adding a card; the agent surfaces the error and the card does not appear in the UI

## Rule: Agent operates via MCP tools

- Agent's task prompt enumerates the available MCP tools at session start
- Agent's task prompt points to the knowledge MCP for protocol guidance
- Agent calls add_rule via MCP; the Rule row is created and visible in the UI
- Agent attempts to add a rule with a malformed payload; the MCP tool returns a validation error
- Agent attempts to add a question with missing required text; the MCP tool returns a validation error

## Rule: Documentation is split — PM gets UI, agent gets knowledge MCP

- First-time PM clicks a "What is a rule?" tooltip on the blue card type and reads the inline definition
- PM hovers over the readiness check status indicator and sees the failing condition explained
- PM follows a doc link to "How Example Mapping works" without leaving the session
- Agent calls the knowledge MCP tool with a query about Three Amigos protocol and receives relevant guidance
- Agent does not write a tutorial paragraph about BDD when the PM seems confused; surfaces the doc link instead
