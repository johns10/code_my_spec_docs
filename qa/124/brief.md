# Qa Story Brief

## Tool

web

## Auth

None. Navigate directly to `http://127.0.0.1:4003/projects/code-my-spec/requirements/project_setup`.
The local web (port 4003) uses `LocalOnly` plug with no user authentication.

## Seeds

No seeds needed. The `code-my-spec` project exists in the local SQLite DB.
For incomplete-step scenarios, use the `qa-fixture-project` project (already seeded
in the running dev DB with `local_path` pointing to a non-existent directory,
causing all 12 setup steps to be incomplete).

## What To Test

- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/requirements/project_setup`
  and verify the page renders `Project Setup (12/12)` in the progress header
- Verify all 12 step names appear: Application in web, Codemyspec deps, Compilers,
  Spex config, Test boundaries, Test support namespace, Spex case, Project structure,
  Agents md, Rules, Credo checks, Claude md
- Verify that all 12 steps are shown as checked (no inline prompts rendered)
- Navigate to `http://127.0.0.1:4003/projects/qa-fixture-project/requirements/project_setup`
  and verify the page renders `Project Setup (0/12)` in the progress header
- Verify that all 12 steps show their inline prompt instructions (no step is skipped)
- Verify no `[data-role="setup-error"]` banner appears on either page (happy path)
- Navigate to a step detail page such as
  `http://127.0.0.1:4003/projects/code-my-spec/requirements/project_setup/rules`
  and verify the step name, instructions, and "Back to project_setup" link render correctly
- Navigate to a partial completion project such as
  `http://127.0.0.1:4003/projects/math-test-project/requirements/project_setup`
  and verify the progress counter reflects the actual number of completed steps

## Result Path

`.code_my_spec/qa/124/result.md`
