# CodeMySpec.Validation

## Type

context

Validates files edited during Claude Code sessions. Parses transcripts to extract edited files, runs the generic validation pipeline, persists discovered problems, triggers a project sync, and evaluates agent tasks. Exposes two entry points — one for SubagentStop (component task from transcript marker) and one for Stop (session stack evaluation). Called from the hook controller.

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.Problems
- CodeMySpec.Problems.ProblemRenderer
- CodeMySpec.ProjectSync.Sync
- CodeMySpec.StaticAnalysis
- CodeMySpec.Tests
- CodeMySpec.Transcripts.ClaudeCode.FileExtractor
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Validation.TaskEvaluator

## Components

### CodeMySpec.Validation.TaskEvaluator

Evaluates agent tasks. Two entry points: `evaluate_component/2` resolves a component task from a transcript marker and delegates to the task module's `evaluate/3`. `evaluate_sessions/2` looks up sessions by external conversation ID, evaluates the session stack (highest priority), deletes passing sessions, and returns combined feedback for failures.
