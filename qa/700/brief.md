# Qa Story Brief

## Tool

web (Vibium MCP browser tools — all scenarios test LiveView at `/app` on port 4000)

## Auth

Use password login for the QA seed user and magic-link login for fresh-user scenarios.

**QA seed user (existing account + project):**
1. Navigate to `http://127.0.0.1:4000/users/log-in`
2. Fill the password form (bottom form on page): `form[action="/users/log-in"] input[name='user[email]']` → `qa@codemyspec.local`
3. Fill `form[action="/users/log-in"] input[name='user[password]']` → `qa-password-123!`
4. Submit

**Fresh user (no account, no project):**
1. Register a new email at `http://127.0.0.1:4000/users/register`
2. Fill the magic-link email form with the new address and submit
3. Visit `http://127.0.0.1:4000/dev/mailbox` to read the confirmation/login token
4. Navigate to the token URL (replacing `dev.codemyspec.com` with `127.0.0.1:4000` in the link)

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

This creates `qa@codemyspec.local` (password `qa-password-123!`) with account `qa-account` and project `QA Fixture Project`. The seed is idempotent.

For fresh-user scenarios (criteria 6051, 6055, 6056, 6057): register a brand-new email address during the test session (e.g. `qa-700-fresh-<timestamp>@codemyspec.local`).

For the "account-only" scenario (criterion 6053): after registering and confirming, create an account but stop before creating a project.

For the "CLI ever connected" scenario (criteria 6054, 6058): the QA seed user (`qa@codemyspec.local`) may have `cli_first_connected_at` already set if a prior CLI session has ever joined. Check `[data-test='application-rung'][data-state='active']` vs `[data-state='pending']` on mount. If not yet set, a new fresh user who goes through account + project creation and then has a CliChannel join is the correct path — but for browser QA this state is hard to drive without a real CLI. Instead, check the source-level logic: `active_step` returns `:application` when `cli_ever_connected?` is true. Inspect the qa seed user's state from the running app to determine if plugin step is already done.

## What To Test

### Scenario 1 — Newly registered user sees all four steps in order (criterion 6051)

1. Register a fresh account at `http://127.0.0.1:4000/users/register` with a unique email (e.g. `qa-700-fresh@codemyspec.local`)
2. Complete confirmation via `/dev/mailbox` magic link
3. Navigate to `http://127.0.0.1:4000/app`
4. Screenshot the page
5. Assert all four rungs are present in DOM: `[data-test='account-rung']`, `[data-test='project-rung']`, `[data-test='plugin-rung']`, `[data-test='application-rung']`
6. Assert they appear in document order (account → project → plugin → application) by checking that the eyebrow text "step 01", "step 02", "step 03", "step 04" appears in order in the page text
7. Assert each rung's eyebrow contains the step number and name: "step 01" + "account", "step 02" + "project", "step 03" + "plugin", "step 04" + "application"

### Scenario 2 — Mid-journey user sees done/active/pending states side by side (criterion 6052)

1. Log in as `qa@codemyspec.local` — this user has an account and a project (project rung done), but plugin rung status depends on whether CLI has ever connected
2. Navigate to `http://127.0.0.1:4000/app`
3. Screenshot the page
4. Assert `[data-test='account-rung'][data-state='done']` is present
5. Assert `[data-test='project-rung'][data-state='done']` is present
6. Assert `[data-test='plugin-rung'][data-state='active']` is present (plugin is the first incomplete step for a user with account + project but no CLI)
7. Assert `[data-test='application-rung'][data-state='pending']` is present
8. Note: this scenario requires the seed user has NOT had a CLI connect. If the qa seed user already has `cli_ever_connected? = true`, use a different fresh user who has only account + project.

### Scenario 3 — Account-only user has project as active step (criterion 6053)

1. Register a fresh user, confirm via magic link
2. Navigate to `http://127.0.0.1:4000/app` — account rung should be active
3. Create an account by filling the account form ("QA Test Account 700") and submitting
4. After push_navigate back to `/app`, screenshot the page
5. Assert `[data-test='account-rung'][data-state='done']` — account is done
6. Assert `[data-test='project-rung'][data-state='active']` — project is the active step
7. Assert `[data-test='plugin-rung'][data-state='pending']` — plugin not yet reached
8. Assert `[data-test='application-rung'][data-state='pending']` — application not yet reached
9. Assert no other rung carries `data-state='active'`

### Scenario 4 — User with all server-side setup done has application as active step (criterion 6054)

1. Check if `qa@codemyspec.local` has `cli_ever_connected? = true` by navigating to `/app` and checking `[data-test='plugin-rung'][data-state='done']`
2. If the plugin rung is done (CLI has connected before), assert `[data-test='application-rung'][data-state='active']`
3. If not, proceed with the same fresh user from Scenario 3 after creating a project, and note that driving an actual CLI channel join from the browser QA is not possible — document the state reached and note criterion 6054 requires a real CliChannel join that is only testable via spex/unit tests
4. Screenshot whatever state is reached

### Scenario 5 — Every step renders with chamfered shell and step-N eyebrow (criterion 6055)

1. Use the fresh user from Scenario 1 (no account, all four rungs visible with account active)
2. Navigate to `http://127.0.0.1:4000/app`
3. Screenshot the page
4. For each rung, check that it carries the `cms-onboarding` class: `[data-test='account-rung'].cms-onboarding`, `[data-test='project-rung'].cms-onboarding`, `[data-test='plugin-rung'].cms-onboarding`, `[data-test='application-rung'].cms-onboarding`
5. Check page text for "// step 01", "// step 02", "// step 03", "// step 04" in the rendered content
6. Note: the plugin rung in active/done state wraps in a `<div class="contents">` wrapper; the inner `#cms-onboarding-card` carries the class. Check both selectors if needed.

### Scenario 6 — Pending project step renders without a submittable form (criterion 6056)

1. Use the fresh user (no account) from Scenario 1 at `/app`
2. Screenshot the page (account form is active; project form should be absent)
3. Assert `[data-test='project-rung'][data-state='pending']` is present
4. Assert `form#project_form` is NOT present in the DOM
5. Assert `input[name='project[name]']` is NOT present in the DOM

### Scenario 7 — Pending application step does not navigate when clicked (criterion 6057)

1. Use the fresh user (no account) from Scenario 1 at `/app`
2. Screenshot the application rung
3. Assert `[data-test='application-rung'][data-state='pending']` is present
4. Get the rendered HTML of `[data-test='application-rung']` and confirm it does NOT contain `href="http://localhost:4003"` (the rung is a `<div>`, not an `<a>` tag)
5. Confirm the element does not carry any href attribute pointing to the local workspace

### Scenario 8 — Active application step opens local workspace in new tab (criterion 6058)

1. This requires a user with account + project + CLI ever connected (`cli_ever_connected? = true`)
2. If `qa@codemyspec.local` has plugin rung as "done", proceed; otherwise note limitation
3. Navigate to `http://127.0.0.1:4000/app`
4. Screenshot the page
5. Assert `a[data-test='application-rung'][href^='http://localhost:4003']` is present (the rung is an anchor tag)
6. Get the rendered HTML of `[data-test='application-rung']` and confirm `target="_blank"` is present
7. Confirm `noopener` is present in the `rel` attribute

## Result Path

`.code_my_spec/qa/700/result.md`
