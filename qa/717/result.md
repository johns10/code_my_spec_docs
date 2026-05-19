# Qa Result

## Status

partial

## Scenarios

### Criterion 6416 — Project chain edges flow downward toward later gates

pass

Fetched `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` via curl and extracted the `data-graph` JSON from the `#sigma-graph` element's `data-graph` attribute. The graph contains 15 project nodes and 13 project→project edges. Every edge satisfies source.y > target.y (e.g. project_setup y=0 → personas_complete y=-1400 → stories_exist y=-2800 → … → qa_setup y=-14000). Zero violations found.

Evidence: 822 nodes / 3866 edges. All 13 project-chain edges flow strictly downward.

### Criterion 6417 — Component zone edges flow downward toward later tiers

fail

Analyzed 348 component→component cross-entity edges. 344 flow downward (sy > ty). 4 edges have equal y values (sy == ty == -25000), violating the strict downward-flow requirement.

The 4 violations are bidirectional edges between components that form circular dependencies:
- `Accounts.Account: implementation file` ↔ `Accounts.Member: implementation file` (y=-25000 on both)
- `Personas.PersonaStory: implementation file` ↔ `Personas.Persona: implementation file` (y=-25000 on both)

Root cause: `GraphProjector.resolve_depths` assigns depth 0 to all nodes in circular dependency cycles (code comment: "remaining nils get depth 0 (circular deps or missing)"). With both peers at depth 0, `normalize_comp_zone_y` assigns the same y coordinate. The edges between them are horizontal (sy == ty), not downward. Since Elixir modules cannot have true circular imports, the bidirectional dependency records likely represent a data quality issue — one direction of each pair was likely inserted by mistake.

### Criterion 6420 — Removing the only story-to-project edge keeps the project chain at the top

partial

The application correctly implements the 5-band layout with both early and late project gates. The graph shows 11 early project gates (y=0 to y=-14000, above the story zone) and 4 late project gates (y=-51800 to y=-56000, below the story zone): `all bdd specs passing`, `qa journey plan`, `qa journey execute`, `qa journey wallaby`. There are 53 story→project edges feeding these late gates.

The app-level intent of this criterion IS satisfied: early gates are at the top (max y=0), no total collapse to bottom band occurred. The regression described in the story (commit a774e35b collapsing the entire project chain to the bottom) is NOT present. However, the criterion's spex assertion `project_min_y > other_max_y` (all project nodes above all non-project nodes) evaluates to `-56000 > -16000 = false` because the late project band legitimately sits below the story zone. The assertion is overly strict for a schema that has both early and late project gates.

### Criterion 6421 — All five bands populated stack in correct order

pass

Band ordering verified from extracted data-graph JSON:
- Pre-story project band: y=0 to y=-14000 (11 nodes)
- Pre-component story band: y=-16000 to y=-21600 (161 nodes)
- Component zone: y=-25000 to y=-45000 (542 nodes)
- Post-component story band: y=-47000 to y=-48400 (104 nodes)
- Post-story project band: y=-51800 to y=-56000 (4 nodes)

All adjacency assertions pass:
- project_top(0) > pre_story_top(-16000): true
- pre_story_bottom(-21600) > component_top(-25000): true
- component_bottom(-45000) > post_story_top(-47000): true
- post_story_bottom(-48400) > project_bottom(-56000): true

Note: A previous QA run recorded a story/component band overlap. This run finds no overlap — the bands are distinct with 2000-4000 unit gaps between them. The layout appears to have been fixed between runs.

### Criterion 6422 — Empty post-story-project band leaves remaining four bands in correct order

partial

Test 1 (max project y == 0): PASS. The pre-story project band correctly anchors at the top of the canvas (y=0).

Test 2 (no project/story node below component zone): The spex assertion fails as written, but this is expected behavior. 108 nodes legitimately sit below the component zone (y < -45000): 104 post-component-story nodes (y=-47000 to -48400) and 4 late project nodes (y=-51800 to -56000). The 5-band model requires post-story and late-project nodes to appear below the component zone. The premise of the assertion (that the post-story band should be empty) does not match the current schema, which has 4 late project gates.

### Criterion 6423 — Component layers stack top-to-bottom in increasing dependency depth

pass

Component zone has 10 distinct y tiers ranging from y=-25000 (shallowest/top, depth 0) to y=-45000 (deepest/bottom). The `normalize_comp_zone_y` pass correctly uses the global topological depth map to assign tier positions. All inter-entity component edges either flow downward (344 edges, sy > ty) or are horizontal due to circular deps (4 edges, sy == ty). Zero upward-flowing edges observed. Tier structure is consistent with dependency depth ordering.

