# Anubis.Server.Frame

The Anubis Frame — pure user state + read-only context.

## User fields

  * `assigns` - shared user data as a map. For HTTP transports, this inherits
    from `Plug.Conn.assigns`.

## Component maps

Runtime-registered components are stored in typed maps keyed by name/URI:

  * `tools` - `%{name => %Tool{}}`
  * `resources` - `%{uri => %Resource{}}`
  * `prompts` - `%{name => %Prompt{}}`
  * `resource_templates` - `%{name => %Resource{uri_template: ...}}`

## Pagination

  * `pagination_limit` - optional limit for listing operations

## Context

  * `context` - read-only `%Context{}`, refreshed by Session before each callback

## assign(frame, assigns)

Assigns a value or multiple values to the frame.

## Examples

    frame = Frame.assign(frame, :status, :active)
    frame = Frame.assign(frame, %{status: :active, count: 5})
    frame = Frame.assign(frame, status: :active, count: 5)

## assign_new(frame, key, fun)

Assigns a value to the frame only if the key doesn't already exist.

The value is computed lazily using the provided function.

## Examples

    frame = Frame.assign_new(frame, :timestamp, fn -> DateTime.utc_now() end)

## clear_components(frame)

Clears all runtime-registered components

## from_saved(map)

Reconstructs Frame from a previously saved map.

Only `assigns` and `pagination_limit` are restored. Runtime-only fields (`tools`,
`resources`, `prompts`, `resource_templates`) are initialized empty — their validator
functions are not serializable. `context` is left as the default struct and will be
set by Session before each callback invocation.

## get_components(frame)

Retrieves all runtime-registered components as a flat list

## new(assigns \\ %{})

Creates a new frame with optional initial assigns.

## Examples

    iex> Frame.new()
    %Frame{assigns: %{}}

    iex> Frame.new(%{user: "alice"})
    %Frame{assigns: %{user: "alice"}}

## put_pagination_limit(frame, limit)

Sets the pagination limit for listing operations.

## Examples

    frame = Frame.put_pagination_limit(frame, 10)
    frame.pagination_limit
    # => 10

## register_prompt(frame, name, opts)

Registers a prompt definition at runtime.

## register_resource(frame, uri, opts)

Registers a resource definition with a fixed URI.

For parameterized resources, use `register_resource_template/3` instead.

## register_resource_template(frame, uri_template, opts)

Registers a resource template definition using a URI template (RFC 6570).

## Examples

    frame = Frame.register_resource_template(frame, "file:///{path}",
      name: "project_files",
      title: "Project Files",
      description: "Access files in the project directory"
    )

## register_tool(frame, name, opts)

Registers a tool definition at runtime.

## to_saved(frame)

Serializes Frame for persistent storage.

Only `assigns` and `pagination_limit` are persisted. The following fields are
**runtime-only** and excluded from serialization:

  * `tools` — runtime-registered tool definitions (includes validator functions)
  * `resources` — runtime-registered resource definitions
  * `prompts` — runtime-registered prompt definitions
  * `resource_templates` — runtime-registered resource template definitions
  * `context` — rebuilt by Session before each callback invocation

Compile-time components (registered via the `component` macro) are always
available from the server module and do not need persistence.