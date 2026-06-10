# ExCliVcr.PortProxy

Handles Port recording and replay.

During recording: Creates a real port and proxies messages, logging them.
During replay: Spawns a fake process that sends recorded messages.

## start_recording/3

Start a port proxy for recording.
Opens the real port and intercepts messages.

## start_replay/2

Start a port proxy for replay.
Sends recorded messages to the owner.

## get_messages/1

Get the collected messages from a recording proxy.

## command/2

Forward a Port.command to the real port (during recording).

## close/1

Close the port proxy.