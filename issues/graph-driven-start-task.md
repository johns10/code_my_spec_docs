Graph-Driven Dispatch in StartImplementation

Context

StartImplementation's dispatch is BDD-spec-driven: runs specs, checks file coverage. When all specs exist
and pass, it says "complete" even though story requirements are unsatisfied (0/32 complete in fuellytics).
Fix: make dispatch fully graph-driven. The requirement graph owns all checking and routing.

Design Principles

1. Graph owns checking — no BDD spec running or file-existence checks outside the graph
2. Generic dispatch — route based on RequirementDefinition.satisfied_by and .scope, no task-specific
branches
3. Generic evaluate — two cases based on scope (local vs dependencies), no task-module-specific clauses
4. Scope-aware dispatch — :local calls command directly, :dependencies uses ProjectCoordinator chain
traversal
5. No duplicate expensive operations — run spex once at command start, Pipeline handles it in stop hook for
evaluate cycles

Story Requirement Chain (TDD order)

component_linked   (satisfied_by: LinkStoryComponent,    prereqs: [],                     scope: :local)
bdd_specs_exist    (satisfied_by: WriteBddSpecs,         prereqs: ["component_linked"],    scope: :local)
component_complete (satisfied_by: ManageImplementation,   prereqs: ["bdd_specs_exist"],     scope:
:dependencies)
bdd_specs_passing  (satisfied_by: nil,                   prereqs: ["component_complete"],  scope: :local)
qa_complete        (satisfied_by: QaStory,               prereqs: ["bdd_specs_passing"],   scope: :local)

TDD flow: link component → write specs → implement component tree → verify specs pass → QA.

bdd_specs_passing has satisfied_by: nil — handled inline by dispatch (reads Problems, generates fix
prompt). No separate task module needed.

Already Done

- requirement_definition_data.ex — chain updated: bdd_specs_passing added to story_requirements,
component_complete scope: :dependencies + satisfied_by: ManageImplementation, component_linked
satisfied_by: LinkStoryComponent, qa_complete prereqs: ["bdd_specs_passing"], bdd_specs_passing prereqs:
["component_complete"]

Remaining Changes

1. Create LinkStoryComponent agent task (new file)

New file: lib/code_my_spec/agent_tasks/link_story_component.ex

Lightweight task that prompts the agent to link a story to a surface component using the
set-story-component tool. Extracts existing dispatch_blocked logic from StartImplementation.

defmodule CodeMySpec.AgentTasks.LinkStoryComponent do
alias CodeMySpec.{Components, Stories}

def command(scope, session, _opts \\ []) do
    story_id = get_story_id(session)
    story = Stories.get_story!(scope, story_id)
    all_components = Components.list_components_with_dependencies(scope)
    surface_components = filter_surface(all_components)
    {:ok, build_prompt(story, surface_components)}
end

