# Phoenix.Channel.Server



## broadcast(pubsub_server, topic, event, payload)

Broadcasts on the given pubsub server with the given
`topic`, `event` and `payload`.

The message is encoded as `Phoenix.Socket.Broadcast`.

## broadcast!(pubsub_server, topic, event, payload)

Broadcasts on the given pubsub server with the given
`topic`, `event` and `payload`.

Raises in case of crashes.

## broadcast_from(pubsub_server, from, topic, event, payload)

Broadcasts on the given pubsub server with the given
`from`, `topic`, `event` and `payload`.

The message is encoded as `Phoenix.Socket.Broadcast`.

## broadcast_from!(pubsub_server, from, topic, event, payload)

Broadcasts on the given pubsub server with the given
`from`, `topic`, `event` and `payload`.

Raises in case of crashes.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## close(pid, timeout)

Emulates the socket being closed.

Used by channel tests.

## dispatch(subscribers, from, msg)

Hook invoked by Phoenix.PubSub dispatch.

## join(socket, channel, message, opts)

Joins the channel in socket with authentication payload.

## local_broadcast(pubsub_server, topic, event, payload)

Broadcasts on the given pubsub server with the given
`topic`, `event` and `payload`.

The message is encoded as `Phoenix.Socket.Broadcast`.

## local_broadcast_from(pubsub_server, from, topic, event, payload)

Broadcasts on the given pubsub server with the given
`from`, `topic`, `event` and `payload`.

The message is encoded as `Phoenix.Socket.Broadcast`.

## push(pid, join_ref, topic, event, payload, serializer)

Pushes a message with the given topic, event and payload
to the given process.

Payloads are serialized before sending with the configured serializer.

## reply(pid, join_ref, ref, topic, arg, serializer)

Replies to a given ref to the transport process.

Payloads are serialized before sending with the configured serializer.

## socket(pid)

Gets the socket from the channel.

Used by channel tests.