### Criterion 6424 — Satisfaction state maps to brand color tokens consistently across bands

pass

All 822 nodes use exactly the 3 brand palette colors with zero off-palette values:
- `#ff3838` (satisfied / bg-primary signal red)
- `#f5f5f7` (actionable / bg-success white-on-black)
- `#fde047` (blocked / bg-warning yellow)

Colors are applied consistently across project, story, and component bands. No band-specific color reinterpretation observed.

### Criterion 6425 — Large-project layout keeps distinct bands and non-overlapping nodes

pass

Graph renders 822 nodes and 3866 edges across 5 distinct non-overlapping bands. Adjacent bands have exclusive y-ranges with gaps of 2000-3400 units between them:
- Early project: [0, -14000] → gap 2000 → Pre-story: [-16000, -21600]
- Pre-story: [-16000, -21600] → gap 3400 → Components: [-25000, -45000]
- Components: [-25000, -45000] → gap 2000 → Post-story: [-47000, -48400]
- Post-story: [-47000, -48400] → gap 3400 → Late project: [-51800, -56000]

No y-range overlaps between any adjacent bands. Band separation is intact even with 822 nodes.

## Evidence

Vibium browser tools were not available in this subagent context. All evidence is from curl HTML extraction and data-graph JSON analysis.

- Curl `GET http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` returned 200 OK with `#sigma-graph[data-graph]` element present.
- Parsed `data-graph` JSON: 822 nodes, 3866 edges. Node entity_type counts: `{project: 15, story: 265, component: 542}`.
- Full graph data saved to `/tmp/graph_data.json` for analysis.
- Note: Vibium MCP tools (`mcp__vibium__browser_*`) were unavailable in this subagent. Browser-level screenshots could not be captured. All assertions are based on the data-graph JSON payload delivered by the server.

## Issues

### Circular component dependencies place peers at same Y tier, violating downward-flow invariant

#### Severity
MEDIUM

#### Scope
APP

#### Description
`GraphProjector.resolve_depths/2` assigns depth 0 to all nodes in circular dependency cycles (source: `graph_projector.ex`, comment "remaining nils get depth 0 (circular deps or missing)"). When two components form a mutual dependency (A depends on B, B depends on A), both land at depth 0 and receive the same y coordinate from `normalize_comp_zone_y`. The edges between them are horizontal (sy == ty), violating criterion 6417's requirement that component-zone edges flow strictly downward (sy > ty).

Observed circular pairs in the live graph at `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`:
- `Accounts.Account: implementation file` ↔ `Accounts.Member: implementation file` (both y=-25000)
- `Personas.PersonaStory: implementation file` ↔ `Personas.Persona: implementation file` (both y=-25000)

Since Elixir modules cannot have true circular imports (the compiler rejects them), these bidirectional dependency records likely represent a data quality issue — one direction of each pair was probably inserted by mistake. Cleaning the spurious dependency records would eliminate the cycles and allow `resolve_depths` to assign distinct depths, restoring downward edge flow. Alternatively, `GraphProjector` could detect cycles and apply a tiebreaker (e.g. alphabetical module name) to distinguish nodes within a circular pair.

Reproduction: `GET http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`, parse `data-graph`, filter component→component edges where `source.attributes.entity_id != target.attributes.entity_id` and `source.attributes.y == target.attributes.y`.

### Criteria 6420 and 6422 spex assertions mismatch current 5-band schema

#### Severity
LOW

#### Scope
QA

#### Description
Criterion 6420's spex asserts `project_min_y > other_max_y` (all project nodes above all non-project nodes). This was written assuming the post-a774e35b schema had NO late_project gates, but the current schema has 4 late gates (`all bdd specs passing`, `qa journey plan`, `qa journey execute`, `qa journey wallaby`) that legitimately sit at y=-51800 to y=-56000, below the story zone. The assertion evaluates to `-56000 > -16000 = false` and fails. The correct assertion for this criterion's intent should verify that the HIGHEST project node is at y=0 (passes) and that no collapse to all-bottom occurred — not that ALL project nodes are above all non-project nodes.

Criterion 6422's spex asserts no project/story node sits below the component zone bottom (y=-45000). The 104 post-story-band story nodes (y=-47000 to -48400) and 4 late project nodes (y=-51800 to -56000) correctly appear below the component zone per the 5-band design. This assertion's premise conflicts with the 5-band layout model.

Both spex files should be updated to assert the correct 5-band invariants rather than a simpler 3-band model. Test files: `criterion_6420_*_spex.exs` and `criterion_6422_*_spex.exs`.
