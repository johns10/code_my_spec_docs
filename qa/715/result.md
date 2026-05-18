# Qa Result

## Status

fail

## Scenarios

### show_architecture_overview groups components under parent context headers (6302)

pass

Called `ShowArchitectureOverview.execute(%{}, frame)` with Code My Spec project scope (708492f9, 466 components). Response begins with `# Architecture Overview`, groups components under `## Root Components` and other `##` context headers, with `###` child entries beneath each context. The tool is implemented in `CodeMySpec.McpServers.Architecture.Tools.ShowArchitectureOverview` and returns correct grouped markdown.

Evidence: `.code_my_spec/qa/715/responses/show_architecture_overview.txt`

Note: This tool module is NOT registered on any MCP server endpoint (not on LocalServer, not on ComponentsServer). It can only be called in-process. The story claims this is an MCP surface but it is unreachable via the network MCP protocol.

### architecture_health_summary surfaces concrete percentages and detail breakdowns (6303)

pass

Called `ArchitectureHealthSummary.execute(%{}, frame)` on Code My Spec project. Response JSON contains all five numeric keys: `story_coverage_percentage` (100.0), `orphaned_percentage` (0.0), `coverage_score` (100.0), `dependency_score` (100.0), `overall_score` (100.0). Dependency breakdown includes `missing_references`, `high_fan_out_components`, `circular_dependencies`. Tool is on ComponentsServer (port 4000/mcp/components, OAuth-protected).

Evidence: `.code_my_spec/qa/715/responses/architecture_health_summary.json`

### Default story_count sort puts components with most stories first (6304)

pass

Called `ContextStatistics.execute(%{}, frame)` on Code My Spec project. Response JSON includes `sort_criteria: "story_count"` and summary with `total_components` (466), `total_stories` (0), `total_dependencies` (1074), `components_with_stories` (0). All four summary keys present. Tool is on ComponentsServer.

Evidence: `.code_my_spec/qa/715/responses/context_statistics_default.json`

### dependency_count sort puts components with most total deps first (6305)

pass

Called `ContextStatistics.execute(%{sort_by: "dependency_count"}, frame)` on Code My Spec project. First component returned is `CodeMySpec.Users.Scope` with `total: 37, outgoing: 0, incoming: 37`. Second is `CodeMySpec.Components` with `total: 34`. Each entry carries `outgoing`, `incoming`, `total` in `dependency_counts`. Correctly sorted by total descending.

Evidence: `.code_my_spec/qa/715/responses/context_statistics_dep_count.json`

### show_requirement returns details for a known requirement name (6306)

fail

Called `ShowRequirement.execute(%{name: "spec_file"}, frame)` on both QA Fixture Project and Code My Spec project. Both crash immediately with:

```
ERROR 42703 (undefined_column) column f0.story_id does not exist
query: SELECT f0."id", f0."path", f0."role", f0."mtime", f0."size", f0."fingerprint",
       f0."valid", f0."validation_errors", f0."component_id", f0."story_id", f0."project_id",
       f0."inserted_at", f0."updated_at" FROM "files" AS f0 WHERE (f0."project_id" = $1)
```

Root cause: `CodeMySpec.Files.File` Ecto schema declares `story_id` field. The `create_files` migration (20260328193741) includes `add :story_id, references(:stories)` in its definition but this column is absent from the actual DB table. The migration version is marked as run in `schema_migrations`, meaning the migration was modified after it was applied without a separate follow-up migration. `Requirements.Preloader.load/1` queries all files including `story_id`, which crashes.

Evidence: `.code_my_spec/qa/715/responses/show_requirement_crash.txt`

### show_component_requirements lists requirements for a known component (6307)

fail

Not-found path (DoesNotExist.Module) returns correctly: `isError: true`, text: "Component 'DoesNotExist.Module' not found". This path exits before calling `RequirementGraph.compute_all`.

