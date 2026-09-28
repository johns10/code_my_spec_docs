# Qa Story Brief

Story 894 — Stop hook is a main menu.

The surface is an HTTP endpoint, not a page, so this is a `curl` brief. The
menu is rendered by `CodeMySpec.Validation.Menu` and reaches the agent only
inside a **refusal** — the allow path must stay an empty body, because nothing
on it reaches the model. That constraint is itself worth testing: a menu
leaking into an allowed stop is a defect, not a feature.

## Tool

curl

## Auth

No user auth. The local endpoint refuses non-loopback callers (`Plugs.LocalOnly`)
and takes project scope from the harness id.

    HARNESS=6bc4851f-f735-4590-bb1c-c660619b4019
    BASE=http://127.0.0.1:4004

Every request carries the id as a header:

    curl -sS -X POST "$BASE/api/harnesses/$HARNESS/hooks/stop" \
      -H 'Content-Type: application/json' \
      -H "X-Harness-Id: $HARNESS" \
      --data-binary @-

Confirm the harness is up and serving this working copy before starting:

    curl -sS "$BASE/health"

## Seeds

None. This story reads state that already exists in the working copy —
problems, issues, questions and requirements — rather than needing fixtures.
That is deliberate: the whole point of the menu is what it says about *this*
checkout, and a seeded project would test the renderer rather than the wiring.

The counts to expect come from the live tools, read immediately before testing
so the comparison is against the same state:

    list_problems(severity: "error")     -> total
    list_issues(status: "incoming")      -> count
    list_requirements(status: "unsatisfied", summary: true)

## What To Test

- **A refusal names a class and a call.** Fire a stop that is refused. The
  reason must contain a `Next:` line naming exactly one of `check_answer`,
  `list_problems`, `list_issues`, `get_next_requirement` — and that call must
  be on the same line as `Next:`, not below it. (criterion 2388)

- **One directive, not four.** With more than one class live, exactly one call
  appears in the directive line. Count them; two is a failure and so is zero.
  (2390)

- **The tally carries counts for the rest.** Every other live class appears as
  `N <label>` — `2 issues`, `12 requirements` — and *without* its tool name, so
  the response offers one action rather than four. (2390)

- **Problems outrank requirements.** With both live, the directive is
  `list_problems` and `get_next_requirement` appears nowhere in the response.
  (2400)

- **Asking is offered alongside.** With no question outstanding, the response
  carries both the directive and an `ask_user` offer. The offer is unconditional
  because nothing can detect that an agent needs input. (2403)

- **The allow path stays empty.** Fire a stop that is allowed. The body must be
  `{}` — no `systemMessage`, no menu, no advisory text. This is story 554's
  compactness rule and the reason the menu is refusal-only. A menu here is a
  defect.

- **The menu survives truncation.** The response is capped at 4096 bytes and the
  menu's bytes are reserved before the findings. On a working copy with many
  problems, confirm the `Next:` line is present in a response that was truncated
  — look for `... more problems omitted (response size limit)` and the directive
  in the same body.

- **Counts match reality.** Compare the tally's numbers against `list_problems`,
  `list_issues` and `list_requirements` read at the same moment. Requirements is
  known to count *unsatisfied* rather than *actionable* — a deliberate trade to
  avoid a filesystem read on the hot path — so a mismatch against
  `get_next_requirement` is expected and is not a finding. A mismatch against
  `list_requirements(status: "unsatisfied")` is.

- **An unbound working copy stays quiet.** A stop naming a harness with no
  project must not raise. This crashed during implementation (`comparing
  p.project_id with nil is forbidden`) and is guarded; confirm the guard holds
  from outside.

## Setup Notes

The running build must contain the menu. Verified before this session:
`git merge-base --is-ancestor 7cd50696 origin/main`, with `:4000` and `:4004`
both restarted onto `cf31844a`.

Two behaviours are deliberately absent and must not be reported as defects:

- **Nothing on an allowed stop.** Criterion 2401 asserted the opposite and was
  deleted once it emerged that the allow path cannot carry anything to the
  model. The case it covered — a clean tree with work outstanding, and silence —
  is unaddressed by this story and recorded as an open question on it.
- **Requirements are never the directive in practice.** Every validation refusal
  implies at least one problem, and problems rank above requirements, so the
  requirements tier is reachable only on a refusal carrying no problems. If it
  never appears as the `Next:` line during this session, that is expected.

## Result Path

`.code_my_spec/qa/894/result.md`
