# Qa Result

## Status

fail

## Scenarios

### Criterion 6416 — Project chain edges flow downward

pass

Navigated to `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` and extracted the `data-graph` JSON from the HTML response. Found 15 project nodes and 13 project→project edges. Every project-to-project edge has `source.y > target.y` — the project chain lays out correctly as a vertical column from y=0 down to y=-12750.

### Criterion 6417 — Component zone edges flow downward

fail

Extracted component→component edges from the `data-graph` JSON. Found 348 component-to-component edges. Of these, 309 violate the downward-flow rule: 192 are upward (source.y < target.y) and 117 are horizontal (source.y == target.y). Sample violations:

- `component_8d9b28aeb62052ed8184...implementation_file → component_5e473e3...implementation_file`: src y=-7200, tgt y=-7000 (upward by 200)
- `component_4de532b9...implementation_file → component_3916da5c...implementation_file`: src y=-6450, tgt y=-6250 (upward by 200)

The component zone layout uses horizontal tree placement for each tier, where siblings within a tier share the same y-band. Cross-tree component edges (implementation_file → implementation_file between different components at similar but not identical depths) violate the downward invariant because they connect nodes at different tiers in ways the projector's tier-based layout does not account for.

### Criterion 6420 — Removing story-to-project edge keeps project chain at top

not tested

This criterion requires a synthetic fixture (removing the only story-to-project edge) that cannot be set up without mutating the running project's graph. The current graph has 53 story→project edges and the project nodes are already correctly placed at the top (y=0 to y=-12750). The degenerate case cannot be observed without a controlled graph fixture.

### Criterion 6421 — All five bands stack in correct order

fail

Extracted y-ranges from `data-graph` JSON:
- Project band: y=[−12750, 0]
- Story band: y=[−10850, −4000]
- Component band: y=[−9450, −6250]

The story band bottom (y=−10850) is lower than the component band top (y=−6250), meaning the component zone overlaps into the story zone by 4600 units. Specifically: 542 of 542 component nodes fall within the story band's y-range, and 104 story nodes fall within the component band's y-range. The expected invariant (`story_bottom_y > component_top_y`) is violated. The project band is correctly above the story band (project_top=0 > story_top=−4000).

### Criterion 6422 — Empty post-story-project band leaves remaining four bands correct

not tested

Current schema has no late_project nodes (all 15 project nodes land in early_project because no project node receives a cross-entity edge per the `fan_in_idx` fallback). The post-story-project band is empty by design in the current data, but there are no dedicated late-project nodes to observe.

### Criterion 6423 — Component layers stack top-to-bottom by dependency depth

partial

The projector produces 10 distinct y-levels for components, with values at -6250, -6450, -7000, -7200, -7750, -7950, -8500, -8700, -9250, -9450. These represent the tier-based layout where depth-0 components render first (highest y, closest to story band). However, as noted in criterion 6417, cross-component edges between nodes in adjacent tiers frequently flow upward or horizontally, violating the expected downward-only invariant for intra-component edges.

### Criterion 6424 — Satisfaction state maps to brand color tokens consistently

pass

All 822 nodes use exactly the three brand palette colors: `#ff3838` (satisfied, 694 nodes), `#f5f5f7` (actionable, 30 nodes), `#fde047` (blocked, 98 nodes). No off-palette colors observed. Color assignment is consistent across all entity types (project, story, component).

### Visual layout check

fail

Screenshots at `.code_my_spec/qa/717/screenshots/4004_graph_overview.png` and `4004_graph_initial_load.png` show all 822 nodes compressed into a thin horizontal band in the center of the canvas. The sigma.js rendering makes the distinct y-bands invisible at the default zoom level — the graph appears as a single squashed horizontal line rather than clearly separated project/story/component vertical zones. Sigma's auto-fit collapses the wide y-range (−12750 to 0) into a tiny viewport fraction because the node spread is disproportionate (12750 y units tall, but very wide horizontally from story x-coordinates).

## Evidence

- `.code_my_spec/qa/717/screenshots/4004_graph_overview.png` — graph at initial load, shows all nodes collapsed into a horizontal line
- `.code_my_spec/qa/717/screenshots/4004_graph_initial_load.png` — same view confirming the collapsed layout with "822 nodes, 3866 edges" in the debug footer

## Issues

### Component zone edges flow upward — 309 of 348 intra-component edges violate downward invariant

#### Severity
HIGH

#### Scope
APP

#### Description
The requirements graph criterion states "component zone edges flow downward toward later tiers." Extracting the `data-graph` JSON from `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`, 309 of 348 component→component edges have `source.y <= target.y` (192 upward, 117 same-y).

The root cause is that the component zone tier layout places all nodes of a given dependency depth at the same y-band, but cross-component edges connect nodes from different trees that happen to share similar (but not identical) y positions. The `implementation_file` requirement in one component tree links to `implementation_file` in another component at a different tier. The GraphProjector assigns y based on intra-tree depth, not global component depth, so sibling-tier dependencies between trees produce horizontal or upward edges.

Reproduction: `curl -s "http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true" | grep -o 'data-graph="[^"]*"' | python3 -c "import sys,json; d=sys.stdin.read().replace('&quot;','\"'); g=json.loads(d); nodes={n['key']:n for n in g['nodes']}; print(sum(1 for e in g['edges'] if (s:=nodes.get(e['source'])) and (t:=nodes.get(e['target'])) and s['attributes']['entity_type']=='component' and t['attributes']['entity_type']=='component' and s['attributes']['y']<=t['attributes']['y']))"`

### Story and component bands overlap — 4600-unit y-range collision

#### Severity
HIGH

#### Scope
APP

#### Description
The band ordering criterion requires `story_bottom_y > component_top_y`. In the current graph, the story band extends from y=−4000 (top) to y=−10850 (bottom), and the component band occupies y=−6250 (top) to y=−9450 (bottom). The component band top (−6250) is 4600 units above the story band bottom (−10850), meaning the component zone is entirely inside the story zone's y-range.

All 542 component nodes fall within the story band's y-range. The `GraphProjector.project_layout/2` places the component zone start (`comp_zone_y`) relative to the pre-component story zone's lowest node, but the story zone spans a wide y-range (265 stories × 350-unit row gap, spread across many columns). The post-component story nodes (`post_sigma`) use a y below the component zone, but the pre-component story nodes extend much further down than `comp_zone_y` starts.

Visual: `.code_my_spec/qa/717/screenshots/4004_graph_overview.png` shows the entire graph as a single horizontal band — bands are not visually distinct.

Reproduction: Check `story_bottom` vs `comp_top` in the JSON: project band max_y=0, story max_y=−4000, story min_y=−10850, comp max_y=−6250.
