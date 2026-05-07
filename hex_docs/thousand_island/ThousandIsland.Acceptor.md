# ThousandIsland.Acceptor



## child_spec(arg)

Returns a specification to start this module under a supervisor.

`arg` is passed as the argument to `Task.start_link/1` in the `:start` field
of the spec.

For more information, see the `Supervisor` module,
the `Supervisor.child_spec/2` function and the `t:Supervisor.child_spec/0` type.