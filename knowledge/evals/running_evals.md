# Running evals

`mix cms.eval` runs agents and writes artifacts. It does not assert. It costs real
model spend and real wall clock, so it is run deliberately, by a person, when the
answer could have moved.

    mix cms.eval                          every behavioural criterion
    mix cms.eval --pattern criterion_3539 one criterion
    mix cms.eval --runs 1                 one measurement instead of ten

## When to run

When something that changes behaviour changed: a role brief, the operating rules,
the project guide, the tool list, or the model. Nothing else notices those — that
is what [the staleness check](asserting.md#stale) is for, and it tells you which
criteria to re-record rather than making you guess.

Not on the promote gate. The gate runs under a deadline; this does not fit inside
one and should not try.

## The ladder

Do not run ten first. Run one, look at it, fix, run more. Failure is cheapest at
the start.

    1 run    →  read the transcript end to end
    2 runs   →  is the fix real or did you get lucky once
    2 runs   →  still holding
    10 runs  →  the measurement

Each rung is a decision to keep going. A criterion that is wrong, or a product bug,
shows up on run 1 — and finding it there costs one run instead of ten.

## Debugging runs are discarded

**The runs you iterated against are not the measurement.** If you tuned the prompt
until run 1 passed, then ran two more and tuned again, those runs were optimised
against. Reporting their rate would be reporting a fitted number as a measured one.

So: the ladder is debugging. When you stop changing things, **freeze the prompt and
run a clean N**. That run is the artifact. Change the prompt afterwards and you owe
a fresh N — which the staleness check will tell you about anyway.

## Fix on the spot

At this stage, when a run looks wrong, fix it and iterate rather than filing an
issue and waiting. The loop is the point and ceremony kills it.

The one discipline that survives: **know which of the three things you are fixing.**
[Diagnosing](diagnosing.md) has the table. Fixing a product bug by editing the prompt
is the failure mode this whole practice exists to catch, and it looks exactly like
progress while you are doing it.

## Errored runs

A run that errored — harness restart, provider timeout, channel drop — is not
evidence about the agent. It does not go in the denominator. It is **excluded and
re-run** until N clean runs exist.

Cap the retries. A criterion that errors repeatedly is telling you something about
the harness, and that is a finding worth having rather than a loop worth running.

## Cost

Ten criteria x ten runs x a multi-turn scenario against a real model. Use
`--pattern` while iterating; you almost never want the whole suite until the end.
`--runs` lowers the count, and a threshold asserted over two runs is a smoke test
rather than a measurement — say so if you report one.
