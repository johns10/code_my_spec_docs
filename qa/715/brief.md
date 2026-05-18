# Qa Story Brief

## Tool

curl (for MCP tool calls: use `mcp__plugin_codemyspec_local__*` agent tools via the running LocalServer on port 4004)

## Auth

No auth required. The local MCP server on port 4004 uses `Plugs.LocalOnly` (loopback trust only) with no user credentials. MCP tool calls are made directly via the agent's `mcp__plugin_codemyspec_local__*` tools, which manage the SSE channel internally.

Note: Do NOT curl `4004/mcp` for `tools/call` — Anubis returns `202 Accepted` with empty body; actual responses come over the SSE channel. Use the agent MCP tools instead.

## Seeds

No additional seeds required beyond what is already in the running dev database. The tools query the live CodeMySpec project data (components, stories, requirements) which already has rich content.

For any tool that needs specific fixture data (orphaned contexts, cyclic dependencies), the spex BDD tests use `Fixtures` helpers in-process. The QA approach is to call each tool against the live project and observe real output shapes.

## What To Test

All tools are on the architect/requirements MCP surface registered on LocalServer. Call each via the agent's MCP plugin tools, passing the working directory of the CodeMySpec repo as context.

- **show_architecture_overview** (criterion 6302): Call the tool with no params. Verify the response begins with `# Architecture Overview`, has `##` context section headers, and `###` child component entries underneath.

- **architecture_health_summary** (criterion 6303): Call the tool with no params. Verify the JSON response contains the five numeric keys: `story_coverage_percentage`, `orphaned_percentage`, `coverage_score`, `dependency_score`, `overall_score`. Verify dependency issue breakdown keys: `missing_references`, `high_fan_out_components`, `circular_dependencies`.

- **context_statistics default sort** (criterion 6304): Call `context_statistics` with no params. Verify summary keys `total_components`, `total_stories`, `total_dependencies`, `components_with_stories` appear. Verify components with more stories appear before components with fewer.

- **context_statistics dependency_count sort** (criterion 6305): Call `context_statistics` with `sort_by: "dependency_count"`. Verify each entry carries `outgoing`, `incoming`, `total` dependency counts. Verify components with more dependencies appear first.

- **show_requirement** (criterion 6306): Call `show_requirement` with `name: "spec_file"`. Verify response has `# spec_file` header, contains "Context specification file exists" description, and has `**Status:**`, `**Entity:**`, `**Execution:**`, `**Validation:**` fields.

- **show_component_requirements** (criterion 6307): Call with a known module name from the live project (e.g. `CodeMySpec.McpServers`). Verify response has component name as header, `**Requirements:** N/M satisfied` count, and checklist lines `- [ ] **requirement_name**`.

- **show_story_requirements** (criterion 6308): Call with a known story ID from the live project. Verify response has story title as header, `**Requirements:** N/M satisfied` count, and checklist lines.

- **Unknown reference not-found** (criterion 6309): Call `show_component_requirements` with `component: "DoesNotExist.Module"`. Verify response contains "DoesNotExist.Module" and "not found" (case-insensitive).

- **orphaned_contexts** (criterion 6310): Call `orphaned_contexts` with no params against the live project. Verify the tool returns a list (even if empty in the live project), confirming the tool executes without error. If any orphaned contexts exist in the live data, verify they appear.

- **validate_dependency_graph** (criterion 6311): Call `validate_dependency_graph` with no params. Verify the tool responds (pass if clean graph, or cycle report if cycles exist). Verify no crash/error in the response format.

- **start_context_design** (criterion 6312): Call `start_context_design` with no params. Verify response contains "Unsatisfied User Stories", "Existing Components", and "Elixir architect" + "Phoenix contexts" framing.

- **show_architecture** (criterion 6313): Call `show_architecture` with no params. Verify response begins with `flowchart TD`, contains node lines in `name[Name]` format, and contains edge lines with `-->` connectors.

## Result Path

`.code_my_spec/qa/715/result.md`
