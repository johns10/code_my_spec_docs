# Naive BDD: the tests ran, the tests passed, the app didn't work

_Part 5 of the [BDD Attention Thesis](/blog/bdd-attention-thesis). Previous: [Part 4: Spec Files](/blog/bdd-attention-spec-files)._

---

I found BDD. The format was right — Given/When/Then scenarios, structured tightly enough that the interpretation gaps closed, executable against a real browser. No translation step between "spec says X" and "X is verified in the running application." This was the thing I'd been missing.

So I wrote the acceptance criteria and let the model write the BDD specs from them.

## What naive BDD looked like

The model was good at the format. Give it acceptance criteria and it would produce syntactically correct feature files, step definitions, the full Wallaby test structure. The specs compiled. The tests ran. A lot of them passed.

The problem I didn't see coming: the model was writing specs it knew how to pass. Not specs that verified the feature. Specs it could make green.

## The Potemkin village

I built a full Phoenix LiveView analytics platform — MetricFlow — using this approach. Thirteen working days of actual development. Fifty-one stories, over four hundred acceptance criteria, fifty-plus BDD spec files. The specs ran against the real application. Most of them passed.

The integrations didn't work. Not in a "some edge cases fail" way. In a "you click Connect Google and nothing actually connects" way.

The coding agent would hit a `FunctionClauseError` in the OAuth callback. Instead of fixing the underlying bug, it would wrap the failure in a try/catch, render a flash message saying "Connection successful," and return a 200. The test suite would check for the flash message. It would find it. The spec would pass.

The QA agent — a separate agent running the browser scenarios — would test the same story. It would see the flash message. It would mark the scenario passing.

Two agents, each doing exactly what they were built to do, producing a Potemkin village of green tests over completely broken functionality. I watched this happen. The QA agent told me over and over that QA passed. I'd go click through the integrations manually and find nothing worked.

The integrations took more QA iterations than every other feature combined. Connecting marketing platforms via OAuth: six failed runs before passing. Managing integrations: seven. Triggering data sync: twelve failed runs across two days. Every time a human sat down and actually used the app, bugs surfaced that the specs hadn't caught — because the specs had been written to match what the model was building, not to verify what the feature was supposed to do.

## Ambiguity compounding

The second failure was slower and harder to see.

A vague acceptance criterion produced a vague BDD scenario. The vague scenario produced vague step definitions. The vague step definitions produced code that technically satisfied the scenario but didn't do what anyone actually wanted.

The Google integration is the clearest example. The acceptance criterion said something like "a user can connect their Google account." The model wrote a spec that verified you could go through an OAuth flow and land on a success page. The spec passed. What it didn't verify: that the OAuth scopes were correct, that each Google product (Ads, Analytics, Search Console) had its own separate authorization flow, that the token was being stored in a way the data sync could actually use.

The spec said "connect Google" and it connected Google. In the loosest possible interpretation of those words.

Every ambiguity in the acceptance criteria flowed forward. The spec inherited it. The step definitions inherited it from the spec. The implementation inherited it from the steps. By the time the QA agent was running scenarios, the ambiguity had compounded through three layers. When a scenario failed, fixing it meant tracing all the way back to the original story and asking: what did we actually mean by this?

## What was missing

What was wrong was where the human showed up in the process. I was writing acceptance criteria — which are always loose — and then handing the spec-writing entirely to the model. The model produced specs that were faithful to the ACs and passable by the code it was generating. The human review happened after the specs were written, after the code was generated, after the tests were already passing.

By then, I was staring at green tests and a broken app, trying to figure out which layer the problem lived in.

The gate needed to be earlier. Not "review the passing specs" but "review the scenarios before a single line of code is generated." A structured step where a human looks at the concrete examples — Given this state, when a user does this, then they see this specific thing — and says: yes, that's what I meant, or no, that's not what I meant at all.

That step exists. It has a name.

**Continue to [Part 6: Three Amigos](/blog/bdd-attention-three-amigos).**
