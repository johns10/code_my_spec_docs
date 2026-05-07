# Slipstream.ConnectionSupervisor

A supervisor for connection processes

Slipstream.ConnectionSupervisor is a simple module-based `DynamicSupervisor` which
is used to supervise connection processes. As such, you may track the number
of connection processes with `DynamicSupervisor.count_children/1`.
Slipstream.ConnectionSupervisor uses its module name as the DynamicSupervisor name,
so you may pass `Slipstream.ConnectionSupervisor` into any DynamicSupervisor function.

## Examples

    iex> Slipstream.ConnectionSupervisor |> DynamicSupervisor.count_children()
    %{active: 15, specs: 15, supervisors: 0, workers: 15}

## child_spec(arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.