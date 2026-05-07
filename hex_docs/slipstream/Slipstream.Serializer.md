# Slipstream.Serializer

A behaviour that serializes incoming and outgoing socket messages.

## decode!/2

Decodes binary into `Slipstream.Message` struct.

## encode!/2

Encodes `Slipstream.Message` structs to binary.

Should return either a binary (string) when using a text based protocol
or `{:binary, binary}` for cases where a binary protocol is used over
the wire (such as MessagePack).