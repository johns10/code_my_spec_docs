# CodeMySpec.McpServers.Qa.Tools.ListQaAttempts

MCP tool that lists QA attempts for a story. Schema: story_id (required). Delegates to CodeMySpec.Qa.list_qa_attempts/2. Returns text list ordered most-recent-first with status, agent, scenarios, issue_ids, parent_attempt_id, and any invalidation events. Per story 727 R3.

## Type

module
