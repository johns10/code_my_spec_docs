# How CodeMySpec Built and Verified a Fuel Card App in 5 Days

We generated a fuel card management app — card swipes, SMS verification, fraud detection, the works. The git log spans 6 calendar weeks. The actual generation happened in about 5 active days. Here's how we verified it wasn't a house of cards.

## What Is Fuellytics and What Does It Do?

Fuellytics manages fuel cards for fleet operations. A driver swipes a card at the pump, gets an SMS, photographs their odometer through a mobile PWA, and the system runs fraud checks — GPS validation, odometer cross-referencing, duplicate detection, consecutive violation tracking that auto-locks cards.

We later added Stripe Treasury so customers could fund their expense accounts, along with billing and compliance controls to support that. It's currently in UAT, waiting on Stripe production approval for Treasury.

None of the code was written by hand. CodeMySpec generated it from specifications using Claude Code.

## How Long Did It Actually Take to Build?

The bursts came from getting CodeMySpec working, then pointing it at Fuellytics:

- **Feb 19-21**: Core app — accounts, auth, drivers, vehicles, fuel cards, SMS notifications, fraud detection, PWA verification. 29 commits in 3 days.
- **Feb 23**: QA blitz. CodeMySpec churned out the app fast, but it churned out broken stuff too. We built QA and pointed it at every story. 10 commits.
- **Feb 25-27**: Multi-tenancy, Stripe Issuing, reports, deployment. 10 commits.
- **Mar 6**: Realized we couldn't release to customers without Treasury — people need to fund their expense accounts. Built Treasury, billing, and compliance in another burst. 5 commits.

About 5 active development days. 55 commits total. The weeks between were spent improving CodeMySpec to handle what Fuellytics needed next.

## What Is the Hardest Part of AI-Generated Code?

Here's the thing nobody talks about yet. The hard part of AI-generated code isn't generating it. Generation is trivial now. The hard part is managing the velocity.

CodeMySpec can produce a full context — schema, repository, LiveView, tests, BDD specs — in minutes. But if you let it run unchecked, you get 100,000 lines of code that compiles, passes its own tests, and doesn't actually work. The agent moves so fast that verification becomes the bottleneck, not development.

In the age of AI, development is about managing the velocity of the agent. Before, we were trying to build faster. Now building is the easy part. The question is: how do you keep up with what the agent produces?

## How Do BDD Specs Verify That AI Code Does What Users Want?

Every acceptance criterion on every user story became an executable [BDD spec](/pages/bdd-specs-for-ai-generated-code). The SMS notification story alone had 8 criteria — SMS sent on swipe, contains the right content, includes a verification link, tracks delivery status, flags unresponsive drivers, clears flags on late verification.

Each criterion became its own spec file:

```
test/spex/373_sms_notification_with_pwa_link/
  criterion_3705_sms_sent_within_seconds_of_card_swipe_spex.exs
  criterion_3706_sms_contains_transaction_amount_location_timestamp_spex.exs
  ...8 files total
```

20+ story directories. Over 31,000 lines of test code. Generated from the user stories, not from the code. Human intent was the source of truth.

When specs failed, a different agent got structured feedback — which scenario, which line, which criterion — and fixed either the implementation or the spec. Specs had to pass before the next step. No exceptions.

## How Does Agentic QA Catch Bugs That BDD Specs Miss?

BDD specs caught requirement misunderstandings. But they test through APIs and interfaces. They don't open a browser and use the app like a human would.

So we ran [agentic QA](/pages/agentic-qa) — an AI agent that tests every story against the running application. It writes a brief, executes the plan, records results with evidence, and files issues for anything that fails.

This is where things got interesting.

Story 373 — the SMS notification flow — had all 8 BDD specs passing. The QA agent tested the same story against the live app and found 4 bugs. The worst one: a fraud vulnerability where yellow-flagged drivers could clear their flag by tapping a link without submitting a photo. The BDD spec for it *explicitly passed* — the spec's definition of "verify" was too loose.

That's a bug no unit test would ever catch. And the BDD spec confirmed it was fine.

Across the full QA campaign — 30+ stories tested against the running application — over 100 issues were found, filed with severity and reproduction steps, and triaged. A concentrated push that fed directly into the next round of fixes.

## Why Is No Single Layer of Testing Enough for AI-Generated Code?

Here's what building Fuellytics taught us: no single layer of testing is enough.

**Unit tests** catch implementation errors. They don't know what the user wanted.

**BDD specs** catch requirement misunderstandings. They don't test the running application.

**Story QA** catches bugs that only surface in the real environment. It doesn't test paths across features.

**Journey QA** tests end-to-end flows — register, create a card, trigger a swipe, verify, check fraud dashboard, lock a card. It catches the seam bugs between features.

Each layer catches a different category of bug. Skip one and that category ships to production.

The agent generates code at a pace that makes all of this necessary. Not optional. Not nice-to-have. The verification system is how you keep up with the velocity. It's how you turn "the AI built something" into "the AI built the right thing."

## Where Does the Project Stand Now?

Fuellytics is in UAT. We submitted for Stripe Treasury production access — they review fraud controls, compliance handling, and financial operations before approving.

We were confident in the submission because we have evidence. Not "we think the fraud detection works." 30+ QA result documents with screenshots and reproduction steps. 100+ issues found, triaged, and fixed. Every acceptance criterion on every story tested both as a BDD spec and against the running application.

Five days of generation. Verification is what made it real.

## Frequently Asked Questions

**Can AI really generate a production-ready application in 5 days?** AI can generate the code in 5 days, but the code alone is not production-ready. What makes it production-ready is the verification pipeline -- BDD specs, agentic QA, and journey testing -- that catches the bugs the generator inevitably introduces. Without verification, you have 100,000 lines of code that compiles but does not work correctly.

**What is the difference between BDD specs and agentic QA?** BDD specs are executable tests generated from user story acceptance criteria that verify behavior through APIs and interfaces. Agentic QA is an AI agent that tests the same stories against the running application the way a human would, opening browsers, clicking buttons, and filing issues for anything that fails. BDD specs catch requirement misunderstandings while agentic QA catches bugs that only surface in the real environment.

**How many bugs did the QA process find in Fuellytics?** The full QA campaign across 30+ stories found over 100 issues, each filed with severity and reproduction steps. Even stories where all 8 BDD specs passed had bugs discovered by the QA agent, including a fraud vulnerability where flagged drivers could clear their flag without submitting verification photos.

**Why do you need multiple layers of testing for AI-generated code?** Each testing layer catches a different category of bug. Unit tests catch implementation errors. BDD specs catch requirement misunderstandings. Story QA catches bugs in the running application. Journey QA catches seam bugs between features. Skip any one layer and that entire category of bug ships to production.

**How does CodeMySpec manage the velocity of AI code generation?** CodeMySpec enforces a stop-and-validate loop after every task. The agent generates code, a validation hook fires automatically, and structured feedback is returned for any failures. The agent must address the feedback before moving on. This turns uncontrolled velocity into a disciplined build-verify-fix cycle.
