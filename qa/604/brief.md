# Qa Story Brief

## Tool

web

## Auth

Register a fresh user via `/users/register` — the wizard requires a new user with zero accounts and zero projects. The QA seed user (`qa@codemyspec.local`) already has an account and project and will NOT trigger the wizard.

Steps to authenticate as a fresh user:
1. Navigate to `http://127.0.0.1:4000/users/register`
2. Fill the registration form with a unique email (e.g. `qa-wizard-test@example.com`)
3. Submit the form — this triggers a magic-link email
4. Navigate to `http://127.0.0.1:4000/dev/mailbox` to read the magic-link email
5. Click the magic-link token URL — this logs the user in and confirms their account
6. The user now has zero accounts and lands on `/app` in the account-creation state

No shell auth scripts are needed for this flow — the magic-link registration is done entirely in-browser via Vibium.

## Seeds

Run base seeds before testing:

```
mix run priv/repo/qa_seeds.exs
```

No story-specific seed beyond registration of a fresh user (done in-browser during the test).

## What To Test

### Scenario A: Account creation step (prerequisite)
- Navigate to `http://127.0.0.1:4000/users/register`
- Register with email `qa-wizard-604@example.com`
- Visit `/dev/mailbox`, grab magic-link URL, follow it
- Navigate to `http://127.0.0.1:4000/app` — expect the account-creation form (`#account_form`) to be visible
- Fill account name "QA Test Account" and submit
- Expect redirect back to `/app` showing the project-name form (`#project_form`)

### Scenario B: Multi-word name title-cases each word and strips spaces (criterion 5375)
- On the project-name step, type `my project` into `input[name='project[name]']`
- Observe the live preview (`[data-test="project-module-preview"]`) — expect to see `MyProject`
- Submit the form
- Navigate to `/app/projects`, find the created project link, navigate to `/app/projects/{id}/edit`
- Confirm the `input[name='project[module_name]']` has value `MyProject`

### Scenario C: Hyphenated name title-cases each segment as one word (criterion 5376)
- Register a second fresh user, create an account, then type `fuellytics-app` into the project-name input
- Observe the live preview — expect `FuellyticsApp`
- Submit and verify the edit page shows `module_name = FuellyticsApp`

### Scenario D: Leading number is stripped from derivation (criterion 5377)
- Register a third fresh user, create an account, then type `3rd party tool` into the project-name input
- Observe the live preview — expect `RdPartyTool`
- Submit and verify the edit page shows `module_name = RdPartyTool`

### Scenario E: All-punctuation name falls back to Project + short id (criterion 5378)
- Register a fourth fresh user, create an account, then type `!!!` into the project-name input
- Observe the live preview — it should show a value starting with `Project` followed by alphanumerics
- Submit and verify the edit page shows `module_name` matching `Project[A-Za-z0-9]+`

### Scenario F: Created project scoped to active account (criterion 5505)
- After project creation in Scenario B, navigate to `/app/projects`
- The newly-created project must appear in the account-scoped listing
- This confirms `account_id` was set to the user's active account

### Scenario G: Active project preference set to new project (criterion 5507)
- After project creation in Scenario B, navigate to `/app/issues` (a `:require_active_project` gated route)
- Expect: HTTP 200 or a redirect that does NOT go to `/projects/picker`
- A picker redirect here means the active_project preference was not set on creation

### Scenario H: User lands on /app after creation with no picker detour (criterion 5508)
- After submitting the project-name form in Scenario B, confirm the URL lands on `/app` (or within `/app/`)
- Navigate to the post-submit URL
- Confirm the page loads with 200 and does NOT redirect through `/accounts/picker` or `/projects/picker`

## Result Path

`.code_my_spec/qa/604/result.md`
