# CodeMySpec.McpServers.Qa.Tools.InvalidateQaAttempt

MCP tool that invalidates a passed QaAttempt. Schema: attempt_id (required), reason (required, non-empty). Delegates to CodeMySpec.Qa.invalidate_qa_attempt/3. Returns invalidation_id in text response. Rejects empty reason at tool boundary per story 727 R4 (criterion 6457 failure path).

## Type

module
