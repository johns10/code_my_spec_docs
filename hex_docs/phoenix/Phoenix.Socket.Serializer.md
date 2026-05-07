# Phoenix.Socket.Serializer

A behaviour that serializes incoming and outgoing socket messages.

By default Phoenix provides a serializer that encodes to JSON and
decodes JSON messages.

Custom serializers may be configured in the socket.

## decode!/2

Decodes iodata into `Phoenix.Socket.Message` struct.

## encode!/1

Encodes `Phoenix.Socket.Message` and `Phoenix.Socket.Reply` structs to push format.

## fastlane!/1

Encodes a `Phoenix.Socket.Broadcast` struct to fastlane format.