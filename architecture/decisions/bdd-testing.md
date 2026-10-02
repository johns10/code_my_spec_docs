# Use BDD specs with SexySpex over LiveViewTest

## Status
Accepted (pre-made, revised)

## Context
We need a testing approach that validates user-facing behaviour and bridges the
gap between stories and code. Every acceptance criterion on a story gets one spec
file, and that file is the evidence the criterion is met.

## Decision
Use `sexy_spex` for the Given-When-Then DSL and `Phoenix.LiveViewTest` for
driving the interface. A spex mounts the real LiveView with `live/3`, submits
real forms with `render_submit/1`, and asserts on rendered markup with
`has_element?/2` — the same surface a person uses, reached through the view's own
process rather than a browser.

`when_` blocks drive the real surface. A spex that calls a context function
directly is asserting the implementation rather than the behaviour, and passes
while the thing a user does is broken.

Real-browser testing is QA's, not the suite's. A QA agent drives the running
application through Vibium and writes findings as issues against the story. That
is a different activity from the suite — it runs against a deployed build, it is
exploratory, and it is not a gate.

## Consequences
The suite needs no ChromeDriver, no browser process, and no user-agent sandbox
metadata, which is most of what made browser suites slow and flaky. It runs in
the same VM as the code, so a spex can hold a real harness socket and watch what
an agent actually calls.

The cost is that a spex cannot catch anything that only breaks in a real browser
— CSS, JavaScript hooks, focus and scroll behaviour. Those are QA's to find, and
a criterion that depends on them is one a spex should not claim to cover.
