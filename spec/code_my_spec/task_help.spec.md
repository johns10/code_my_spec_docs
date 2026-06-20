# CodeMySpec.TaskHelp

Read-only context that resolves per-task help content for the agent progress view. Maps an agent task type to `.code_my_spec/content/<task_type>.md` (curated body) plus its `.yaml` sidecar (`video_url`), returning the curated help for major task types and signalling a generic fallback otherwise. Reads through the scope environment.

## Type

context
