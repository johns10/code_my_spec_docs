# Anubis.Transport.Behaviour

Defines the behavior that all transport implementations must follow.

## supported_protocol_versions/0

Returns the list of MCP protocol versions supported by this transport.

## Examples

    iex> MyTransport.supported_protocol_versions()
    ["2024-11-05", "2025-03-26"]

## message/0

The JSON-RPC message encoded