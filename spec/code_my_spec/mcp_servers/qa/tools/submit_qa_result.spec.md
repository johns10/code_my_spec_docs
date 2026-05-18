# CodeMySpec.McpServers.Qa.Tools.SubmitQaResult

MCP tool that submits a QA outcome. Schema: task_id (required), status (required: pass | partial | fail), scenarios (required, list of %{name, status, observation}), issue_ids (optional, list of uuid). Delegates to CodeMySpec.Qa.submit_qa_result/2. Returns attempt_id in text response. Per story 726 R1-R7.

## Type

module
