# Phoenix.Tracker.State



## clocks(state)

Returns the causal context for the set.

## compact(state)

Compacts a sets causal history.

Called as needed and after merges.

## delta_size(state)

Returns the dize of the delta.

## extract(state, remote_ref, remote_context)

Extracts the set's elements from ets into a mergeable list.

Used when merging two sets.

## get_by_key(state, topic, key)

Returns a list of elements for the topic who belong to an online replica.

## get_by_pid(state, pid)

Returns all elements for the pid.

## get_by_pid(state, pid, topic, key)

Returns the element matching the pid, topic, and key.

## get_by_topic(state, topic)

Returns a list of elements for the topic who belong to an online replica.

## has_delta?(state)

Checks if set has a non-empty delta.

## join(state, pid, topic, key, meta \\ %{})

Adds a new element to the set.

## leave(state, pid)

Removes all elements from the set for the given pid.

## leave(state, pid, topic, key)

Removes an element from the set.

## leave_join(state, pid, topic, key, meta)

Updates an element via leave and join.

Atomically updates ETS local entry.

## merge(local, remote)

Merges two sets, or a delta into a set.

Returns a 3-tuple of the updated set, and the joined and left elements.

## Examples

    iex> {s1, joined, left} =
         Phoenix.Tracker.State.merge(s1, Phoenix.Tracker.State.extract(s2))

    {%Phoenix.Tracker.State{}, [...], [...]}

## new(replica, shard_name)

Creates a new set for the replica.

## Examples

    iex> Phoenix.Tracker.State.new(:replica1, :shard_name)
    %Phoenix.Tracker.State{...}

## online_list(state)

Returns a list of elements in the set belonging to an online replica.

## remove_down_replicas(state, replica)

Removes all elements for replicas that are permanently gone.

## replica_down(state, replica)

Marks a replica as down in the set and returns left users.

## replica_up(state, replica)

Marks a replica as up in the set and returns rejoined users.

## reset_delta(state)

Resets the set's delta.

## tracked_key(table, topic, key, down_replicas)

Performs table lookup for tracked key in the topic.

Filters out those present on downed replicas.

## tracked_values(table, topic, down_replicas)

Performs table lookup for tracked elements in the topic.

Filters out those present on downed replicas.