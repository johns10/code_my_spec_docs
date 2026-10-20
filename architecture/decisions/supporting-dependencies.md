---
deps: [mox, meck, benchee, file_system, floki, earmark, yaml_elixir, dir_walker, briefly, nimble_csv, recase, uuid, inflex, client_utils, flame]
---
# Supporting dependencies

## Status
Accepted

## Context
Small libraries that are not decisions of their own: test doubles (`mox`, `meck`), benchmarking (`benchee`), file watching (`file_system`), HTML and Markdown parsing (`floki`, `earmark`), YAML (`yaml_elixir`), directory walking (`dir_walker`), temp files (`briefly`), CSV (`nimble_csv`), string and inflection helpers (`recase`, `inflex`), ids (`uuid`), the shared `client_utils` package, and `flame` for elastic compute.

## Decision
Use them where needed without a separate record each. A dependency that grows into a real choice moves out of this list into its own ADR.

## Consequences
The coverage check passes for these as a group. `flame` and `client_utils` are the most likely to deserve their own ADR.
