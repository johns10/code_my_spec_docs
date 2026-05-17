# QA Result — Story 124: Project Setup

## Status

pass

## Scenarios

### Scenario 1: Page loads and renders correctly — PASS

Navigated to `/projects/code-my-spec/requirements/project_setup`. The page loaded
without errors, rendering the requirement name `PROJECT_SETUP` and description
"Project bootstrap setup is complete".

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_project_setup_main.png`

### Scenario 2: Progress counter renders in N/12 format — PASS

Three projects tested to cover different completion states:
- code-my-spec (fully configured): renders `Project Setup (12/12)` in the header
- qa-fixture-project (no files configured): renders `Project Setup (0/12)`
- math-test-project (2 steps incomplete): renders `Project Setup (10/12)`

All three cases correctly show the `N/12` format in the progress header.

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_project_setup_main.png`,
`.code_my_spec/qa/124/screenshots/4003_124_qa_project_setup_incomplete.png`,
`.code_my_spec/qa/124/screenshots/4003_124_math_project_partial.png`

### Scenario 3: All 12 step names are present on the page — PASS

Verified all 12 step names appear on the page for the code-my-spec project:
Application in web, Codemyspec deps, Compilers, Spex config, Test boundaries,
Test support namespace, Spex case, Project structure, Agents md, Rules,
Credo checks, Claude md.

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_project_setup_main.png`

### Scenario 4: Completed steps show no inline prompt heading — PASS

For the code-my-spec project (12/12), all steps render as checkbox list items
with `checked=""` attribute. No inline prompt headings appear for any completed step.

For the math-test-project (10/12), the 10 completed steps render with checked
checkboxes only. No prompt headings appear for those steps.

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_math_project_partial.png`

### Scenario 5: Incomplete steps show inline prompt text — PASS

For the qa-fixture-project (0/12), all 12 steps render with their full prompt
instructions inline on a single page — one prompt per incomplete step.

For the math-test-project (10/12), only the 2 incomplete steps (Codemyspec deps and
Spex case) render with their prompts inline. Verified:
- "ADD CODEMYSPEC DEPENDENCIES" prompt appears after the Codemyspec deps checkbox
- "CREATE SPEX CASE MODULE" prompt appears after the Spex case checkbox

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_qa_project_setup_incomplete.png`,
`.code_my_spec/qa/124/screenshots/4003_124_math_project_partial.png`

### Scenario 6: No setup-error banner on happy path — PASS

For both the fully-complete code-my-spec project (12/12) and the fully-incomplete
qa-fixture-project (0/12), no `[data-role="setup-error"]` element is present in the
DOM. The `:if={@setup_error}` guard prevents rendering when the assign is nil.

### Scenario 7: Step detail page navigation — PASS

Tested two step detail pages:
- `/projects/code-my-spec/requirements/project_setup/rules` — renders "RULES" heading,
  "INSTALL DEFAULT RULES" instruction, "Back to project_setup" link
- `/projects/code-my-spec/requirements/project_setup/compilers` — renders "COMPILERS"
  heading, "CONFIGURE COMPILERS" with syntax-highlighted code, "Back to project_setup" link

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_step_detail_rules.png`,
`.code_my_spec/qa/124/screenshots/4003_124_step_detail_compilers.png`

### Scenario 8: Error banner for step command errors — NOT TESTABLE VIA BROWSER

Criterion 5268 requires injecting a stub step via `Application.put_env` — an
in-process BEAM operation only possible in test context. The code path exists:
`handle_show_for_project` assigns `setup_error: inspect(reason)` when `command/2`
errors. The `[data-role="setup-error"]` element appears in the template gated by
`:if={@setup_error}`. Cannot trigger via browser-based QA.

### Scenario 9: Invalid step ID error handling — PASS

Navigated to `/projects/qa-fixture-project/requirements/project_setup/nonexistent_step`.
The page renders a red error banner "Step not found: nonexistent_step" using the
standard error element. No crash, no blank page.

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_nonexistent_step.png`

## Evidence

- `.code_my_spec/qa/124/screenshots/4003_124_project_setup_main.png` — code-my-spec project, 12/12 complete
- `.code_my_spec/qa/124/screenshots/4003_124_qa_project_setup_incomplete.png` — qa-fixture-project, 0/12 complete
- `.code_my_spec/qa/124/screenshots/4003_124_qa_project_top.png` — qa-fixture-project, 0/12 full page
- `.code_my_spec/qa/124/screenshots/4003_124_step_detail_rules.png` — Rules step detail page
- `.code_my_spec/qa/124/screenshots/4003_124_step_detail_compilers.png` — Compilers step detail page
- `.code_my_spec/qa/124/screenshots/4003_124_nonexistent_step.png` — Invalid step ID error
- `.code_my_spec/qa/124/screenshots/4003_124_math_project_partial.png` — math-test-project, 10/12 partial
- `.code_my_spec/qa/124/screenshots/4003_124_math_project_partial_full.png` — math-test-project, 10/12 full page
- `.code_my_spec/qa/124/screenshots/4003_124_init_page.png` — Init page showing breadcrumb issue

## Issues

### InitLive breadcrumb path indicator shows /overview instead of /init

#### Severity
LOW

#### Scope
APP

#### Description
When navigating to `/projects/code-my-spec/init`, the header prompt strip shows:
`~/Documents/github/code_my_spec :: /overview`

The path indicator should show `/init` to reflect the current section. This occurs
because `InitLive` does not pass a `section` attribute to `Layouts.app`, so
`section_path(nil)` falls back to `"/overview"` (defined in `layouts.ex`).

The `RequirementsLive` correctly passes `section={section_for(@live_action)}` and the
prompt strip shows `/requirements`. The `InitLive` omits the `section:` assign entirely.

Steps to reproduce:
1. Navigate to `http://127.0.0.1:4003/projects/code-my-spec/init`
2. Observe the prompt strip in the header: shows `:: /overview` instead of `:: /init`

Expected: `:: /init` or `:: /project-init`
Actual: `:: /overview`

Evidence: `.code_my_spec/qa/124/screenshots/4003_124_init_page.png`
