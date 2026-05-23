# Qa Story Brief

## Tool

web (Vibium MCP browser tools for LiveView; JavaScript evaluation for data-graph extraction)

## Auth

No auth required. Port 4004 uses `LocalOnly` — loopback requests are accepted without a session cookie.

Navigate directly: `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`

## Seeds

No seed script needed. The "code-my-spec" project is already linked with `local_path` pointing to `/Users/johndavenport/Documents/github/code_my_spec`. The running CodeMySpec repo has a full requirements graph with project, story, and component nodes.

Verify the server is up before testing:
```
curl -s http://127.0.0.1:4004/health
```

## What To Test

All scenarios hit: `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`

The `#sigma-graph` element carries a `data-graph` attribute with the full JSON graph (nodes + edges). Extract it via `browser_get_attribute(selector: "#sigma-graph", attribute: "data-graph")`.

- **Scenario 1 — Page loads with sigma-graph element (visual check):**
  Navigate to the graph URL, wait for `#sigma-graph` to attach, take a screenshot. Verify the element exists and has a non-empty `data-graph` attribute. Acceptance: page renders without error.

- **Scenario 2 — Project chain edges flow downward (criterion 6416):**
  Parse `data-graph` JSON. Filter edges where both `source` and `target` nodes have `entity_type == "project"`. For each such edge, assert `source.attributes.y > target.attributes.y`. Acceptance: all project-chain edges flow downward toward later gates. Assert at least one project→project edge exists.

- **Scenario 3 — Topmost node is a project node (criterion 6420):**
  From `data-graph`, find `max(project node y values)` and `max(all node y values)`. Assert they are equal — the topmost canvas position belongs to a project node. Acceptance: project chain stays at top even when no cross-entity edges feed into it.

- **Scenario 4 — Band ordering: project band above component band (criteria 6421, 6422):**
  Group nodes by `entity_type`. Assert `min(project_ys) > max(component_ys)`. Acceptance: every project node sits strictly above every component node; post-project band is empty in this layout.

- **Scenario 5 — Brand color palette consistent across bands (criterion 6424):**
  Collect unique `color` attribute values from all nodes. Allowed palette: `#ff3838` (satisfied), `#f5f5f7` (actionable), `#fde047` (blocked). Assert no color falls outside this palette. Acceptance: satisfaction state maps to brand color tokens consistently.

- **Scenario 6 — No two nodes share the same (x, y) position (criterion 6425):**
  Collect all `(attributes.x, attributes.y)` pairs from nodes. Assert no duplicates. Acceptance: layout produces no overlapping nodes.

- **Scenario 7 — Component zone edges flow downward (criterion 6417):**
  Filter edges where both source and target have `entity_type == "component"` and different `entity_id` values (cross-component edges). For each, assert `source.attributes.y > target.attributes.y`. If no cross-component edges exist in the graph, note it and pass trivially. Acceptance: component zone edges flow toward deeper dependency tiers.

- **Scenario 8 — Visual appearance: legend visible (supplemental):**
  Verify the legend (Satisfied / Actionable / Blocked) is rendered. Take a full-page screenshot as visual evidence.

## Result Path

`.code_my_spec/qa/717/result.md`
