# MCP tools, code mode and agent tasks

How agents reach the harness's tools — directly, or from a Lua script through
code mode — and how the task tools turn a requirement into a prompt and judge
the result. The design behind `lib/code_my_spec/code_mode*`,
`lib/code_my_spec/mcp_servers/code_mode.ex`, the `start_task` and
`run_provisioning_step` tools, and the agent task modules. Code comments point
here by section name. The original research into the Lua runtime is in
`knowledge/code_mode/lua_for_mcp.md`.

| Module | Role |
|---|---|
| `CodeMode` | Runs a script against a catalog (`eval/3`), renders docs (`docs/2`), caps answers (`cap/1`). |
| `CodeMode.Catalog` | Which tools a script may call, their schemas, and the exclusion reasons. Pure. |
| `CodeMode.Bindings` | Binds catalog tools and refusal stubs into the Lua VM; captures `print`. |
| `McpServers.CodeMode` | Builds catalogs from `ScriptableTools` registrations and the machine's reported tools; the invoker. |
| `McpServers.Tasks.Tools.StartTask` | Resolves owner and requirement, checks the claim, creates/resumes the task, returns the prompt. |
| `McpServers.Devops.Tools.RunProvisioningStep` | Runs one provisioning step out of sequence, asynchronously. |
| `AgentTasks.StartAgentTask` | Skill/CLI route: starts a task by session type and builds its prompt. |
| `AgentTasks.TaskEvaluator` | Dispatches a task's evaluator and completes, cancels or leaves the task. |
| `AgentTasks.ArchitectureDesign`, `WriteBddSpecs`, `FixBddSpecs`, `QaStory` | Per-requirement prompt (`command/2`) and verdict (`evaluate/2`). |

## Code mode runtime

- **Two entry points.** `eval/3` runs a script with the catalog's tools bound
  as Lua functions; `docs/2` answers what a tool takes, on demand (index, one
  tool by `name:`, or ranked `search:`). The point is a short advertised tool
  list plus composition inside one call instead of round trips through the
  agent's context.
- **The VM is `lua` (pure Elixir, no NIFs).** `Sandbox` sets the instruction
  budget, call depth and string-size limits and runs each evaluation in its own
  task under a wall clock (30s default).
- **Never raises for what the script did.** Compile errors, broken limits,
  crashed tools and timeouts are all `Result` errors with a `kind`
  (`:compile`, `:instruction_budget`, `:call_depth`, `:result_too_large`,
  `:sandboxed`, `:rejected_call`, `:runtime`, `:timeout`, `:crashed`). An agent
  retries a limit and rewrites a bug, so the kinds are kept apart.
- **Prints survive a raise.** They are kept in the process dictionary of the
  evaluation's task, because a raising `Lua.eval!` discards the state it built.
- **Answers are capped.** `cap/1` cuts a rendered answer to
  `max_answer_bytes/0` (24,000), trims to valid UTF-8, and appends a note saying
  so. The sandbox bounds what a script builds, not what it returns. Every
  caller that renders a script's answer uses this one cap.
- **A script with no return value answers `nil`**, not an empty list.

## The catalog and the boundary

- **Nothing under `CodeMode` references Anubis or the server.** `McpServers`
  depends on `CodeMySpec`, not the reverse. The MCP layer builds the catalog
  from registrations and passes an invoker builder in, so the runtime is
  tested with plain-function tools.
- **Registrations come from `ScriptableTools`**, not `LocalServer`. The long
  tail is registered there so scripts reach it without it being advertised;
  unregistered would mean unreachable.
- **A registration is read structurally** (`:name`, `:description`,
  `:input_schema`) and normalised to `%{name, description, schema, invoke}`.
- **Scope is closed over when the catalog is built.** Every `invoke` already
  holds the caller's scope and frame, so a script acts with exactly the
  caller's authority; arguments cannot change it.
- **Two caller identities.** An agent we run is identified by its connection,
  so `agent_id` goes on the script's frame. A Claude Code session is identified
  by a `session_id` the `PreToolUse` hook injects into tool input, so the
  script path adds it to the arguments — only where the tool's schema declares
  it, and never over a session the script named.
- **Scoping by list, not role.** `allowed` is the list on the agent's row
  (`Agents.ToolSets`); `nil` means unscoped. Out-of-scope tools are removed from
  the catalog and named by `Catalog.out_of_scope/2`.

## Exclusions

- **Excluded by behaviour.** A tool that waits on a person
  (`ask_user_question`, `check_answer`, `list_user_questions`), spawns work
  (`start_analysis`, `assign_subagent`), dispositions the caller's own turn
  (`tap_out`, `reject_offer`), or shows something to a person (`show_in_panel`)
  means something different inside a loop.
