# Qa Result

## Status

pass

## Scenarios

### 5091 — Advisory problems summarized, not enumerated, when stop is blocked

pass

Configuration: `compile_warnings: block`, `exunit: dont_block`. Fixture: `pipeline_compile_block_exunit_advisory/` (one compile warning + one exunit failure). Set via `NO_SERVER=true MIX_ENV=dev_cli mix run`. Touched `lib/example_context.ex` in the sandbox to trigger changed-file detection. Fired `POST /api/hooks/stop` with `test_output_files` pointing at fixture files.

The compile warning blocked the stop. The exunit failure was demoted to advisory. Response had `decision: "block"`. Blocking section listed `compiler (1):` with `lib/example_context.ex:2 — variable "unused" is unused`. Advisory header was `Additional problems (not blocking):` with one line `  - exunit: 1 error (advisory)`. No exunit file path or message body appeared in the advisory section.

Evidence: `.code_my_spec/qa/554/responses/5091_compile_blocks_exunit_advisory.json`

### 5092 — Advisory problems do not appear in an allow response

pass

Configuration: `exunit: dont_block`, `compile_warnings: dont_block`. Fixture: `pipeline_exunit_failure/` (one exunit failure, empty compile.jsonl). With both sources set to `dont_block`, the single exunit failure was demoted to advisory. Stop was allowed.

Response was exactly `{}`. No `reason` field, no `decision` field, no `problems` field.

Evidence: `.code_my_spec/qa/554/responses/5092_advisory_only_allow.json`

### 5093 — Blocking problem messages compacted to one line

pass

Configuration: `exunit: block_all`, `compile_warnings: dont_block`. Fixture: `pipeline_exunit_failure/exunit.json` whose message body is `"exunit failure fixture\ncode: assert 1 == 2, ...\nstacktrace: ...\n"` — a multi-line body with stacktrace.

Response had `decision: "block"`. The exunit entry appeared as a single line: `  - test/example_context_test.exs:4 — exunit failure fixture`. Line referenced file:line, included the first message line, contained no `stacktrace:` and no `^code:`. Line length was 60 chars (well under the 250-char tolerance).

Evidence: `.code_my_spec/qa/554/responses/5093_message_compaction.json`

### 5094 — Per-source enumeration capped at 10

pass

Configuration: `exunit: block_all`, `compile_warnings: dont_block`. Fixture: `pipeline_exunit_many_failures/exunit.json` with 15 distinct exunit failures.

Response had `decision: "block"`. Source header showed full count: `exunit (15):`. Exactly 10 detail lines with `test/many_failures/case_NN_test.exs` paths appeared. Overflow footer read `... 5 more exunit problems (use get_issue to inspect)`, mentioning `get_issue`.

Evidence: `.code_my_spec/qa/554/responses/5094_per_source_cap.json`

### 5095 — Total response size is hard-capped at 4 KB

pass

Configuration: `compile_warnings: block`, `exunit: block_all`. Fixture: `pipeline_overflow_4kb/` with 15 long-message compiler warnings and 15 long-message exunit failures, each rendered line near the 200-char per-problem cap.

Response had `decision: "block"`. Total response JSON was 3928 bytes. The reason field is a substring of this and well under 4096 bytes. Response contained `response size limit` and `omitted` in a tail footer indicating truncation.

Evidence: `.code_my_spec/qa/554/responses/5095_total_size_cap.json`

### 5096 — A single blocking problem is never overflow-truncated

pass

Configuration: `exunit: block_all`, `compile_warnings: dont_block`. Fixture: `pipeline_exunit_long_message/exunit.json` with one failure whose raw message is ~279 characters on a single line.

Response had `decision: "block"`. The exunit line referenced `test/long_message_test.exs:42` and ended with `...` (per-problem truncation). Line: `  - test/long_message_test.exs:42 — assertion failed with an intentionally very long diagnostic body spanning several sentences: this message exists to verify the per-problem length cap truncates to approximately 200 characters while...`. Line length was 236 chars (≤ 250). No `response size limit` footer. Total response was 456 bytes (well under 4096).

Evidence: `.code_my_spec/qa/554/responses/5096_single_problem_no_overflow.json`

## Evidence

- `.code_my_spec/qa/554/responses/5091_compile_blocks_exunit_advisory.json` — block with compiler warning, advisory exunit summarized as `1 error (advisory)`
- `.code_my_spec/qa/554/responses/5092_advisory_only_allow.json` — `{}` allow when all problems are advisory
- `.code_my_spec/qa/554/responses/5093_message_compaction.json` — single exunit failure with stacktrace compacted to one line
- `.code_my_spec/qa/554/responses/5094_per_source_cap.json` — 15 exunit failures: 10 inline plus overflow footer
- `.code_my_spec/qa/554/responses/5095_total_size_cap.json` — overflow_4kb fixture, response capped with size-limit footer
- `.code_my_spec/qa/554/responses/5096_single_problem_no_overflow.json` — single long-message problem truncated per-problem, no overflow footer

## Issues

None
