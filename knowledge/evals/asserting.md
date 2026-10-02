# Asserting on artifacts

Spex read artifacts. They never start an agent and never call a model, so they run
in the ordinary suite at ordinary speed and are gated like everything else.

A criterion's spex answers two questions, in this order:

1. **Is this artifact still about the prompt we ship today?** If not, it is not
   evidence. Stop here.
2. **Does the rate meet the threshold?**

## Stale

An artifact recorded against one prompt says nothing about a different one. When the
prompt has moved, the criterion **fails** — the artifact is not evidence and a green
built on it would be the `952cc0f1` latch again in new clothes.

Failing rather than warning means a prompt edit red-lights its criteria until someone
re-records. That is the intended pressure: the alternative is a stale artifact sitting
green indefinitely.

### Not every edit is a change

Hashing the prompt makes every whitespace reflow and every tool-list reordering a
failure, which trains people to ignore the signal. So the comparison is by
**similarity, not identity** — a prompt that is ~95% the same is the same prompt, and
does not stale.

Two things must be normalised out before comparing, or the threshold fights noise
rather than measuring drift:

- **Machine-specific tool names.** The tool index carries 85 browser tools on a box
  with a browser and none on a box without. Compare a normalised list, or artifacts
  go stale on every other machine.
- **Whitespace and ordering** where it carries no meaning.

### The known weakness of a percentage

**Text similarity does not track significance, and the counterexample is the criterion
this practice was built on.**

Criterion 3539 asserts an agent claims work before doing it. The instruction that
makes it true is one line in a ~10,000-character prompt. Delete that line and the
prompt is 99.9% the same — comfortably inside any threshold — while the behaviour it
measures is no longer supported by the prompt at all. Meanwhile reflowing a paragraph
might exceed 5% and stale everything for no reason.

So the percentage is a pragmatic filter against churn, not a correctness argument. If
it starts lying in either direction, the fix is to compare **structure** rather than
characters: diff at the instruction level, treat an added, removed or reworded
instruction as drift, and ignore everything else. Recorded here so that when someone
hits it, it reads as a known limit rather than a surprise.

## Rate

Each criterion states its own threshold — 9 in 10, 7 in 10 — in its own terms. The
threshold belongs to the criterion because what counts as reliable differs: an agent
that claims work correctly 7 times in 10 is broken, while a judgement call landing 7
in 10 may be fine.

Errored runs are not in the denominator. Ten clean runs means ten. See
[running evals](running_evals.md#errored-runs).

## Three outcomes, kept apart

| Outcome | Means | Do |
|---|---|---|
| **PASS** | Rate met, prompt current | Nothing |
| **FAIL (rate)** | Measured, agent did the wrong thing too often | [Diagnose](diagnosing.md) |
| **FAIL (stale)** | Not measured against the prompt we ship | Re-record |

The two failures must be distinguishable in the output. They are both red, but one
says *the agent is wrong* and the other says *you do not know yet* — and sending
someone to debug an agent that was never measured is the expensive mistake.

## A rate in the middle is the finding

Six in ten is not a flake and not a near-miss. It means the agent read the
instruction one way sometimes and another way the rest of the time, which is a
statement about the prompt being **ambiguous** — information no single run can
produce.

Re-running until it passes discards the measurement. Fix the ambiguity, then measure
again.
