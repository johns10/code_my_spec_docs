# Qa Story Brief

## Tool

web

## Auth

No auth required for the local endpoint (port 4004). `Plugs.LocalOnly` accepts loopback IPs directly. Navigate to `http://127.0.0.1:4004` directly.

## Seeds

No seeds required — testing against the live CodeMySpec project graph which already has real data. The graph computes from live Files + Problems in the dev DB.

## What To Test

**Graph LiveView surface** (`http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`):

- Navigate to the requirements graph and verify the page renders with a sigma.js canvas and graph data embedded in `#sigma-graph[data-graph]`
- Extract the `data-graph` JSON and verify every edge's `source` and `target` keys exist in the node list (no dangling edges — criterion 5597)
- Verify orphan reference indicator: check whether orphan_reference field appears in node attributes, or whether dangling prereq edges surface as flagged (criterion 5598)
- Verify satisfied nodes stay red regardless of upstream state — a locally-satisfied node whose upstream prereq is unsatisfied should still render as satisfied (criterion 5620 leaf-truth)
- Verify `tests_passing` at a context level depends on all children's terminal requirements (criterion 5603)
- Verify a context `tests_passing` stays unsatisfied when any child implementation file is missing (criterion 5604)
- Identify two sibling schemas under the same parent context and confirm no edges run between them (independent siblings actionable simultaneously — criterion 5607)
- Confirm a sibling with an explicit dep on another sibling has a blocking edge while unrelated siblings are independently actionable (criterion 5608)
- Traverse every node via undirected BFS and confirm each node shares a connected component with at least one project-typed node (fully connected graph — criterion 5611)
- Verify ~207 orphan components in the live graph appear as disconnected islands (no path to project root), confirming criterion 5612 is met
- Verify story kickoff resolves to the correct surface dep: find a story with a cross-context dep, confirm `bdd_specs_exist` edge targets that dep (criterion 5649)
- Verify standalone surface kickoff lands on surface directly when there are no cross-context deps (criterion 5651)
- Verify transitive reduction elides child-`implementation_file` → parent-`implementation_file` shortcut when child's `tests_passing` provides a longer path (criterion 5646)
- Verify linear chain edges are preserved when no alternative path exists (criterion 5647)

**get_next_requirement MCP surface** (criteria 6494-6497):

- Using `get_next_requirement` on the live project, confirm the current response is coherent (returns a valid requirement, not a component requirement that's gated by an unsatisfied project chain — criterion 6494 principle verified via current state)
- Verify the graph legend and visual indicators (satisfied/actionable/blocked color coding visible, debug node/edge counts present)

## Result Path

`.code_my_spec/qa/562/`
