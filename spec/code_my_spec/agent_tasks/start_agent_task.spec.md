# CodeMySpec.AgentTasks.StartAgentTask

Orchestrates agent task session startup. Validates inputs, syncs the project,
resolves the correct AgentTask module, creates a filesystem-backed Session,
and calls the module's `command/2` to generate the initial prompt.

Classifies tasks into five categories — bootstrap, project, componentless,
topic, and component — each with a different startup pipeline.

## Dependencies

- CodeMySpec.AgentTasks
- CodeMySpec.AgentTasks.TaskMarker
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Environments.Environment
- CodeMySpec.Paths
- CodeMySpec.ProjectSync.FileWatcherServer
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.Sessions
- CodeMySpec.Sessions.Session

## Functions

### valid_types/0

Returns the list of valid session type strings.

```elixir
@spec valid_types() :: [String.t()]
```

**Process**:
1. Return the compile-time list of valid session type keys (includes "spec" plus all `@session_type_map` keys)

**Test Assertions**:
- returns a list of strings
- includes "spec" as a valid type
- includes all session type map keys (e.g. "component_spec", "start_implementation", "qa_story")

### componentless_tasks/0

Returns the list of session types that don't require a component/module_name argument.

```elixir
@spec componentless_tasks() :: [String.t()]
```

**Process**:
1. Return the compile-time `@componentless_tasks` list

**Test Assertions**:
- returns a list of strings
- includes "project_setup", "architecture_design", "write_bdd_specs"
- does not include component-bound tasks like "component_spec" or "component_code"

### run/2

Start an agent task session and return the prompt. Does not perform IO.

```elixir
@spec run(CodeMySpec.Users.Scope.t(), map()) :: {:ok, String.t(), map()} | {:error, term()}
```

**Process**:
1. Extract `external_id`, `session_type`, and `module_name` from args map
2. Classify the session_type into one of five categories:
   - **Bootstrap** (`@bootstrap_tasks`): minimal scope, no project sync needed
   - **Project** (`@project_tasks`): full sync, finds-or-creates session (idempotent)
   - **Componentless** (`@componentless_tasks`): full sync, no component lookup
   - **Topic** (`@topic_tasks`): full sync, stores topic in session state
   - **Component** (default): full sync, looks up component by module_name
3. Execute the appropriate pipeline for the category:
   a. Validate external_id is present
   b. Validate environment exists (except bootstrap which builds one)
   c. Validate active project exists (except bootstrap)
   d. Sync project via `Sync.sync_all/2` and start file watcher (except bootstrap)
   e. Resolve the AgentTask module from session_type (with auto-detection for "spec")
   f. Create or find the Session record
   g. Enrich session with virtual fields (component, project)
   h. Call `agent_task_module.command(scope, session)` to generate prompt
   i. Prepend project context (documentation pointer, decisions, architecture reference)
4. Return `{:ok, prompt, sync_result}` or `{:error, reason}`

**Test Assertions**:
- returns `{:error, "External ID is required"}` when external_id is nil
- returns `{:error, ...}` when environment is nil (non-bootstrap tasks)
- returns `{:error, "No active project"}` when scope has no active project
- returns `{:error, ...}` when sync fails
- returns `{:error, ...}` when component module_name is not found
- returns `{:error, ...}` when session_type is unknown
- bootstrap tasks succeed without a project or config.yml
- bootstrap tasks build an environment from cwd when scope has none
- componentless tasks succeed without a module_name argument
- topic tasks store the topic in session state and prepend a TaskMarker
- component tasks look up the component by module_name and pass it to the session
- "spec" session_type auto-detects ContextSpec for context components
- "spec" session_type auto-detects LiveViewSpec for liveview components
- "spec" session_type auto-detects LiveContextSpec for live_context components
- "spec" session_type defaults to ComponentSpec for other component types
- project tasks find existing active session by type + external_id instead of creating a new one
- project tasks create a new session when no matching active session exists
- prompt includes project documentation pointer (`.code_my_spec/`)
- prompt includes architecture reference when overview.md exists
- prompt includes architecture decision records when decisions index exists
- prompt does not include decisions section when no decisions exist
