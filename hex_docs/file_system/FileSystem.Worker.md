# FileSystem.Worker

FileSystem Worker Process with the backend GenServer, receive events from Port Process
and forward it to subscribers.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.