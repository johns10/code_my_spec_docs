# Phoenix.LiveView.Diff



## component_to_rendered(socket, component, assigns, mount_assigns)

Converts a component to a rendered struct.

## delete_component(cid, arg)

Deletes a component by `cid` if it has not been used meanwhile.

## get_push_events_diff(socket)

Returns a diff containing only the events that have been pushed.

## mark_for_deletion_component(cid, arg)

Marks a component for deletion.

It won't be deleted if the component is used meanwhile.

## new_components(uuids \\ 1)

Returns the diff component state.

## new_fingerprints()

Returns the diff fingerprint state.

## read_component(socket, cid, components, fun)

Execute the `fun` with the component `cid` with the given `socket` and returns the result.

`:error` if the component cid does not exist.

## render(socket, rendered, prints, components)

Renders a diff for the rendered struct in regards to the given socket.

## render_private(socket, diff)

Render information stored in private changed.

## to_iodata(map, component_mapper \\ fn _cid, content -> content end)

Converts a diff into iodata.

It only accepts a full render diff.

## update_component(socket, components, arg)

Sends an update to a component.

Like `write_component/5`, it will store the result under the `cid
 key in the `component_diffs` map.

If the component exists, a `{diff, new_components}` tuple
is returned. Otherwise, `:noop` is returned.

The component is preloaded before the update callback is invoked.

## Example

    {diff, new_components} = Diff.update_component(socket, state.components, update)

## write_component(socket, cid, components, fun)

Execute the `fun` with the component `cid` with the given `socket` as template.

It returns the updated `cdiffs` and the updated `components` or
`:error` if the component cid does not exist.