- **The spine is excluded because it is already direct**: `get_next_requirement`,
  `start_task`, `evaluate_task`, `sync_project`, `cancel_task`, `promote`, and
  `promote_sync` (which also blocks for a merge and restart).
- **Code mode's own tools are excluded** (`run_script`, `tool_docs`) so a
  script cannot nest a VM inside a tool call; the limits are per evaluation and
  would not see it.
- **Every excluded tool must stay directly callable**, or excluding it makes it
  unreachable. `Catalog.excluded/0` is public so this can be checked.
- **The agent lifecycle is scriptable** (`start_agent`, `turn_off_agent`,
  `turn_on_agent`, `retire_agent`, `restart_agent`); who may manage the fleet is
  a `ToolSets` grant (main only; a caller with no agent identity keeps them).

## Refusals

- **Absence reads as a misspelling.** "attempt to call a nil value" makes an
  agent try spellings instead of learning the tool is not for it. So every
  known name a script may not call is bound to a stub that raises a sentence
  saying why and where the tool is.
- **Stub groups** (`Bindings.install/6`): excluded tools
  (`Catalog.exclusion_reason/1`); out-of-scope tools ("exists, and this kind of
  agent is not given it"); direct-only tools of other roles
  (`Catalog.direct_only/2`).
- **"Call it directly" only when the caller carries the tool.** Otherwise the
  refusal says it belongs to another role, so the agent does not hunt for a
  fault or reconnect.
- **Stale tool lists.** An MCP client negotiates its tool list once at connect;
  a tool registered since is missing on the caller's side only. Refusals for
  carried tools say to reconnect (`/mcp`) if a direct call answers `Unknown
  tool`.
- **Substitutes.** `escalate_question` points at `ask_user_question` (granting
  `escalate_question` would write the main agent's question table, not the
  `Questions.Question` rows product works with). `retire_criterion` points at
  filing an app issue on the story.
- **Unknown names** get a "did you mean" from the catalog (Jaro > 0.82, top 3)
  and a pointer to `tool_docs`. Agents guess Playwright names for the browser
  catalog; the real name is often close in intent but not in spelling.
- **Known defect.** `Bindings.explain_direct_names/2` calls
  `Catalog.direct_only/1` with the server's names and no `allowed`, and
  `direct_only(_, nil)` answers `[]`, so the direct-only group is never bound
  and those names fall through to the unknown-name diagnostic. Stubs are also
  bound with `Lua.set!`, which overwrites, so binding order decides which
  refusal wins.

## Script results and arguments

- **Data or prose.** A tool implementing `ScriptResult.script_result/2` gives a
  script data; otherwise the script gets the tool's reply text. Prose cannot be
  iterated, so opting in is what makes composition possible.
- **Never `structured_content` on the direct path.** Claude ignores the text
  beside structured data, so direct calls answer with prose alone; the script
  path is separate.
- **Three invoke answers.** `{:ok, value}`; `{:error, msg}` — the tool ran and
  could not answer, returned to Lua as `nil, err` so a script can carry on;
  `{:invalid_call, msg}` — the call was malformed and the tool never ran, which
  raises and stops the script.
- **Unknown arguments are rejected** before validation, because validation
  drops undeclared keys and the call would silently run unfiltered. A bare
  positional value (`"_"`) gets the table-of-names hint.
- **Validation is the same as a real MCP call's**, so a script is not a laxer
  door; the schema also casts Lua numbers to the integers tools expect.
- **Arguments are decoded recursively** with `LuaValue.from_lua/1`, so nested
  arrays and objects reach validation as JSON shapes. `{}` and no argument both
  mean no arguments.
- **A tool crash is the tool's bug**: rescued, logged, returned as an error.
- **Validation errors are rendered as their sentence plus field name**, not as
  inspected structs.

## Machine tools

- **The browser tools live on the agent's machine** (reported by the working
  copy with the manifest: `machine_tools`, `machine_tool_docs`). Their invoker
  calls `Transport.impl().call_machine_tool/4` down the channel to that copy.
- **Separate catalog, separate sandbox.** Browser tools wait by design (they
  take durations), ours are database reads, and one wall clock cannot suit
  both. They are reached through `run_browser_script`, with a deadline the
  caller sets. The machine's tools arrive as one tool on the agent, not as
  their list.
- **Each call gets the script's budget less `@machine_call_margin_ms`** (2s,
  floor 1s), so a hung call reports as a timeout before the sandbox kills the
  script and the error with it. The derived timeout is stated on the entry.
- **The browser is a capability.** The agent's list names our tools, which
  share nothing with the machine's names; `browser_capability/0` in the list
  grants the machine's catalog whole. A matching name is still permitted alone.
