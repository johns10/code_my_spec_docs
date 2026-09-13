---
component_type: "*"
session_type: "design"
---

# Analyzer Output Is Not Rewritten

**Analyzer output should not be rewritten.** Whatever a source's own tool
printed — `mix test`'s dots and failure blocks, `mix credo`'s issue list,
`mix compile`'s warnings, `sobelow`'s findings — is what reaches the agent.
Never a synthesized summary, a count, a "clean" placeholder, or a
per-finding line reformatted from structured data, when the tool's own
real output exists and could have been kept.

## Why

The analysis service exists so an agent's own `mix test`/`mix spex`/
`mix compile`/`mix credo` can be routed through a shared, single-flight
ledger without the agent being able to tell — same output, same exit
code, dedup and slot management happening entirely out of sight. A
routed command that comes back looking different from a real one is a
routed command the agent can tell was routed, and any behavior an agent
learns to expect from real analyzer output silently stops applying.

Reformatting also loses information a downstream reader may need and
has no way to ask for back: exact line context, coloring/priority bands,
the surrounding compiler chatter that explains *why* a warning fired.
Synthesizing a summary is a one-way trip — the real output is gone at
that layer, not recoverable further down the call chain.

## What this looks like in code

- Capture the tool's raw stdout/stderr at the point of shelling out, and
  carry it — not just the structured diagnostics parsed out of it — through
  every intermediate representation to the response the agent sees.
- A wire contract between two processes (harness ↔ server) that carries
  structured diagnostics but no raw output field for some source is
  already in violation, whether or not anything downstream currently
  reformats what little arrives.
- "No problems found" is not a license to invent placeholder text
  (`"clean"`, `"no issues"`) in place of the tool's own true empty/quiet
  output — if the real tool prints nothing on a clean run, forwarding
  nothing is correct; if it prints something even when clean (a summary
  line, a version banner), forward that.
- A canonical sweep invocation that ignores an individual caller's own
  flags (a fixed `mix compile --return-errors` regardless of what an
  agent's own `mix compile <flags>` asked for) is a separate, narrower
  concern from this rule — this rule is about not reformatting the output
  of whatever *did* run, not about guaranteeing every caller-specific flag
  is honored by a shared sweep.

## Verifying it

For each analyzer source, there should be a scenario proving: given a
real (or realistically simulated) run of that tool with known output,
the text that reaches the agent through the routed path is that output,
byte for byte — not a count, not a reformatted line, not a placeholder.
