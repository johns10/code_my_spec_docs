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

## Rule: Analyzers and validators are configurable with four modes

- Engineer sets credo to off, credo does not run at all during stop hook
- Engineer sets exunit to block changed, test failures on untouched components don't block
- Engineer sets exunit to don't block, test failures are persisted but agent is allowed to stop
- Engineer sets spex to block all, spex runs on every stop and any failure blocks
- Engineer leaves spec_validation at default block_changed, stub spec files in the DB don't block turns that didn't touch them
- Engineer sets spec_validation to block_all, stub spec files in the DB block every turn until fixed
- Engineer sets spec_validation to off while in rapid prototyping, no spec validation runs
- Engineer sets qa_validation to dont_block, broken QA briefs are persisted but don't block the stop
- Engineer resets everything to defaults after a refactor is done

## Rule: ProjectConfiguration is created with defaults on first use

- First stop hook on a new project, ProjectConfiguration is created with defaults, pipeline works normally
- Engineer has never visited the config screen, everything behaves as if they set the defaults manually

