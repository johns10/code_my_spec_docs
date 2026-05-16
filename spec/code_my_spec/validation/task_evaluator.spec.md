# CodeMySpec.Validation.TaskEvaluator

Evaluates agent tasks. Two entry points for the two hook events: `evaluate_component/2` resolves a component task from a transcript marker and delegates to the task module's `evaluate/3` (SubagentStop). `evaluate_sessions/2` looks up sessions by external conversation ID, evaluates the session stack at highest priority, deletes passing sessions, and returns combined feedback for failures (Stop).

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Sessions
- CodeMySpec.Sessions.SessionType
- CodeMySpec.Transcripts.TaskIdentifier
- CodeMySpec.Utils
