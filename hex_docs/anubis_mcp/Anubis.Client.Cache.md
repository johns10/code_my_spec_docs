# Anubis.Client.Cache



## cleanup(client)

Cleans up all cache tables for a client process.
Should be called when the client process terminates.

## clear_tool_validators(client)

Clears all tool validators from the cache.

## get_tool_validator(client, tool_name)

Gets a tool output validator from the cache.

## put_tool_validators(client, tools)

Stores tool output validators in the cache.
Clears existing validators before storing new ones.