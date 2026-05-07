# Anubis.Protocol

MCP protocol version management.

Provides version validation, negotiation, feature detection, and transport
compatibility checking. Delegates version-specific logic to modules under
`Anubis.Protocol.*` via `Anubis.Protocol.Registry`.

## Adding a new protocol version

1. Create a new module under `lib/anubis/protocol/` implementing `Anubis.Protocol.Behaviour`
2. Register it in `Anubis.Protocol.Registry`

## compatible_transports(version, transport_modules)

Returns transport modules that support a protocol version.

## fallback_version()

Returns the fallback protocol version for compatibility.

## get_features(version)

Returns the set of features supported by a protocol version.

Delegates to the version module's `supported_features/0` callback.

## get_module(version)

Returns the protocol module for a given version string.

## Examples

    iex> Anubis.Protocol.get_module("2025-06-18")
    {:ok, Anubis.Protocol.V2025_06_18}

## latest_version()

Returns the latest supported protocol version.

## negotiate_version(client_version, server_version)

Negotiates protocol version between client and server versions.

Returns the best compatible version or an error if incompatible.

## supported_versions()

Returns all supported protocol versions.

## supports_feature?(version, feature)

Checks if a feature is supported by a protocol version.

## validate_client_config(version, transport_module, capabilities)

Validates client configuration for protocol compatibility.

This function checks if the client configuration is compatible with
the specified protocol version, including transport and capabilities.

## validate_transport(version, transport)

Validates if a transport is compatible with a protocol version.

## validate_version(version)

Validates if a protocol version is supported.