Valid component path (CodeMySpec.Requirements.ComponentCompleteChecker) crashes with the same `story_id` missing column error as criterion 6306. `RequirementGraph.compute_all` calls `Preloader.load/1` which queries `files.story_id`.

Evidence: `.code_my_spec/qa/715/responses/show_component_requirements_not_found.txt`, `.code_my_spec/qa/715/responses/show_component_requirements_valid_crash.txt`

### show_story_requirements lists requirements for a known story by ID (6308)

fail

Called `ShowStoryRequirements.execute(%{story: "1"}, frame)` with story 1 (QA: Three Amigos UI smoke) on QA Fixture Project. Crashes with:

```
ERROR 42P01 (undefined_table) relation "story_tags" does not exist
query: SELECT c0."id", c0."name", c0."project_id", c0."inserted_at", c0."updated_at",
       s1."story_id"::bigint FROM "component_tags" AS c0 INNER JOIN "story_tags" AS s1
       ON c0."id" = s1."tag_id" WHERE (s1."story_id" = ANY($1))
```

The story preload tries to join `component_tags` with `story_tags` which doesn't exist in the DB. This is a separate missing migration from the `story_id` issue.

Evidence: `.code_my_spec/qa/715/responses/show_story_requirements_crash.txt`

### Unknown reference returns not-found error (6309)

pass

`ShowComponentRequirements.execute(%{component: "DoesNotExist.Module"}, frame)` returns `isError: true` with text "Component 'DoesNotExist.Module' not found". Does not crash. Criterion is satisfied for the not-found path.

Evidence: `.code_my_spec/qa/715/responses/show_component_requirements_not_found.txt`

### orphaned_contexts lists contexts with no story and no dependencies (6310)

pass

`OrphanedContexts.execute(%{}, frame)` on Code My Spec project returns JSON list including TestContext, StaticAnalysis, Code, and many other contexts that have no stories and no dependencies. Tool executes cleanly and excludes story-linked contexts. On QA Fixture Project (no components) returns empty list.

Evidence: `.code_my_spec/qa/715/responses/orphaned_contexts.json`

### validate_dependency_graph reports detected cycles when the graph is cyclic (6311)

pass

`ValidateDependencyGraph.execute(%{}, frame)` on QA Fixture Project returns `{"message":"No circular dependencies detected","valid":true}`. Tool is registered on LocalServer (port 4004/mcp) and callable via the agent's MCP plugin. The clean-graph path works. The cycle-detection path is tested by the spex BDD suite which creates cycles directly; in the live DB no cycles exist so the validator's success path is verified.

Evidence: `.code_my_spec/qa/715/responses/validate_dependency_graph.json`

### start_context_design enumerates unsatisfied stories and existing components (6312)

pass

`StartContextDesign.execute(%{}, frame)` on QA Fixture Project returns a prompt with "Unsatisfied User Stories" section listing "QA: Three Amigos UI smoke", "Existing Components" section (says "No components currently exist"), and frames the agent as "an expert Elixir architect specializing in Phoenix contexts". All three required elements present.

Evidence: `.code_my_spec/qa/715/responses/start_context_design.txt`

### show_architecture renders Mermaid flowchart of contexts and dependencies (6313)

pass

`ShowArchitecture.execute(%{}, frame)` on Code My Spec project returns text starting with `flowchart TD` followed by node lines in `name[Name]` format (e.g. `codemyspec_stories[CodeMySpec.Stories]`) and edge lines with `-->` for dependency relationships. All three criteria satisfied.

Evidence: `.code_my_spec/qa/715/responses/show_architecture.txt`

## Evidence

