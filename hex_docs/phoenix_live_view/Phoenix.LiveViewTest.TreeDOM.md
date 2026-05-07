# Phoenix.LiveViewTest.TreeDOM



## all_attributes(tree, name)

Returns all values of the attribute `name` from the node.

## all_values(tree)

Returns all values of the attributes from the node.

Handles phx-value-* attributes.

## attribute(node, key)

Returns the value of the attribute `key` from the node or nil if not found.

## attrs(tree)

Returns all attributes of the node.

## by_id!(tree, id)

Returns the node with the given `id`, raises an error if not found.

## child_nodes(tree)

Returns the child nodes of the node.

## filter(node, fun)

Filters nodes according to `fun`. Walks the tree in a post-walk manner, visiting children before parents.

## find_live_views(tree)

Find live views in the given HTML tree.

## inner_html!(tree, id)

Returns the children of the node with the given `id`, raises an error if not found.

## inspect_html(nodes)

Returns an HTML representation of the nodes for showing in error messages.

## normalize_to_tree(html, opts \\ [])

Normalizes the given HTML to a tree with optional sorting of attributes.

## reduce(tree, acc, fun)

Reduces the tree with the given function.

## remove_stream_children(html_tree)

Removes stream children from the given HTML tree.

## reverse_filter(tree, fun)

Filters nodes and returns them in reverse order.

## set_attr(el, name, val)

Sets the attribute `name` to the value `val` on the node.

## tag(arg1)

Returns the tag name of the node.

## to_html(text)

Returns the HTML representation of the node.

## to_text(tree, trim \\ true)

Returns the text representation of the node, removing extra whitespace.

## walk(tree, fun)

Walks the tree and updates nodes based on the given function.