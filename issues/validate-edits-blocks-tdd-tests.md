# ValidateEdits Hook Blocks TDD Test File Writes

## Problem

The `ValidateEdits` stop hook runs tests against every file written during a session. When writing test files TDD-style (tests first, no implementation), the hook compiles and runs the tests, which fail with `UndefinedFunctionError` because the module under test doesn't exist yet. The hook then blocks the file write.

This defeats the TDD workflow where you write failing tests first, then implement the module to make them pass.

## Reproduction

1. Write a test file for a module that doesn't exist yet (e.g. `test/code_my_spec/agent_tasks/design_ui_test.exs` for `CodeMySpec.AgentTasks.DesignUi`)
2. The stop hook runs, compiles, and executes the tests
3. All tests fail with `UndefinedFunctionError` since the module is not available
4. Hook returns `block` decision, preventing the file from being saved

## Expected Behavior

Test files written for not-yet-implemented modules should be allowed through. The hook should recognize that `UndefinedFunctionError` for the module under test is expected in TDD mode.

## Possible Solutions

1. **Skip test execution for missing modules**: If the test file references a module that doesn't exist in `lib/`, skip running those tests and only validate syntax/compilation of the test file itself.
2. **Only compile-check test files**: For `_test.exs` files, only verify the test file parses/compiles (ignoring missing module errors), don't actually run the tests.
3. **Detect TDD context**: If no corresponding implementation file exists for a test file, skip the test run entirely.
4. **Separate compile from run**: Compilation errors in the test file itself (syntax errors) should block. Runtime errors from missing modules should not.

## Related

- `lib/code_my_spec/agent_tasks/validate_edits.ex` - the hook handler
- Also saw: `[ComponentTest] Error: "no function clause matching in CodeMySpec.AgentTasks.ComponentTest.check_tdd_state/2"` - suggests `check_tdd_state/2` has a missing clause, possibly related
