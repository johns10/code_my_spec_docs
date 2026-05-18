# CodeMySpec.Qa.Invalidations

Invalidate action on a QaAttempt. Public API: invalidate/3 (validates non-empty reason, writes Invalidation row stamped with engineer scope id + timestamp, leaves original attempt unchanged). Delegated to from CodeMySpec.Qa. Per story 727 R4 + R7 (qa_complete re-clamp is a side effect of the checker reading current state, not orchestrated here).

## Type

module