- **Missing docs degrade, not fail.** A harness that reported names without
  docs gets a generic description and an `%{"type" => "object"}` schema.
- **Entries carry `:schema`** (what `Docs` reads), since they do not go
  through `Catalog.from/3`.

## start_task

- **The owner comes off the connection.** `Plugs.AgentScope` has checked the
  agent id; an argument cannot start another agent's task. With no agent, the
  owner is the session (`session_id`), looked up by external id, then internal
  id, then registered lazily — a session opened before the plugin's hooks were
  enabled never got its row. `agent_id` may also be a sub-agent label, which
  owns tasks on the caller's session.
- **The agent wins over the session** when both arrive: the agent is asked for
  its active task at the end of the turn.
- **Requirement resolution.** Issue work is not in the graph and is read
  through `Agents.Work.actionable/3`. Story, component and project work is
  found in `RequirementGraph.cached_graph/1`; a story placed on another copy is
  read there (`Requirements.placed_story_node/4`).
- **Existing tasks** (prepared, active, blocked) are matched on requirement and
  entity: active returns the prompt, prepared is activated, blocked resumes
  only once its blocker is resolved and the work is still eligible.
- **Claim checks, in order**: role (work the role is not offered is refused;
  an agent holding an active task passes so `TaskOwner` gives the refusal it
  must act on), story binding, team story (`Agents.claim_story/3` assigns the
  story to the whole team), already satisfied (refused, graph refreshed, stale
  offer closed), QA eligibility.
- **Resume eligibility for story tasks uses `Work.story_actionable/3`**:
  `Work.actionable/3` hides story nodes while the owner holds an issue.
- **A story QA task captures its review at start**; one that cannot (superseded,
  uncertified) is cancelled rather than left holding the agent.
- **`init_session/2` runs only for sessions.** An agent has its own
  `continuous` column; two writers would disagree.
- **No owner at all** answers a message naming both remedies: Claude Code can
  `register_session`; an agent we run cannot and should report a harness fault.

## Task evaluation

- **Outcomes** (`TaskEvaluator.handle_result/6`): `{:ok, :valid}` and
  `{:ok, :valid, advisory}` complete the task, clear the stuck counter and
  nudge other agents; `{:ok, :skip, why}` leaves the task active and does not
  block the stop; `{:ok, :invalid, feedback}` blocks with feedback and bumps
  the repeat counter; a missing entity (`:entity_missing`, `:story_not_found`,
  `:component_not_found`) cancels the task; an evaluator crash is reported with
  a marker so it is not mistaken for "not met".
- **Manual validation tasks are skipped** entirely.
- **Stuck loops.** Invalid feedback is hashed onto the session; `Hooks.Stop`
  ends continuous mode when the same hash repeats `@stuck_threshold` (5) times.
  Background re-evaluations pass `record_feedback: false`.
- **Not-found on this path means gone.** The evaluating scope is the task's own
  session's, so "wrong project" cannot happen by accident here.
- **Completion nudges other agents** by emitting
  `[:code_my_spec, :tasks, :completed]`; `Agents.Events` starts the wake on
  `TaskSupervisor`. It must be off the caller's process: an in-BEAM agent
  completes inside the harness channel, and a synchronous call back into that
  channel kills it (`:calling_self` is an exit, not an exception). A missed
  nudge is acceptable; the next completion sends it.
- **Custom `evaluate/2` modules take no opts**; only the unified evaluator
  honours `sync: false`.

## Unobservable environments

- **"Could not look" is not "not there".** Under a light harness the server
  holds no working copy and every file operation answers `:no_environment`.
  `Environments.unobservable?/1` is the one list of such replies; checkers ask
  it rather than keeping their own.
- **Checkers pass unobservable errors through, not as `:invalid`**, so
  `TaskEvaluator` can name the task, type and working copy. It still blocks:
  an allowed stop carries no text, so allowing would silently wave through an
  unverified requirement.
- **Prefer file records to disk.** `Files` rows (synced by the harness) answer
  without a working copy: spec paths, knowledge files, implementation files.
- **`stat`, not `file_exists?/2`, when the answer decides something.**
  `file_exists?/2` returns `false` for both "absent" and "no disk".
- **Resolve asymmetric guesses toward the safe mode.** `ArchitectureDesign`
  treats an unreadable proposal or marker as present/patch mode: initial mode
  executes a proposal end-to-end, while revision's worst case is no edits.

## Agent task prompts

