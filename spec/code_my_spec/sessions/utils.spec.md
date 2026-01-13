# CodeMySpec.Sessions.Utils

Utility functions for working with sessions and interactions.

This module provides helper functions for querying and analyzing session state, particularly for finding specific interactions within a session's interaction history.

## Dependencies

- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Interaction

## Delegates

None.

## Functions

### find_last_completed_interaction/1

Finds the last completed interaction in a session based on command timestamp.

```elixir
@spec find_last_completed_interaction(Session.t()) :: Interaction.t() | nil
```

**Process**:

1. Return nil if session status is :complete or :failed (terminal states)
2. Filter session interactions to only completed ones (those with a result)
3. Sort completed interactions by command timestamp in descending order
4. Return the first interaction (most recent) or nil if none found

**Test Assertions**:

- returns nil when session status is :complete
- returns nil when session status is :failed
- returns nil when session has no interactions
- returns nil when session has only pending interactions (no completed ones)
- returns the interaction with the most recent command timestamp when multiple completed interactions exist
- returns the single completed interaction when only one exists
- correctly handles interactions with identical timestamps