def evaluate(scope, session, _opts \\ []) do
    story_id = get_story_id(session)
    story = Stories.get_story!(scope, story_id)
    if story.component_id, do: {:ok, :valid},
    else: {:ok, :invalid, "Story still has no linked component. Link it using set-story-component and
stop."}
end

# build_prompt: lists surface components with type/linked stories, shows set-story-component usage
# filter_surface: filters to controller, live_context, liveview, liveview_component, context,
coordination_context
# get_story_id: reads from session.state["topic"]  session[:story_id]
end

2. Update BddSpecPassingChecker — read Problems instead of running specs

File: lib/code_my_spec/requirements/bdd_spec_passing_checker.ex

Current: calls BddSpecs.run_specs per story (32 stories = 32 runs). Replace with querying Problems table:

def check(scope, defn, %Story{} = story, _opts) do
problems = Problems.list_project_problems(scope, source: "spex")
story_problems = filter_for_story(problems, story.id)
satisfied = story_problems == []
# build result map with failure details from problems
end

defp filter_for_story(problems, story_id) do
story_prefix = "test/spex/#{story_id}_"
Enum.filter(problems, &String.starts_with?(&1.file_path, story_prefix))
end

3. Rewrite StartImplementation — fully graph-driven

File: lib/code_my_spec/agent_tasks/start_implementation.ex

command/3 — run spex first, then sync + dispatch

def command(scope, session, opts \\ []) do
env = scope.environment
run_and_persist_spex(scope, env)
with {:ok, _} <- maybe_sync_project(scope, env, opts) do
    case dispatch(env, scope, session) do
    :complete -> {:ok, all_complete_message(env)}
    {:ok, prompt} -> {:ok, prompt}
    end
end
end

dispatch/3 — graph-driven story selection

defp dispatch(env, scope, session) do
stories = load_stories_with_requirements(scope)
case find_next_incomplete_story(stories) do
    nil -> :complete
    story -> dispatch_story(env, scope, session, story)
end
end

defp dispatch_story(env, scope, session, story) do
actionable = Requirements.next_actionable(scope, story)
case Enum.to_list(actionable) do
    [{task_module, definitions}  _] ->
    dispatch_task(env, scope, session, story, task_module, hd(definitions))
    [] ->
    # nil-satisfied_by requirements (bdd_specs_passing) — handle inline
    dispatch_nil_satisfied(env, scope, story)
end
end

dispatch_task/6 — scope-aware routing

defp dispatch_task(env, scope, session, story, task_module, defn) do
case defn.scope do
    :local -> dispatch_local(env, scope, session, story, task_module)
    :dependencies -> dispatch_dependencies(env, scope, session, story)
end
end

# :local — call task_module.command directly, write status with scope: "local"
defp dispatch_local(env, scope, session, story, task_module) do
task_session = build_task_session(session, story)
case task_module.command(scope, task_session) do
    {:ok, prompt} ->
    write_status(env, %{
        satisfied_by: inspect(task_module),
        scope: "local",
        story_id: story.id,
        session: %{story_id: story.id, external_conversation_id: get_external_id(session)}
    })
    {:ok, wrap_prompt(format_task_heading(task_module, story), prompt)}
    {:error, _} -> :complete
end
end

# :dependencies — ProjectCoordinator.find_next_in_chain → Orchestrate
defp dispatch_dependencies(env, scope, session, story) do
all_components = Components.list_components_with_dependencies(scope)
component = Enum.find(all_components, &(&1.id == story.component_id))
if is_nil(component), do: :complete,
else: (pre_flight(scope, component); orchestrate_via_chain(env, scope, session, story, component,
all_components))
end

dispatch_nil_satisfied/3 — inline handling for bdd_specs_passing

When next_actionable returns empty but story is incomplete, the only nil-satisfied_by requirement in the
chain that can reach this state is bdd_specs_passing (component_linked also has nil but now has
LinkStoryComponent).

defp dispatch_nil_satisfied(env, scope, story) do
unsatisfied = (story.requirements  []) > Enum.reject(& &1.satisfied) > Enum.map(& &1.name)

cond do
    "bdd_specs_passing" in unsatisfied ->
    dispatch_fix_specs(env, scope, story)
    true ->
    dispatch_blocked_meta(env, story, remaining_meta(story))
end
end

dispatch_fix_specs/3 reads from Problems table (not running specs):

defp dispatch_fix_specs(env, scope, story) do
problems = Problems.list_project_problems(scope, source: "spex")
story_problems = filter_story_problems(problems, story.id)
details = Enum.map_join(story_problems, "\n", &"- #{&1.file_path}:#{&1.line}: #{&1.message}")
write_status(env, %{scope: "local", satisfied_by: nil, story_id: story.id, task: "fix_specs"})
{:ok, wrap_prompt("Fix Failing Specs: #{story.title}", """
All component requirements are satisfied, but BDD specs are still failing.
## Failing BDD Specs
#{details}
## Instructions
1. Read the failing spec files to understand expected behavior
2. Read the relevant implementation files
3. Fix the implementation to make specs pass
4. Run `mix test` on the failing spec files to verify
""")}
end

orchestrate_via_chain/6 — existing chain traversal (keep from current code)

Uses ProjectCoordinator.find_next_in_chain → Orchestrate.collect_components → find_actionable →
generate_prompt_files. Writes status with scope: "dependencies" and component_id.

evaluate/3 — sync before re-dispatch

def evaluate(scope, session, _opts \\ []) do
env = scope.environment
with {:ok, status} <- read_status(env),
        {:ok, :valid} <- evaluate_current_task(scope, session, env, status),
        :ok <- clear_status(env),
        {:ok, _} <- maybe_sync_project(scope, env, []) do
    case dispatch(env, scope, session) do
    :complete -> {:ok, :valid}
    {:ok, prompt} -> {:ok, :invalid, prompt}
    end
else
    {:ok, :invalid, feedback} -> {:ok, :invalid, feedback}
    {:error, :not_found} -> {:ok, :valid}
    {:error, reason} -> {:error, reason}
end
end

evaluate_current_task — two generic clauses (no legacy fallback)

# Local scope: call task_module.evaluate generically
defp evaluate_current_task(scope, session, _env, %{"scope" => "local", "satisfied_by" => satisfied_by} =
status)
    when is_binary(satisfied_by) and satisfied_by != "" do
task_module = String.to_existing_atom(satisfied_by)
task_session = rebuild_session(session, status)
task_module.evaluate(scope, task_session)
end

# Local scope with nil satisfied_by (fix_specs) — check Problems
defp evaluate_current_task(scope, _session, _env, %{"scope" => "local", "story_id" => story_id}) do
problems = Problems.list_project_problems(scope, source: "spex")
story_problems = filter_story_problems(problems, story_id)
if story_problems == [], do: {:ok, :valid},
else: {:ok, :invalid, "BDD specs still failing:\n" <> Enum.map_join(story_problems, "\n", &"-
#{&1.message}")}
end

# Dependencies scope: check chain completion
defp evaluate_current_task(scope, _session, _env, %{"scope" => "dependencies", "component_id" =>
component_id}) do
all_components = Components.list_components_with_dependencies(scope)
root = Enum.find(all_components, &(&1.id == component_id))
case ProjectCoordinator.find_next_in_chain(root, all_components) do
    {:ready, focused} ->
    components = Orchestrate.collect_components(scope, focused)
    actionable = Orchestrate.find_actionable(scope, components)
    if Enum.empty?(actionable), do: {:ok, :valid}, else: {:ok, :invalid, "New actionable work
available."}
    {:blocked, _} -> {:ok, :valid}
    :complete ->
    Orchestrate.cleanup_status_directory(Orchestrate.component_status_dir(root), scope.environment &&
scope.environment.cwd)
    {:ok, :valid}
end
end

Delete from StartImplementation

- resolve_story/2, resolve_failing_story/3, resolve_next_story/2
- derive_failing_story_ids/2, failure_file_path/1
- run_bdd_specs/1, get_story_failures/2, filter_story_failures/2
- dispatch_fix_specs/3 (old version), dispatch_unmapped/2, dispatch_write_specs/4
- dispatch_blocked/4 (moved to LinkStoryComponent)
- Old task-specific evaluate_current_task clauses
- Unused aliases: BddSpecs, BddSpecs.Parser, WriteBddSpecs

New helpers

- load_stories_with_requirements/1 — Stories.list_project_stories_by_priority >
Repo.preload(:requirements)
- find_next_incomplete_story/1 — first story with any unsatisfied requirement
- build_task_session/2 — builds session with state: %{"topic" => story_id}
- rebuild_session/2 — rebuilds from status
- format_task_heading/2 — derives heading from module name + story title
- remaining_meta/1 — unsatisfied requirements for blocked message
- run_and_persist_spex/2 — glob spex files, Pipeline.run_spex, clear+create Problems
- filter_story_problems/2 — filter problems by story ID file path pattern

Files

1. ~~`lib/code_my_spec/requirements/requirement_definition_data.ex`~~ — DONE (chain updated, satisfied_by
set)
2. lib/code_my_spec/requirements/bdd_spec_passing_checker.ex — read Problems instead of running specs
3. lib/code_my_spec/agent_tasks/link_story_component.ex — new, lightweight component linking task
4. lib/code_my_spec/agent_tasks/start_implementation.ex — full rewrite of dispatch + evaluate

Verification

1. mix compile --warnings-as-errors
2. mix test test/code_my_spec/requirements/ --exclude scenario --exclude external
3. mix test test/code_my_spec/agent_tasks/ --exclude scenario --exclude external
4. mix test --exclude scenario --exclude external
     ╰───────────────────────────────────────────────────────────
