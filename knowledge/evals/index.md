# Evals

An eval measures what an agent *actually does* with the prompt and tools it has.
Every other check here asserts on code. These assert on conduct, and conduct is
non-deterministic, so an eval reports a **rate** rather than a pass.

## An eval is a cassette for behaviour

The closest thing in this codebase is a cassette, and the analogy is exact enough
to carry:

| Cassette | Eval artifact |
|---|---|
| Records a real HTTP call once | Records a real agent turn once |
| Replayed by tests thereafter | Asserted on by spex thereafter |
| Re-record when the API changes | Re-record when the prompt changes |
| A cassette from a failed run replays the failure forever | An artifact from a broken run certifies the break forever |

So the same discipline applies. The expensive real thing happens **once**, deliberately,
outside the test run. What the suite sees is a recording.

## Three programs, not one

    mix cms.eval          runs agents against a real model, writes artifacts
    mix spex              reads artifacts, asserts rates, never calls a model
    the person            reads a transcript and decides what went wrong

Keeping these apart is the whole design. They were one program until 2026-09-20,
and [what that cost](#what-this-replaces) is below.

## Quick reference

| What you need | Where |
|---|---|
| Run evals, and the iteration ladder | [Running evals](running_evals.md) |
| What a run records, and where it lives | [Artifacts](artifacts.md) |
| How spex judge an artifact; FAIL vs STALE | [Asserting](asserting.md) |
| A run looks bad — now what | [Diagnosing](diagnosing.md) |

## What this replaces

Story 1039's eval criteria carried `@moduletag :eval` and `config :ex_unit,
exclude: [:eval]` kept them out of every run. Ten of its twelve spec files never
executed, and `SpecsPassingChecker` cannot be contradicted by a file that never
ran — so `bdd_specs_passing` latched green over criteria nobody had measured
(`952cc0f1`).

Splitting production from assertion dissolves that. The spex become ordinary
spex: fast, always run, gated like everything else. The expensive half moves out
of ExUnit entirely, where it belongs, because a measurement that has to finish
inside somebody else's deadline stops being one.

**`@moduletag :eval` and the `exclude: [:eval]` config both go away.** If you find
yourself keeping `mix cms.eval` as a `mix spex` wrapper, you have rebuilt the
coupling this replaced.
