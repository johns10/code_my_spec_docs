# Anubis.Protocol.Registry

Registry for MCP protocol version modules.

Maps version strings to their implementing modules, supports version negotiation,
and provides the central dispatch point for version-specific protocol logic.

## Usage

    iex> Anubis.Protocol.Registry.get("2025-11-25")
    {:ok, Anubis.Protocol.V2025_11_25}

    iex> Anubis.Protocol.Registry.supported_versions()
    ["2025-11-25", "2025-06-18", "2025-03-26", "2024-11-05"]

    iex> Anubis.Protocol.Registry.negotiate("2025-03-26")
    {:ok, "2025-03-26", Anubis.Protocol.V2025_03_26}

## fallback_version()

Returns the fallback protocol version for compatibility.

## get(version)

Get the protocol module for a given version string.

## Examples

    iex> Anubis.Protocol.Registry.get("2025-06-18")
    {:ok, Anubis.Protocol.V2025_06_18}

    iex> Anubis.Protocol.Registry.get("unknown")
    :error

## get_features(version)

Returns the features supported by a given version.

Delegates to the version module's `supported_features/0` callback.

## latest_module()

Returns the module for the latest supported protocol version.

## latest_version()

Returns the latest supported protocol version string.

## negotiate(client_version)

Negotiate the best version given a client's requested version.

MCP spec: the server picks the version, the client proposes one.
If we support the requested version, use it. Otherwise, return an error
with the list of supported versions.

## Examples

    iex> Anubis.Protocol.Registry.negotiate("2025-11-25")
    {:ok, "2025-11-25", Anubis.Protocol.V2025_11_25}

    iex> Anubis.Protocol.Registry.negotiate("9999-01-01")
    {:error, :unsupported_version, ["2025-11-25", "2025-06-18", "2025-03-26", "2024-11-05"]}

## negotiate(client_version, server_versions)

Negotiate version between client and server supported version lists.

Used when the server has a restricted set of supported versions.
Returns the best matching version (client's preference if in server list,
otherwise server's latest).

## Examples

    iex> Anubis.Protocol.Registry.negotiate("2025-03-26", ["2025-11-25", "2025-03-26"])
    {:ok, "2025-03-26", Anubis.Protocol.V2025_03_26}

    iex> Anubis.Protocol.Registry.negotiate("2024-11-05", ["2025-11-25", "2025-03-26"])
    {:ok, "2025-11-25", Anubis.Protocol.V2025_11_25}

## progress_params_schema(version)

Returns the progress notification params schema for a given version.

Delegates to the version module's `progress_params_schema/0` callback.

## supported?(version)

Check if a version string is supported.

## supported_versions()

List all supported versions in preference order (newest first).

## supports_feature?(version, feature)

Checks if a feature is supported by a protocol version.