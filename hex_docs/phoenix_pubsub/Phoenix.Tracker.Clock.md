# Phoenix.Tracker.Clock



## append_clock(clockset, arg)

Adds a replicas context to a clockset, keeping only dominate contexts.

## clockset_replicas(clockset)

Returns a list of replicas from a list of contexts.

## dominates?(c1, c2)

Checks if one clock causally dominates the other for all replicas.

## dominates_or_equal?(c1, c2)

Checks if one clock causally dominates the other for their shared replicas.

## filter_replicas(c, replicas)

Returns the clock with just provided replicas.

## lowerbound(c1, c2)

Returns the lower bound causal context of two clocks.

## replicas(c)

Returns replicas from the given clock.

## upperbound(c1, c2)

Returns the upper bound causal context of two clocks.