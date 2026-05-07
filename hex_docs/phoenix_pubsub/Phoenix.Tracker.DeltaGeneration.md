# Phoenix.Tracker.DeltaGeneration



## extract(state, generations, remote_ref, remote_context)

Extracts minimal delta from generations to satisfy remote clock.

Falls back to extracting entire crdt if unable to match delta.

## remove_down_replicas(generations, replica_ref)

Prunes permanently downed replicates from the delta generation list