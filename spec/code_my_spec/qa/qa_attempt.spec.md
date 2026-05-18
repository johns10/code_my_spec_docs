# CodeMySpec.Qa.QaAttempt

Immutable QA attempt row. Fields: id, story_id, status (:pass | :partial | :fail), scenarios (list of embedded Scenario), issue_ids (list of uuid), agent_id, parent_attempt_id (nullable, links to prior attempt on same story), submitted_at. Append-only — never mutated after insert. Per story 727 R1.

## Type

schema
