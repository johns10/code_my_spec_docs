# ExCliVcr.PortProxy

Handles Port recording and replay.

During recording: Creates a real port and proxies messages, logging them.
During replay: Spawns a fake process that sends recorded messages.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## close(proxy)

Close the port proxy.

## command(proxy, data)

Forward a Port.command to the real port (during recording).

## get_messages(proxy)

Get the collected messages from a recording proxy.

## start_recording(open_args, opts, owner_pid)

Start a port proxy for recording.
Opens the real port and intercepts messages.

## start_replay(recording, owner_pid)

Start a port proxy for replay.
Sends recorded messages to the owner.