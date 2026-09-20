# Artifacts

An artifact is the recording of one eval run. It is a **test fixture**, kept with
the other test fixtures and committed:

    test/fixtures/evals/<criterion>/<run>.json

Beside `test/fixtures/cassettes/`, and for the same reason. A cassette records a
real HTTP exchange so tests need not make one; an eval artifact records a real
agent turn so spex need not run one. Committing them is what makes a rate
auditable by somebody other than the person who produced it — an uncommitted
measurement is a number you are asked to take on trust.

## What a run records

Everything needed to (a) judge the run, (b) know whether the judgement is still
current, and (c) let a person see what actually happened.

**The verdict**
- criterion id, run index, pass/fail for this run, and why
- `errored` with the reason when the run never reached a verdict

**The staleness key** — see [asserting](asserting.md#stale)
- the **composed** system prompt, in full: role brief + operating rules +
  project guide + tool index, exactly as `SystemPrompt.compose/4` built it
- model and provider

**The conduct**
- every tool call the agent made, **in order**, with arguments
- read from `read_agent_conversation`, which is the agent's own transcript —
  a model will narrate a call it never made, so what it *said* is not evidence
  and what it *called* is

**The context**
- when, against which build, on which checkout

## Record the composed prompt, not the role brief

The whole prompt, or the staleness check is blind to the half that broke.

Criterion 3539 is the worked example. It asserts a coding agent calls
`get_next_requirement` then `start_task`. Neither `RoleBrief` nor `OperatingRules`
mentions claiming work — that instruction lives only in the project guide
(`.code_my_spec/AGENTS.md`, four times over). Hash the role brief alone and the
guide could vanish entirely without staling anything, which is exactly the bug
that was live when this was written: the eval's temp checkout had no `AGENTS.md`,
`SystemPrompt.guide/1` returned `nil`, and the agent was measured on a prompt that
never told it what to do.

## Readable by a person, quickly

The point of recording is "look at what the agent did." A wall of raw turns is not
that. The ordered tool calls with their arguments are the thing worth reading, and
they should be the thing you see first — the prose around them is narration.

## Size

Transcripts are large and these are committed. Keep the full raw turn payloads out
of the artifact; keep the tool calls, arguments, verdict and prompt. If a run needs
its full payload to be understood, that is worth a note in the artifact rather than
megabytes in git forever.
