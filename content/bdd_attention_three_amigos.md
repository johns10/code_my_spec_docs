# Three Amigos: the gate that was missing

_Part 6 of the [BDD Attention Thesis](/blog/bdd-attention-thesis). Previous: [Part 5: Naive BDD](/blog/bdd-attention-naive-bdd)._

---

The gate needed to be at the beginning. Not "review the output" but "define what the output should be, in enough detail that there's nothing left to interpret."

MetricFlow taught me this. The BDD format was right, running specs against a real browser was right, and I was still debugging a broken app through three layers of accumulated ambiguity — because by the time I showed up to review, the specs were written, the code was generated, and the tests were already passing.

That process already existed. It's been part of BDD since the beginning. It's called Three Amigos.

## What Three Amigos actually is

Before writing any scenario, walk through the story from three perspectives.

**Business.** What problem does this solve? What are the rules that govern it? What does success look like from a user's point of view?

**Developer.** How will this be implemented? What are the constraints? What dependencies exist? What could make this harder than it looks?

**QA.** What could go wrong? What are the edge cases? What failure modes are we not covering?

The output isn't just acceptance criteria — it's concrete examples. Not "a user can connect Google Analytics" but: "Given I'm on the integrations page and haven't connected Google Analytics yet, When I click Connect, Then I see the OAuth authorization screen with the analytics.readonly scope explicitly requested."

The specificity isn't pedantry. It's the work — the ambiguity resolved before any code touches the story.[^1]

## Why the model can't do this alone

Cheparsky has the diagnosis: if only one party writes the specs, SDD fails the same way BDD failed — the specs reflect one perspective, usually the most optimistic one.[^2]

That's exactly what happened in MetricFlow. I wrote acceptance criteria that reflected my high-level intent. The model wrote BDD specs that reflected its interpretation of my intent, filtered through what it knew how to build and test. There was no moment where a second perspective entered the room and said: wait, what do you actually mean by "connect Google"?

The QA perspective — "what could go wrong" — was never applied before the spec was written. It was only applied after the code was generated, when the QA agent ran scenarios and found things passing that shouldn't have. By then, fixing meant rewriting backward through every layer.

## How I run the session now

After MetricFlow, I stopped handing the model an AC and saying "write specs." One agent plays all three amigos while I hold product intent, and it interviews me to surface rules, edge cases, and open questions before any scenarios get written.

The ordering matters. Persona linkage first — who is actually doing this, what do they know, what would confuse them. Then rules — the governing constraints, capped at under ten. Then scenarios for each rule, happy path first, failure path only when a real failure surface exists. Anything unresolved gets parked as an open question rather than derailing the session.

The deliverable isn't Gherkin. It's a populated set of rules, scenario titles, and open questions. The PM reviews scenario titles before any code generation starts — that's the gate, that's where "yes, that's what I meant" or "no, that's not right" happens.

## Why good scenarios still aren't enough

Three Amigos ensures the spec asks the right question. That's not the same as ensuring the spec can't cheat to answer it.

A scenario for "user successfully connects Google Analytics" would reach into the app's `Integrations` context, call `get_integration(scope, id)`, and assert the returned struct showed `:connected`. The spec passed. The user might still not see a connected integration on the page.

That's a spec proving a database row changed, not proving the user's experience changed. The difference matters enormously when coding agents are involved, because a coding agent will find every unintended path. If a spec can bypass the real user surface to verify state, the agent will write code that satisfies the spec without satisfying the user.

The fix is enforcing the boundary at compile time. Specs live in a sealed module — no importing the core app, no calling context functions, no touching `Repo`. The rule isn't a convention. It's enforced by the compiler. If a spec tries to call `Integrations.get_integration/2` directly, the project doesn't compile.

The only thing a spec is allowed to do is what a real user can do:

- **Drive through the real surface.** Navigate the LiveView. Submit forms. Fire HTTP hooks. Nothing else.
- **Observe through the real surface.** Check what's in the rendered HTML. Read the HTTP response. If the user can't see it, the spec can't check it.

For the Google Analytics integration: the spec navigates to the integrations page and asserts the integration card shows "Connected" in the rendered HTML. That only passes if the user actually sees it. No flash message trick works here — the spec isn't checking for a flash, it's checking what the page renders after the OAuth flow completes and the user lands back in the app.

This is what closes the MetricFlow Potemkin village. Not just better scenario titles. A structural constraint that makes the spec honest by construction.

## What changed

"Connect Google Analytics" as an acceptance criterion generates a spec that verifies you can complete an OAuth flow and see a success message. A Three Amigos session on the same story produces:

- Given I'm on the integrations page with no Google Analytics connection, When I click Connect, Then I'm redirected to Google's OAuth screen requesting the analytics.readonly scope
- Given I've authorized the OAuth flow, When I'm redirected back to the app, Then my Google Analytics connection shows as active and displays the property name
- Given I have an active Google Analytics connection, When the data sync runs, Then metrics from the last 30 days are available in my dashboard
- Given the OAuth authorization fails or is denied, When I'm redirected back, Then I see a specific error message and the connection remains unconnected

Those are four different features. "Connect Google Analytics" described one of them, loosely.

The model didn't write those scenarios. The PM confirmed them. The model then generated Gherkin from confirmed scenario titles, with the PM-approved intent as the anchor. The gate held.

## Where the thesis lands

Six installments, one mechanical claim: every layer that holds against attention is a layer the model re-reads fresh, from a place it didn't author.

Prompt and pray failed because the chat log isn't memory. The three-file workflow worked because guidelines lived in a file, loaded at position zero, every session. Module specs worked because "done" lived in a file the model couldn't redefine. BDD specs worked because the verification lived in a file the agent had to satisfy by driving a real browser. Three Amigos works because the scenarios are confirmed by a human before any code gets generated, and the sealed boundary works because the rule is enforced by the compiler, not by the model's memory of an instruction from forty turns ago.

Every step is the same move: take the thing the model would otherwise have to "remember," and put it somewhere it has to read.

The front gate is now closed. There's a separate problem on the back end — running specs aren't the same as a working application, and even the strictest spec can pass while a real bug ships. That's a different argument, in a different series.

---

[^1]: John Ferguson Smart, "The Anatomy of a Three Amigos Requirements Discovery Workshop." https://johnfergusonsmart.com/three-amigos-requirements-discovery/
[^2]: Cheparsky, "AI in Testing #10: Spec-Driven Development — BDD's Second Chance or Just More Docs?" https://medium.com/@cheparsky/ai-in-testing-10-spec-driven-development-bdds-second-chance-or-just-more-docs-151e30ecc97e
