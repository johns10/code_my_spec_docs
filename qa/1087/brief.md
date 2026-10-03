# QA Brief — Story 1087: A big docs embed never slows my searches

## Context

`get_next_requirement` lists `implementation_file` as unsatisfied for
`CodeMySpec.Embeddings.HexDocProjector` and
`CodeMySpec.Embeddings.SqliteVecBackend` — neither file exists in `lib/`.
However, the three acceptance criteria for this story do not depend on
those two components: the BDD specs added in d9a955ba7 exercise the
already-implemented search-priority queue (`OrtexServing`),
`HexDocSweep`, and `PgVectorBackend` instead. Those two missing files
appear to belong to later/parallel work on this component, not to this
story's criteria.

## Method

The criteria are backend concurrency/consistency behaviors (search
latency under a concurrent bulk import, model-version pinning across a
serving upgrade, burst-box crash recovery) that are not meaningfully
exercisable through browser click-through QA. Each criterion already has
a SexySpex scenario that boots a real harness checkout and drives the
actual code path, so QA ran those directly rather than duplicating them
by hand:

```
mix test test/spex/1087_a_big_docs_embed_never_slows_my_searches/criterion_1768_an_agent_searches_during_a_big_docs_import_spex.exs
mix test test/spex/1087_a_big_docs_embed_never_slows_my_searches/criterion_1771_a_model_upgrade_re-embeds_before_searching_spex.exs
mix test test/spex/1087_a_big_docs_embed_never_slows_my_searches/criterion_1772_a_lost_burst_box_resumes_where_it_stopped_spex.exs
```

## Result

| Criterion | Scenario | Result |
|---|---|---|
| 1768 | Agent searches during a big docs import | PASS — search returned in well under 1s while a 50-file import ran concurrently |
| 1771 | Model upgrade re-embeds before searching | PASS |
| 1772 | Lost burst box resumes where it stopped | PASS — observed `HexDocReconciler` deferring the package as retryable on `:serving_down` rather than failing outright |

All 3 criteria: 1 test each, 0 failures.
