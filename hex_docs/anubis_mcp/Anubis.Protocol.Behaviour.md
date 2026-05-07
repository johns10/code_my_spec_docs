# Anubis.Protocol.Behaviour

Behaviour that each MCP protocol version module must implement.

Each protocol version (e.g., 2024-11-05, 2025-03-26, 2025-06-18) implements
this behaviour to isolate version-specific logic. This makes it trivial to add
support for new MCP spec versions without scattering conditionals across the codebase.

## Version differences

- **2024-11-05**: Initial spec, SSE transport, basic tools/resources/prompts
- **2025-03-26**: Added Streamable HTTP, JSON-RPC batching, authorization framework, tool annotations
- **2025-06-18**: Removed batching, added structured tool output, elicitation, resource_link type

## notification_methods/0

All notification methods supported by this version.

## notification_params_schema/1

Peri schema for validating notification params by method for this version.

## progress_params_schema/0

Progress notification params schema for this version.

## request_methods/0

All request methods supported by this version.

## request_params_schema/1

Peri schema for validating request params by method for this version.

## supported_features/0

List of features/capabilities this protocol version supports.

## version/0

Returns the version string this module implements (e.g., '2025-03-26').