- **ArchitectureDesign.** Revision when components exist (count decides first;
  `proposal.md` only records how the architecture was first produced), else
  when a proposal exists. The mode is recorded in a marker file at `command/2`
  and read by `evaluate/2`; only `command/2` clears it, so a failing patch-mode
  evaluate is not promoted to a full execution. Patch mode passes when the
  task's story is linked; orphans are not a gate. Initial mode reads, validates
  and executes the proposal. `execute_proposal/1` forces the full cycle. The app
  name is the project's `module_name`; a display-name derivation disagrees with
  it.
- **WriteBddSpecs.** The prompt lists the project's own BDD knowledge files
  from file records, frames the component as a stub only when no
  implementation file row exists, prints each criterion's scenario body inline,
  and infers a surface from its `when_` steps (or none rather than a guess).
  The file path is "suggested": the `criterion:` option binds a spec, and
  renaming an adopted spec breaks it. `evaluate/2` is
  `RequirementCalculator.bdd_specs_covered/3` over the same rows the
  `bdd_specs_exist` requirement reads, and reports where it looked. The app
  name comes from `mix.exs`, else the project's module name.
- **FixBddSpecs.** A story's prompt lists only that story's spex problems,
  matched on file records' `story_id`; with no story, the project's. Only
  failures whose story's component has a satisfied `implementation_file` are
  shown. Completing it is the ready-for-QA certification (`ReadyForQa`), and
  the green prompt says evaluation is the step that certifies.
- **QaStory.** `qa_complete` is a DB attempt (`submit_qa_result`). `evaluate/2`
  passes on a passing attempt, skips a sub-agent's task, demands a resubmit
  after a failed or invalidated attempt, and otherwise checks plan and brief,
  files issues from an optional `result.md`, and demands a submit. The prompt
  resolves the copy's own app URL (never main's for a story's fix), lists fixes
  submitted since the last attempt, and warns about repros consumed by being
  run. Spec paths come from file records.
- **StartAgentTask** is the skill/CLI route by session type. The type map is a
  function so it is not a compile-time reference to every task module. Every
  `custom_evaluate_modules/0` module must appear in it (`ConsistencyTest`).
  Sync is incremental (`changed_paths`); a harness that cannot be scanned
  syncs itself by manifest.

## run_provisioning_step

- **Bypasses ordering only.** Same `Provisioning.run_step/3`, verified against
  the provider, under the same `RunLock`; a step that cannot run yet refuses
  itself. Used when an earlier step (`:repository`, `:secrets`) is blocked on a
  local checkout the light harness cannot provide.
- **Confirmations as parameters.** `inbound_probe_to`, `confirm_apex_repoint`
  and `confirm_inbound_mx_repoint` carry the answers a step pauses for, so an
  agent with no person at the console can give them. `force` skips
  verification (every step's run is idempotent).
- **`:deploy` requires `environment`.** Without one the step deploys every
  environment in no defined order, prod included, halting at the first failure.
- **`:server` never creates a server here**; an unlinked environment pauses.
  Only `Steps.provision_account_server/3`, through the account-level tool,
  creates one.
- **Asynchronous.** A step can outlive the transport and the sandbox's wall
  clock. The spawned task claims `RunLock` and only then acks (5s handshake),
  so the reply is "started" or "already running". An agent that started it is
  messaged the outcome (`Starter.tell/2`); others watch `devops_status`. Under
  test (`:provisioning_run_async` false) it runs synchronously, since a spawned
  child holds neither the sandbox checkout nor `Req.Test` allowances.

## Lessons

- **Never leave a name unbound when a script may reach for it.** A bare "nil
  value" sends agents chasing spellings; bind a stub that says why and where.
- **A refusal's advice must be advice this caller can take.** "Call it
  directly" or "reconnect" to a role that does not carry the tool sends it
  hunting for a fault that does not exist.
- **A malformed call must stop the script.** Returning `nil, err` for a call
  that never ran let scripts report confident conclusions from nothing.
- **Reject arguments the schema does not declare.** Validation drops them, and
  the call runs unfiltered with an answer that looks right.
- **Never cut an answer silently.** A fragment read as the whole answer is
  worse than no cut.
- **Inner timeouts must be shorter than outer ones, and readable.** Equal
  deadlines make the failure ambiguous and can lose the error.
- **"Could not look" must never become a verdict.** Pass it through to the
  evaluator; flattened into `:invalid` it blocks with no task, no copy and no
  way out.
- **Read file records, not disk, from the server.** Under a light harness disk
  reads are always empty, and "empty" reads as a plausible answer.
- **A task's verdict and its requirement's must come from the same function
  over the same rows**, or the task passes while the requirement stays open.
- **A prompt must not name files in a repository it does not control.** List
  what the file records say exists.
- **Work done off a channel process must not call back into it.** A
  synchronous call to self is an exit, not an exception, and `rescue` misses it.
