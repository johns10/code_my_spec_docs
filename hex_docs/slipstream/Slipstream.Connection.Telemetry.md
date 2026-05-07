# Slipstream.Connection.Telemetry



## begin(state)

Emits the start event for a connection

## conclude(state, reason)

Emits the stop event for a connection

## span(initial_pipeline, func)

Wraps the connection pipeline in order to emit telemetry for each message
sent to the connection process