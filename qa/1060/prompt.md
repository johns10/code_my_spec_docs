# QA Story 1060: The main agent answers what it can and escalates only what it cannot

Begin this review by calling `start_task` with requirement_name `qa_complete`,
entity_type `story`, and entity_id `1060`. Use the returned task ID
and review instructions. This captures the certified revision and submitted
fixes when QA actually starts. If readiness is blocked, finish the required
story work before beginning QA; do not test from an uncaptured prompt.
