# Slipstream.TelemetryHelper



## begin_connect(socket, config)

Emits a start event for an attempt to connect

Emitted in cases of a client using `Slipstream.connect/2`,
`Slipstream.connect!/2` or `Slipstream.reconnect/1`.

## begin_join(socket, topic, params)

Emits a start event for an attempt to join

Emitted in cases of a client using `Slipstream.join/3` or
`Slipstream.rejoin/3`.

## conclude_connect(socket, event)

Emits a stop event for an attempt to connect

Emitted when the connection process tells the client that it has successfully
connected with a `Slipstream.Events.ChannelConnected` event.

## conclude_join(socket, event)

Emits a stop event for an attempt to join

Emitted when the connection process tells the client that it has successfully
connected with a `Slipstream.Events.TopicJoinSucceeded` event.

## wrap_dispatch(module, function, args, func)

Wraps a callback dispatch to a Slipstream client module