# Project Configuration — Examples

## Rule: All quality gate configuration is local to the engineer's machine

- Engineer opens the local web UI and sees configuration for their project
- Configuration persists across sessions (stored in local SQLite)
- Two engineers on the same project can have different configurations

## Rule: Requirement toggles control the requirements graph

- Engineer turns off require_specs, components no longer need spec files to be done
- Engineer turns off require_reviews but keeps require_specs, spec required but design review is not
- Engineer turns off require_unit_tests, test file and tests_passing requirements disappear from graph
- Engineer turns everything off for rapid prototyping, only implementation file is required
- Engineer turns require_unit_tests back on, test requirements reappear for all components

## Rule: Compile always runs, warning blocking is configurable

- Engineer has compile_warnings set to block, agent gets blocked on unused variable warning
- Engineer turns off compile_warnings blocking, agent is allowed to stop with warnings
- Agent introduces a syntax error, blocked regardless of warning setting

## Rule: Expensive analyzers are configurable with four modes

- Engineer sets credo to off, credo does not run at all during stop hook
- Engineer sets exunit to block changed, test failures on untouched components don't block
- Engineer sets exunit to don't block, test failures are persisted but agent is allowed to stop
- Engineer sets spex to block all, spex runs on every stop and any failure blocks
- Engineer resets everything to defaults after a refactor is done

## Rule: ProjectConfiguration is created with defaults on first use

- First stop hook on a new project, ProjectConfiguration is created with defaults, pipeline works normally
- Engineer has never visited the config screen, everything behaves as if they set the defaults manually

## Rule: Cheap static validations always run and block on changed files

- Agent modifies a spec file with a missing required section, blocked
- Agent modifies an implementation file, no spec validation runs (wrong role)
- Spec validation finds issues on an untouched file, agent is not blocked
