# Phoenix.PubSub.Adapter

Specification to implement a custom PubSub adapter.

## broadcast/4

Broadcasts the given topic, message, and dispatcher to
all nodes in the cluster (except the current node itself).

## child_spec/1

Returns a child specification that mounts the processes
required for the adapter.

`child_spec` will receive all options given `Phoenix.PubSub`.
Note, however, that the `:name` under options is the name
of the complete PubSub system. The reserved key space to
be used by the adapter is under the `:adapter_name` key.

## direct_broadcast/5

Broadcasts the given topic, message, and dispatcher to
given node in the cluster (it may point to itself).

## node_name/1

Returns the node name as an atom or a binary.