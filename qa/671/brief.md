# Qa Story Brief

## Tool

web (Vibium MCP browser tools for the configuration LiveView; curl for graph data inspection)

Note: The requirements graph embeds its full JSON in the `data-graph` attribute of `#sigma-graph`.
Curl can fetch this directly without a browser, making it the most reliable verification tool
for graph structure assertions.

## Auth

No authentication required. The local endpoint at `http://127.0.0.1:4004` uses `Plugs.LocalOnly`
and trusts loopback connections. No login step needed.

**Important:** The running app at port 4004 uses the SQLite CLI DB at `~/.codemyspec/cli_dev.db`,
NOT the Postgres dev DB. Use `MIX_ENV=dev_cli` for any mix commands that need to interact with
the same database. Direct SQLite queries also work for reading/updating configuration.

## Seeds

No special seeds required. Use the `code-my-spec` project — it has 542 components including
context-type components (which produce review_file/review_valid nodes) and is already in the DB.

Before each scenario, set the desired config state via SQLite:
```
sqlite3 ~/.codemyspec/cli_dev.db "UPDATE project_configurations SET require_specs=1, require_reviews=1, require_unit_tests=1 WHERE project_id = (SELECT id FROM projects WHERE name='Code My Spec')"
```

To verify current state:
```
sqlite3 ~/.codemyspec/cli_dev.db "SELECT p.name, pc.require_specs, pc.require_reviews, pc.require_unit_tests FROM project_configurations pc JOIN projects p ON p.id = pc.project_id WHERE p.name='Code My Spec'"
```

## What To Test

Graph URL: `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`
Config URL: `http://127.0.0.1:4004/projects/code-my-spec/configuration`

The graph JSON is embedded in the HTML response as `data-graph="..."` (HTML-encoded).
Parse with:
```python
import re, json, html
m = re.search(r'data-graph="([^"]+)"', content)
raw = html.unescape(m.group(1))
data = json.loads(raw)
```

Node attributes: `entity_type` (component/story/project), `name`, `entity_id`
Edge fields: `source`, `target` (key strings like `component_<id_nodashes>_<name>`)

### Scenario 1: Default config (all true) — full graph (criteria 5630, 5632, 5634, 5644)
- Set all three flags to true
- Fetch graph
- Assert component nodes include spec_file, spec_valid (criterion 5630)
- Assert component nodes include review_file, review_valid (criterion 5632, for context-type components)
- Assert component nodes include test_file, test_spec_alignment, tests_passing (criterion 5634)
- Assert story nodes include bdd_specs_exist (criterion 5634)
- Assert 0 dangling edges (criterion 5644)

### Scenario 2: require_specs=false removes spec nodes (criteria 5629, 5637)
- Set require_specs=false, others true
- Assert no component node named spec_file or spec_valid
- Assert no edge endpoint ends with _spec_file or _spec_valid
- Assert 0 dangling edges

### Scenario 3: require_reviews=false removes review nodes (criteria 5631, 5637)
- Set require_reviews=false, others true
- Assert no component node named review_file or review_valid
- Assert no edge endpoint ends with _review_file or _review_valid
- Assert spec and test nodes still present

### Scenario 4: Reviews disabled splices impl_file onto spec_valid (criterion 5635)
- In reviews-disabled state
- Collect edges targeting implementation_file nodes
- Assert none have source ending in _review_file or _review_valid
- Assert at least one incoming edge exists (impl_file is not a root)

### Scenario 5: require_unit_tests=false removes test nodes, BDD survives (criterion 5633)
- Set require_unit_tests=false, others true
- Assert no test_file/test_spec_alignment/tests_passing component nodes
- Assert bdd_specs_exist story nodes still present

### Scenario 6: All three disabled — coherent graph (criteria 5638, 5765)
- Set all three to false
- Assert only implementation_file remains as component node type
- Assert 0 dangling edges
- Assert 542+ implementation_file component nodes (child nodes survive)

### Scenario 7: Toggle reviews off then on returns baseline (criteria 5641, 5642)
- From all-disabled: re-enable reviews → review nodes appear
- Re-disable → review nodes gone
- Re-enable all three → baseline restored (3543 nodes, 56 review, 1092 spec)

### Scenario 8: Only reviews disabled leaves specs and tests untouched (criterion 5643)
- Set require_reviews=false only
- Assert spec nodes (1092) and test nodes present
- Assert review nodes: 0

### Scenario 9: Specs disabled — review_file has no spec-pointing incoming edge (criterion 5636)
- Set require_specs=false, require_reviews=true
- Assert review_file nodes exist
- Assert no incoming edge to any review_file has source ending in _spec_file or _spec_valid

## Result Path

`.code_my_spec/qa/671/result.md`

## Setup Notes

The running server at port 4004 uses `MIX_ENV=dev_cli` with SQLite. The `mix run` commands
without `MIX_ENV=dev_cli` connect to Postgres and will NOT see the same data. Use SQLite
direct queries or `NO_SERVER=true MIX_ENV=dev_cli mix run` for scripted setup.

The `code-my-spec` project has context-type components (which produce review_file/review_valid
nodes) and is the best project for testing all three filter scenarios.
