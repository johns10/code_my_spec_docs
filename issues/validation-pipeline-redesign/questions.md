# Validation Pipeline — Questions

## Q: Analyzer blocking configuration UI

Each analyzer needs configurable blocking modes:
- off — don't run at all
- block all — run it, block on any violations
- block changed — run it, block only on violations touching changed files
- don't block — run it, persist problems, never block

This lives in AnalyzersLive in the local web app. Separate story.
Does not change task validation (RequirementCalculator), only the
stop hook blocking decision.

## Resolved: Spex defaults to off

Spex is too expensive to run on every stop. Defaults to off.
Task modules can opt in via analyzers/0 = [:spex_stale].
Future: configurable via the analyzer config UI.
