# BDD Specs for AI-Generated Code

Unit tests verify your code works. BDD specs verify your app does what users actually want.

## "Tests Pass" != "It Works"

Here's a pattern I see constantly. The AI generates code. It generates tests. The tests pass. You ship it. A user finds a bug that the tests should have caught.

The problem isn't that there are no tests. The problem is that the tests validate the AI's *interpretation* of what you wanted — not what you actually wanted. If the model misunderstands a requirement, it writes code that handles it wrong and tests that confirm the wrong behavior. Self-confirming loop. Tests pass. App is wrong.

Unit tests answer: "does this function return the expected output?" They don't answer: "does this application do what the user story said it should do?"

That's a different question entirely.

## One Scenario Per Acceptance Criterion

Every acceptance criterion on every user story becomes an executable BDD scenario. Not "the AI wrote some tests." Each test traces back to a specific criterion that a human approved.

A user story says: "When a driver's fuel card is swiped, the system sends an SMS notification within seconds." That story has acceptance criteria: SMS is sent on swipe, SMS contains the transaction amount and location, SMS includes a verification link, the link contains the right tokens, the system tracks delivery status.

Each of those criteria becomes its own spec file:

```
test/spex/373_sms_notification_with_pwa_link/
  criterion_3705_sms_sent_within_seconds_of_card_swipe_spex.exs
  criterion_3706_sms_contains_transaction_amount_location_timestamp_spex.exs
```

The directory is named after the story. Each file is named after the criterion. You can look at the file tree and know exactly what's being tested and why.

## How It Works

The specs use a given/when/then DSL that reads like the acceptance criteria they came from:

```elixir
spex "SMS sent within seconds of card swipe" do
  scenario "card processor sends authorization event and SMS is triggered" do
    given_ "a valid Stripe issuing_authorization.created webhook payload", context do
      # Sets up a realistic card swipe event
    end

    when_ "the card processor sends the webhook to our endpoint", context do
      conn = post(context.conn, "/api/webhooks/card-swipe", context.webhook_payload)
      {:ok, Map.put(context, :conn, conn)}
    end

    then_ "the webhook responds with success", context do
      assert json_response(context.conn, 200)
    end

    then_ "the response confirms an SMS notification was queued", context do
      response = json_response(context.conn, 200)
      assert response["sms_status"] in ["queued", "sent"]
    end
  end
end
```

The agent generates these specs from the user stories, not from the code. That's the key difference. The source of truth is what you told the system to build, not what it decided to build.

On Fuellytics — a fuel card management platform with fraud detection and Stripe Treasury — this produced 20+ story directories of BDD specs covering everything from SMS notifications to card locking to compliance controls. Over 31,000 lines of test code total.

## Write Them, Fix Them, Move On

The `WriteBddSpecs` agent picks the next story with incomplete criterion coverage and generates scenarios for every acceptance criterion. When specs fail, the `FixBddSpecs` agent gets structured feedback — which scenario failed, on which line, against which criterion — and fixes the implementation or the spec.

Specs must pass before the next step in the pipeline. The AI doesn't get to decide its own tests are good enough. The requirement system blocks progress until specs are green.

This is the automation that replaces manually clicking through the app after every change. Instead of "let me check if the SMS thing still works," the BDD suite checks it on every run against every criterion you defined.

## What This Catches (and What It Doesn't)

BDD specs catch requirement misunderstandings. They catch the case where the AI built something that technically works but doesn't match what the user story described. They catch regressions — when a change to one feature breaks a criterion on another story.

They don't catch everything. BDD specs test components through their APIs and interfaces. They don't open a browser and click through the full application the way a user would. They don't catch integration issues that only surface when multiple features interact in the running app.

That's a different layer of verification — [agentic QA](/pages/agentic-qa), where an AI agent tests the running application end-to-end with browser automation. BDD specs reduce how much QA has to catch. They don't eliminate it.

The combination is what works: BDD specs verify the app does what users want. QA verifies it actually does it in practice.
