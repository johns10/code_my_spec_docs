# CodeMySpec.Qa.Invalidation

Audit event recording that an engineer invalidated a QaAttempt. Fields: id, qa_attempt_id (fk), invalidated_by_user_id, reason (non-empty string), invalidated_at. Append-only audit row; the original attempt is preserved. Per story 727 R4.

## Type

schema
