# Use Wallaby for browser-based integration testing

## Status
Superseded by [BDD testing](bdd-testing.md)

## Context
We need a way to drive a real browser for end-to-end testing that handles LiveView's async rendering and integrates with Ecto's sandbox for database isolation.

## Decision
Use Wallaby (`wallaby`) with ChromeDriver for all browser-based integration tests. It provides concurrent test execution, automatic retry/wait for async content (critical for LiveView), Ecto sandbox integration via user_agent metadata, and a clean DSL for interacting with pages (visit, fill_in, click, assert_has).

## Consequences
This was a pre-made decision for the standard CodeMySpec stack. It is no longer in
effect: `wallaby` is not a dependency of this project, and of 609 spex files that
drive the UI, zero reference it.

The premise did not survive contact. A spex asserts on what a *user* can see, and
`Phoenix.LiveViewTest` reaches that through the LiveView process directly — no
ChromeDriver to install, no browser to keep alive across a suite, and the Ecto
sandbox works without user-agent metadata because the test and the view share a
process tree. Real-browser work still exists, but it belongs to QA against the
running application rather than to the suite. See [BDD testing](bdd-testing.md).
