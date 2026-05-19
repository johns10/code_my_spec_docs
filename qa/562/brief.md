# Qa Story Brief

## Tool

web

## Auth

No auth required for the local endpoint (port 4004). `Plugs.LocalOnly` accepts loopback IPs directly. Navigate to `http://127.0.0.1:4004` directly.

## Seeds

No seeds required — testing against the live CodeMySpec project graph which already has real data. The graph computes from live Files + Problems in the dev DB.

## What To Test

- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` and verify the page renders with a sigma.js canvas and graph data embedded in `#sigma-graph[data-graph]`
- Extract the `data-graph` JSON and verify every edge's `source` and `target` keys exist in the node list (no dangling edges — criterion 5597)
- Check that rendered node attributes include an `orphan_reference` field (criterion 5598 — expect this to fail as the current projector silently drops broken edges rather than flagging them)
- Verify `spec_file` nodes for components whose files exist on disk render satisfied (color `#ff3838`), while deeper requirements like `tests_passing` on a parent context remain unsatisfied when children's chains are incomplete (criterion 5599)
- Verify the fan-in shape: for each child component, at least one edge runs from a child-owned node into a parent-context node, confirming `tests_passing` depends on every child's terminal requirement (criterion 5603)
- Verify a context's `tests_passing` stays unsatisfied when any child implementation file is missing (criterion 5604)
- Identify two sibling schemas under the same parent context and confirm no edges run between them (no false serialization — criterion 5607)
- For a component with an explicit dependency on a sibling, verify a prerequisite edge exists in the graph while unrelated siblings have no cross-edges (criterion 5608)
- Traverse every node via undirected BFS and confirm each node shares a connected component with at least one project-typed node (fully connected graph — criterion 5611)
- If an orphan component (no parent context, no story link) appears in the graph, verify its connected component does not include a project node (criterion 5612)
- Find a story linked to a surface with a cross-context dependency: verify `bdd_specs_exist` has an outgoing edge to the dep's `spec_file` and no direct edge to the surface's `spec_file` (criterion 5649)
- Find a story linked to a standalone surface with no cross-context deps: verify `bdd_specs_exist` has exactly one component-bound outgoing edge, landing on the parent context's first requirement (criterion 5651)
- Verify that when a child's `tests_passing` provides a longer path to the parent's `implementation_file`, the direct shortcut child-`implementation_file` → parent-`implementation_file` edge is elided by transitive reduction (criterion 5646)
- Verify that edges in a strictly linear chain (no parallel alternative path) are preserved by transitive reduction (criterion 5647)

## Result Path

`.code_my_spec/qa/562/`
