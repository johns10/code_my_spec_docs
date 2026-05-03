# Agentic QA

Unit tests and BDD specs verify pieces. QA verifies the running application — and an AI agent does it for you.

## Tests Aren't Enough

Unit tests check logic. [BDD specs](/blog/bdd-specs-for-ai-generated-code) check behavior against acceptance criteria. Neither opens a browser, hits your API, and clicks through the app like a user would.

That's a whole category of bugs that nobody catches until production. The kind where individual components work fine in isolation but break when the full system runs together. The kind where the API response shape is technically correct but the data inside it is wrong.

On Fuellytics — a fuel card management app we built with AI in about 5 active development days — QA agents found over 100 issues that passed all other tests. Including a fraud vulnerability that BDD specs explicitly marked as passing.

## Story QA

Every user story gets its own QA session against the running application. The agent:

1. Reads the story and its acceptance criteria
2. Writes a brief — what it plans to test and how
3. Executes the plan against the live app (API calls, browser automation)
4. Records results with evidence (responses, screenshots)
5. Files issues automatically for anything that fails

Every story gets QA'd. Not just the ones you remember to check.

Here's what this looks like in practice. Story 373 on Fuellytics is "SMS Notification with PWA Link" — when a driver swipes a fuel card, the system sends an SMS with a verification link. BDD specs for this story had 8 scenarios covering every acceptance criterion. All passed.

The QA agent tested the same story against the running app and found 4 bugs:

- **The API response had a hardcoded SMS body.** The actual SMS sent to drivers was correct — amount, location, verification link, everything. But the webhook API response always returned `"Verification SMS sent to driver"` instead of the real content. BDD specs tested the API response. QA tested what actually happened. Different answers.

- **SMS delivery tracking was broken for new transactions.** The webhook returned `sms_message_sid: "pending"` (hardcoded) instead of the real Twilio SID. Delivery status callbacks couldn't find the message. The tracking feature existed and worked — it just wasn't wired up to new transactions.

- **A fraud surface in the verification flow.** Yellow-flagged transactions (driver didn't respond within 6 minutes) cleared their flag when the driver *opened* the verification link — without submitting a photo. BDD specs tested that the flag cleared after "verification." QA revealed that visiting the URL was enough. No photo required. A flagged driver could clear the flag by tapping a link.

- **Two supposedly distinct tokens were identical.** The API returned both a `verification_token` and an `installer_auth_token` — same value for both. BDD specs only checked that both fields were non-empty. QA noticed they were the same string.

None of these would have been caught by unit tests. The BDD spec for the fraud vulnerability *explicitly passed* — the spec's definition of "verify" was too loose.

## Journey QA

Story QA tests one story at a time. Journey QA tests paths through the app that span multiple features.

The agent plans end-to-end journeys: register an account → create a fuel card → trigger a card swipe → receive SMS notification → verify via PWA → check fraud detection dashboard → lock a card → verify the lock holds. Each journey crosses multiple stories and multiple contexts.

Then it executes those journeys against the live application with browser automation. It's testing the same paths a real user would take — not isolated API calls, but the full flow through the UI.

This is where integration bugs surface. The kind where the accounts system and the card system and the notification system all work individually but break at the seams.

## From Journeys to Regression Tests

Passing QA journeys get converted into permanent Wallaby browser tests. What started as exploratory QA by an agent becomes your regression suite.

Next time a change breaks a journey that used to work, you know immediately. Not because someone remembered to manually test it. Because the regression test caught it.

## The Issues Pipeline

QA findings don't just get logged — they become structured issue records. Each issue has severity, reproduction steps, root cause analysis, and a suggested fix. Issues get triaged into accepted (real bug, needs fixing), dismissed (not a bug or won't fix), or incoming (needs review).

Accepted issues feed back into the development backlog. A different agent picks them up and fixes them. The agent that found the bug files the ticket. The agent that fixes it references the ticket. The loop closes.

On Fuellytics, over 100 issues went through this pipeline across 30+ stories. The QA campaign ran as a concentrated push — a day of story QA producing briefs, results, screenshots, and issues that fed directly into the next round of development.

## What This Makes Possible

We submitted Fuellytics for Stripe Treasury production access. That's a serious approval process — they review your fraud controls, compliance handling, and financial operations.

We were confident in the submission because QA told us exactly what worked and what didn't. Not "we think the fraud detection works." Not "tests pass." The QA agent tested every story against the running app and filed issues for everything it found. We fixed them. We know what state the application is in because the evidence is sitting in 30+ result documents with screenshots and reproduction steps.

That's the difference between "it should work" and "here's the proof."
