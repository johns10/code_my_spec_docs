# CodeMySpec.Qa.QaAttempts

CRUD + query module for QaAttempt. Public API: submit/2 (validates required fields, writes row, links parent_attempt_id), list/2 (most-recent-first per story_id, includes invalidation events), complete?/2 (true iff latest non-invalidated attempt on story has status :pass). Delegated to from CodeMySpec.Qa.

## Type

module