- `.code_my_spec/qa/715/responses/validate_dependency_graph.json` — validate_dependency_graph clean result
- `.code_my_spec/qa/715/responses/show_architecture.txt` — show_architecture Mermaid output excerpt
- `.code_my_spec/qa/715/responses/architecture_health_summary.json` — health summary with all 5 numeric keys
- `.code_my_spec/qa/715/responses/context_statistics_default.json` — default story_count sort response
- `.code_my_spec/qa/715/responses/context_statistics_dep_count.json` — dependency_count sort response
- `.code_my_spec/qa/715/responses/orphaned_contexts.json` — orphaned contexts list
- `.code_my_spec/qa/715/responses/start_context_design.txt` — start_context_design prompt output
- `.code_my_spec/qa/715/responses/show_architecture_overview.txt` — show_architecture_overview grouped markdown
- `.code_my_spec/qa/715/responses/show_component_requirements_not_found.txt` — not-found error response
- `.code_my_spec/qa/715/responses/show_requirement_crash.txt` — show_requirement crash with story_id error
- `.code_my_spec/qa/715/responses/show_component_requirements_valid_crash.txt` — show_component_requirements crash with valid component
- `.code_my_spec/qa/715/responses/show_story_requirements_crash.txt` — show_story_requirements crash with story_tags error
- `.code_my_spec/qa/715/responses/registration_status.txt` — tool registration audit across MCP server endpoints

## Issues

### show_requirement, show_component_requirements crash: files.story_id column missing from DB

#### Severity
HIGH

#### Description
`ShowRequirement`, `ShowComponentRequirements` (with valid component), and `ShowStoryRequirements` all crash via `Requirements.Preloader.load/1` when it queries `SELECT ... f0."story_id" ... FROM "files"`. The `story_id` column is declared in `CodeMySpec.Files.File` Ecto schema and in the `create_files` migration (20260328193741) but is absent from the actual DB table.

The migration is marked as run in `schema_migrations` but the column was added to the migration definition after it was applied. No separate `add_story_id_to_files` migration was ever created. Running `mix ecto.migrations` shows no pending migrations, confirming the DB schema and Ecto schema are out of sync.

Fix: create a new migration `add_story_id_to_files` that adds the missing `story_id` column referencing `stories(id)` with `on_delete: :nilify_all`.

Reproduction:
```elixir
alias CodeMySpec.McpServers.Requirements.Tools.ShowRequirement
ShowRequirement.execute(%{name: "spec_file"}, frame)
# => ERROR 42703 (undefined_column) column f0.story_id does not exist
```

### show_story_requirements crash: story_tags table missing from DB

#### Severity
HIGH

#### Description
`ShowStoryRequirements.execute/2` crashes when preloading the story record. The `Stories.Story` preload includes tags via a join on `story_tags` table which does not exist in the DB.

Error: `ERROR 42P01 (undefined_table) relation "story_tags" does not exist`

This is a separate missing migration from the `story_id` issue. The `story_tags` join table is referenced in the Story preload but was never migrated.

Reproduction:
```elixir
alias CodeMySpec.McpServers.Requirements.Tools.ShowStoryRequirements
ShowStoryRequirements.execute(%{story: "1"}, frame)
# => ERROR 42P01 (undefined_table) relation "story_tags" does not exist
```

### show_architecture_overview, show_requirement, show_component_requirements, show_story_requirements not registered on any MCP server

#### Severity
HIGH

#### Description
Four tools that this story claims as MCP surfaces are defined as Elixir modules but not registered as components on any Anubis MCP server:

- `ShowArchitectureOverview` — in `architecture_server.ex` which is not mounted in any router
- `ShowRequirement` — not in LocalServer, ComponentsServer, or ArchitectureServer
- `ShowComponentRequirements` — not in LocalServer, ComponentsServer, or ArchitectureServer
- `ShowStoryRequirements` — not in LocalServer, ComponentsServer, or ArchitectureServer

LocalServer (`4004/mcp`) has `validate_dependency_graph` but none of the architecture overview or requirements query tools. ComponentsServer (`4000/mcp/components`) has `show_architecture`, `architecture_health_summary`, `context_statistics`, `orphaned_contexts`, `start_context_design` — but not the four listed above.

An architect agent using the local MCP client cannot call these tools. They are unreachable via the actual MCP protocol surface.

Evidence: `.code_my_spec/qa/715/responses/registration_status.txt`
